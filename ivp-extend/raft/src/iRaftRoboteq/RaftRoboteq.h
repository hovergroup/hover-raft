/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RaftRoboteq.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef RaftRoboteq_HEADER
#define RaftRoboteq_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include <iostream>
#include <string.h>

class RaftRoboteq: public CMOOSApp {
public:
    RaftRoboteq();
    ~RaftRoboteq();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();

private:
    int m_tcp_sockfd;

private:
    // State variables
    unsigned int m_iterations;
    double m_timewarp;
};

#endif 
