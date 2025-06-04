#include "ns.h"

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
    int r;
    int tick;
    int cnt=0;
    void *va;

    while (1) {
        tick = sys_time_msec();
        if (tick % 3 != 0) {
            sys_yield();
            continue;
        }
        if ((r = sys_receive_packet(nsipcbuf.pkt.jp_data, &nsipcbuf.pkt.jp_len)) < 0) {
            if (r != -E_RX_NO_PKT) {
                panic("sys_receive_packet error:%e", r);
            }
            continue;
        }
        va = malloc(PGSIZE);
        cprintf("[input.c] ------ 2 cnt:%d \n", cnt++);
        memmove(va, &nsipcbuf, PGSIZE);
        ipc_send(ns_envid, NSREQ_INPUT, va, PTE_P | PTE_U | PTE_W);
        free(va);
        cprintf("[input.c] ------ 3 cnt:%d \n", cnt);
    }
}
