#include <stdio.h>

int cuadrado (int a) 
{
    int c ;

    c = a * a ;    

    return c ;
}

main ()
{
     int a ;
     int c ;
     
     a = 7 ;
     puts ("El cuadrado de ") ;
     printf ("%d", a) ;
     c = cuadrado (a) ;
     puts (" es ") ;
     printf ("%d\n", c) ;
//@ cr     
     a = 12 ;
     puts ("El cuadrado de ") ;
     printf ("%d", a) ;
     puts (" es ") ;
     printf ("%d\n", cuadrado (a)) ;
//@ cr     

//   system("pause") ;
}

//@ main
