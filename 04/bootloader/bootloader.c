// Initialize pci ethernet controller
// Do we want ARP? Server gets to know the client MAC address through this
// Connect via UDP
// Implemenent TFTP protocol
// Download file
//

#include <stdint.h>
#include <stdbool.h>
#include <net/eth.h>

#define MAX_PAYLOAD_SIZE 400

struct eth_frame {
	uint8_t preamble[7];
	uint8_t sfd;
	uint8_t dest_mac[6];
	uint8_t src_mac[6];
	uint8_t eth_type[2];
	uint8_t payload[MAX_PAYLOAD_SIZE];
	uint8_t fcs[4];
};

/* https://datatracker.ietf.org/doc/html/rfc768 */
struct udp_header {
	/**
	 * Source Port is an optional field, when meaningful, it indicates the port
	 * of the sending  process,  and may be assumed  to be the port  to which a
	 * reply should  be addressed  in the absence of any other information.  If
	 * not used, a value of zero is inserted.
	 */
	uint16_t source_port;
	/** 
	 * Destination  Port has a meaning  within  the  context  of  a  particular
	 * internet destination address.
	 */
	uint16_t destination_port;
	/** 
	 * Length  is the length  in octets  of this user datagram  including  this
	 * header  and the data.   (This  means  the minimum value of the length is
	 * eight.)
	 */
	uint16_t length;
	/**
	 * Checksum is the 16-bit one's complement of the one's complement sum of a
	 * pseudo header of information from the IP header, the UDP header, and the
	 * data,  padded  with zero octets  at the end (if  necessary)  to  make  a
	 * multiple of two octets.
	 * If the computed  checksum  is zero,  it is transmitted
	 * as all ones (the equivalent  in one's complement  arithmetic).   An all zero
	 * transmitted checksum  value means that the transmitter  generated  no checksum
	 * (for debugging or for higher level protocols that don't care).
	 */
	uint16_t checksum;
};


struct udp_datagram {
	struct udp_header header;
	uint8_t data[];
};

void init();
bool bind(uint16_t socket);
void receive(struct eth_frame frame);


int main() {
	init();
	return 0;
}

void init() {


}
