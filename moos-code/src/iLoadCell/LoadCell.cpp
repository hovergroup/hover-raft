/*
 * Josh Leighton
 *        File: LoadCell.cpp
 *  Created on: Apr 06, 2015
 *      Author: Josh Leighton
 */

#include <iterator>
#include "MBUtils.h"
#include "LoadCell.h"

using namespace std;

//---------------------------------------------------------
// Constructor

LoadCell::LoadCell()
{
}

//---------------------------------------------------------
// Destructor

LoadCell::~LoadCell()
{
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool LoadCell::OnNewMail(MOOSMSG_LIST &NewMail)
{
    MOOSMSG_LIST::iterator p;

    for(p=NewMail.begin(); p!=NewMail.end(); p++) {
        CMOOSMsg &msg = *p;
        string key = msg.GetKey();
        if (key == "VARIABLE") {
            string val = msg.GetString();
        }
    }

    return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool LoadCell::OnConnectToServer()
{
    m_Comms.Register("VARIABLE", 0);
    return true;
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool LoadCell::Iterate()
{
    return true;
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool LoadCell::OnStartUp()
{
    string config_val;
    m_MissionReader.GetConfigurationParam("config_var", config_val);

    return true;
}

