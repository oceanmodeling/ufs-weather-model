list(APPEND pahm_exe_src_files
   PAHM/version.F90
   PAHM/src/sizes.F90
   PAHM/src/global.F90
   PAHM/src/messages.F90
   PAHM/src/timedateutils.F90
   PAHM/src/utilities.F90
   PAHM/src/sortutils.F90
   PAHM/src/csv_parameters.F90
   PAHM/src/csv_utilities.F90
   PAHM/src/csv_module.F90      
   PAHM/src/mesh.F90
   PAHM/src/vortex.F90
   PAHM/src/parwind.F90
   PAHM/src/netcdfio.F90
   PAHM/src/driver_mod.F90
   PAHM/src/pahm.F90
)

list(APPEND pahm_lib_src_files
   PAHM/version.F90
   PAHM/src/sizes.F90
   PAHM/src/global.F90
   PAHM/src/messages.F90
   PAHM/src/timedateutils.F90
   PAHM/src/utilities.F90
   PAHM/src/sortutils.F90
   PAHM/src/csv_parameters.F90
   PAHM/src/csv_utilities.F90
   PAHM/src/csv_module.F90      
   PAHM/src/mesh.F90
   PAHM/src/vortex.F90
   PAHM/src/parwind.F90
   PAHM/src/netcdfio.F90
   PAHM/src/driver_mod.F90
)

list(APPEND pahm_nuopc_src_files
  PAHM/nuopc/pahm_cap.F90
  PAHM/nuopc/pahm_mod.F90
)
