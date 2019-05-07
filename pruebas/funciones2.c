#include <stdio.h>

int a;

int mifuncion () 
{
    int c ;

    c = 123 ;
    
    puts ("Prueba") ;
    return c+1 ;
}


main ()
{
     int c ;
     
     c = mifuncion () ;
//@ cr     
     printf ("%d\n", c) ;
//     system("pause") ;
 }

//@ main
