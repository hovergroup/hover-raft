/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Xbox360Controller.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "Xbox360Controller.h"

using namespace std;

//---------------------------------------------------------
// Constructor

Xbox360Controller::Xbox360Controller() {
    axes = 2;
    buttons = 2;
    version = 0x000800;
    btnmapok = 1;
}

//---------------------------------------------------------
// Destructor

Xbox360Controller::~Xbox360Controller() {
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool Xbox360Controller::OnNewMail(MOOSMSG_LIST &NewMail) {
    MOOSMSG_LIST::iterator p;

    for (p = NewMail.begin(); p != NewMail.end(); p++) {
        CMOOSMsg &msg = *p;
    }

    return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool Xbox360Controller::OnConnectToServer() {
    m_Comms.Notify("XBOX_LSTICKX", 0.0);
    m_Comms.Notify("XBOX_LSTICKY", 0.0);
    m_Comms.Notify("XBOX_RSTICKX", 0.0);
    m_Comms.Notify("XBOX_RSTICKY", 0.0);
    m_Comms.Notify("XBOX_LTRIG", 0.0);
    m_Comms.Notify("XBOX_RTRIG", 0.0);
    m_Comms.Notify("XBOX_DPADX", 0.0);
    m_Comms.Notify("XBOX_DPADY", 0.0);
    m_Comms.Notify("XBOX_A", 0.0);
    m_Comms.Notify("XBOX_B", 0.0);
    m_Comms.Notify("XBOX_X", 0.0);
    m_Comms.Notify("XBOX_Y", 0.0);
    m_Comms.Notify("XBOX_RB", 0.0);
    m_Comms.Notify("XBOX_LB", 0.0);
    m_Comms.Notify("XBOX_SELECT", 0.0);
    m_Comms.Notify("XBOX_START", 0.0);
    m_Comms.Notify("XBOX_XBOX", 0.0);
    return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool Xbox360Controller::Iterate() {
    m_iterations++;
    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool Xbox360Controller::OnStartUp() {
    string device = "/dev/input/js1";
    m_MissionReader.GetConfigurationParam("device", device);

    if ((fd = open(device.c_str(), O_RDONLY)) < 0) {
        perror("jstest");
        return 1;
    }

    ioctl(fd, JSIOCGVERSION, &version);
    ioctl(fd, JSIOCGAXES, &axes);
    ioctl(fd, JSIOCGBUTTONS, &buttons);
    ioctl(fd, JSIOCGNAME(NAME_LENGTH), name);

    getaxmap(fd, axmap);
    getbtnmap(fd, btnmap);

    for (int i = 0; btnmapok && i < buttons; i++) {
        if (btnmap[i] < BTN_MISC || btnmap[i] > KEY_MAX) {
            btnmapok = 0;
            break;
        }
    }
    if (!btnmapok) {
        cout << "Joystick not compatible" << endl;
        return false;
    } else {
        cout << "Found: " << name << endl;
        string sname = string(name);
        if (sname.find("Microsoft X-Box 360 pad") == string::npos)
            return false;
        io_thread = boost::thread(boost::bind(&Xbox360Controller::io_loop, this));
        return true;
    }
}

void Xbox360Controller::io_loop() {
    int *axis;
    char *button;
    int i;
    struct js_event js;

    axis = (int*) calloc(axes, sizeof(int));
    button = (char*) calloc(buttons, sizeof(char));

    while (1) {
        if (read(fd, &js, sizeof(struct js_event)) != sizeof(struct js_event)) {
            perror("\njstest: error reading");
            exit (1);
        }

        switch (js.type & ~JS_EVENT_INIT) {
        case JS_EVENT_BUTTON:
            button[js.number] = js.value;
            break;
        case JS_EVENT_AXIS:
            axis[js.number] = js.value;
            break;
        }

//        printf("\r");

        if (axes) {
            m_Comms.Notify("XBOX_LSTICKX", (double) axis[0]);
            m_Comms.Notify("XBOX_LSTICKY", (double) axis[1]);
            m_Comms.Notify("XBOX_RSTICKX", (double) axis[3]);
            m_Comms.Notify("XBOX_RSTICKY", (double) axis[4]);
            m_Comms.Notify("XBOX_LTRIG", (double) axis[2]);
            m_Comms.Notify("XBOX_RTRIG", (double) axis[5]);
            m_Comms.Notify("XBOX_DPADX", (double) axis[6]);
            m_Comms.Notify("XBOX_DPADY", (double) axis[7]);
//            printf("LStickX:%6d", axis[0]);
//            printf("LStickY:%6d", axis[1]);
//            printf("LTrig:%6d", axis[2]);
//            printf("RStickX:%6d", axis[3]);
//            printf("RStickY:%6d", axis[4]);
//            printf("RTrig:%6d", axis[5]);
//            printf("DPadX:%6d", axis[6]);
//            printf("DPadY:%6d", axis[7]);
        }

        if (buttons) {
            m_Comms.Notify("XBOX_A", (double) button[0]);
            m_Comms.Notify("XBOX_B", (double) button[1]);
            m_Comms.Notify("XBOX_X", (double) button[2]);
            m_Comms.Notify("XBOX_Y", (double) button[3]);
            m_Comms.Notify("XBOX_RB", (double) button[5]);
            m_Comms.Notify("XBOX_LB", (double) button[4]);
            m_Comms.Notify("XBOX_SELECT", (double) button[6]);
            m_Comms.Notify("XBOX_START", (double) button[7]);
            m_Comms.Notify("XBOX_XBOX", (double) button[8]);
//            printf("A:%d ", button[0]);
//            printf("B:%d ", button[1]);
//            printf("X:%d ", button[2]);
//            printf("Y:%d ", button[3]);
//            printf("LB:%d ", button[4]);
//            printf("RB:%d ", button[5]);
//            printf("Sel:%d ", button[6]);
//            printf("Start:%d ", button[7]);
//            printf("XBox:%d ", button[8]);
        }

//        fflush(stdout);
    }
}

//---------------------------------------------------------
// Procedure: RegisterVariables

void Xbox360Controller::RegisterVariables() {
    // m_Comms.Register("FOOBAR", 0);
}

