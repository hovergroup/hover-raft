#--------------------------------------------------------
# The CMakeLists.txt for:                       pRaftControl
# Author(s):                              
#--------------------------------------------------------

# FILE(GLOB SRC *.cpp)

SET(SRC
  RaftControl.cpp
  RaftControl_Info.cpp
  main.cpp
)



ADD_EXECUTABLE(pRaftControl ${SRC})

TARGET_LINK_LIBRARIES(pRaftControl
   ${MOOS_LIBRARIES}
   mbutil
   m
   pthread)

