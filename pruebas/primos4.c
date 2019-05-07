#include <stdio.h>

int d ;
int n  ;
int m ;


int esprimo (int n) 
{
    int primo ;
    int d ;

    primo = 1 ;
    d = 2 ;
    while (d < n) {
        if (n % d == 0) {
            primo = 0 ;
        }
        d = d + 1 ;
    }
    return (primo) ;        
}


void listaprimos (int n, int m)
{
    while (n < m) {
        if (esprimo (n)) {
            printf ("%d  ", n) ;
        }
        n = n + 1 ;
//@  ." - " 
    } 
}


main ()
{
    int d ;
    int i ;

    listaprimos (1, 100) ;

//    system ("pause") ;
}

//@ main
