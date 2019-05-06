#include	<stdio.h> 
#include	<stdlib.h>
#include	<string.h>
#include	"stack.h"

Stack newStack(){
	Stack stack;
	stack.head = NULL;
	return stack;
}

void push(Stack* stack, void* data, int size){
	Node* newNode = (Node*)malloc(sizeof(Node));
	newNode->next = stack->head;
	newNode->data = malloc(size);

	stack->head = newNode;

	int i;
	for (i=0; i<size; i++) 
		((char*)newNode->data)[i] = ((char*)data)[i];
}
void* pop(Stack* stack){
	Node* temp = stack->head;
	stack->head = stack->head->next;
	return temp;
}
void empty(Stack* stack){
	while(!isEmpty(stack)){
		free(pop(stack));
	}
}
int isEmpty(Stack* stack){
	return stack->head==NULL;
}
simbolo* getMatrix(Stack* stack,char* name){
	Node* temp = stack->head;
	while(temp!=NULL){
		if(strcmp(((simbolo*)temp->data)->nombre,name)==0){
			return (simbolo*)temp;
		}
		temp = temp->next;
	}
}