#include <stdio.h>


main ()
{
    int resultado ;
    int n ;

    n = 7 ;
    resultado = 1 ;

    while (n>1) {
        resultado = resultado * n;
        n = n - 1 ;

//@ ." main_n=" main_n @ .
//@ ." resultado=" main_resultado @ . cr

    }
    printf("%d\n", resultado) ;
    
//    system ("pause") ;
}

//@ main cr
