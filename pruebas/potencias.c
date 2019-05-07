// Potencias de DOS
#include <stdio.h>

int potencias [100] ;
int m ;

main ()
{
    int i ;

    m = 30 ;

    i = 1 ; 
    potencias [0] = 1 ;
    while (i < m) {    // corregido 2019 el limite <= por <
        potencias [i] = potencias [i-1] * 2 ;
        i = i + 1 ;
    }


    i = 1 ; 
    while (i < m) {   // corregido 2019 el limite <= por <
//@  ." Potencia de 2 a la  " 
//@  main_i @ . ." : " 
        printf (" %d  ", potencias [i]) ;
//@  cr
        i = i + 1 ;
    }
}

//@ main

