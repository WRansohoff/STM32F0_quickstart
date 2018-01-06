#include "interrupts_c.h"

/*
 * A button on pin A4 will use the [4:15] interrupt.
 */
void EXTI4_15_IRQ_handler(void) {
    if (EXTI_GetITStatus(EXTI_Line4) != RESET) {
        interrupt_state = !interrupt_state;
        // Reset the 'pending' flag to acknowledge the interrupt.
        // Or w/periph library: EXTI_ClearITPendingBit(EXTI_Line4);
        EXTI->PR |= EXTI_PR_PR4;
    }
}
