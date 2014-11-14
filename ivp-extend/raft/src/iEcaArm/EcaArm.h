/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: EcaArm.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef EcaArm_HEADER
#define EcaArm_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <boost/asio.hpp>
#include <boost/thread.hpp>

#include <iostream>

enum DemandType {
    stop = 0,
    voltage_cw,
    voltage_ccw,
    speed_cw,
    speed_ccw,
    position
};

struct DemandMessage {
    unsigned char start_byte;
    unsigned char demand_type;
    unsigned short demand;
    unsigned short speed_limit;
    unsigned short current_limit;
    unsigned char stop_byte;
};

struct DemandPackage {
    unsigned char start_byte;
    unsigned char master_data[3];

    DemandMessage motor_demands[5];

    unsigned char checksum;
    unsigned char stop_byte;
};

struct SensorMessage {
    unsigned char start_byte;
    unsigned short position;
    unsigned short speed;
    unsigned short current;
    unsigned char temperature;
    unsigned char stop_byte;
};

struct SensorPackage {
    unsigned char start_byte;
    unsigned char master_temperature;
    unsigned char master_voltage;
    unsigned char master_current;

    SensorMessage motor_data[5];

    unsigned char checksum;
    unsigned char stop_byte;
};

class EcaArm: public CMOOSApp {
public:
    EcaArm();
    ~EcaArm();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();

private:
    boost::asio::io_service io_service;
    boost::asio::serial_port sock;
//    boost::asio::ip::tcp::socket sock;
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

    double command_left, command_right;
    bool new_command_left, new_command_right;


    DemandType demand_types[5];
    double voltage_demands[5], speed_demands[5], last_update_time[5];
};

#endif 
