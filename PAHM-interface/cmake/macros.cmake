###========================================
### Macros for NetCDF
###========================================
macro(addNetCDF TARGET)
  if(NetCDF_Fortran_FOUND)
    target_compile_definitions(${TARGET} PRIVATE NETCDF)
    if(NetCDF4_FOUND)
      target_compile_definitions(${TARGET} PRIVATE HAVE_NETCDF4)
      target_compile_definitions(${TARGET} PRIVATE NETCDF_CAN_DEFLATE)
    endif()
    target_include_directories(${TARGET} PRIVATE ${NetCDF_Fortran_INCLUDE_DIRS})
    target_link_libraries(${TARGET} PUBLIC NetCDF::NetCDF_Fortran)
  endif()
endmacro()
