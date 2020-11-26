@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;C:/Xilinx/Vivado/2014.2/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2014.2/ids_lite/ISE/lib/nt64;C:/Xilinx/Vivado/2014.2/bin;%PATH%
set XILINX_PLANAHEAD=C:/Xilinx/Vivado/2014.2

xelab -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot transcodeur_7_seg_behav --prj C:/Users/Pierre-Olivier/Documents/GitHub/Projet_horloge/project_H/project_H.sim/sim_1/behav/transcodeur_7_seg.prj   xil_defaultlib.transcodeur_7_seg
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)
