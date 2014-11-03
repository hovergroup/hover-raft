/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftRoboteq_HEADER
#define RaftRoboteq_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <boost/asio/deadline_timer.hpp>
#include <boost/asio/io_service.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/asio/read_until.hpp>
#include <boost/asio/streambuf.hpp>
#include <boost/asio/write.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>

#include <iostream>

using boost::asio::ip::tcp;
using boost::asio::deadline_timer;

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
    boost::asio::io_service io_service_;
    bool stopped_;
    tcp::socket socket_;
    boost::asio::streambuf input_buffer_;
    deadline_timer deadline_;

    boost::thread worker_thread;

    void handle_read(const boost::system::error_code& ec);
    void start_read();
    void stop();
    void run();

private:
    // State variables
    unsigned int m_iterations;
    double m_timewarp;
};

#endif 
