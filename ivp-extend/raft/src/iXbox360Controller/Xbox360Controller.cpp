/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Xbox360Controller.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "Xbox360Controller.h"

char *axis_names[ABS_MAX + 1] = {
"X", "Y", "Z", "Rx", "Ry", "Rz", "Throttle", "Rudder",
"Wheel", "Gas", "Brake", "?", "?", "?", "?", "?",
"Hat0X", "Hat0Y", "Hat1X", "Hat1Y", "Hat2X", "Hat2Y", "Hat3X", "Hat3Y",
"?", "?", "?", "?", "?", "?", "?",
};

char *button_names[KEY_MAX - BTN_MISC + 1] = {
"Btn0", "Btn1", "Btn2", "Btn3", "Btn4", "Btn5", "Btn6", "Btn7", "Btn8", "Btn9", "?", "?", "?", "?", "?", "?",
"LeftBtn", "RightBtn", "MiddleBtn", "SideBtn", "ExtraBtn", "ForwardBtn", "BackBtn", "TaskBtn", "?", "?", "?", "?", "?", "?", "?", "?",
"Trigger", "ThumbBtn", "ThumbBtn2", "TopBtn", "TopBtn2", "PinkieBtn", "BaseBtn", "BaseBtn2", "BaseBtn3", "BaseBtn4", "BaseBtn5", "BaseBtn6", "BtnDead",
"BtnA", "BtnB", "BtnC", "BtnX", "BtnY", "BtnZ", "BtnTL", "BtnTR", "BtnTL2", "BtnTR2", "BtnSelect", "BtnStart", "BtnMode", "BtnThumbL", "BtnThumbR", "?",
"?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?",
"WheelBtn", "Gear up",
};

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

bool Xbox360Controller::Iterate() {
    m_iterations++;
    return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool Xbox360Controller::OnStartUp() {
    string device = "/dev/input/js0";

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

        printf("\r");

        if (axes) {
            printf("Axes: ");
            for (i = 0; i < axes; i++)
                printf("%2d:%6d ", i, axis[i]);
        }

        if (buttons) {
            printf("Buttons: ");
            for (i = 0; i < buttons; i++)
                printf("%2d:%s ", i, button[i] ? "on " : "off");
        }

        fflush(stdout);
    }
}

//---------------------------------------------------------
// Procedure: RegisterVariables

void Xbox360Controller::RegisterVariables() {
    // m_Comms.Register("FOOBAR", 0);
}

