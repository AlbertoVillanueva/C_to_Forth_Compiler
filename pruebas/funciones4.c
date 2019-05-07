#include <stdio.h>

int c ;

int mifuncion (int a, int b) 
{
    int c ;
    
    if (a < b) {
       puts ("a es menor que b") ;
       c = a ;
    } else {
       puts ("b es menor que a") ;
       c = b ;
    }   
    return c ;
}



main ()
{
     int a ;
     int b ;
     
     a = 7 ;
     b = 3 ;
     c = mifuncion (a, b) ;
     puts ("El menor es ") ;
     printf ("%d\n", c) ;
//@ cr     
     a = 3 ;
     b = 7 ;
     c = mifuncion (a, b) ;
     puts ("El menor es ") ;
     printf ("%d\n", c) ;
//@ cr     
     a = 4 ;
     b = 4 ;
     c = mifuncion (a, b) ;
     puts ("El menor es ") ;
     printf ("%d\n", c) ;

//   system("pause") ;
 }

//@ main
