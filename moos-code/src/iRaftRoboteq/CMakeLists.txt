#--------------------------------------------------------
# The CMakeLists.txt for:                       iRaftRoboteq
# Author(s):                              
#--------------------------------------------------------

# FILE(GLOB SRC *.cpp)

SET(SRC
  RaftRoboteq.cpp
  RaftRoboteq_Info.cpp
  main.cpp
)



ADD_EXECUTABLE(iRaftRoboteq ${SRC})

TARGET_LINK_LIBRARIES(iRaftRoboteq
    boost_system
    boost_thread
    ${MOOS_LIBRARIES}
    mbutil
    m
    pthread)

