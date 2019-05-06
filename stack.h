#ifndef _STACK_H_
#define _STACK_H_

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

typedef struct node_t{
	void* data;
	struct node_t* next;
}Node;

typedef struct{
	Node* head;
}Stack;

typedef struct simbolo_t {
	char *nombre;
	char *expresion;
}simbolo;
typedef struct globales_t{
	char* nombre;
	char overlap;//boolean
}globales;

Stack newQueue();
void push(Stack* stack, void* data, int size);
void* pop(Stack* stack);
void empty(Stack* stack);
int isEmpty(Stack* stack);
simbolo* getMatrix(Stack* stack,char* name);
#endif
