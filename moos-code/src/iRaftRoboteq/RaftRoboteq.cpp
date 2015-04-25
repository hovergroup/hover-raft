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

//using boost::asio::ip::tcp;
using namespace boost::asio;

//---------------------------------------------------------
// Constructor

RaftRoboteq::RaftRoboteq() :
                sock(io_service),
                deadline_timer(io_service) {
    slow_queries.push_back("?V\r");
    slow_queries.push_back("?T\r");
    slow_queries.push_back("?A\r");
    slow_queries.push_back("?BA\r");
    slow_queries.push_back("?DI 1\r");
    slow_query_index = 0;

    power_report_count = 0;
    power_command_count = 0;
    ack_count = 0;
    nack_count = 0;
    last_report_time = -1;
    
    command_left = 0;
    command_right = 0;
    new_command_left = false;
    new_command_right = false;
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
        // only process new messages
        if (MOOSTime() - msg.GetTime() < 5) {
            string key = msg.GetKey();
            if (key == "DESIRED_POWER_CH2") {
                command_left = msg.GetDouble();
                new_command_left = true;
            } else if (key == "DESIRED_POWER_CH1") {
                command_right = msg.GetDouble();
                new_command_right = true;
            } else if (key == "ECA_ARM_POWER") {
                if (msg.GetDouble() == 1) {
                    setArmPower(true);
                } else {
                    setArmPower(false);
                }
            }
        }
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RaftRoboteq::OnConnectToServer() {
    m_Comms.Register("DESIRED_POWER_CH1", 0);
    m_Comms.Register("DESIRED_POWER_CH2", 0);
    m_Comms.Register("ECA_ARM_POWER", 0);

    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftRoboteq::Iterate() {
    if (new_command_left) {
        setThrust(2, command_left);
        new_command_left = false;
    }

    if (new_command_right) {
        setThrust(1, command_right);
        new_command_right = false;
    }
    
    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RaftRoboteq::OnStartUp() {
//    string address = "192.168.1.51";
//    string port = "5001";
    string port = "/dev/ttyUSB0";
//    m_MissionReader.GetConfigurationParam("address", address);
    m_MissionReader.GetConfigurationParam("port", port);

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


    boost::asio::async_write(sock, boost::asio::buffer("^ECHOF 1\r", 9),
            boost::bind(&RaftRoboteq::handle_basic_write, this, _1));
    
    start_write();
    start_read();
    io_thread = boost::thread(boost::bind(&RaftRoboteq::io_loop, this));

    return (true);
}

void RaftRoboteq::io_loop() {
    cout << "Running io service" << endl;
    io_service.run();
    cout << "Finished running io service" << endl;
}


void RaftRoboteq::handle_basic_write(const boost::system::error_code& ec) {
    if (!ec) {
    } else {
        cout << "Error on basic write: " << ec.message() << endl;
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
    boost::asio::async_read_until(sock, input_buffer, '\r',
            boost::bind(&RaftRoboteq::handle_read, this, _1, _2));
}

void RaftRoboteq::handle_read(const boost::system::error_code& ec, std::size_t bt) {
    if (!ec) {
        // construct istream from boost streambuf
        std::string line;
        std::istream is(&input_buffer);
	//std::getline(is, line);
	safeGetline(is, line);
	
	parseLine(line);

        start_read();
    } else {
        cout << "Error on receive: " << ec.message() << endl;
    }
}

std::istream& RaftRoboteq::safeGetline(std::istream& is, std::string& t)
{
    t.clear();

    // The characters in the stream are read one-by-one using a std::streambuf.
    // That is faster than reading them one-by-one using the std::istream.
    // Code that uses streambuf this way must be guarded by a sentry object.
    // The sentry object performs various tasks,
    // such as thread synchronization and updating the stream state.

    std::istream::sentry se(is, true);
    std::streambuf* sb = is.rdbuf();

    for(;;) {
        int c = sb->sbumpc();
        switch (c) {
        case '\n':
            return is;
        case '\r':
            if(sb->sgetc() == '\n')
                sb->sbumpc();
            return is;
        case EOF:
            // Also handle the case when the last line has no line ending
            if(t.empty())
                is.setstate(std::ios::eofbit);
            return is;
        default:
            t += (char)c;
        }
    }
}

void RaftRoboteq::start_write() {
    string slow_query = slow_queries[slow_query_index] + "?P\r?AI 1\r";
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
    int power = -thrust * 10.0;
    char command [100];
    int n = sprintf(command, "!G %d %d\r", channel, power);
    boost::asio::async_write(sock, boost::asio::buffer(command, n),
            boost::bind(&RaftRoboteq::handle_command_write, this, _1));
}

void RaftRoboteq::setArmPower(bool power) {
    string command;
    if (power)
        command = "!D1 2\r";
    else
        command = "!D0 2\r";

    boost::asio::async_write(sock, boost::asio::buffer(command, command.size()),
            boost::bind(&RaftRoboteq::handle_basic_write, this, _1));
}

void RaftRoboteq::parseLine(string line) {
    switch (line[0]) {
    case 'V':
        int v1, v2, v3;
        if (sscanf(line.c_str(), "V=%d:%d:%d", &v1, &v2, &v3) == 3) {
            m_Comms.Notify("ROBOTEQ_BATTERY_VOLTAGE", v2/10.0);
        } else {
            cout << "Voltage parse error" << endl;
        }
        break;

    case 'A':
        int a1, a2;
        if (line.size() < 2) break;
        if (line[1] == 'I') {
            if (sscanf(line.c_str(), "AI=%d", &a1) == 1) {
                m_Comms.Notify("ROBOTEQ_AIN1_VOLTS", a1/1000.0);
            } else {
                cout << "Ain parse error" << endl;
            }
        } else {
            if (sscanf(line.c_str(), "A=%d:%d", &a1, &a2) == 2) {
                m_Comms.Notify("ROBOTEQ_CH1_CURRENT", a1/10.0);
                m_Comms.Notify("ROBOTEQ_CH2_CURRENT", a2/10.0);
            } else {
                cout << "Motor current parse error" << endl;
            }
        }
        break;

    case 'B':
        int b1, b2;
        if (sscanf(line.c_str(), "BA=%d:%d", &b1, &b2) == 2) {
            m_Comms.Notify("ROBOTEQ_CH1_BATTERY_CURRENT", b1/10.0);
            m_Comms.Notify("ROBOTEQ_CH2_BATTERY_CURRENT", b2/10.0);
        } else {
            cout << "Battery current parse error" << endl;
        }
        break;

    case 'T':
        int t1, t2;
        if (sscanf(line.c_str(), "T=%d:%d", &t1, &t2) == 2) {
            m_Comms.Notify("ROBOTEQ_CH1_TEMPERATURE", (double) t1);
            m_Comms.Notify("ROBOTEQ_CH2_TEMPERATURE", (double) t2);
        } else {
            cout << "Temperature parse error" << endl;
        }
        break;

    case 'D':
        int d1;
        if (sscanf(line.c_str(), "DI=%d", &d1) == 1) {
            m_Comms.Notify("ROBOTEQ_ESTOP", (double) d1);
        } else {
            cout << "Estop parse error" << endl;
        }
        break;

    case 'P':
        int p1, p2;
        if (sscanf(line.c_str(), "P=%d:%d", &p1, &p2) == 2) {
            m_Comms.Notify("ROBOTEQ_CH1_POWER", p1);
            m_Comms.Notify("ROBOTEQ_CH2_POWER", p2);
            power_report_count++;
        } else {
            cout << "Power parse error" << endl;
        }
        break;

    case '+':
        ack_count++;
        break;

    case '-':
        nack_count++;
        break;
    }


    if (MOOSTime() - last_report_time > 5) {
        double time_elapsed = MOOSTime() - last_report_time;
        double power_report_rate = power_report_count / time_elapsed;
        double power_command_rate = power_command_count / time_elapsed;
        double nack_rate = nack_count / time_elapsed;
	double ack_rate = ack_count / time_elapsed;

        m_Comms.Notify("ROBOTEQ_REPORT_RATE", power_report_rate);
        m_Comms.Notify("ROBOTEQ_COMMAND_RATE", power_command_rate);
        m_Comms.Notify("ROBOTEQ_NACK_RATE", nack_rate);
	m_Comms.Notify("ROBOTEQ_ACK_RATE", ack_rate);

        power_report_count = 0;
        power_command_count = 0;
        ack_count = 0;
        nack_count = 0;
        last_report_time = MOOSTime();
    }
}
