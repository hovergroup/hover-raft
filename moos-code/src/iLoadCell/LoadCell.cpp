/*
 * Josh Leighton
 *        File: LoadCell.cpp
 *  Created on: Apr 06, 2015
 *      Author: Josh Leighton
 */

#include <iterator>
#include "MBUtils.h"
#include "LoadCell.h"

//#include <cstdlib>
//#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

//using namespace std;

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
        std::string key = msg.GetKey();
        if (key == "VARIABLE") {
        	std::string val = msg.GetString();
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
	portno = 9002;
    m_MissionReader.GetConfigurationParam("port", portno);

    io_thread = boost::thread(boost::bind(&LoadCell::io_loop, this));
    return true;
}

void LoadCell::io_loop() {
    int sockfd, newsockfd;
    socklen_t clilen;
    struct sockaddr_in serv_addr, cli_addr;
    int n;
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
    	std::cout << "ERROR opening socket" << std::endl;
       exit(1);
    }
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
    if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
    	std::cout << "ERROR on binding" << std::endl;
    	std::cout << errno << std::endl;
    	exit(1);
    }
    listen(sockfd,5);
    clilen = sizeof(cli_addr);
    while (true) {
    	std::vector<char> buffer (256, 0);
		newsockfd = accept(sockfd,
					(struct sockaddr *) &cli_addr,
					&clilen);
		if (newsockfd < 0) {
			std::cout << "ERROR on accept" << std::endl;
			exit(1);
		}
		bool closed = false;
		while (!closed) {
			n = read(newsockfd,&buffer[0],255);
			if (n < 0)
				std::cout << "read error" << std::endl;
			else if (n == 0) {
				std::cout << "connection closed" << std::endl;
				closed = true;
			} else {
				std::cout << "Got data: ";
				for (int i=0; i<buffer.size(); i++) {
					std::cout << buffer[i];
				}
				std::cout << std::endl;
//				std::vector<char>::iterator it =
//						std::find(buffer.begin(), buffer.end(), "\n");
			}
		}
		close(newsockfd);
    }
    close(sockfd);
}
