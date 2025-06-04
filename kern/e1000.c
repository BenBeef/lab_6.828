#include <kern/e1000.h>
#include <kern/pmap.h>
#include <kern/e1000_hw.h>
#include <inc/string.h>

// LAB 6: Your driver code here
volatile uint32_t e1000_reg_base0;

// transmit ring struct
struct tx_queue_conf tq_conf = {};
struct tx_queue_conf *tq_reg = &tq_conf;

// receive ring struct
struct rex_queue_conf rq_conf = {};
struct rex_queue_conf *rq_reg = &rq_conf;

struct mac_addr maddr = {
        0x52,
        0x54,
        0x00,
        0x12,
        0x34,
        0x56,
        0x00,
        0x80, // Receive descriptor valid
};


void
init_tx_desc(struct tx_desc *td, uint32_t addr, uint16_t length)
{
    td->addr_l = addr;
    td->length = length;

    // cmd RS bit
    td->cmd = (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP) >> 24;

    // init all status.DD bit to 1 (which mean free)
    td->status |= E1000_TXD_STAT_DD;
}

// Transmit Initialization
// like <8254x Family of Gigabit Ethernet Controllers Software Developer’s Manual> section 14.5
void
transmit_init_14_5()
{
    int i, len, v;

    // transmit queue 16-byte aligned
    assert((uint32_t)tx_queue % 16 == 0);

    // fill tx_queue
    cprintf("[e1000.c] ----- tx_blocks:%x, e1000_reg_base0:%x \n", tx_blocks, e1000_reg_base0);
    for (i = 0; i < MAX_TX; i++) {
        init_tx_desc(&tx_queue[i], PADDR(tx_blocks + i), TX_BLOCK_LEN);
    }

    // init Transmit Descriptor Ring Structure
    len = MAX_TX * sizeof(struct tx_desc);
    assert(len == ROUNDDOWN(len, 128)); // len must be 128 aligned
    tq_reg->tq_base_addr_l = PADDR(tx_queue);
    tq_reg->tq_len = len;
    tq_reg->tq_head = 0;
    tq_reg->tq_tail = 0;

    *(struct tx_queue_conf *)(e1000_reg_base0 + E1000_TDBAL) = *tq_reg;


    // init the Transmit Control Register (TCTL)
    v = E1000_TCTL_EN | E1000_TCTL_PSP | 0x10 << 4 | 0x40 << 12;
    *(uint32_t *)(e1000_reg_base0  + E1000_TCTL) = v;

    // TIPG
    v = 10 | (4 << 10) | (6 << 20);
    *(uint32_t *)(e1000_reg_base0  + E1000_TIPG) = v;
}

void
show_dd_bits()
{
    char res[MAX_TX + 1];
    int num=0;
    for (int i=0; i < MAX_TX; i ++ ) {
        res[i] = tx_queue[i].status & E1000_TXD_STAT_DD ? '1' : '0';
        num += tx_queue[i].status & E1000_TXD_STAT_DD ? 1 : 0;
    }

    res[MAX_TX] = '\0';
    cprintf("[e1000.c] ---- bits %s, total_1:%d \n", (char *)res, num);
}

// transmit a packet by
// a) check full
// b) copy packet data into next descriptor
// c) update tdt
int
transmit_a_packet(void *data_ptr, uint16_t length)
{
    static int cnt = 0;
//    cprintf("[transmit_a_packet] ------------ tx_queue if full cnt:%x \n", cnt++);
    if (length > TX_BLOCK_LEN || length < 0)
        return -E_INVAL;
    if (data_ptr == NULL)
        return -E_INVAL;

//    show_dd_bits();

    if (!(tx_queue[tq_reg->tq_tail].status & E1000_TXD_STAT_DD)) {
        // check full
        return -E_TX_FULL;
    }

    // copy data to tx_desc block
    memcpy(KADDR(tx_queue[tq_reg->tq_tail].addr_l), data_ptr, length);
    // update length
    tx_queue[tq_reg->tq_tail].length = length;
    // set cmd.RS bit
    tx_queue[tq_reg->tq_tail].cmd = (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP) >> 24;
    // clean DD bit
    tx_queue[tq_reg->tq_tail].status &= ~E1000_TXD_STAT_DD;
//    cprintf("[transmit_a_packet] ------------  cnt:%x \n", cnt++);
    // next tdt
    tq_reg->tq_tail = (tq_reg->tq_tail + 1) % MAX_TX;
    // update tdt.register
    *(uint32_t *)(e1000_reg_base0 + E1000_TDT) = tq_reg->tq_tail;

    return 0;
}


void
init_rex_desc(struct rex_desc *rd, uint32_t addr, uint16_t length)
{
    rd->addr_l = addr;
    rd->length = length;
    rd->status = 0;
}

// receive Initialization
// like <8254x Family of Gigabit Ethernet Controllers Software Developer’s Manual> section 14.4
void
receive_init_14_4()
{
    int i, len, v;
    struct mta mat_arr = {};

    // receive queue 16-byte aligned
    assert((uint32_t)rex_queue % 16 == 0);

    // fill rex_queue
    for (i = 0; i < MAX_REC_X; i++) {
        init_rex_desc(&rex_queue[i], PADDR(rex_blocks + i), TX_BLOCK_LEN);
    }

    // init Transmit Descriptor Ring Structure
    len = MAX_REC_X * sizeof(struct rex_desc);
    assert(len == ROUNDDOWN(len, 128)); // len must be 128 aligned
    rq_reg->rq_base_addr_l = PADDR(rex_queue);
    rq_reg->rq_len = len;
    rq_reg->rq_head = 1;
    rq_reg->rq_tail = 0;

    *(struct rex_queue_conf *)(e1000_reg_base0 + E1000_RDBAL) = *rq_reg;

    // init the MTA (Multicast Table Array) to 0b
    *(struct mta *)(e1000_reg_base0 + E1000_MTA) = mat_arr;

    // init Receive Address
    *(struct mac_addr *)(e1000_reg_base0  + E1000_RA) = maddr;

    // init the Receive Control Register (RCTL)
    v = E1000_RCTL_EN | E1000_RCTL_SECRC ;
    *(uint32_t *)(e1000_reg_base0  + E1000_RCTL) = v;
}


void
show_rec_dd_bits(uint32_t loc_tail)
{
    char res[MAX_REC_X + 1];
    int num=0;
    for (int i=0; i < MAX_REC_X; i ++ ) {
        res[i] = rex_queue[i].status & E1000_RXD_STAT_DD ? '1' : '0';
        num += rex_queue[i].status & E1000_RXD_STAT_DD ? 1 : 0;
    }

    res[MAX_REC_X] = '\0';
    uint32_t head, tail;
    head = *(uint32_t * )(e1000_reg_base0 + E1000_RDH);
    tail = *(uint32_t * )(e1000_reg_base0 + E1000_RDT);
    cprintf("[e1000.c] ---- head: %x, tail/loc_tail: %x/%x, dd.bits %s, total_1:%d \n", head, tail, loc_tail, (char *)res, num);
}

// receive a packet by
// a) receive packet
// b) handle empty
// return < 0 if error else length of the packet
int
receive_a_packet(void *dstva, uint32_t *len)
{
    if (dstva == NULL)
        return -E_INVAL;

    int cnt = 0, max_cnt = 64;
    uint32_t rdt =  rq_reg->rq_tail;

    // rdt not prepared data
    while (!(rex_queue[rdt].status & E1000_RXD_STAT_DD)) {
        if(cnt > max_cnt)
            return -E_RX_NO_PKT;
        asm volatile ("pause");
        cnt ++;
        rdt ++;
    }
    // copy data to dstva
    memmove(dstva, KADDR(rex_queue[rdt].addr_l), rex_queue[rdt].length);
    *len = rex_queue[rdt].length;

    // clean status, update length
    rex_queue[rdt].status = 0;
    rex_queue[rdt].length = TX_BLOCK_LEN;

    // next rdt
    if (!(rex_queue[rdt + 1].status & E1000_RXD_STAT_DD))
        return 0;
    rq_reg->rq_tail = (rdt + 1) % MAX_REC_X;

    // update rdt.register
    *(uint32_t *)(e1000_reg_base0 + E1000_RDT) = rq_reg->rq_tail;

    return 0;
}


// test transmit packet directly
void transmit_test() {

    int r;
    char *block;
    block = "Hello e1000.";
    for (int i=0; i < 5; i++) {
        if ((r=transmit_a_packet(block, strlen(block))) < 0)
            cprintf("[e1000.c] ----- transmit error:%e \n", r);
    }
}

int
pci_e1000_attach(struct pci_func *pcif)
{
    pci_func_enable(pcif);
    e1000_reg_base0 = (uint32_t) mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);
    cprintf("[e1000.c] ----- device status:0x%x  \n", *((uint32_t *)e1000_reg_base0 + 2));
    transmit_init_14_5();
    receive_init_14_4();
    return 1;
}
