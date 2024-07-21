#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.h"
 
void init_hash_table(){
    int i; 
    hash_table = malloc(SIZE * sizeof(list_t*));
    for(i = 0; i < SIZE; i++) hash_table[i] = NULL;
}
 
unsigned int hash(char *key){
    unsigned int hashval = 0;
    for(;*key!='\0';key++) hashval += *key;
    hashval += key[0] % 11 + (key[0] << 3) - key[0];
    return hashval % SIZE;
}
 
void insert(char *name, int len, int type, int declaracao, int lineno){
    unsigned int hashval = hash(name);
    list_t *token = hash_table[hashval];

    while ((token != NULL) && (strcmp(name,token->nome_token) != 0)) token = token->next;
    
    /* variable not yet in table */
    if (token == NULL){
        token = (list_t*) malloc(sizeof(list_t));
        strcpy(token->nome_token, name);  
        /* add to hashtable */
        token->tipo_token = type;
        token->declaracao = declaracao;
        token->lines = (RefList*) malloc(sizeof(RefList));
        token->lines->lineno = lineno;
        token->lines->next = NULL;
        token->next = hash_table[hashval];
        hash_table[hashval] = token; 
        //printf("Inserted %s for the first time with linenumber %d!\n", name, lineno); // error checking
    }
    /* found in table, so just add line number */
    else{
        RefList *linhas = token->lines;
        while (linhas->next != NULL) linhas = linhas->next;
        /* add linenumber to reference list */
        linhas->next = (RefList*) malloc(sizeof(RefList));
        linhas->next->lineno = lineno;
        linhas->next->next = NULL;
        //printf("Found %s again at line %d!\n", name, lineno);
    }
}
 
list_t *lookup(char *name){ /* return symbol if found or NULL if not found */
    unsigned int hashval = hash(name);
    list_t *token = hash_table[hashval];
    while ((token != NULL) && (strcmp(name,token->nome_token) != 0)) 
        token = token->next;
    return token; // NULL is not found
}

int type_lookup(char *name){ /* return symbol if found or NULL if not found */
    unsigned int hashval = hash(name);
    list_t *token = hash_table[hashval];
    while ((token != NULL) && (strcmp(name,token->nome_token) != 0)) 
        token = token->next;
    return token->tipo_token; // NULL is not found
}
 
char *return_type(int type){
    if (type == TIPO_INT) return "INTEIRO";
    else if (type == TIPO_REAL) return "REAL";
    else if (type == TIPO_LITERAL) return "STRING";
    return "NULL";
}

/* print to stdout by default */ 
void tabsimb_dump(FILE * OUTTABELA){  
  fprintf(OUTTABELA,"------------ ------- -----------\n");
  fprintf(OUTTABELA,"Name         Type    Declaration\n");
  fprintf(OUTTABELA,"------------ ------- -----------\n");
  for (int index=0; index < SIZE; ++index){ 
    if (hash_table[index] != NULL){ 
        list_t *token = hash_table[index];
        while (token != NULL){ 

            fprintf(OUTTABELA,"%-12s ",token->nome_token);
            if (token->tipo_token == TIPO_INT) fprintf(OUTTABELA,"%-8s","inteiro");
            else if (token->tipo_token == TIPO_REAL) fprintf(OUTTABELA,"%-8s","real");
            else if (token->tipo_token == TIPO_LITERAL) fprintf(OUTTABELA,"%-8s","string");
            else fprintf(OUTTABELA,"%-7s","undef"); // if UNDEF or 0
            if (token->declaracao == PARAMETRO) fprintf(OUTTABELA,"%-10s","parametro");
            if (token->declaracao == VARIAVEL) fprintf(OUTTABELA,"%-10s","variavel");
            fprintf(OUTTABELA,"\n");
            token = token->next;
        }
    }
  }
}

list_t **get_hash_table() {
    return hash_table;
}

list_t *get_hash_table_entry(int index) {
    if (index >= 0 && index < SIZE) {
        return hash_table[index];
    }
    return NULL;
}

// Variável global para a lista de quadruplas
list_expressoes *lista_expressoes = NULL;

// Inicializa a lista de quadruplas
void init_lista_expressoes() {
    lista_expressoes = NULL;  // Inicializa a lista como vazia
}

// Insere uma nova quadrupla na lista
void insere_expressao(char *operacao, char *arg1, char *arg2, char *resultado) {
    // Aloca memória para a nova quadrupla
    list_expressoes *nova_quadrupla = (list_expressoes*) malloc(sizeof(list_expressoes));
    
    // Preenche os campos da quadrupla
    nova_quadrupla->operacao = strdup(operacao);
    nova_quadrupla->arg1 = strdup(arg1);
    nova_quadrupla->arg2 = strdup(arg2);
    nova_quadrupla->resultado = strdup(resultado);
    
    // Insere a nova quadrupla no início da lista
    nova_quadrupla->next = lista_expressoes;
    lista_expressoes = nova_quadrupla;
}

// Consulta uma quadrupla na lista
list_expressoes* consulta_expressao(char *resultado) {
    list_expressoes *current = lista_expressoes;
    while (current != NULL) {
        if (strcmp(current->resultado, resultado) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;  // Retorna NULL se não encontrar a quadrupla
}

// Realiza o dump de todas as quadruplas na lista
void dump_lista_expressoes() {
    list_expressoes *current = lista_expressoes;
    while (current != NULL) {
        printf("Operacao: %s, Arg1: %s, Arg2: %s, Resultado: %s\n", current->operacao, current->arg1, current->arg2, current->resultado);
        current = current->next;
    }
}