#include "main.h"

/**
 * Main program.
 *
 * Dummy project contents: blink an LED.
 */
int main(void) {
    // Enable the GPIOA peripheral's clock.
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);
    // Enable the SYSCFG clock, to allow for EXTI configuration.
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);

    // Initialize GPIO pin A1 as push/pull output, no pupdr, high-speed.
    // Example output.
    GPIO_InitTypeDef gpio_init_struct;
    gpio_init_struct.GPIO_Pin   = GPIO_Pin_1;
    gpio_init_struct.GPIO_Mode  = GPIO_Mode_OUT;
    gpio_init_struct.GPIO_OType = GPIO_OType_PP;
    gpio_init_struct.GPIO_Speed = GPIO_Speed_50MHz;
    gpio_init_struct.GPIO_PuPd  = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOA, &gpio_init_struct);

    // Initialize GPIO pin A4 as input, with pullup.
    // Example button/etc input.
    gpio_init_struct.GPIO_Pin   = GPIO_Pin_4;
    gpio_init_struct.GPIO_Mode  = GPIO_Mode_IN;
    gpio_init_struct.GPIO_PuPd  = GPIO_PuPd_UP;
    GPIO_Init(GPIOA, &gpio_init_struct);

    // Reset 'interrupt_state' variable.
    interrupt_state = 0;
    // Set SYSCFG settings to link EXTI line with pin A4.
    SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOA, EXTI_PinSource4);
    // Setup EXTI initialization struct.
    EXTI_InitTypeDef exti_init;
    exti_init.EXTI_Line = EXTI_Line4;
    exti_init.EXTI_Mode = EXTI_Mode_Interrupt;
    exti_init.EXTI_Trigger = EXTI_Trigger_Falling;
    exti_init.EXTI_LineCmd = ENABLE;
    // Initialize the EXTI line.
    EXTI_Init(&exti_init);
    // Initialize the interrupt in the NVIC.
    NVIC_InitTypeDef nvic_init;
    nvic_init.NVIC_IRQChannel = EXTI4_15_IRQn;
    nvic_init.NVIC_IRQChannelPriority = 0x03;
    nvic_init.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&nvic_init);

    // Since this is a microcontroller, there's no point in
    // exiting our program before power-off.
    while (1) {
        // Light up the LED or don't, depending on button input state.
        if (interrupt_state) {
            GPIOA->BSRR = GPIO_Pin_1;
            delay_us(500000);
        }
        else {
            GPIOA->BRR = GPIO_Pin_1;
            delay_us(500000);
        }
    }
}
