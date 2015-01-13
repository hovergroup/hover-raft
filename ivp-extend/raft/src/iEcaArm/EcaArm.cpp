/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: EcaArm.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "EcaArm.h"

using namespace std;

//using boost::asio::ip::tcp;
using namespace boost::asio;

//---------------------------------------------------------
// Constructor

EcaArm::EcaArm() :
                sock(io_service),
                deadline_timer(io_service) {
    last_report_time = -1;
    report_count = 0;
}

//---------------------------------------------------------
// Destructor

EcaArm::~EcaArm() {
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool EcaArm::OnNewMail(MOOSMSG_LIST &NewMail) {
    MOOSMSG_LIST::iterator p;

    for (p = NewMail.begin(); p != NewMail.end(); p++) {
        CMOOSMsg &msg = *p;
        // only process new messages
        if (MOOSTime() - msg.GetTime() < 5) {
            string key = msg.GetKey();
            if (key == "ECA_YAW_VOLTAGE_CMD") {
                last_update_time[yaw_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), true, yaw_index);
            } else if (key == "ECA_SHOULDER_VOLTAGE_CMD") {
                last_update_time[shoulder_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), true, shoulder_index);
            } else if (key == "ECA_ELBOW_VOLTAGE_CMD") {
                last_update_time[elbow_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), true, elbow_index);
            } else if (key == "ECA_WRIST_VOLTAGE_CMD") {
                last_update_time[wrist_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), true, wrist_index);
            } else if (key == "ECA_GRIP_VOLTAGE_CMD") {
                last_update_time[grip_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), true, grip_index);
            } else if (key == "ECA_YAW_SPEED_CMD") {
                last_update_time[yaw_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), false, yaw_index);
            } else if (key == "ECA_SHOULDER_SPEED_CMD") {
                last_update_time[shoulder_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), false, shoulder_index);
            } else if (key == "ECA_ELBOW_SPEED_CMD") {
                last_update_time[elbow_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), false, elbow_index);
            } else if (key == "ECA_WRIST_SPEED_CMD") {
                last_update_time[wrist_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), false, wrist_index);
            } else if (key == "ECA_GRIP_SPEED_CMD") {
                last_update_time[grip_index] = msg.GetTime();
                handleDemand(msg.GetDouble(), false, grip_index);
            } else if (key == "ECA_ENABLE") {
                if (msg.GetDouble() == 1) {
                } else {
                }
            }
        }
    }

    return (true);
}

void EcaArm::handleDemand(double command, bool is_voltage, int index) {
    if (command > 100) command = 100;
    if (command < -100) command = -100;
    if (is_voltage) {
        demands[index] = fabs(command) * max_voltage/100.0;
    } else {
        demands[index] = fabs(command) * /*max_speed*/12000/100.0;
    }
    DemandType this_demand;
    if (command < 0) {
        if (is_voltage) this_demand = demand_voltage_cw;
        else this_demand = demand_speed_cw;
    } else if (command > 0) {
        if (is_voltage) this_demand = demand_voltage_ccw;
        else this_demand = demand_speed_ccw;
    } else {
        this_demand = demand_stop;
    }
    demand_types[index] = this_demand;
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool EcaArm::OnConnectToServer() {
    m_Comms.Register("ECA_YAW_VOLTAGE_CMD", 0);
    m_Comms.Register("ECA_SHOULDER_VOLTAGE_CMD", 0);
    m_Comms.Register("ECA_ELBOW_VOLTAGE_CMD", 0);
    m_Comms.Register("ECA_WRIST_VOLTAGE_CMD", 0);
    m_Comms.Register("ECA_GRIP_VOLTAGE_CMD", 0);

    m_Comms.Register("ECA_YAW_SPEED_CMD", 0);
    m_Comms.Register("ECA_SHOULDER_SPEED_CMD", 0);
    m_Comms.Register("ECA_ELBOW_SPEED_CMD", 0);
    m_Comms.Register("ECA_WRIST_SPEED_CMD", 0);
    m_Comms.Register("ECA_GRIP_SPEED_CMD", 0);

    m_Comms.Register("ECA_ENABLE", 0);

    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool EcaArm::Iterate() {
    for (int i=0; i<5; i++) {
        if (MOOSTime() - last_update_time[i] > 0.5) {
            demand_types[i] = demand_stop;
        }
    }

    DemandPackage package;
    package.start_byte = 0xE7;
    package.master_data[0] = 0;
    package.master_data[1] = 0;
    package.master_data[2] = 0;

    DemandMessage message;
    for (int i=0; i<5; i++) {
        message.start_byte = 0x00;
        message.demand_type = demand_types[i];
        message.demand = demands[i];
        message.speed_limit = 4095;
        message.current_limit = 4095;
        message.stop_byte = 0x00;
        package.motor_demands[i] = message;
    }

    package.checksum = doChecksum(&package.start_byte, 49);
    package.stop_byte = 0xE5;
    
    bswapDemandPackage(package);
    
    boost::asio::const_buffer buf = boost::asio::buffer(&package, sizeof(package));
    const int * p1 = boost::asio::buffer_cast<const int*>(buf);
    
    /*std::vector<unsigned char> data (sizeof(package), 0);
    memcpy(&data[0], &package.start_byte, sizeof(package));
    
    for (int i=0; i<sizeof(package); i++) {
        //cout << hex << *p1;
        //++p1;
        cout << hex << (int) data[i] << " ";
    }
    cout << dec << endl; */
    
    //cout << "Writing " << sizeof(package) << " bytes" << endl;
    boost::asio::write(sock, boost::asio::buffer(&package, sizeof(package)));

    //cout << "Reading" << endl;
    boost::asio::async_read(sock, boost::asio::buffer(input_buffer, 51),
            boost::bind( &EcaArm::handle_read, this, _1,
                    boost::ref(deadline_timer),
                    boost::asio::placeholders::error,
                    boost::asio::placeholders::bytes_transferred));
//    sock.async_read_some(boost::asio::buffer(input_buffer, 51),
//            boost::bind( &EcaArm::handle_read, this, _1,
//                    boost::ref(deadline_timer),
//                    boost::asio::placeholders::error,
//                    boost::asio::placeholders::bytes_transferred ) );
    deadline_timer.expires_from_now(boost::posix_time::milliseconds(250));
    deadline_timer.async_wait(boost::bind(&EcaArm::handle_wait, this,
            boost::ref(sock), boost::asio::placeholders::error));
    io_service.reset();
    io_service.run();
    //cout << "iterate complete" << endl << endl;

    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool EcaArm::OnStartUp() {
//    string address = "192.168.1.51";
//    string port = "5001";
    string port = "/dev/ttyUSB0";
//    m_MissionReader.GetConfigurationParam("address", address);
    //m_MissionReader.GetConfigurationParam("port", port);

//    tcp::resolver resolver(io_service);
//    tcp::resolver::query query(tcp::v4(), address, port);
//    tcp::resolver::iterator iterator = resolver.resolve(query);
//
//    sock.connect(*iterator);
//
    cout << "Opening " << port << endl;
    sock.open(port);
    sock.set_option(serial_port_base::baud_rate(115200));
    sock.set_option(
            serial_port_base::flow_control(
                    serial_port_base::flow_control::none));
    sock.set_option(serial_port_base::parity(serial_port_base::parity::none));
    sock.set_option(
            serial_port_base::stop_bits(serial_port_base::stop_bits::one));
    sock.set_option(serial_port_base::character_size(8));

    return (true);
}

unsigned char EcaArm::doChecksum(unsigned char* c, int length) {
    unsigned int sum = 0;
    for (int i=0; i<length; i++) {
        sum += *c;
        c++;
    }
    return (unsigned char) sum;
}

void EcaArm::handle_read(bool data_available, boost::asio::deadline_timer& timeout,
        const boost::system::error_code& error, std::size_t bytes_transferred) {
    if (error || !bytes_transferred) {
        cout << "No data was read" << endl;
        // no data read
        return;
    }

    //cout << "Read " << bytes_transferred << endl;
    if (bytes_transferred == 51) {
        SensorPackage package;
        memcpy(&package.start_byte, &input_buffer[0], 51);
        //bswapSensorPackage(package);
        m_Comms.Notify("ECA_VOLTAGE",111500.0*3.3*package.master_voltage/255.0/6800.0);
        m_Comms.Notify("ECA_CURRENT",(((package.master_current/511.0*3.3)/(39.0/59.0))/0.625)*6.0-0.2);
        for (int i=0; i<5; i++) {
            string prefix = MotorMap.find(i)->second;
            m_Comms.Notify("ECA_" + prefix + "_SPEED", package.motor_data[i].speed);
            m_Comms.Notify("ECA_" + prefix + "_POSITION", package.motor_data[i].position);
        }
        report_count++;
        if (MOOSTime() - last_report_time > 5) {
            m_Comms.Notify("ECA_UPDATE_RATE", report_count/(MOOSTime()-last_report_time));
            last_report_time = MOOSTime();
            report_count = 0;
        }
    }

    deadline_timer.cancel();
}

void EcaArm::handle_wait(boost::asio::serial_port& ser_port, const boost::system::error_code& error)
{
    if (error) {
        // data read, timeout cancelled
        return;
    }
    sock.cancel(); // read_callback fires with error
}

void EcaArm::bswapDemandPackage(DemandPackage & package) {
    for (int i=0; i<5; i++) {
        package.motor_demands[i].demand = bswap16(package.motor_demands[i].demand);
        package.motor_demands[i].speed_limit = bswap16(package.motor_demands[i].speed_limit);
        package.motor_demands[i].current_limit = bswap16(package.motor_demands[i].current_limit);
    }
}

void EcaArm::bswapSensorPackage(SensorPackage & package) {
    for (int i=0; i<5; i++) {
        package.motor_data[i].position = bswap16(package.motor_data[i].position);
        package.motor_data[i].speed = bswap16(package.motor_data[i].speed);
        package.motor_data[i].current = bswap16(package.motor_data[i].current);
    }
}