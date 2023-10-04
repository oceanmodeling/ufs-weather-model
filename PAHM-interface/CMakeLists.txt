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


###############################################################################
### Options
###############################################################################

# User option to build configuration
set(PAHM_DEBUG_INFO OFF CACHE BOOL "Write detailed information in the log file")
set(PAHM_ADDITIONAL_FLAGS "" CACHE STRING "Additional flags to compile PaHM with")

set(PAHM_BUILD_EXECUTABLE OFF CACHE BOOL "Build the PaHM executable")
set(PAHM_BUILD_STATIC_LIB ON CACHE BOOL "Build the PaHM static library")
set(PAHM_BUILD_SHARED_LIB OFF CACHE BOOL "Build the PaHM shared library")

set(COUPLED OFF CACHE BOOL "Build NUOPC cap for coupling")


if(PAHM_BUILD_EXECUTABLE OR PAHM_BUILD_STATIC_LIB OR PAHM_BUILD_SHARED_LIB)
  set(_target_var pahm)

  set(src_files ${pahm_lib_src_files})
  if(COUPLED)
    set(src_files ${src_files} ${pahm_nuopc_src_files})
  endif()

  set(PRECISION_FLAG REAL8)

  if(PAHM_DEBUG_INFO)
    set(DEBUG_FLAG "DEBUG_INFO")
  else()
    unset(DEBUG_FLAG)
  endif()


  ###========================================
  ### Build the program executable
  ###========================================
  if(PAHM_BUILD_EXECUTABLE)
    add_executable(${_target_var} ${pahm_exe_src_files})

    addCompilerFlags(${_target_var})

    get_target_property(_target_mod_dir ${_target_var} Fortran_MODULE_DIRECTORY)
    if(${_target_mod_dir} STREQUAL "")
      set(_target_mod_dir ${CMAKE_Fortran_MODULE_DIRECTORY})
      if(${_target_mod_dir} STREQUAL "")
        set(_target_mod_dir ${CMAKE_BINARY_DIR}/CMakeFiles/mod/${_target_var})
      endif()
    endif()

    install(TARGETS ${_target_var} RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR})

    install(DIRECTORY "${_target_mod_dir}/"
            DESTINATION "include"
            FILES_MATCHING
            PATTERN "*.mod")
  endif(PAHM_BUILD_EXECUTABLE)


  ###========================================
  ### Build the program static library
  ###========================================
  if(PAHM_BUILD_STATIC_LIB)
    set(_target_var_lib lib${_target_var}_static)

    add_library(${_target_var_lib} STATIC ${src_files})

    addCompilerFlags(${_target_var_lib})

    set_target_properties(${_target_var_lib} PROPERTIES OUTPUT_NAME ${_target_var})
    set_target_properties(${_target_var_lib} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

    install(TARGETS ${_target_var_lib} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                                       ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
                                       LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

    unset(_target_var_lib)
  endif(PAHM_BUILD_STATIC_LIB)


  ###========================================
  ### Build the program shared library
  ###========================================
  if(PAHM_BUILD_SHARED_LIB)
    set(_target_var_lib lib${_target_var}_shared)

    add_library(${_target_var_lib} SHARED ${src_files})

    addCompilerFlags(${_target_var_lib})

    set_target_properties(${_target_var_lib} PROPERTIES OUTPUT_NAME ${_target_var})
    set_property(TARGET ${_target_var_lib} PROPERTY POSITION_INDEPENDENT_CODE ON)
    set_target_properties(${_target_var_lib} PROPERTIES VERSION ${PROG_VERSION} SOVERSION ${PROG_MAJOR})

    install(TARGETS ${_target_var_lib} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                                       ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
                                       LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

    unset(_target_var_lib)
  endif(PAHM_BUILD_SHARED_LIB)

  unset(_target_var)
endif(PAHM_BUILD_EXECUTABLE OR PAHM_BUILD_STATIC_LIB OR PAHM_BUILD_SHARED_LIB)
