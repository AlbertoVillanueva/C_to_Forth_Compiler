main(){
	int i;
	int j;
	int k;
	//@ cr
	for (i = 0; i < 3; i=i+1){
		printf("",i);
		for (j = 0; j < 3; j=j+1){
			puts("    ");
			printf("",j);
			//@ cr
			puts("        ");
			for (k = 0; k < 3; k=k+1){
				printf("",k);
			}
			//@ cr
		}
	}
	
}
//@ main

