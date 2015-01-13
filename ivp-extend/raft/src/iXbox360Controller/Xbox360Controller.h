/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Xbox360Controller.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef Xbox360Controller_HEADER
#define Xbox360Controller_HEADER

#include "MOOS/libMOOS/MOOSLib.h"
#include <boost/thread.hpp>

#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <string>

#include <linux/input.h>
#include <linux/joystick.h>
#include "axbtnmap.h"

#define NAME_LENGTH 128

class Xbox360Controller: public CMOOSApp {
public:
    Xbox360Controller();
    ~Xbox360Controller();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();
    void RegisterVariables();

private:
    int fd;
    unsigned char axes;
    unsigned char buttons;
    int version;
    char name[NAME_LENGTH];
    uint16_t btnmap[BTNMAP_SIZE];
    uint8_t axmap[AXMAP_SIZE];
    int btnmapok;

    boost::thread io_thread;

    void io_loop();

private:
    // State variables
    unsigned int m_iterations;
    double m_timewarp;
};

#endif 
