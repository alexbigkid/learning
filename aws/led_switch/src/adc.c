/* This source is just for understanding purpose.
** There is no logic here. We are not going to use
** this code outside. This will be used for understand the
** Unit test mock.
*/
#include "adc.h"

//We will assume that, ADC value will be updated in this value.
volatile int adc_value = 0;

int adc_read( void )
{
    /* We will assume that some other function outside is updating this
    ** adc_value variable. This variable will have updated adc's value.
    ** So, Simply return that variable for explain mock test.
    */
    return adc_value;
}

