/*
 * Josh Leighton
 *        File: LoadCell.h
 *  Created on: Apr 06, 2015
 *      Author: Josh Leighton
 */

#ifndef LoadCell_HEADER
#define LoadCell_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

class LoadCell : public CMOOSApp
{
public:
    LoadCell();
    ~LoadCell();

protected:
    bool OnNewMail(MOOSMSG_LIST &NewMail);
    bool Iterate();
    bool OnConnectToServer();
    bool OnStartUp();

private:
};

#endif 
