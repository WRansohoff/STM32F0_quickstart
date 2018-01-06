#include "interrupts_c.h"

/*
 * A button on pin A4 will use the [4:15] interrupt.
 */
void EXTI4_15_IRQ_handler(void) {
    interrupt_state = !interrupt_state;
    // Reset the 'pending' flag to acknowledge the interrupt.
    // For now only one EXTI interrupt is active, but it is best to
    // check which event you're responding to.
    EXTI->PR |= EXTI_PR_PR4;
}
