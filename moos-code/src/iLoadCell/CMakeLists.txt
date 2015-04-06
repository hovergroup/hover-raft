# ---------------------------------------------
# iLoadCell
#        File: CMakeLists.txt
#  Created on: Apr 06, 2015
#      Author: Josh Leighton
# ---------------------------------------------

# FILE(GLOB SRC *.cpp)

SET(SRC
    LoadCell.cpp
    LoadCell_Info.cpp
    main.cpp
)



ADD_EXECUTABLE(iLoadCell ${SRC})

TARGET_LINK_LIBRARIES(iLoadCell
    mbutil
    ${MOOS_LIBRARIES}
    ${MOOS_DEPEND_LIBRARIES}
    boost_thread
    boost_system
    )

