#ifndef _VVC_GLOBAL_H
#define _VVC_GLOBAL_H

#include "stm32f0xx.h"

// Assembly methods.
extern void delay_us(unsigned int d);

// Global variables.
volatile unsigned char interrupt_state;

#endif
