###############################################################################
### Fortran compiler flags
###############################################################################

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "-g -fbacktrace")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Waliasing -fcray-pointer -fconvert=big-endian -fno-range-check -fbacktrace")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -fcheck=bounds -ffpe-trap=invalid,zero,overflow,underflow" )
  set(CMAKE_Fortran_LINK_FLAGS "")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS "-g -traceback")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -sox")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal -fp-model source")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -check -check noarg_temp_created -check nopointer -fpe0 -ftrapuv -init=snan,arrays")
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(C_PREPROCESS_FLAG "-cpp")
  set(COMM "intel")
else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()

###############################################################################
### Set variables
###############################################################################

#------------------------------------------------------------------------------
# Specify ROMS specific variables
if(NOT ROMS_APP AND NOT ROMS_APP_DIR)
  message(STATUS "Using ROMS default application")

  set(ROMS_APP IRENE)
  set(ROMS_APP_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/APP/${ROMS_APP})

  set(ROMS_UFS_APPLICATION     ${ROMS_APP})
  set(ROMS_UFS_APPLICATION_DIR ${ROMS_APP_DIR})

elseif( ROMS_APP AND NOT ROMS_APP_DIR)
  message(ERROR "If you set ROMS_APP you must also set ROMS_APP_DIR to
                  the absolute path containing your application configuration." )
else()
  set(ROMS_UFS_APPLICATION     ${ROMS_APP})
  set(ROMS_UFS_APPLICATION_DIR ${ROMS_APP_DIR})
endif()

message(STATUS "ROMS_UFS_APPLICATION=${ROMS_UFS_APPLICATION}")
message(STATUS "ROMS_UFS_APPLICATION_DIR=${ROMS_UFS_APPLICATION_DIR}")

set(MY_HEADER_DIR ${ROMS_APP_DIR})
set(MY_CPP_FLAGS ANALYTICAL_DIR='${ROMS_APP_DIR}';HEADER_DIR='${ROMS_APP_DIR}';ROOT_DIR='${ROMS_SRC_DIR}';MPI)
set(LIBTYPE STATIC)
set(ROMS_EXECUTABLE OFF)

#------------------------------------------------------------------------------
# Set netcdf variables
if(NetCDF_Fortran_FOUND)
  set(ENV{NETCDF_INCDIR} "${NetCDF_Fortran_INCLUDE_DIRS}")
  set(ENV{NETCDF_LIBDIR} "${NetCDF_Fortran_LIBRARIES}")
endif()

#------------------------------------------------------------------------------
# Set build directory
set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})

###############################################################################
### Set configuration specific variables
###############################################################################

#------------------------------------------------------------------------------
# Bulk flux
set(BULK_FLUX OFF CACHE BOOL "Use ROMS provided bulk flux algorithm.")
if (BULK_FLUX)
  add_definitions(-DBULK_FLUXES)
  add_definitions(-DCOOL_SKIN)
  add_definitions(-DEMINUSP)
  add_definitions(-DLONGWAVE_OUT)
  add_definitions(-DWIND_MINUS_CURRENT)
endif()

#------------------------------------------------------------------------------
# ROMS Coupling
add_definitions(-DCMEPS)
add_definitions(-DCDEPS)

if(ROMS_APP STREQUAL "IRENE")
  add_definitions(-DESMF_LIB)
  add_definitions(-DFRC_COUPLING)
  add_definitions(-DROMS_STDOUT)
  add_definitions(-DVERIFICATION)
  add_definitions(-DCOLLECT_ALLREDUCE)
  add_definitions(-DOUT_DOUBLE)
endif()

###############################################################################
### Add iclude directories and ROMS project 
###############################################################################

if (ESMF_FOUND)
  include_directories(${ESMF_F90COMPILEPATHS})
endif()

add_subdirectory(ROMS)

target_include_directories(ROMS_static PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/ROMS/modules>
                                        $<INSTALL_INTERFACE:mod>)

###############################################################################
### Install
###############################################################################

install(
  TARGETS ROMS_static 
  EXPORT  roms-config
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  COMPONENT Library)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod DESTINATION ${CMAKE_INSTALL_PREFIX}/ROMS)

install(EXPORT      roms-config
        DESTINATION lib/cmake)
