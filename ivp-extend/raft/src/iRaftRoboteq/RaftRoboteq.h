/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftRoboteq_HEADER
#define RaftRoboteq_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <boost/asio/io_service.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/asio/streambuf.hpp>

#include <iostream>

using boost::asio::ip::tcp;

class RaftRoboteq: public CMOOSApp {
public:
    RaftRoboteq(boost::asio::io_service& io_service);
    ~RaftRoboteq();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();
    void RegisterVariables();

private:
    tcp::socket socket_;
    boost::asio::streambuf input_buffer_;

private:
    // State variables
    unsigned int m_iterations;
    double m_timewarp;
};

#endif 
