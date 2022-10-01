#ifndef ZLS_TIMING_H
#define ZLS_TIMING_H
#include <sys/times.h>
#include <time.h>
#include "zls.h"
//
//====================================================================================
//
// CPU and Performance Timing
//
//====================================================================================

typedef struct cputime{

    clock_t  cputot[2]; // cpu clock cycles - not necesarily real time
    clock_t  cpuusr[2];
    clock_t  cpusys[2];

    clock_t  realtime[2];    // real (clock on the wall) time, but in cycles too

} CPUCoords, *CPUCoordPtr;

//====================================================================================
//
extern CPUCoords gZLS_GlobalCPUTimer;
//
// compute cycles between printing cycle progress reports > 16, even number
//
extern Counter kZLS_CycleProgressPrint;
//
// compute cycles between cpu/cell/cycles performance checks
// must be an integer multiple of kZLS_CycleProgressPrint
//
extern Counter kZLS_CPUCyclePerformance;
//
//====================================================================================
//
// main public timing calls.
//
//
// Start up the global timing, ctp is the *global* cpu timer structure:
// gZLS_GlobalCPUTimer, ie zlst_InitGlobalTiming(&gZLS_GlobalCPUTimer);
//
int zlst_InitGlobalTiming( CPUCoordPtr ctp );
//
int zlst_ClearCPUTimes   ( CPUCoordPtr ctp );
int zlst_StartCPUTimes   ( CPUCoordPtr ctp ); // to setup local timers
int zlst_MarkCPUTimes    ( CPUCoordPtr ctp ); // like end but for continuing use, updates [1] values
int zlst_EndCPUTimes     ( CPUCoordPtr ctp );
int zlst_SaveCPUTimes    ( CPUCoordPtr ct_sav, CPUCoordPtr ctp );
int zlst_ResumeCPUTimes  ( CPUCoordPtr ctp, CPUCoordPtr ct_sav );
int zlst_CopyCPUTimes    ( CPUCoordPtr ct_dst, CPUCoordPtr ct_src);

int zlst_ProgressCheck   ( CPUCoordPtr ctp, double nCells );
//
//====================================================================================
//
// lower level calls
//
int zlst_ElapsedCPUTimes ( CPUCoordPtr ct , char * title);
int zlst_ElapsedCellRates( CPUCoordPtr ct, double nCells, char * title );
//====================================================================================


#endif // ZLS_TIMING_H
