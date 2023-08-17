/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Hurrice Irene, 27-29 Aug 2011 using DOPPIO grid
**
** Application flag:   IRENE
** Input script:       roms_doppio.in     ! not yet created
**
*/

#define NLM_DRIVER

/* Basic physics options */

#define UV_ADV
#define UV_COR
#define UV_VIS2
#define MIX_S_UV           /* momentum mixing on s-surfaces */
#undef  SPLINES_VVISC
#undef  SPLINES_VDIFF
#define TS_DIF2
#define MIX_GEO_TS         /* tracer mixing on constant z surfaces */
#define SOLVE3D
#define SALINITY
#define NONLIN_EOS
#define CRAIG_BANNER
#define CHARNOK

#define ATM_PRESS
 

/* Basic numerics options */

#define UV_U3HADVECTION
#define DJ_GRADPS
#define CURVGRID
#define MASKING

/* Outputs */

#define AVERAGES

/* Surface and bottom boundary conditions */

#define UV_QDRAG

#define SOLAR_SOURCE       /* solar shortwave distributed over water column */
#define ANA_BSFLUX
#define ANA_BTFLUX

/* Vertical subgridscale turbulence closure */

#define GLS_MIXING
#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# undef  CANUTO_A
# define N2S2_HORAVG
# define RI_SPLINES
#endif

/* Open boundary condition settings */

#ifdef  NLM_DRIVER
# define SSH_TIDES         /* Activated tides for initial, simple case */
# define UV_TIDES          /* Reactivated when tidal data acquired     */
#endif

#ifdef SSH_TIDES
# undef RAMP_TIDES
# define ADD_FSOBC         /* Tide data is added to OBC from HYCOM */
#endif
#ifdef UV_TIDES
# define ADD_M2OBC         /* Tide data is added to OBC from HYCOM */
#endif
