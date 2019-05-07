int factorial(int n){
	int retorno;
	if(n==1){
		retorno = 1;
	}else{
		retorno = n*factorial(n-1);
	}
	return retorno;
}

main ()
{
	int resultado;
	resultado = factorial(7);
    printf("%d\n", resultado) ;
}

//@ main cr

