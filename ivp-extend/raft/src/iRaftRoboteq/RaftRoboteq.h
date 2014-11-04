/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftRoboteq_HEADER
#define RaftRoboteq_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>

#include <boost/asio.hpp>

#include <iostream>
#include <string.h>

class RaftRoboteq: public CMOOSApp {
public:
    RaftRoboteq();
    ~RaftRoboteq();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();

private:
    boost::asio::io_service io_service;
    boost::asio::ip::tcp::socket sock;

//    boost::thread io_thread;
//    boost::asio::deadline_timer timeout;


    int m_tcp_sockfd;
    std::vector<char> tcpReadBuffer;
    std::string string_buffer;
};

#endif 
