#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
    struct jif_pkt *pkt;
    uint32_t req, whom;
    int perm, r;

    while (1) {
        perm = 0;
        req = ipc_recv((int32_t *) &whom, &nsipcbuf, &perm);
        if (req != NSREQ_OUTPUT) {
            cprintf("Invalid request type %08x from %08x: no argument page\n", req, whom);
            continue;
        }
        //	- send the packet to the device driver
        pkt = &nsipcbuf.pkt;
        while ((r = sys_transmit_packet(pkt->jp_data, pkt->jp_len)) != 0) {
            if (r != -E_TX_FULL) {
                panic("ipc_send error %e", r);
            } else {
                cprintf("[output.c] ----- tx queue is full \n");
            }
        }
    }
}
