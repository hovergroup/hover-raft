#--------------------------------------------------------
# The CMakeLists.txt for:                         iOS5000
# Author(s):                          Andrew Patrikalakis
#--------------------------------------------------------

ADD_EXECUTABLE(testing_app testing_app.cpp)
   
TARGET_LINK_LIBRARIES(testing_app
	gsl
    gslcblas)