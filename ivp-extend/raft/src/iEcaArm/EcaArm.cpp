/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftControl.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "RaftControl.h"

using namespace std;

//---------------------------------------------------------
// Constructor

RaftControl::RaftControl() {
    enable = false;
}

//---------------------------------------------------------
// Destructor

RaftControl::~RaftControl() {
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool RaftControl::OnNewMail(MOOSMSG_LIST &NewMail) {
    MOOSMSG_LIST::iterator p;

    for (p = NewMail.begin(); p != NewMail.end(); p++) {
        CMOOSMsg &msg = *p;
        string key = msg.GetKey();
        if (key == "XBOX_LSTICKY") {
            left_thrust = -mapThrust(msg.GetDouble(), left_y_neg_dead, left_y_pos_dead);
        } else if (key == "XBOX_RSTICKY") {
            right_thrust = -mapThrust(msg.GetDouble(), right_y_neg_dead, right_y_pos_dead);
        } else if (key == "XBOX_START") {
            if (msg.GetDouble() == 1) {
                enable = !enable;
            }
        }
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RaftControl::OnConnectToServer() {
    string lstickx_dead, lsticky_dead, rstickx_dead, rsticky_dead;
    m_MissionReader.GetConfigurationParam("lstickx_dead", lstickx_dead);
    m_MissionReader.GetConfigurationParam("lsticky_dead", lsticky_dead);
    m_MissionReader.GetConfigurationParam("rstickx_dead", rstickx_dead);
    m_MissionReader.GetConfigurationParam("rsticky_dead", rsticky_dead);
    parseDeadBand(lstickx_dead, left_x_neg_dead, left_x_pos_dead);
    parseDeadBand(lsticky_dead, left_y_neg_dead, left_y_pos_dead);
    parseDeadBand(lstickx_dead, right_x_neg_dead, right_x_pos_dead);
    parseDeadBand(lsticky_dead, right_y_neg_dead, right_y_pos_dead);

    m_Comms.Register("XBOX_LSTICKY", 0);
    m_Comms.Register("XBOX_RSTICKY", 0);
    m_Comms.Register("XBOX_START", 0);
    return (true);
}

bool RaftControl::parseDeadBand(string config, double & neg, double & pos) {
    float a, b;
    if (sscanf(config.c_str(), "%f,%f", &a, &b) == 2) {
        neg = std::min(a,b);
        pos = std::max(a,b);
        return true;
    } else {
        return false;
    }
}

double RaftControl::mapThrust(double input, double neg, double pos) {
    double output;
    if (input > pos) {
        output = 100/(32767-pos) * (input-pos);
    } else if (input < neg) {
        output = -100/(-32767-neg) * (input-neg);
    } else {
        output = 0;
    }
    if (output > 100) output = 100;
    if (output < -100) output = -100;
    return output;
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RaftControl::Iterate() {
    if (enable) {
        m_Comms.Notify("DESIRED_THRUST_LEFT", left_thrust);
        m_Comms.Notify("DESIRED_THRUST_RIGHT", right_thrust);
    } else {
        m_Comms.Notify("DESIRED_THRUST_LEFT", 0.0);
        m_Comms.Notify("DESIRED_THRUST_RIGHT", 0.0);
    }
    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RaftControl::OnStartUp() {


    return (true);
}

//---------------------------------------------------------
// Procedure: RegisterVariables

void RaftControl::RegisterVariables() {
    // m_Comms.Register("FOOBAR", 0);
}

