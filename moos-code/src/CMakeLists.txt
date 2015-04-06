##############################################################################
# FILE:        moos-ivp-extend/src/CMakeLists.txt
# DATE:        2010/09/07
# DESCRIPTION: CMakeLists.txt file for the moos-ivp-extend source directory
##############################################################################


#============================================================================
# Add the libraries in the current directory to the include path
#============================================================================
FILE(GLOB LOCAL_LIBRARY_DIRS ./lib_*)
INCLUDE_DIRECTORIES(${LOCAL_LIBRARY_DIRS})
#                    "./protobuf")

#============================================================================
# List the subdirectories to build...
#============================================================================

ADD_SUBDIRECTORY(iEcaArm)
ADD_SUBDIRECTORY(iRaftRoboteq)
ADD_SUBDIRECTORY(iXbox360Controller)
ADD_SUBDIRECTORY(pRaftControl)
ADD_SUBDIRECTORY(iLoadCell)

IF(BUILD_SHORE_APPS)
    ADD_SUBDIRECTORY(testing_app)
ENDIF(BUILD_SHORE_APPS)

##############################################################################
#                           END of CMakeLists.txt
##############################################################################

