#ifndef _VVC_INTERRUPTS_H
#define _VVC_INTERRUPTS_H

#include "global.h"

/*
 * C handlers for interrupts that are used in the program.
 * The function names can be found in the vector table assembly file;
 * by default, they weakly map to a default 'infinite loop' handler.
 */
void EXTI4_15_IRQ_handler(void);

#endif
