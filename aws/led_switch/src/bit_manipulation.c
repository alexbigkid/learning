#include "bit_manipulation.h"
#include "adc.h"

uint8_t Jill = 0x00;
uint8_t Jung = 0xFF;
uint8_t Jukk = 0x00;

int8_t do_bit_man(int8_t position)
{
    if( ( position < 0 ) || ( position > 7 ) )
    {
        //positon should be 0 to 7. Because we are going to modify 8 bit value.
        return -1;
    }

    //set particular bit
    Jill |= ( 1 << position );

    //clear particular bit
    Jung &= ~( 1 << position );

    //toggle particular bit
    Jukk ^= ( 1 << position );

    int result = adc_read();

    if( result >= 30 )
    {
        printf("Temperature is High\n");
    }
    else
    {
        printf("Temperature is Low\n");
    }

    return 0;
}

