
/* Alberto Villanueva Nieto Cristian Cabrera Pinto 04 */
/* alberto.villanueva@alumnos.uc3m.es 100363778@alumnos.uc3m.es */
%{                          // SECCION 1 Declaraciones de C-Yacc
#include <stdio.h>
#include <string.h>           // declaraciones para cadenas
#include <stdlib.h>           // declaraciones para exit ()
#define FF fflush(stdout);    // para forzar la impresion inmediata
typedef struct s_atributos { 
    int valor;
    char *cadena ; 
} t_atributos ; 
typedef struct simbolo_t {
    char *nombre;
    char *expresion;
}simbolo;

simbolo t_simbolos_matrices [50];
int num_matrices = 0;
int isMatrix; //0 no es una matriz y 1 es una matriz
char temp [2048] ; 
char *genera_cadena () ; 
#define YYSTYPE t_atributos 
%}
%token NUMERO         // Todos los token tienen un tipo para la pila
%token IDENTIF       // Identificador=variable
%token INTEGER       // identifica la definicion de un entero
%token STRING
%token MAIN          // identifica el comienzo del proc. main
%token WHILE         // identifica el bucle main
%token DO
%token IF
%token ELSE
%token FOR
%token PUTS
%token PRINTF
%token EQUAL
%token UNEQUAL
%token LESSOREQ
%token GREATEROREQ
%token AND
%token OR
%token ADDER
%token SUBSTRACTER
%right '='                    // es la ultima operacion que se debe realizar
%right '?' ':'
%left  AND OR '&' '|'
%left EQUAL UNEQUAL
%left '<' LESSOREQ '>' GREATEROREQ
%left '+' '-'                   // menor orden de precedencia
%left '*' '/' '%'                // orden de precedencia intermedio
%left SIGNO_UNARIO            // mayor orden de precedencia
%left POSTFIX
%%
                                          // Seccion 3 Gramatica - Semantico
programa:      def_var principal 		{ ; }
             ;

principal:     MAIN				
                 '(' ')' '{' def_var    { 
                                            printf (": main \n"); 
                                            FF; 
                                        }
                 codigo '}'  		    { 
                                            printf (";\n"); 
                                            FF; 
                                        }
                 ;
  
def_var:     /* lambda */		{ ; }
             | INTEGER IDENTIF  { 
                                    printf ("variable %s ", $2.cadena); 
                                    FF; 
                                } 
             restoDef_var       {   
                                    if(isMatrix==1){
                                        t_simbolos_matrices[num_matrices].nombre=genera_cadena($2.cadena);
                                        num_matrices++;                                                                                                
                                    }
                                }
               ';' def_var
             ;
restoDef_var: /* lambda */ 		{ 
                                    printf("\n"); 
                                } 
             | '[' expresion    {
                                    printf("%s",$2.cadena);
                                } 
                ']'  matrix      
             ;
matrix:      /*lambda*/         { 
                                    printf("1 - cells allot\n"); 
                                    isMatrix=0;
                                }
             | '[' expresion    {
                                    isMatrix=1; 
                                    t_simbolos_matrices[num_matrices].expresion=genera_cadena($2.cadena);
                                }
               ']'              { 
                                    printf("* cells allot\n"); 
                                }
             ;
codigo:               /* lambda */ 		                        { ; }
             | asignacion';'	                                { 
                                                                    printf ("%s \n", $1.cadena); 
                                                                    FF; 
                                                                }
                 codigo 
             | WHILE 				                            { 
                                                                    printf ("begin ") ; 
                                                                }
		        '(' expresion                                   {
                                                                    printf("%s",$4.cadena);
                                                                } 
                ')' 		                                    { 
                                                                    printf (" while\n") ; 
                                                                }
		        '{' codigo '}'   		                        { 
                                                                    printf ("repeat\n") ; 
                                                                }
                 codigo 
             |  DO                                              {
                                                                    printf("begin\n");
                                                                    FF;
                                                                }
                '{' codigo '}' WHILE '(' expresion              {
                                                                    printf("%s",$8.cadena);
                                                                }
                ')' ';'                                         {
                                                                    printf("while repeat \n");
                                                                    FF;
                                                                }
                codigo
             |  IF '(' expresion                                 {
                                                                    printf("%s",$3.cadena);
                                                                } 
                ')'                                             {
                                                                    printf("if\n");
                                                                } 
                '{' codigo '}' restoIf                          {
                                                                    printf("then\n");
                                                                }
                codigo
             |  PUTS '(' STRING ')' ';'                         {
                                                                    printf(".\" %s\"\n" ,$3.cadena);
                                                                } 
                codigo
             |  PRINTF '(' STRING ',' expresiones ')' ';' codigo
             |  FOR '(' asignacion ';'                          {
                                                                    printf("%s begin",$3.cadena); 
                                                                } 
                expresion                                       {
                                                                    printf("%s while\n",$6.cadena);
                                                                }
                ';' asignacion ')' '{' codigo                   {
                                                                    printf("%s repeat\n",$9.cadena);
                                                                }
                '}' codigo
             ;

asignacion:  IDENTIF '=' expresion                                          { 
                                                                                sprintf (temp,"%s %s !\n",$3.cadena, $1.cadena); 
                                                                                $$.cadena=genera_cadena(temp) ; 
                                                                            }
             | IDENTIF '[' expresion ']' '=' expresion                      {
                                                                                sprintf(temp, "%s %s swap cells %s + !\n", $3.cadena, $6.cadena, $1.cadena); 
                                                                                $$.cadena=genera_cadena(temp);
                                                                            }
             | IDENTIF '[' expresion ']' '[' expresion ']' '=' expresion    {   
                                                                                int i = 0;                                                                            
                                                                                while(strcmp($1.cadena, t_simbolos_matrices[i].nombre)!=0){
                                                                                    i++;
                                                                                }
                                                                        
                                                                                sprintf(temp, "%s %s %s * %s + cells %s + !\n", $9.cadena, $3.cadena, t_simbolos_matrices[i].expresion, $6.cadena, $1.cadena);
                                                                                $$.cadena=genera_cadena(temp);  
                                                                            }
             ;
expresiones: /*lambda*/
            | expresion  {  
                            printf("%s",$1.cadena);
                        } 
                        {
                            printf(".\n");
                        }
            | expresion {
                            printf("%s",$1.cadena);
                        } 
                        {
                            printf(". ");
                        }
            ',' expresiones;
restoIf:     /* lambda */ 
             | ELSE {printf("else\n");}'{' codigo '}';
expresion:     termino				{ $$=$1; }
             | expresion  '+' expresion		    {
                                                    sprintf(temp,"%s %s + ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '-' expresion		    {
                                                    sprintf(temp,"%s %s - ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '*' expresion		    {
                                                    sprintf(temp,"%s %s * ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '/' expresion		    {
                                                    sprintf(temp,"%s %s / ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  EQUAL expresion	    {
                                                    sprintf(temp,"%s %s = ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  UNEQUAL expresion	    {
                                                    sprintf(temp,"%s %s = 0= ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  LESSOREQ expresion	{
                                                    sprintf(temp,"%s %s <= ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  GREATEROREQ expresion	{
                                                    sprintf(temp,"%s %s >= ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '<' expresion		    {
                                                    sprintf(temp,"%s %s < ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '>' expresion	        {
                                                    sprintf(temp,"%s %s > ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '&' expresion		    {
                                                    sprintf(temp,"%s %s and ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '|' expresion		    {
                                                    sprintf(temp,"%s %s or ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  AND expresion	        {
                                                    sprintf(temp,"%s %s and ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  OR expresion	        {
                                                    sprintf(temp,"%s %s or ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion  '%' expresion		    {
                                                    sprintf(temp,"%s %s mod ",$1.cadena,$3.cadena);
                                                    $$.cadena = genera_cadena(temp);
                                                }
             | expresion '?' expresion ':' expresion {
                                                        sprintf(temp,"%s if\n%s\nelse\n%s\nthen\n",$1.cadena,$3.cadena,$5.cadena);
                                                        $$.cadena = genera_cadena(temp);
                                                     }
             ;

termino:       operando				                { $$=$1; }
             | '+' operando %prec SIGNO_UNARIO	    { $$=$2; }
             | '-' operando %prec SIGNO_UNARIO	    { sprintf (temp,"%s negate ",$2.cadena);$$.cadena=genera_cadena(temp); }
             | '!' operando %prec SIGNO_UNARIO      { sprintf (temp,"%s 0= ",$2.cadena);$$.cadena=genera_cadena(temp); }
             | operando ADDER %prec POSTFIX         { sprintf (temp,"%s 1+ ",$2.cadena);$$.cadena=genera_cadena(temp); }
             | operando SUBSTRACTER %prec POSTFIX   { sprintf (temp,"%s 1- ",$2.cadena);$$.cadena=genera_cadena(temp); }
             ;

operando:      IDENTIF      		                            { 
                                                                    sprintf (temp,"%s @ ", $1.cadena);
                                                                    $$.cadena=genera_cadena(temp); 
                                                                }
             | IDENTIF '[' expresion ']'                        { 
                                                                    sprintf (temp,"%s cells %s + @ ", $3.cadena, $1.cadena);
                                                                    $$.cadena = genera_cadena(temp) ; 
                                                                }
            | IDENTIF '[' expresion ']' '[' expresion ']'       {
                                                                    int i = 0;
                                                                    while(strcmp($1.cadena, t_simbolos_matrices[i].nombre)!=0){
                                                                        i++;
                                                                    }
                                                                    sprintf(temp, "%s %s * %s + cells %s +", $3.cadena, t_simbolos_matrices[i].expresion, $6.cadena,$1.cadena);
                                                                    $$.cadena=genera_cadena(temp);
                                                                }
             | NUMERO				                            {
                                                                    sprintf(temp,"%d ",$1.valor);
                                                                    $$.cadena = genera_cadena(temp);
                                                                }
             | '(' expresion ')'		{ $$=$2; }
             ;

%%
                            // SECCION 4    Codigo en C
int n_linea = 1 ;

int yyerror (mensaje)
char *mensaje ;
{
    fprintf (stderr, "%s en la linea %d\n", mensaje, n_linea) ;
    printf ( "bye\n") ;
}

char *mi_malloc (int nbytes)       // reserva n bytes de memoria dinamica
{
    char *p ;
    static long int nb = 0;        // sirven para contabilizar la memoria
    static int nv = 0 ;            // solicitada en total

    p = malloc (nbytes) ;
    if (p == NULL) {
         fprintf (stderr, "No queda memoria para %d bytes mas\n", nbytes) ;
         fprintf (stderr, "Reservados %ld bytes en %d llamadas\n", nb, nv) ;
         exit (0) ;
    }
    nb += (long) nbytes ;
    nv++ ;

    return p ;
}


/***************************************************************************/
/********************** Seccion de Palabras Reservadas *********************/
/***************************************************************************/

typedef struct s_pal_reservadas { // para las palabras reservadas de C
    char *nombre ;
    int token ;
} t_reservada ;

t_reservada pal_reservadas [] = { // define las palabras reservadas y los
    "main",        MAIN,           // y los token asociados
    "int",         INTEGER,
    "while",       WHILE,
    "do",           DO,
    "if",           IF,      
    "else",         ELSE,
    "for",         FOR,
    "puts",         PUTS,
    "printf",       PRINTF,
    "==",           EQUAL,
    "!=",           UNEQUAL,
    "<=",           LESSOREQ,
    ">=",           GREATEROREQ,
    "&&",           AND,
    "||",           OR,
    "++",           ADDER,
    "--",           SUBSTRACTER,
    NULL,          0               // para marcar el fin de la tabla
} ;

t_reservada *busca_pal_reservada (char *nombre_simbolo)
{                                  // Busca n_s en la tabla de pal. res.
                                   // y devuelve puntero a registro (simbolo)
    int i ;
    t_reservada *sim ;

    i = 0 ;
    sim = pal_reservadas ;
    while (sim [i].nombre != NULL) {
           if (strcmp (sim [i].nombre, nombre_simbolo) == 0) {
                                         // strcmp(a, b) devuelve == 0 si a==b
                 return &(sim [i]) ;
             }
           i++ ;
    }

    return NULL ;
}

 
/***************************************************************************/
/******************* Seccion del Analizador Lexicografico ******************/
/***************************************************************************/

char *genera_cadena (char *nombre)     // copia el argumento a un
{                                      // string en memoria dinamica
      char *p ;
      int l ;

      l = strlen (nombre)+1 ;
      p = (char *) mi_malloc (l) ;
      strcpy (p, nombre) ;

      return p ;
}


int yylex ()
{
    int i ;
    unsigned char c ;
    unsigned char cc ;
    char ops_expandibles [] = "!|<=>%+-/*&" ;
    char cadena [256] ;
    t_reservada *simbolo ;

    do {
    	c = getchar () ;

		if (c == '#') {	// Ignora las lineas que empiezan por #  (#define, #include)
			do {		//	OJO que puede funcionar mal si una linea contiene #
			 c = getchar () ;	
			} while (c != '\n') ;
		}
		
		if (c == '/') {	// Si la linea contiene un / puede ser inicio de comentario
			cc = getchar () ;
			if (cc != '/') {   // Si el siguiente char es /  es un comentario, pero...
				ungetc (cc, stdin) ;
		 } else {
		     c = getchar () ;	// ...
		     if (c == '@') {	// Si es la secuencia //@  ==> transcribimos la linea
		          do {		// Se trata de codigo inline (Codigo Forth embebido en C)
		              c = getchar () ;
		              putchar (c) ;
		          } while (c != '\n') ;
		     } else {		// ==> comentario, ignorar la linea
		          while (c != '\n') {
		              c = getchar () ;
		          }
		     }
		 }
		}
		
		if (c == '\n')
		 n_linea++ ;
		
    } while (c == ' ' || c == '\n' || c == 10 || c == 13 || c == '\t') ;

    if (c == '\"') {
         i = 0 ;
         do {
             c = getchar () ;
             cadena [i++] = c ;
         } while (c != '\"' && i < 255) ;
         if (i == 256) {
              printf ("AVISO: string con mas de 255 caracteres en linea %d\n", n_linea) ;
         }		 	// habria que leer hasta el siguiente " , pero, y si falta?
         cadena [--i] = '\0' ;
         yylval.cadena = genera_cadena (cadena) ;
         return (STRING) ;
    }

    if (c == '.' || (c >= '0' && c <= '9')) {
         ungetc (c, stdin) ;
         scanf ("%d", &yylval.valor) ;
//         printf ("\nDEV: NUMERO %d\n", yylval.valor) ;        // PARA DEPURAR
         return NUMERO ;
    }

    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
         i = 0 ;
         while (((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
                 (c >= '0' && c <= '9') || c == '_') && i < 255) {
             cadena [i++] = tolower (c) ;
             c = getchar () ;
         }
         cadena [i] = '\0' ;
         ungetc (c, stdin) ;

         yylval.cadena = genera_cadena (cadena) ;
         simbolo = busca_pal_reservada (yylval.cadena) ;
         if (simbolo == NULL) {    // no es palabra reservada -> identificador 
//               printf ("\nDEV: IDENTIF %s\n", yylval.cadena) ;    // PARA DEPURAR
               return (IDENTIF) ;
         } else {
//               printf ("\nDEV: OTRO %s\n", yylval.cadena) ;       // PARA DEPURAR
               return (simbolo->token) ;
         }
    }

    if (strchr (ops_expandibles, c) != NULL) { // busca c en ops_expandibles
         cc = getchar () ;
         sprintf (cadena, "%c%c", (char) c, (char) cc) ;
         simbolo = busca_pal_reservada (cadena);
         if (simbolo == NULL) {
              ungetc (cc, stdin) ;
              yylval.cadena = NULL ;
              return (c) ;
         } else {
              yylval.cadena = genera_cadena (cadena) ; // aunque no se use
              return (simbolo->token) ;
         }
    }

//    printf ("\nDEV: LITERAL %d #%c#\n", (int) c, c) ;      // PARA DEPURAR
    if (c == EOF || c == 255 || c == 26) {
//         printf ("tEOF ") ;                                // PARA DEPURAR
         return (0) ;
    }

    return c ;
}


int main ()
{
    yyparse () ;
}



