#--------------------------------------------------------
# The CMakeLists.txt for:                         iOS5000
# Author(s):                          Andrew Patrikalakis
#--------------------------------------------------------

ADD_EXECUTABLE(testing_app testing_app.cpp)
   
TARGET_LINK_LIBRARIES(testing_app
	gsl
    gslcblas)

    
ADD_EXECUTABLE(tdma_test tdma_test.cpp)
   
TARGET_LINK_LIBRARIES(tdma_test
    JoshUtils)