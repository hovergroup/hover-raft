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
    use_speed = false;

    last_start_press = -1;
    last_select_press = -1;

    rb = 0;
    lb = 0;
    rtrig = 0;
    ltrig = 0;
    a = 0;
    b = 0;
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
            if (msg.GetTime() - last_start_press > 0.250) {
                if (msg.GetDouble() == 1) {
                    enable = !enable;
                }
                last_start_press = msg.GetTime();
            }
        } else if (key == "XBOX_SELECT") {
            if (msg.GetTime() - last_select_press > 0.250) {
                if (msg.GetDouble() == 1) {
                    use_speed = !use_speed;
                }
                last_select_press = msg.GetTime();
            }
        } else if (key == "XBOX_DPADX") {
            yaw_speed = -mapECASpeed(msg.GetDouble(), -500, 500);
        } else if (key == "XBOX_DPADY") {
            shoulder_speed = -mapECASpeed(msg.GetDouble(), -500, 500);
        } else if (key == "XBOX_RB") {
            rb = msg.GetDouble();
        } else if (key == "XBOX_LB") {
            lb = msg.GetDouble();
        } else if (key == "XBOX_LTRIG") {
            ltrig = mapTrigger(msg.GetDouble(), 0);
        } else if (key == "XBOX_RTRIG") {
            rtrig = mapTrigger(msg.GetDouble(), 0);
        } else if (key == "XBOX_A") {
            a = msg.GetDouble();
        } else if (key == "XBOX_B") {
            b = msg.GetDouble();
        }
    }
    
    if (rb == 1 && lb == 1)
        jaw_speed = 0;
    else if (rb == 1)
        jaw_speed = -100;
    else if (lb == 1)
        jaw_speed = 100;
    else
        jaw_speed = 0;
    
    if (ltrig != 0 && rtrig != 0)
        wrist_speed = 0;
    else if (ltrig != 0)
        wrist_speed = -ltrig;
    else if (rtrig != 0)
        wrist_speed = rtrig;
    else
        wrist_speed = 0;
    
    if (a == 1 && b == 1)
        elbow_speed = 0;
    else if (a == 1)
        elbow_speed = 100;
    else if (b == 1)
        elbow_speed = -100;
    else
        elbow_speed = 0;
    
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
    m_Comms.Register("XBOX_SELECT", 0);
    m_Comms.Register("XBOX_DPADX", 0);
    m_Comms.Register("XBOX_DPADY", 0);
    m_Comms.Register("XBOX_RB", 0);
    m_Comms.Register("XBOX_LB", 0);
    m_Comms.Register("XBOX_A", 0);
    m_Comms.Register("XBOX_B", 0);
    m_Comms.Register("XBOX_LTRIG", 0);
    m_Comms.Register("XBOX_RTRIG", 0);
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

double RaftControl::mapECASpeed(double input, double neg, double pos) {
    double output;
    if (input > pos) {
        output = 100.0/(32767.0-pos) * (input-pos);
    } else if (input < neg) {
        output = -100.0/(-32767.0-neg) * (input-neg);
    } else {
        output = 0;
    }
    if (output > 100) output = 100;
    if (output < -100) output = -100;
    return output;
}

double RaftControl::mapTrigger(double input, double dead) {
    double output;
    if (input > -32767+dead) {
        output = 100.0/(32767.0*2.0) * (input+32767);
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
        m_Comms.Notify("DESIRED_POWER_CH1", left_thrust);
        m_Comms.Notify("DESIRED_POWER_CH2", right_thrust);
        if (use_speed) {
            m_Comms.Notify("ECA_YAW_SPEED_CMD", yaw_speed);
            m_Comms.Notify("ECA_ELBOW_SPEED_CMD", elbow_speed);
            m_Comms.Notify("ECA_SHOULDER_SPEED_CMD", shoulder_speed);
            m_Comms.Notify("ECA_WRIST_SPEED_CMD", wrist_speed);
            m_Comms.Notify("ECA_GRIP_SPEED_CMD", jaw_speed);
        } else {
            m_Comms.Notify("ECA_YAW_VOLTAGE_CMD", yaw_speed);
            m_Comms.Notify("ECA_ELBOW_VOLTAGE_CMD", elbow_speed);
            m_Comms.Notify("ECA_SHOULDER_VOLTAGE_CMD", shoulder_speed);
            m_Comms.Notify("ECA_WRIST_VOLTAGE_CMD", wrist_speed);
            m_Comms.Notify("ECA_GRIP_VOLTAGE_CMD", jaw_speed);
        }
    } else {
        m_Comms.Notify("DESIRED_POWER_CH1", 0.0);
        m_Comms.Notify("DESIRED_POWER_CH2", 0.0);
        m_Comms.Notify("ECA_YAW_VOLTAGE_CMD", 0.0);
        m_Comms.Notify("ECA_ELBOW_VOLTAGE_CMD", 0.0);
        m_Comms.Notify("ECA_SHOULDER_VOLTAGE_CMD", 0.0);
        m_Comms.Notify("ECA_WRIST_VOLTAGE_CMD", 0.0);
        m_Comms.Notify("ECA_GRIP_VOLTAGE_CMD", 0.0);
        m_Comms.Notify("ECA_YAW_SPEED_CMD", 0.0);
        m_Comms.Notify("ECA_ELBOW_SPEED_CMD", 0.0);
        m_Comms.Notify("ECA_SHOULDER_SPEED_CMD", 0.0);
        m_Comms.Notify("ECA_WRIST_SPEED_CMD", 0.0);
        m_Comms.Notify("ECA_GRIP_SPEED_CMD", 0.0);
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

