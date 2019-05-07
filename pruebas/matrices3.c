#include <stdio.h>

int mimatriz [5][5] ;
int i ;
int j ;
int aux ;


void inicializa ()
{
	int i ;
	int j ;

	i = 0 ;
	while (i < 5) {
		j = 0 ;
		while (j < 5) {
			mimatriz [i][j] = i + 2*j ;
			j = j + 1 ;
		}
		i = i + 1 ;
	}	
}


void imprime () 
{
	i = 0 ;
	while (i < 5) {
		j = 0 ;
		while (j < 5) {
			printf ("%d ", mimatriz [i][j]) ;
			j = j + 1 ;
		}
		puts ("\n") ;    // Esto igual no funiona en Forth, se simula con la siguiente embebida
//@ cr
		i = i + 1 ;
	}
}


void transpuesta () 
{
    int i ;
    int j ;
    int aux ;
    
    i = 0 ;
    do {
       j = i+1 ; 
       while (j < 5) {
           aux = mimatriz [i][j] ;
           mimatriz [i][j] = mimatriz [j][i] ;
           mimatriz [j][i] = aux ;
           j = j + 1 ;
       } 
       i = i + 1 ;
    } while  (i < 5) ;
}


main () {
	puts ("Matriz sin inicializar ") ;
//@ cr
	imprime () ;
	inicializa () ;
//@ cr
	puts ("Matriz inicializada ") ;
//@ cr
	imprime () ;
	transpuesta () ;
//@ cr
	puts ("Matriz transpuesta ") ;
//@ cr
	imprime () ;
	
//    system ("pause") ;
}

//@ main



