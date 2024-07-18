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
    while ((token != NULL) && (strcmp(name,token->nome_token) != 0)) token = token->next;
    return token; // NULL is not found
}
 
/* print to stdout by default */ 
void tabsimb_dump(FILE * of){  
  int i;
  fprintf(of,"------------ ------- ----------- ------------\n");
  fprintf(of,"Name         Type    Declaration Line Numbers\n");
  fprintf(of,"------------ ------- ----------- ------------\n");
  for (i=0; i < SIZE; ++i){ 
    if (hash_table[i] != NULL){ 
        list_t *token = hash_table[i];
        while (token != NULL){ 
            RefList *linhas = token->lines;
            fprintf(of,"%-12s ",token->nome_token);
            if (token->tipo_token == TIPO_INT) fprintf(of,"%-8s","inteiro");
            else if (token->tipo_token == TIPO_REAL) fprintf(of,"%-8s","real");
            else if (token->tipo_token == TIPO_LITERAL) fprintf(of,"%-8s","literal");
            else fprintf(of,"%-7s","undef"); // if UNDEF or 0
            if (token->declaracao == PARAMETRO) fprintf(of,"%-10s","parametro");
            if (token->declaracao == VARIAVEL) fprintf(of,"%-10s","variavel");
            while (linhas != NULL){
                fprintf(of,"%4d ",linhas->lineno);
                linhas = linhas->next;
            }
            fprintf(of,"\n");
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