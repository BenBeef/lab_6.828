#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H
#endif  // SOL >= 6

#include <kern/pci.h>
#include <inc/error.h>

#define PCI_82540EM_VENDOR_ID 0x8086
#define PCI_82540EM_DEV_ID 0x100E
#define MAX_TX 64
#define TX_BLOCK_LEN 2000
#define MAX_REC_X 256
#define MAC_ADDR_LEN 6U

int pci_e1000_attach(struct pci_func *pcif);
int transmit_a_packet(void *data_ptr, uint16_t length);
int receive_a_packet(void *data_ptr, uint32_t *len);

struct mac_addr
{
    uint8_t a0;
    uint8_t a1;
    uint8_t a2;
    uint8_t a3;
    uint8_t a4;
    uint8_t a5;
    uint8_t a6;
    uint8_t a7;
};

struct tx_desc
{
    uint32_t addr_l;
    uint32_t addr_h;
    uint16_t length;
    uint8_t cso;
    uint8_t cmd;
    uint8_t status;
    uint8_t css;
    uint16_t special;
};


// Transmit queue
struct tx_desc tx_queue[MAX_TX];
char tx_blocks[MAX_TX][TX_BLOCK_LEN];


// Transmit Descriptor Ring Structure configuration
struct tx_queue_conf
{
    uint32_t tq_base_addr_l;
    uint32_t tq_base_addr_h;
    uint32_t tq_len;  //
    uint32_t tq_len_pad;
    uint32_t tq_head;
    uint32_t tq_head_pad;
    uint32_t tq_tail;
    uint32_t tq_tail_pad;
};

struct rex_desc
{
    uint32_t addr_l;
    uint32_t addr_h;
    uint16_t length;
    uint16_t checksum;
    uint8_t status;
    uint8_t errors;
    uint16_t special;
};

// Receive Descriptor Ring Structure configuration
struct rex_queue_conf
{
    uint32_t rq_base_addr_l;
    uint32_t rq_base_addr_h;
    uint32_t rq_len;  //
    uint32_t rq_len_pad;
    uint32_t rq_head;
    uint32_t rq_head_pad;
    uint32_t rq_tail;
    uint32_t rq_tail_pad;
};

// Transmit queue
struct rex_desc rex_queue[MAX_REC_X];
char rex_blocks[MAX_REC_X][TX_BLOCK_LEN];

struct mta
{
    uint32_t val[127];
};