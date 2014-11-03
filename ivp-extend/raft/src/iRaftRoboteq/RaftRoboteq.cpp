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

RaftRoboteq::RaftRoboteq(boost::asio::io_service& io_service) :
    socket_(io_service)
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
    // register for variables here
    // possibly look at the mission file?
    // m_MissionReader.GetConfigurationParam("Name", <string>);
    // m_Comms.Register("VARNAME", 0);

    RegisterVariables();
    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftRoboteq::Iterate() {
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

    RegisterVariables();
    return (true);
}

//---------------------------------------------------------
// Procedure: RegisterVariables

void RaftRoboteq::RegisterVariables() {
    // m_Comms.Register("FOOBAR", 0);
}

