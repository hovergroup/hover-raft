/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftRoboteq_HEADER
#define RaftRoboteq_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <boost/asio.hpp>
#include <boost/thread.hpp>

#include <iostream>

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
    boost::asio::streambuf input_buffer;
    boost::asio::deadline_timer deadline_timer;

    boost::thread io_thread;

    void io_loop();

    void start_read();
    void handle_read(const boost::system::error_code& ec);
    void start_write();
    void handle_write(const boost::system::error_code& ec);

//    boost::thread io_thread;
//    boost::asio::deadline_timer timeout;


    int m_tcp_sockfd;
    std::vector<char> tcpReadBuffer;
    std::string string_buffer;
};

#endif 
