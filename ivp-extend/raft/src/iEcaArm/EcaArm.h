/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftControl.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftControl_HEADER
#define RaftControl_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

class RaftControl: public CMOOSApp {
public:
    RaftControl();
    ~RaftControl();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();
    void RegisterVariables();

private:
    double right_thrust, left_thrust;
    bool enable;
    // Configuration variables

private:
    double left_x_neg_dead, left_x_pos_dead;
    double left_y_neg_dead, left_y_pos_dead;
    double right_x_neg_dead, right_x_pos_dead;
    double right_y_neg_dead, right_y_pos_dead;

    bool parseDeadBand(std::string config, double & neg, double & pos);
    double mapThrust(double input, double neg, double pos);

    // State variables
    unsigned int m_iterations;
    double m_timewarp;
};

#endif 
