/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "RaftRoboteq.h"

using namespace std;

//---------------------------------------------------------
// Constructor

RaftRoboteq::RaftRoboteq() {
    tcpReadBuffer = vector<char>(1000, 0);
}

//---------------------------------------------------------
// Destructor

RaftRoboteq::~RaftRoboteq() {
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool RaftRoboteq::OnNewMail(MOOSMSG_LIST &NewMail) {
    MOOSMSG_LIST::iterator p;

    for (p = NewMail.begin(); p != NewMail.end(); p++) {
        CMOOSMsg &msg = *p;
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RaftRoboteq::OnConnectToServer() {

    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftRoboteq::Iterate() {
    ssize_t n = recv(m_tcp_sockfd, (void*)&tcpReadBuffer[0], 1000, 0);
    //int n = read(m_tcp_sockfd, &tcpReadBuffer[0], 1000);
    //if (n < 0) {
    //    std::cout << "error reading from socket" << std::endl;
    //    return false;
    //}
    if (n > 0) {
        string_buffer += std::string(tcpReadBuffer.begin(),
                tcpReadBuffer.begin() += n);

        cout << string_buffer;
        string_buffer = "";
    }
    cout << endl;

    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RaftRoboteq::OnStartUp() {
    string address = "192.168.1.51";
    unsigned int port = 5001;
    m_MissionReader.GetConfigurationParam("address", address);
    m_MissionReader.GetConfigurationParam("port", port);

    struct sockaddr_in m_server_address;
    struct hostent *m_server;

    m_tcp_sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (m_tcp_sockfd < 0) {
        std::cout << "Error opening socket" << std::endl;
        return false;
    }

    m_server = gethostbyname(address.c_str());
    if (m_server == NULL) {
        std::cout << "Error, no such host " << address << std::endl;
        return false;
    }

    bzero((char *) &m_server_address, sizeof(m_server_address));
    m_server_address.sin_family = AF_INET;
    bcopy((char *) m_server->h_addr,
            (char *)&m_server_address.sin_addr.s_addr,
            m_server->h_length);
    m_server_address.sin_port = htons(port);
    if (connect(m_tcp_sockfd, (struct sockaddr *) &m_server_address,
            sizeof(m_server_address)) < 0) {
        int errsv = errno;
        std::cout << "error connecting" << std::endl;
        cout << errsv << endl;
        return false;
    }

    return (true);
}
