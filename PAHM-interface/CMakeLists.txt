###############################################################################
### Fortran compiler flags
###############################################################################

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "-g -fbacktrace")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Waliasing -fcray-pointer -fconvert=big-endian -fno-range-check -fbacktrace")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -fcheck=bounds -ffpe-trap=invalid,zero,overflow,underflow" )
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(Fortran_LINELENGTH_FLAG "-ffixed-line-length-none")
  set(Fortran_COMPILER_SPECIFIC_FLAG "-mcmodel=medium")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS "-g -traceback")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -sox")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal -fp-model source")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -check -check noarg_temp_created -check nopointer -fpe0 -ftrapuv -init=snan,arrays")
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(Fortran_LINELENGTH_FLAG "-132")
  set(Fortran_COMPILER_SPECIFIC_FLAG "-mcmodel=medium")
else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${ADCIRC_Extra_FORTRAN_FLAGS}")

###############################################################################
### File lists and macros
###############################################################################

include("pahm_files.cmake")
include("cmake/macros.cmake")

set(src_files ${pahm_lib_src_files})

###############################################################################
### Options
###############################################################################

# User option to build configuration
set(PAHM_DEBUG_INFO OFF CACHE BOOL "Write detailed information in the log file")
set(PAHM_ADDITIONAL_FLAGS "" CACHE STRING "Additional flags to compile PaHM with")

set(PAHM_BUILD_EXECUTABLE OFF CACHE BOOL "Build the PaHM executable")
set(PAHM_BUILD_STATIC_LIB ON CACHE BOOL "Build the PaHM static library")
set(PAHM_BUILD_SHARED_LIB OFF CACHE BOOL "Build the PaHM shared library")

#P.V This is the same as in ADCIRC-interface/CMakeLists.txt; all references to REAL8/REAL4
# should be completely removed for both ADCIRC and PAHM as the REAL8/REAL4 flags have been
# removed from ADCIRC (the model exclusively uses now 64bit calculations) and the same will be
# done in PAHM shortly
set(PRECISION_8BYTE ON CACHE BOOL "Use 8-byte real numbers instead of 4-byte.")
if(PRECISION_8BYTE)
  set(PRECISION_FLAG "REAL8")
else(PRECISION_8BYTE)
  set(PRECISION_FLAG "REAL4")
endif(PRECISION_8BYTE)

#P.V This COUPLED blocked should be removed because we always build a coupled system here
# User option for coupling
set(COUPLED ON CACHE BOOL "Build NUOPC cap for coupling.")
if(COUPLED)
  set(src_files ${src_files} ${pahm_nuopc_src_files})
endif()

if(PAHM_DEBUG_INFO)
  set(DEBUG_FLAG "DEBUG_INFO")
else()
  unset(DEBUG_FLAG)
endif()

set(LOCAL_COMPILER_DEFINITIONS "${PAHM_OPTION_FLAGS} ${PRECISION_FLAG} ${DEBUG_FLAG}")
separate_arguments(LOCAL_COMPILER_DEFINITIONS)

###############################################################################
### Application 
###############################################################################

#P.V Do we need to build both static and shared libraries? Now either one can be built

### Build the program static library
if(PAHM_BUILD_STATIC_LIB)
  add_library(pahm STATIC ${src_files})

  set_target_properties(pahm PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
  target_include_directories(pahm PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod> $<INSTALL_INTERFACE:mod>)
  target_include_directories(pahm PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/mod)
  set_target_properties(pahm PROPERTIES COMPILE_FLAGS "${Fortran_LINELENGTH_FLAG} ${Fortran_COMPILER_SPECIFIC_FLAG}")
  target_compile_definitions(pahm PRIVATE ${LOCAL_COMPILER_DEFINITIONS})
  
  addNetCDF(pahm)
endif(PAHM_BUILD_STATIC_LIB)


### Build the program shared library
if(PAHM_BUILD_SHARED_LIB)
  if (NOT PAHM_BUILD_STATIC_LIB)
    add_library(pahm SHARED ${src_files})

    set_target_properties(pahm PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
    target_include_directories(pahm PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod> $<INSTALL_INTERFACE:mod>)
    target_include_directories(pahm PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/mod)
    set_target_properties(pahm PROPERTIES COMPILE_FLAGS "${Fortran_LINELENGTH_FLAG} ${Fortran_COMPILER_SPECIFIC_FLAG}")
    target_compile_definitions(pahm PRIVATE ${LOCAL_COMPILER_DEFINITIONS})

    set_property(TARGET pahm PROPERTY POSITION_INDEPENDENT_CODE ON)
    set_target_properties(pahm PROPERTIES VERSION 1.0.0 SOVERSION 1.0)

    addNetCDF(pahm)
  else(NOT PAHM_BUILD_STATIC_LIB)
    message(FATAL_ERROR "Only one of PAHM_BUILD_STATIC_LIB and PAHM_BUILD_SHARED_LIB should be set to TRUE")
  endif(NOT PAHM_BUILD_STATIC_LIB)
endif(PAHM_BUILD_SHARED_LIB)

### Build and install the program if requested
if(PAHM_BUILD_EXECUTABLE)
  add_executable(pahm_exe ${pahm_exe_src_files})

  set_target_properties(pahm_exe PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
  target_include_directories(pahm_exe PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod> $<INSTALL_INTERFACE:mod>)
  target_include_directories(pahm_exe PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/mod)
  set_target_properties(pahm_exe PROPERTIES COMPILE_FLAGS "${Fortran_LINELENGTH_FLAG} ${Fortran_COMPILER_SPECIFIC_FLAG}")
  target_compile_definitions(pahm_exe PRIVATE ${LOCAL_COMPILER_DEFINITIONS})
  set_target_properties(pahm_exe PROPERTIES OUTPUT_NAME pahm)

  addNetCDF(pahm_exe)

  install(TARGETS pahm_exe RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR})
endif(PAHM_BUILD_EXECUTABLE)

###############################################################################
### Install
###############################################################################

install(
  TARGETS pahm
  EXPORT  pahm-config
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  COMPONENT Library)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod DESTINATION ${CMAKE_INSTALL_PREFIX}/pahm)

install(EXPORT      pahm-config
        DESTINATION lib/cmake)
