#include <stdio.h>

int mimatriz [5][5] ;
int i ;
int j ;
int aux ;


main () {
	puts ("Matriz sin inicializar ") ;
//@ cr
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

	i = 0 ;
	while (i < 5) {
		j = 0 ;
		while (j < 5) {
			mimatriz [i][j] = i + 2*j ;
			j = j + 1 ;
		}
		i = i + 1 ;
	}	
//@ cr
	puts ("Matriz inicializada ") ;
//@ cr
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

//@ cr
	puts ("Matriz transpuesta ") ;
//@ cr
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
	
//    system ("pause") ;
}

//@ main



