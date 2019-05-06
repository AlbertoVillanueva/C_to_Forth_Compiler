
/* Alberto Villanueva Nieto Cristian Cabrera Pinto 04 */
/* alberto.villanueva@alumnos.uc3m.es 100363778@alumnos.uc3m.es */
%{						  // SECCION 1 Declaraciones de C-Yacc
#include <stdio.h>
#include <string.h>		   // declaraciones para cadenas
#include <stdlib.h>		   // declaraciones para exit ()
void salirFuncion();
typedef struct s_atributos { 
	int valor;
	char *cadena ;
} t_atributos ; 
typedef struct simbolo_t {
	char *nombre;
	char *expresion;
}simbolo;
typedef struct globales_t{
	char* nombre;
	char overlap;//boolean
}globales;
simbolo t_simbolos_matrices [50];
globales var_globales[64];
char* var_locales[64];
int num_matrices = 0;
int isMatrix; //0 no es una matriz y 1 es una matriz
char temp [2048] ;
char funcion [256];
char argumentos[3][256];
int num_argumentos;
int declarando;
int i;
char *genera_cadena () ; 
#define YYSTYPE t_atributos 
%}
%token NUMERO		 // Todos los token tienen un tipo para la pila
%token IDENTIF	   // Identificador=variable
%token INTEGER	   // identifica la definicion de un entero
%token VOID
%token RETURN
%token STRING
%token MAIN		  // identifica el comienzo del proc. main
%token WHILE		 // identifica el bucle main
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
%right '='					// es la ultima operacion que se debe realizar
%right '?' ':'
%left  AND OR '&' '|'
%left EQUAL UNEQUAL
%left '<' LESSOREQ '>' GREATEROREQ
%left '+' '-'				   // menor orden de precedencia
%left '*' '/' '%'				// orden de precedencia intermedio
%left SIGNO_UNARIO			// mayor orden de precedencia
%left POSTFIX
%%
										  // Seccion 3 Gramatica - Semantico
programa:
						{salirFuncion();}
	def_var
	 principal	{ ; }
;

principal:  
	MAIN '(' ')' '{' 		{ sprintf(funcion,"%s-",$1.cadena);}
		def_var				{ printf (": main\n"); }
		codigo '}'  		{ printf (";\n"); salirFuncion(); }
;
  
def_var:
	/* lambda */		{ ; }

	| INTEGER 								{ declarando = 1; }
		restoVariable_funcion def_var
	|VOID IDENTIF 							{
												if(funcion[0] != 0){
													printf("No se permite funciones dentro de funciones\n");
													exit(-1);
												}
												sprintf(funcion,"%s-",$2.cadena);
											}
		'(' argumentos ')' '{' def_var		{
												printf (": %s\n",$2.cadena);
												for(i=0;i<num_argumentos;i++)printf("%s !\n",argumentos[i]);
											}
		codigo '}'							{
												printf (";\n");
												salirFuncion();
											}
		def_var

;
restoVariable_funcion:
	IDENTIF								{
											printf ("variable %s\n",$1.cadena);
											declarando = 0;
										} 
		restoDef_var ';'					{
											if(isMatrix){
												if(num_matrices== 50){
													printf("Creado mas matrices del limite permitido\n");
													return -1;
												}
												t_simbolos_matrices[num_matrices].nombre=genera_cadena($1.cadena);
												num_matrices++;																								
											}
										}
	|IDENTIF '('						{
											if(funcion[0] != 0){
												printf("No se permite funciones dentro de funciones\n");
												exit(-1);
											}
											sprintf(funcion,"%s-",$1.cadena);
											declarando = 0;
										}
		argumentos ')' '{' def_var		{
											printf (": %s\n",$1.cadena);
											for(i=0;i<num_argumentos;i++)printf("%s !\n",argumentos[i]);
										}
		codigo RETURN expresion ';' '}'	{
											printf ("\n%s\n;\n",$11.cadena);
											salirFuncion();
										}
;
argumentos:
	/*lambda*/			{num_argumentos = 0;}
	| INTEGER			{declarando = 1;}
		IDENTIF varios	{
							num_argumentos++;
							sprintf(argumentos[num_argumentos-1],"%s",$3.cadena);
							printf("variable %s\n",argumentos[num_argumentos-1]);
						}
;
varios:	
	/*lambda*/
	|',' INTEGER IDENTIF	{
								num_argumentos++;
								if(num_argumentos>3){
									printf("Error, too many arguments\n");
									return -1;
								}
								sprintf(argumentos[num_argumentos-1],"%s",$3.cadena);
								printf("variable %s\n",argumentos[num_argumentos-1]);
							}
			varios			{ declarando = 0; }
;
restoDef_var:
	/* lambda */ 		{ printf("\n"); } 
	|'[' expresion ']'	{ printf("%s",$2.cadena);} 
		matrix	  
;
matrix:
	/*lambda*/		 	{ printf("1 - cells allot\n"); isMatrix=0; }
	| '[' expresion	']'	{
							isMatrix=1;
							t_simbolos_matrices[num_matrices].expresion=genera_cadena($2.cadena);
					  		printf("%s* cells allot\n",$2.cadena);
						}
;
codigo:
	sentencia
	|sentencia codigo
;
sentencia:
	asignacion';'									{ printf ("%s \n", $1.cadena); } 
	| WHILE 										{ printf ("begin "); }
		'(' expresion ')'							{ printf("%swhile\n",$4.cadena); }
		'{' codigo '}'   							{ printf ("repeat\n") ; } 
	| DO											{ printf("begin\n"); }
		'{' codigo '}' WHILE '(' expresion ')' ';'	{ printf("%swhile repeat \n",$8.cadena); }
	| IF '(' expresion ')'							{ printf("%sif\n",$3.cadena); }
		'{' codigo '}' restoIf						{ printf("then\n"); }
	| PUTS '(' STRING ')' ';'						{ printf(".\" %s\"\n" ,$3.cadena); }
	| PRINTF '(' STRING ',' expresiones ')' ';'
	| FOR '(' asignacion ';' expresion ';'			{ printf("%sbegin %swhile\n",$3.cadena,$5.cadena); }
		 asignacion ')' '{' codigo '}'				{ printf("%srepeat\n",$8.cadena); }
	| IDENTIF '(' funcion_args ')' ';' 				{
														strcpy(temp,$1.cadena);
														strcat(temp,"-");
														//printf("comparo %s con %s\n",temp,funcion);
														if(strcmp(funcion,temp)==0){
															printf("%s\n",$3.cadena);
															for(i=0 ; i<64; i++){
																if(var_locales[i] != NULL){
																	printf("%s @ >r\n",var_locales[i]);
																}
															}
															printf("recurse\n");
															for(i=63 ; i>=0; i--){
																if(var_locales[i] != NULL){
																	printf("r> %s !\n",var_locales[i]);
																}
															}
														}else{
															printf("%s\n%s ",$3.cadena,$1.cadena);
														}
														$$.cadena = genera_cadena(temp);
													}											
;

asignacion:
	IDENTIF '=' expresion											{ sprintf(temp,"%s%s !\n",$3.cadena, $1.cadena); $$.cadena=genera_cadena(temp); }
	| IDENTIF '[' expresion ']' '=' expresion						{ sprintf(temp, "%s%s swap cells %s + !\n", $3.cadena, $6.cadena, $1.cadena); $$.cadena=genera_cadena(temp); }
	| IDENTIF '[' expresion ']' '[' expresion ']' '=' expresion		{   
																		for(i=0;strcmp($1.cadena, t_simbolos_matrices[i].nombre)!=0;1++){
																			if(i==50){
																				printf("Error, matrix doesnt exist\n");
																				return -1;
																			}
																		}
																		sprintf(temp, "%s%s%s* %s+ cells %s + !\n", $9.cadena, $3.cadena, t_simbolos_matrices[i].expresion, $6.cadena, $1.cadena);
																		$$.cadena=genera_cadena(temp);  
																	}
;
expresiones:
	/*lambda*/
	| expresion { printf("%s.\n",$1.cadena); }
	| expresion { printf("%s. ",$1.cadena); }
		',' expresiones
;
restoIf:
	/* lambda */ 
	| ELSE 				{printf("else\n");}
		'{' codigo '}'
;
expresion:
	termino									{ $$=$1; }
	| expresion  '+' expresion				{ sprintf(temp,"%s%s+ ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '-' expresion				{ sprintf(temp,"%s%s- ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '*' expresion				{ sprintf(temp,"%s%s* ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '/' expresion				{ sprintf(temp,"%s%s/ ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  EQUAL expresion			{ sprintf(temp,"%s%s= ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  UNEQUAL expresion			{ sprintf(temp,"%s%s= 0= ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  LESSOREQ expresion			{ sprintf(temp,"%s%s<= ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  GREATEROREQ expresion		{ sprintf(temp,"%s%s>= ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '<' expresion				{ sprintf(temp,"%s%s < ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '>' expresion				{ sprintf(temp,"%s%s> ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '&' expresion				{ sprintf(temp,"%s%sand ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '|' expresion				{ sprintf(temp,"%s%sor ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  AND expresion				{ sprintf(temp,"%s%sand ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  OR expresion				{ sprintf(temp,"%s%sor ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion  '%' expresion				{ sprintf(temp,"%s%smod ",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
	| expresion '?' expresion ':' expresion { sprintf(temp,"%sif\n%s\nelse\n%s\nthen\n",$1.cadena,$3.cadena,$5.cadena); $$.cadena = genera_cadena(temp); }
;

termino:
	operando								{ $$=$1; }
	| '+' operando %prec SIGNO_UNARIO		{ $$=$2; }
	| '-' operando %prec SIGNO_UNARIO		{ sprintf (temp,"%snegate ",$2.cadena);$$.cadena=genera_cadena(temp); }
	| '!' operando %prec SIGNO_UNARIO		{ sprintf (temp,"%s0= ",$2.cadena);$$.cadena=genera_cadena(temp); }
	| operando ADDER %prec POSTFIX			{ sprintf (temp,"%s1+ ",$2.cadena);$$.cadena=genera_cadena(temp); }
	| operando SUBSTRACTER %prec POSTFIX	{ sprintf (temp,"%s1- ",$2.cadena);$$.cadena=genera_cadena(temp); }
;

operando:
	IDENTIF	  											{ sprintf (temp,"%s @ ",$1.cadena); $$.cadena=genera_cadena(temp); }
	| IDENTIF '[' expresion ']'							{ sprintf (temp,"%s cells %s + @ ", $3.cadena, $1.cadena); $$.cadena = genera_cadena(temp) ; }
	| IDENTIF '[' expresion ']' '[' expresion ']'		{
															for(i=0 ; strcmp($1.cadena, t_simbolos_matrices[i].nombre)!=0 ; i++){
																if(i==50){
																	printf("Error, matrix doesnt exist\n");
																	return -1;
																}
															}
															sprintf(temp, "%s%s* %s+ cells %s + @ ", $3.cadena, t_simbolos_matrices[i].expresion, $6.cadena,$1.cadena);
															$$.cadena=genera_cadena(temp);
														}
	| NUMERO											{ sprintf(temp,"%d ",$1.valor); $$.cadena = genera_cadena(temp); }
	| '(' expresion ')'									{ $$=$2; }
	| IDENTIF '(' funcion_args ')' 						{
															strcpy(temp,$1.cadena);
															strcat(temp,"-");
															//printf("comparo %s con %s\n",temp,funcion);
															if(strcmp(funcion,temp)==0){
																sprintf(temp,"%s\n",$3.cadena);
																for(i=0 ; i<64; i++){
																	if(var_locales[i] != NULL){
																		strcat(temp,var_locales[i]);
																		strcat(temp," @ >r\n");
																	}
																}
																strcat(temp,"recurse\n");
																for(i=63 ; i>=0; i--){
																	if(var_locales[i] != NULL){
																		strcat(temp,"r> ");
																		strcat(temp,var_locales[i]);
																		strcat(temp," !\n");
																	}
																}
															}else{
																sprintf(temp,"%s\n%s ",$3.cadena,$1.cadena);
															}
															
															
															$$.cadena = genera_cadena(temp);
														}
;
funcion_args:
	/*lambda*/
	| expresion { sprintf(temp,"%s\n",$1.cadena); $$.cadena = genera_cadena(temp); }
	| expresion ',' funcion_args{ sprintf(temp,"%s\n%s",$1.cadena,$3.cadena); $$.cadena = genera_cadena(temp); }
;
%%
							// SECCION 4	Codigo en C
int n_linea = 1 ;

// los cambios necesarios para cuando sales de una funcion
void salirFuncion(){
	funcion[0] = 0;
	for(i=0;i<64;i++){
		var_globales[i].overlap=0;
		if(var_locales[i]!=NULL){
			free(var_locales[i]);
			var_locales[i] = NULL;
		}
	}
	num_argumentos = 0;
}
int yyerror (mensaje)
char *mensaje ;
{
	fprintf (stderr, "%s en la linea %d\n", mensaje, n_linea) ;
	printf ( "bye\n") ;
}

char *mi_malloc (int nbytes)	   // reserva n bytes de memoria dinamica
{
	char *p ;
	static long int nb = 0;		// sirven para contabilizar la memoria
	static int nv = 0 ;			// solicitada en total

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
	"main",		MAIN,		   // y los token asociados
	"int",		 INTEGER,
	"void",		VOID,
	"return",	RETURN,
	"while",	   WHILE,
	"do",		   DO,
	"if",		   IF,	  
	"else",		 ELSE,
	"for",		 FOR,
	"puts",		 PUTS,
	"printf",	   PRINTF,
	"==",		   EQUAL,
	"!=",		   UNEQUAL,
	"<=",		   LESSOREQ,
	">=",		   GREATEROREQ,
	"&&",		   AND,
	"||",		   OR,
	"++",		   ADDER,
	"--",		   SUBSTRACTER,
	NULL,		  0			   // para marcar el fin de la tabla
} ;

t_reservada *busca_pal_reservada (char *nombre_simbolo)
{								  // Busca n_s en la tabla de pal. res.
								   // y devuelve puntero a registro (simbolo)
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

char *genera_cadena (char *nombre)	 // copia el argumento a un
{									  // string en memoria dinamica
	  char *p ;
	  int l ;

	  l = strlen (nombre)+1 ;
	  p = (char *) mi_malloc (l) ;
	  strcpy (p, nombre) ;

	  return p ;
}


int yylex ()
{
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
//		 printf ("\nDEV: NUMERO %d\n", yylval.valor) ;		// PARA DEPURAR
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
		 simbolo = busca_pal_reservada (cadena) ;
		 if (simbolo == NULL) {	// no es palabra reservada -> identificador 
//			   printf ("\nDEV: IDENTIF %s\n", yylval.cadena) ;	// PARA DEPURAR
				// si no estamos en una funcion añadimos la variable como variable global
				if(funcion[0] == 0){
					for(i=0 ; i<64 ; i++){
						if(var_globales[i].nombre==NULL){
							var_globales[i].nombre = genera_cadena(cadena);
							yylval.cadena = var_globales[i].nombre;
							return (IDENTIF) ;
						}
					}
					printf("Demasiadas variables globales\n");
				}else{
					
					sprintf(temp,"%s%s",funcion,cadena);
					if(!declarando){
						//si no estamos declarando una variable y es una variable global la referenciamos
						for(i=0 ; i<64 ; i++){
							if(!var_globales[i].overlap && var_globales[i].nombre != NULL && strcmp(var_globales[i].nombre,cadena)==0){
								yylval.cadena = var_globales[i].nombre;
								return (IDENTIF) ;
							}
						}
						//si no estamos declarando una variable y es una variable local la referenciamos
						for(i=0 ; i<64 ; i++){
							if(var_locales[i] != NULL && strcmp(var_locales[i],temp)==0){
								yylval.cadena = var_locales[i];
								return (IDENTIF) ;
							}
						}
					}
					//si estamos declarando una variable y existe una variable global con el mismo nombre decimos que esa variable global tiene overlap
					for(i=0 ; i<64 ; i++){
						if(var_globales[i].nombre != NULL && strcmp(var_globales[i].nombre,cadena)==0){
							var_globales[i].overlap = 1;
							break;
						}
					}
					//buscamos una posicion vacia y lo añadimos como variable local
					for(i=0 ; i<64 ; i++){
						if(var_locales[i] == NULL){
							var_locales[i] = genera_cadena(temp);
							yylval.cadena = var_locales[i];
							return (IDENTIF) ;
						}
					}
					printf("Demasiadas variables locales");
				}
		 } else {
//			   printf ("\nDEV: OTRO %s\n", yylval.cadena) ;	   // PARA DEPURAR
			   yylval.cadena = genera_cadena (cadena) ;
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

//	printf ("\nDEV: LITERAL %d #%c#\n", (int) c, c) ;	  // PARA DEPURAR
	if (c == EOF || c == 255 || c == 26) {
//		 printf ("tEOF ") ;								// PARA DEPURAR
		 return (0) ;
	}

	return c ;
}


int main ()
{
	yyparse () ;
}



