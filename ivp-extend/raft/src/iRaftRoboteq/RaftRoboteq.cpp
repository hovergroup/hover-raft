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

//---------------------------------------------------------
// Constructor

RaftRoboteq::RaftRoboteq() :
    stopped_(false),
    socket_(io_service_),
    deadline_(io_service_)
{
    m_iterations = 0;
    m_timewarp = 1;
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
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RaftRoboteq::OnConnectToServer() {

    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftRoboteq::Iterate() {
    if (stopped_)
        return false;

    cout << m_iterations << endl;
    m_iterations++;

    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RaftRoboteq::OnStartUp() {
    string address = "192.168.1.51";
    unsigned int port = 50001;
    m_MissionReader.GetConfigurationParam("address", address);
    m_MissionReader.GetConfigurationParam("port", port);

    boost::system::error_code myError;
    boost::asio::ip::address_v4 targetIP;
    targetIP = boost::asio::ip::address_v4::from_string(address, myError);
    cout << "GetIP - " << myError.message() << endl;
    if (myError)
        return false;
    myError.clear();

    tcp::endpoint endpoint;
    endpoint.address(targetIP);
    endpoint.port(port);

    cout << "Attempting connection to " <<
            endpoint.address().to_string() << ":" <<
            endpoint.port() << endl;

    socket_.connect(endpoint, myError);
    cout << "Connect - " << myError.message() << endl;
    if (myError)
        return false;

    start_read();

    worker_thread = boost::thread(boost::bind(&RaftRoboteq::run, this));


//    io_service_.post(boost::bind(&RaftRoboteq::start_read, this, _1));
//    worker_threads.create_thread(
//            boost::bind(&boost::asio::io_service::run, this, &io_service_));

    return (true);
}

void RaftRoboteq::run() {
    io_service_.run();
}

void RaftRoboteq::stop() {
    stopped_ = true;
    socket_.close();
    deadline_.cancel();
}

void RaftRoboteq::start_read() {
    deadline_.expires_from_now(boost::posix_time::seconds(60));

    boost::asio::async_read_until(socket_, input_buffer_, '\n',
            boost::bind(&RaftRoboteq::handle_read, this, _1));
}

void RaftRoboteq::handle_read(const boost::system::error_code& ec) {
    if (stopped_)
        return;

    if (!ec) {
        // Extract the newline-delimited message from the buffer.
        std::string line;
        std::istream is(&input_buffer_);
        std::getline(is, line);

        // Empty messages are heartbeats and so ignored.
        if (!line.empty()) {
            std::cout << "Received: " << line << "\n";
        }

        start_read();
    } else {
        std::cout << "Error on receive: " << ec.message() << "\n";

        stop();
    }
}
