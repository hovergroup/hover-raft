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
#include "boost/assign.hpp"

#include <iostream>

#pragma pack(1)

enum DemandType {
    demand_stop = 0,
    demand_voltage_cw,
    demand_voltage_ccw,
    demand_speed_cw,
    demand_speed_ccw,
    demand_position
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
    //unsigned char bytes[8];
    // this next bit is completely different from the documentation
    unsigned char dummy;
    unsigned char temperature;
    unsigned short current;
    //unsigned char stop_byte;
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

static const std::map<int,std::string> MotorMap = boost::assign::map_list_of
        (0,"SHOULDER")
        (1,"YAW")
        (2,"ELBOW")
        (3,"WRIST")
        (4,"GRIP");

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
    boost::asio::deadline_timer deadline_timer;

    unsigned char input_buffer[51];

    void handle_read(bool data_available, boost::asio::deadline_timer& timeout,
            const boost::system::error_code& error, std::size_t bytes_transferred);
    void handle_wait(boost::asio::serial_port& ser_port, const boost::system::error_code& error);

    static const int yaw_index = 1;
    static const int shoulder_index = 0;
    static const int elbow_index = 2;
    static const int wrist_index = 3;
    static const int grip_index = 4;

    static const int max_voltage = 65535;
   int max_speed;

    DemandType demand_types[5];
    unsigned short demands[5];
    double last_update_time[5];

    int mapVoltage(double voltage);
    int mapRPM(double voltage);
    void handleDemand(double command, bool is_voltage, int index);
    
    unsigned short bswap16(unsigned short val) { return (val<<8)|(val>>8); }
    void bswapDemandPackage(DemandPackage & package);
    void bswapSensorPackage(SensorPackage & package);

    unsigned char doChecksum(unsigned char* c, int length);
    
    double last_report_time;
    int report_count;
};

#endif 
