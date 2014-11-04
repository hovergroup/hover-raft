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
    void handle_read(const boost::system::error_code& ec, std::size_t bt);
    void start_write();
    void handle_write(const boost::system::error_code& ec);
    void handle_command_write(const boost::system::error_code& ec);
    void handle_basic_write(const boost::system::error_code& ec);
    
    std::istream& safeGetline(std::istream& is, std::string& t);

    void parseLine(std::string line);
    void setThrust(int channel, double thrust);
    void setArmPower(bool power);

    std::vector<std::string> slow_queries;
    int slow_query_index;
    int power_report_count, power_command_count, ack_count, nack_count;
    double last_report_time;
};

#endif 
