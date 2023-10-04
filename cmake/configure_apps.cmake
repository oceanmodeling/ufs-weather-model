###############################################################################
### Doc
# This file turns ON (only ON, not OFF) a component in a valid application
# If a user wishes to add a new application, they should add an
# Application handle (APP_NAME) in the list of `VALID_APPS` in the
# top-level CMakeLists.txt
# Next, they can define an if-endif block with that APP_NAME and
# turn ON the components specific to this new application.
# Note, only the components required for the application should be turned ON.
# It is forbidden to turn OFF or change any other CMake option in this file.
###############################################################################

###############################################################################
### Configure Application Components
###############################################################################
string(TOUPPER ${APP} APP)

if(APP MATCHES "^(ATM|ATMW|ATMWM|ATMAQ|ATML)$")
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
  set(FV3        ON  CACHE BOOL "Enable FV3"                 FORCE)
  set(STOCH_PHYS ON  CACHE BOOL "Enable Stochastic Physics"  FORCE)
  if(APP MATCHES "ATMW")
    set(WW3      ON  CACHE BOOL "Enable WAVEWATCH III"       FORCE)
    message("Configuring UFS app in Atmosphere with Waves mode")
    set(CMEPS    ON  CACHE BOOL "Enable CMEPS"               FORCE)
  elseif(APP MATCHES "ATMWM")
    set(WW3      ON  CACHE BOOL "Enable WAVEWATCH III"       FORCE)
    message("Configuring UFS app in Atmosphere with Waves mode")
  elseif(APP MATCHES "ATMAQ")
    set(AQM      ON  CACHE BOOL "Enable AQM"                 FORCE)
    message("Configuring UFS app in Atmosphere with Air Quality mode")
  elseif(APP MATCHES "ATML")
    set(CMEPS    ON  CACHE BOOL "Enable CMEPS"               FORCE)
    set(NOAHMP   ON  CACHE BOOL "Enable NOAHMP"              FORCE)
    message("Configuring UFS app in Atmosphere with Air Quality mode")
  else()
    message("Configuring UFS app in Atmosphere Only mode")
  endif()
endif()

if(APP MATCHES "^(NG-GODAS)$")
  set(CMEPS      ON  CACHE BOOL "Enable CMEPS"               FORCE)
  set(STOCH_PHYS ON  CACHE BOOL "Enable Stochastic Physics"  FORCE)
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
  set(MOM6       ON  CACHE BOOL "Enable MOM6"                FORCE)
  set(CICE6      ON  CACHE BOOL "Enable CICE6"               FORCE)
  set(CDEPS      ON  CACHE BOOL "Enable CDEPS"               FORCE)
  message("Configuring UFS app in (CDEPS) Data Atmosphere mode")
endif()

if(APP MATCHES "^(S2S|S2SA|S2SW|S2SWA|S2SWAL)$")
  set(APP_MSG "Configuring UFS app in S2S")
  set(CMEPS      ON  CACHE BOOL "Enable CMEPS"               FORCE)
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
  set(FV3        ON  CACHE BOOL "Enable FV3"                 FORCE)
  set(MOM6       ON  CACHE BOOL "Enable MOM6"                FORCE)
  set(CICE6      ON  CACHE BOOL "Enable CICE6"               FORCE)
  set(STOCH_PHYS ON  CACHE BOOL "Enable Stochastic Physics"  FORCE)
  if(APP MATCHES "^(S2SW|S2SWA|S2SWAL)")
    set(WW3      ON  CACHE BOOL "Enable WAVEWATCH III"       FORCE)
    string(CONCAT APP_MSG ${APP_MSG} " with Waves")
  endif()
  if(APP MATCHES "^(S2SA|S2SWA)")
    set(UFS_GOCART ON  CACHE BOOL "Enable GOCART"            FORCE)
    string(CONCAT APP_MSG ${APP_MSG} " with Aerosols")
  endif()
  if(APP MATCHES "^S2SWAL")
    set(NOAHMP     ON  CACHE BOOL "Enable NOAHMP"            FORCE)
  endif()
  message("${APP_MSG} mode")
endif()

if(APP MATCHES "^(HAFS|HAFSW|HAFS-ALL)$")
  set(CMEPS      ON  CACHE BOOL "Enable CMEPS"               FORCE)
  if(APP MATCHES "^(HAFS-ALL)$")
    set(CDEPS    ON  CACHE BOOL "Enable CDEPS"               FORCE)
    message("Configuring UFS app in HAFS with CDEPS mode")
  endif()
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
  set(FV3        ON  CACHE BOOL "Enable FV3"                 FORCE)
  set(STOCH_PHYS ON  CACHE BOOL "Enable Stochastic Physics"  FORCE)
  set(HYCOM      ON  CACHE BOOL "Enable HYCOM"               FORCE)
  if(APP MATCHES "^(HAFSW|HAFS-ALL)$")
    set(WW3      ON  CACHE BOOL "Enable WAVEWATCH III"       FORCE)
    message("Configuring UFS app in HAFS with Waves mode")
  endif()
endif()

if(APP MATCHES "^(ATMAERO)$")
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
  set(FV3        ON  CACHE BOOL "Enable FV3"                 FORCE)
  set(STOCH_PHYS ON  CACHE BOOL "Enable Stochastic Physics"  FORCE)
  set(UFS_GOCART ON  CACHE BOOL "Enable GOCART"              FORCE)
  message("Configuring UFS app in Atmosphere with Aerosols mode")
endif()

if(APP MATCHES "^(LND)$")
  set(CMEPS      ON  CACHE BOOL "Enable CMEPS"               FORCE)
  set(CDEPS      ON  CACHE BOOL "Enable CDEPS"               FORCE)
  set(NOAHMP     ON  CACHE BOOL "Enable NOAHMP"              FORCE)
  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
endif()


######################################
### Coastal Application Components ###
######################################

##########
### ADCIRC APPS/TESTS: Use CDEPS/CMEPS, ADCIRC, PAHM, WW3
#list(APPEND CSTL_ADC_APPS CSTLA CSTLPA CSTLAW CSTLPAW CSTL-ALL)

##########
### FVCOM APPS/TESTS: Use CDEPS/CMEPS, FVCOM, WW3
#list(APPEND CSTL_FVC_APPS CSTLF CSTLFW CSTL-ALL)

##########
### ROMS APPS/TESTS: Use CDEPS/CMEPS, ROMS, CICE, WW3
#list(APPEND CSTL_ROM_APPS CSTLR CSTLRW CSTLRC CSTLRCW CSTL-ALL)

##########
### SCHISM APPS/TESTS: Use CDEPS/CMEPS, SCHISM, PAHM(internal/external), CICE?, WW3
#list(APPEND CSTL_SCH_APPS CSTLS CSTLPS CSTLSW CSTLPSW CSTL-ALL)

##########
### PAHM APPS/TESTS: Use CMEPS, with ADCIRC, SCHISM, WW3
#list(APPEND CSTL_PAM_APPS CSTLP CSTLPA CSTLPAW CSTLPS CSTLPSW CSTL-ALL)

##########
### WW3 APPS/TESTS: Use CDEPS/CMEPS, with ADCIRC, FVCOM, SCHISM, ROMS
#list(APPEND CSTL_WW3_APPS CSTLW CSTLAW CSTLPAW CSTLFW CSTLSW CSTLRW CSTLRCW CSTLSW CSTLPSW CSTL-ALL)

##########
### ALL APPS/TESTS (COMBINE EVERYTHING TOGETHER)
#list(APPEND CSTL_ALL_APPS  ${CSTL_ADC_APPS} ${CSTL_FVC_APPS} ${CSTL_ROM_APPS} ${CSTL_SCH_APPS} ${CSTL_PAM_APPS} ${CSTL_WW3_APPS} CSTL-ALL)
#list(REMOVE_DUPLICATES CSTL_ALL_APPS)


if(APP IN_LIST CSTL_ALL_APPS)
  set(CMEPS      ON  CACHE BOOL "Enable CMEPS"               FORCE)
  set(CDEPS      ON  CACHE BOOL "Enable CDEPS"               FORCE)

  ### ADCIRC
  if(APP IN_LIST CSTL_ADC_APPS)
    set(ADCIRC   ON  CACHE BOOL "Enable ADCIRC"              FORCE)
    message("Configuring UFS app in COASTAL with ADCIRC model")
  endif()

  ### FVCOM
  if(APP IN_LIST CSTL_FVC_APPS)
    set(FVCOM    ON  CACHE BOOL "Enable FVCOM"               FORCE)
    message("Configuring UFS app in COASTAL with FVCOM model")
  endif()

  ### ROMS
  if(APP IN_LIST CSTL_ROM_APPS)
    set(ROMS     ON  CACHE BOOL "Enable ROMS"                FORCE)
    message("Configuring UFS app in COASTAL with ROMS model")
  endif()

  ### SCHISM
  if(APP IN_LIST CSTL_SCH_APPS)
    set(SCHISM   ON  CACHE BOOL "Enable SCHISM"              FORCE)
    message("Configuring UFS app in COASTAL with SCHISM model")
  endif()

  ### PAHM
  if(APP IN_LIST CSTL_PAM_APPS)
    set(PAHM   ON  CACHE BOOL "Enable PAHM"              FORCE)
    message("Configuring UFS app in COASTAL with PAHM model")
  endif()

  ### WW3
  if(APP IN_LIST CSTL_WW3_APPS)
    set(WW3      ON  CACHE BOOL "Enable WAVEWATCH III"       FORCE)
    message("Configuring UFS app in HAFS with Waves mode")
  endif()

  set(FMS        ON  CACHE BOOL "Enable FMS"                 FORCE)
endif()
