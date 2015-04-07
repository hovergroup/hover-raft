/*
 * Josh Leighton
 *        File: LoadCell.h
 *  Created on: Apr 06, 2015
 *      Author: Josh Leighton
 */

#ifndef LoadCell_HEADER
#define LoadCell_HEADER

#include "MOOS/libMOOS/MOOSLib.h"
#include <boost/thread.hpp>

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

    void io_loop();
private:
    boost::thread io_thread;
    int portno;

    std::vector<std::string> var_names;
};

#endif 
