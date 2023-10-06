###############################################################################
### Fortran compiler flags
###############################################################################

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -fcheck=bounds -ffpe-trap=invalid,zero,overflow,underflow" )
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(Fortran_LINELENGTH_FLAG "-ffixed-line-length-none -ffree-form")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal -fp-model source")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -check -check noarg_temp_created -check nopointer -fpe0 -ftrapuv -init=snan,arrays")
  set(CMAKE_Fortran_LINK_FLAGS "")
  set(Fortran_LINELENGTH_FLAG "-free")
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

# air pressure as focing
set(AIR_PRESSURE OFF CACHE BOOL "Use surface air pressure for forcing.")
if(AIR_PRESSURE)
  add_definitions(-DAIR_PRESSURE)
endif()

# parallelization
if(MPI)
  add_definitions(-DMULTIPROCESSOR)
endif()

# metis
set(ENABLE_METIS5 ON CACHE BOOL "Build with Metis version 5 support.")
if(ENABLE_METIS5)
  add_definitions(-DMETIS_5)
  list(APPEND fvcom_extra_files FVCOM/src/func_pointer.c FVCOM/src/partition.c)
else()
  list(APPEND fvcom_extra_files FVCOM/src/func_pointer.c)
endif()

# proj
add_definitions(-DPROJ)

# activate coupling
add_definitions(-DFVCOM_COUPLED)

# netcdf
if(NetCDF_FOUND)
  add_definitions(-DUSE_NETCDF4)
  if(NetCDF_PARALLEL)
    add_definitions(-DPIO)
  endif()
endif()

###############################################################################
### File lists and macros
###############################################################################

include("fvcom_files.cmake")

###############################################################################
### Application
###############################################################################

add_library(fvcom STATIC ${fvcom_nuopc_files} ${fvcom_main_files} ${fvcom_mods_files} ${fvcom_modsw_files} ${fvcom_mainw_files} ${fvcom_bio_files} ${fvcom_extra_files})
set_target_properties(fvcom PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
set_target_properties(fvcom PROPERTIES COMPILE_FLAGS "${Fortran_LINELENGTH_FLAG}")
set_target_properties(fvcom PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod)
target_include_directories(fvcom PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod> $<INSTALL_INTERFACE:mod>)
target_link_libraries(fvcom PRIVATE metis julian fproj proj esmf NetCDF::NetCDF_Fortran)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/proj/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/fproj/include)

###############################################################################
### Install dependencies
###############################################################################

include(ExternalProject)

# extract tar files
list(APPEND deps
  julian)

foreach(dep ${deps})
  if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${dep})
    message(INFO " ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/libs/${dep}.tgz is already extracted.")
  else()
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/libs/${dep}.tgz
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
endforeach()

# install proj
ExternalProject_Add(proj_bld
  URL ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/libs/proj.tgz
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/proj
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/proj
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/proj/configure
    --prefix=<INSTALL_DIR>
    --enable-shared=no
    --without-mutex
  UPDATE_COMMAND "")
add_library(proj STATIC IMPORTED)
add_dependencies(fvcom proj_bld proj)
target_include_directories(fvcom PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/proj/include)
set_property(TARGET proj PROPERTY IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/proj/lib/libproj.a)

# install fproj
ExternalProject_Add(fproj_bld
  URL ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/libs/fproj.tgz
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/fproj
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/fproj
  BUILD_IN_SOURCE 1
  BUILD_ALWAYS
  CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/fproj/configure
    --prefix=<INSTALL_DIR>
    --exec-prefix=<INSTALL_DIR>
    --with-proj4=${CMAKE_CURRENT_BINARY_DIR}/proj
    CPPFLAGS=-DIFORT\ -I${CMAKE_CURRENT_BINARY_DIR}/fproj
  BUILD_COMMAND make -j 1
  DEPENDS proj_bld proj
  UPDATE_COMMAND "")
add_library(fproj STATIC IMPORTED)
add_dependencies(fvcom fproj_bld fproj)
target_include_directories(fvcom PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/fproj/include)
set_property(TARGET fproj PROPERTY IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/fproj/lib/libfproj4.a)

# install julian
add_library(julian STATIC ${julian_files})
add_dependencies(fvcom julian)
set_target_properties(julian PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
target_include_directories(fvcom PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/julian)

# install metis
ExternalProject_Add(metis_bld
  URL ${CMAKE_CURRENT_SOURCE_DIR}/FVCOM/libs/metis.tgz
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/metis
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}
  BUILD_IN_SOURCE TRUE
  CMAKE_ARGS 
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DGKLIB_PATH:PATH=<SOURCE_DIR>/GKlib)
add_library(metis STATIC IMPORTED)
add_dependencies(fvcom metis_bld)
set_property(TARGET metis PROPERTY IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/lib/libmetis.a)

###############################################################################
### Install
###############################################################################

install(
  TARGETS fvcom
          julian
  EXPORT  fvcom-config
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  COMPONENT Library)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod DESTINATION ${CMAKE_INSTALL_PREFIX}/FVCOM)

install(EXPORT      fvcom-config
        DESTINATION lib/cmake)
