#--------------------------------------------------------
# The CMakeLists.txt for:                       iEcaArm
# Author(s):                              
#--------------------------------------------------------

# FILE(GLOB SRC *.cpp)

SET(SRC
  EcaArm.cpp
  EcaArm_Info.cpp
  main.cpp
)



ADD_EXECUTABLE(iEcaArm ${SRC})

TARGET_LINK_LIBRARIES(iEcaArm
    boost_system
    boost_thread
    ${MOOS_LIBRARIES}
    mbutil
    m
    pthread)

