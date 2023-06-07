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
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS "-g -traceback")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -sox")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal -fp-model source")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -check -check noarg_temp_created -check nopointer -fpe0 -ftrapuv -init=snan,arrays")
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(Fortran_LINELENGTH_FLAG "-free")
  set(C_PREPROCESS_FLAG "-cpp")
else()
  message(WARNING "Fortran compiler with ID ${CMAKE_Fortran_COMPILER_ID} will be used with CMake default options")
endif()

###############################################################################
### Set variables
###############################################################################

# double vs. single precision output
set(DOUBLE_PRECISION OFF CACHE BOOL "Use 8-byte real numbers instead of 4-byte in output.")
if(DOUBLE_PRECISION)
  add_definitions(-DDOUBLE_PRECISION)
else()
  add_definitions(-DDOUBLE_PRECISION -DSINGLE_OUTPUT)
endif()

# coordinate type
set(COORDINATE_TYPE CARTESIAN CACHE STRING "Sets coordinate type.")
set_property(CACHE COORDINATE_TYPE PROPERTY STRINGS CARTESIAN SPHERICAL)
if(COORDINATE_TYPE STREQUAL "SPHERICAL")
  add_definitions(-DSPHERICAL)
endif()

# wetting and drying
set(WET_DRY OFF CACHE BOOL "Activate wetting-drying capability.")
if(WET_DRY)
  add_definitions(-DWET_DRY)
endif()

# parallelization
if(MPI)
  add_definitions(-DMULTIPROCESSOR)
endif()

# metis
add_definitions(-DMETIS_5)

###############################################################################
### File lists and macros
###############################################################################

include("fvcom_files.cmake")

###############################################################################
### Application
###############################################################################

add_library(fvcom STATIC ${fvcom_main_files} ${fvcom_mods_files})
set_target_properties(fvcom PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
set_target_properties(fvcom PROPERTIES COMPILE_FLAGS "${Fortran_LINELENGTH_FLAG}")
#target_include_directories(fvcom PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/mod)
#target_include_directories(fvcom PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod> $<INSTALL_INTERFACE:mod>)
#target_link_libraries(fvcom PUBLIC esmf $<TARGET_OBJECTS:julian> $<TARGET_OBJECTS:proj> $<TARGET_OBJECTS:fproj> $<TARGET_OBJECTS:metis>)
#target_link_libraries(fvcom PUBLIC esmf $<TARGET_OBJECTS:julian> $<TARGET_OBJECTS:metis>)
#target_link_libraries(fvcom PUBLIC esmf $<TARGET_OBJECTS:julian> $<TARGET_OBJECTS:proj> $<TARGET_OBJECTS:fproj>)
#target_link_libraries(fvcom PUBLIC esmf $<TARGET_OBJECTS:julian> $<TARGET_OBJECTS:proj>)
target_link_libraries(fvcom PUBLIC esmf $<TARGET_OBJECTS:metis> $<TARGET_OBJECTS:julian> $<TARGET_OBJECTS:proj> $<TARGET_OBJECTS:fproj>)

###############################################################################
### Install dependencies
###############################################################################

include(ExternalProject)

# extract tar files
list(APPEND deps
  julian
  proj
  fproj)
  #metis)

foreach(dep ${deps})
  if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${dep})
    message(INFO " ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/src/libs/${dep}.tgz is already extracted.")
  else()
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/src/libs/${dep}.tgz
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
endforeach()

# install proj
ExternalProject_Add(proj_bld
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/proj
  CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/proj/configure
    --prefix=${CMAKE_CURRENT_BINARY_DIR}/proj
  BUILD_COMMAND ${MAKE})
add_library(proj STATIC IMPORTED)
add_dependencies(fvcom proj_bld)

# install fproj
ExternalProject_Add(fproj_bld
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/fproj
  CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/fproj/configure
    CPPFLAGS=-DIFORT
    --prefix=${CMAKE_CURRENT_BINARY_DIR}/fproj
    --with-proj4=${CMAKE_CURRENT_BINARY_DIR}/proj
  BUILD_COMMAND ${MAKE})
add_library(fproj STATIC IMPORTED)
add_dependencies(fvcom fproj_bld)

# install julian
file(GLOB_RECURSE source_list ${CMAKE_CURRENT_BINARY_DIR}/julian/*)
add_library(julian STATIC ${source_list})
target_include_directories(julian PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/julian)
target_include_directories(fvcom PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/julian)

# install metis
#file(GLOB_RECURSE source_list ${CMAKE_CURRENT_BINARY_DIR}/metis/*)
#add_library(metis STATIC ${source_list})
#target_include_directories(metis PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/metis)
ExternalProject_Add(metis_bld
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/metis
  GIT_REPOSITORY https://github.com/KarypisLab/METIS.git
  GIT_TAG v5.2.1)
add_library(metis STATIC IMPORTED)
add_dependencies(fvcom metis_bld)


###############################################################################
### Install
###############################################################################

install(
  TARGETS fvcom
  EXPORT  fvcom-config
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  COMPONENT Library)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod DESTINATION ${CMAKE_INSTALL_PREFIX}/FVCOM)

install(EXPORT      fvcom-config
        DESTINATION lib/cmake)
