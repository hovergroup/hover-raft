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

using boost::asio::ip::tcp;
using namespace boost::asio;

//---------------------------------------------------------
// Constructor

RaftRoboteq::RaftRoboteq() :
                sock(io_service),
                deadline_timer(io_service) {
    slow_queries.push_back("?V\n");
    slow_queries.push_back("?T\n");
    slow_queries.push_back("?A\n");
    slow_queries.push_back("?BA\n");
    slow_queries.push_back("?DI 1\n");
    slow_query_index = 0;

    power_report_count = 0;
    power_command_count = 0;
    power_ack_count = 0;
    power_nack_count = 0;
    last_report_time = -1;
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
        string key = msg.GetKey();
        if (key == "DESIRED_THRUST_LEFT") {
            setThrust(2, msg.GetDouble());
        } else if (key == "DESIRED_THRUST_RIGHT") {
            setThrust(1, msg.GetDouble());
        } else if (key == "ECA_ARM_POWER", 0) {
            if (msg.GetDouble() == 0) {
                setArmPower(false);
            } else {
                setArmPower(true);
            }
        }
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RaftRoboteq::OnConnectToServer() {
    m_Comms.Register("DESIRED_THRUST_LEFT", 0);
    m_Comms.Register("DESIRED_THRUST_RIGHT", 0);
    m_Comms.Register("ECA_ARM_POWER", 0);

    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftRoboteq::Iterate() {

    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RaftRoboteq::OnStartUp() {
    string address = "192.168.1.51";
    string port = "5001";
    m_MissionReader.GetConfigurationParam("address", address);
    m_MissionReader.GetConfigurationParam("port", port);

    tcp::resolver resolver(io_service);
    tcp::resolver::query query(tcp::v4(), address, port);
    tcp::resolver::iterator iterator = resolver.resolve(query);

    sock.connect(*iterator);

    start_read();
    start_write();
    io_thread = boost::thread(boost::bind(&RaftRoboteq::io_loop, this));

    return (true);
}

void RaftRoboteq::io_loop() {
    cout << "Running io service" << endl;
    io_service.run();
    cout << "Finished running io service" << endl;
}


void RaftRoboteq::handle_eca_power_write(const boost::system::error_code& ec) {
    if (!ec) {
    } else {
        cout << "Error on eca power write: " << ec.message() << endl;
    }
}

void RaftRoboteq::handle_command_write(const boost::system::error_code& ec) {
    if (!ec) {
        power_command_count++;
    } else {
        cout << "Error on command write: " << ec.message() << endl;
    }
}

void RaftRoboteq::start_read() {
    boost::asio::async_read_until(sock, input_buffer, '\n',
            boost::bind(&RaftRoboteq::handle_read, this, _1));
}

void RaftRoboteq::handle_read(const boost::system::error_code& ec) {
    if (!ec) {
        // Extract the newline-delimited message from the buffer.
        std::string line;
        std::istream is(&input_buffer);
        std::getline(is, line);

        parseLine(line);

        start_read();
    } else {
        cout << "Error on receive: " << ec.message() << endl;
    }
}

void RaftRoboteq::start_write() {
    string slow_query = slow_queries[slow_query_index] + "?P\n";
    boost::asio::async_write(sock, boost::asio::buffer(slow_query, slow_query.size()),
            boost::bind(&RaftRoboteq::handle_write, this, _1));

    slow_query_index++;
    if (slow_query_index == slow_queries.size()) {
        slow_query_index = 0;
    }
}

void RaftRoboteq::handle_write(const boost::system::error_code& ec) {
    if (!ec) {
        deadline_timer.expires_from_now(boost::posix_time::milliseconds(20));
        deadline_timer.async_wait(boost::bind(&RaftRoboteq::start_write, this));
    } else {
        cout << "Error on query write: " << ec.message() << endl;
    }
}

void RaftRoboteq::setThrust(int channel, double thrust) {
    int power = thrust * 10.0;
    char command [100];
    int n = sprintf(command, "!G %d %d\n", channel, power);
    boost::asio::async_write(sock, boost::asio::buffer(command, n),
            boost::bind(&RaftRoboteq::handle_command_write, this, _1));
}

void RaftRoboteq::setArmPower(bool power) {
    string command;
    if (power)
        command = "!D1 1\n";
    else
        command = "!D0 1\n";

    boost::asio::async_write(sock, boost::asio::buffer(command, command.size()),
            boost::bind(&RaftRoboteq::handle_eca_power_write, this, _1));
}

void RaftRoboteq::parseLine(string line) {
    switch (line[0]) {
    case 'V':
        int v1, v2, v3;
        sscanf(line.c_str(), "V=%d:%d:%d", &v1, &v2, &v3);
        m_Comms.Notify("ROBOTEQ_BATTERY_VOLTAGE", v2/10.0);
        break;

    case 'A':
        int a1, a2;
        sscanf(line.c_str(), "A=%d:%d", &a1, &a2);
        m_Comms.Notify("ROBOTEQ_MOTOR_CURRENT_LEFT", a1/10.0);
        m_Comms.Notify("ROBOTEQ_MOTOR_CURRENT_RIGHT", a2/10.0);
        break;

    case 'B':
        int b1;
        sscanf(line.c_str(), "BA=%d", &b1);
        m_Comms.Notify("ROBOTEQ_BATTERY_CURRENT", b1/10.0);
        break;

    case 'T':
        int tm, t1, t2;
        sscanf(line.c_str(), "T=%d,%d,%d", &tm, &t1, &t2);
        m_Comms.Notify("ROBOTEQ_IC_TEMPERATURE", tm/10.0);
        m_Comms.Notify("ROBOTEQ_TEMPERATURE_LEFT", t1/10.0);
        m_Comms.Notify("ROBOTEQ_TEMPERATURE_RIGHT", t2/10.0);
        break;

    case 'D':
        int d1;
        sscanf(line.c_str(), "DI=%d", &d1);
        m_Comms.Notify("ROBOTEQ_ESTOP", (double) d1);
        break;

    case 'P':
        int p1, p2;
        sscanf(line.c_str(), "P=%d,%d", &p1, &p2);
        m_Comms.Notify("ROBOTEQ_POWER_LEFT", p1);
        m_Comms.Notify("ROBOTEQ_POWER_RIGHT", p2);
        power_report_count++;
        break;

    case '+':
        power_ack_count++;
        break;

    case '-':
        power_nack_count++;
        break;
    }


    if (MOOSTime() - last_report_time > 5) {
        double time_elapsed = MOOSTime() - last_report_time;
        double power_report_rate = power_report_count / time_elapsed;
        double power_command_rate = power_command_count / time_elapsed;

        double power_nack_percent;
        if (power_command_count == 0) {
            power_nack_percent = 0;
        } else {
            power_nack_percent = 100.0 * power_nack_count / power_command_count;
        }

        m_Comms.Notify("ROBOTEQ_REPORT_RATE", power_report_rate);
        m_Comms.Notify("ROBOTEQ_COMMAND_RATE", power_command_rate);
        m_Comms.Notify("ROBOTEQ_NACK_PERCENT", power_nack_percent);

        power_report_count = 0;
        power_command_count = 0;
        power_ack_count = 0;
        power_nack_count = 0;
        last_report_time = MOOSTime();
    }
}
