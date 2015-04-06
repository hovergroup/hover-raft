#--------------------------------------------------------
# The CMakeLists.txt for:                       iXbox360Controller
# Author(s):                              
#--------------------------------------------------------

# FILE(GLOB SRC *.cpp)

SET(SRC
  Xbox360Controller.cpp
  Xbox360Controller_Info.cpp
  axbtnmap.cpp
  main.cpp
)



ADD_EXECUTABLE(iXbox360Controller ${SRC})

TARGET_LINK_LIBRARIES(iXbox360Controller
   ${MOOS_LIBRARIES}
   boost_thread
   boost_system
   mbutil
   m
   pthread)

