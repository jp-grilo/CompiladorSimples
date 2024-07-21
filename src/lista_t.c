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
  fprintf(OUTTABELA,"-------------- ------------ -----------\n");
  fprintf(OUTTABELA,"Name           Type         Declaration\n");
  fprintf(OUTTABELA,"-------------- ------------ -----------\n");
  for (int index=0; index < SIZE; ++index){ 
    if (hash_table[index] != NULL){ 
        list_t *token = hash_table[index];
        while (token != NULL){ 
            // Print nome
            fprintf(OUTTABELA,"%-14s ",token->nome_token);
            // Print tipo
            if (token->tipo_token == TIPO_INT) fprintf(OUTTABELA,"%-13s","inteiro");
            else if (token->tipo_token == TIPO_REAL) fprintf(OUTTABELA,"%-13s","real");
            else if (token->tipo_token == TIPO_LITERAL) fprintf(OUTTABELA,"%-13s","string");
            else if (token->tipo_token == CONST_INT) fprintf(OUTTABELA,"%-13s","const int");
            else if (token->tipo_token == CONST_REAL) fprintf(OUTTABELA,"%-13s","const real");
            else if (token->tipo_token == CONST_LITERAL) fprintf(OUTTABELA,"%-13s","const lit");
            else fprintf(OUTTABELA,"%-7s","undef"); // if UNDEF or 0
            // Print declaracao
            if (token->declaracao == PARAMETRO) fprintf(OUTTABELA,"%-10s","parametro");
            else if (token->declaracao == VARIAVEL) fprintf(OUTTABELA,"%-10s","variavel");
            else if (token->declaracao == CONSTANTE) fprintf(OUTTABELA,"%-10s","constante");
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

list_expressoes *lista_expressoes = NULL;

list_expressoes* criar_expressoes(char *operacao, char *arg1, char *arg2, int resultado, int tipo_associado) {
    list_expressoes* nova_exp = (list_expressoes*)malloc(sizeof(list_expressoes));
    if (nova_exp == NULL) {
        fprintf(stderr, "Erro ao alocar memória para list_expressoes\n");
        exit(1);
    }

    // Aloca e copia as strings para os campos operacao, arg1 e arg2, tratando casos de NULL
    nova_exp->operacao = (operacao != NULL) ? strdup(operacao) : NULL;
    nova_exp->arg1 = (arg1 != NULL) ? strdup(arg1) : NULL;
    nova_exp->arg2 = (arg2 != NULL) ? strdup(arg2) : NULL;
    nova_exp->resultado = resultado;
    nova_exp->tipo_associado = tipo_associado;
    nova_exp->next = NULL;

    return nova_exp;
}

void adicionar_expressoes(char *operacao, char *arg1, char *arg2, int resultado, int tipo_associado) {
    list_expressoes *nova_exp = criar_expressoes(operacao, arg1, arg2, resultado, tipo_associado);
    if (lista_expressoes == NULL) {
        lista_expressoes = nova_exp;
    } else {
        list_expressoes *atual = lista_expressoes;
        while (atual->next != NULL) {
            atual = atual->next;
        }
        atual->next = nova_exp;
    }
}

list_expressoes* buscar_expressoes_por_resultado(int resultado) {
    list_expressoes *atual = lista_expressoes;

    while (atual != NULL) {
        if (atual->resultado == resultado) {
            return atual; // Retorna o ponteiro para a quadrupla encontrada
        }
        atual = atual->next;
    }
    return NULL; // Retorna NULL se não encontrar a quadrupla
}

void liberar_lista() {
    list_expressoes *atual = lista_expressoes;
    list_expressoes *proximo;

    while (atual != NULL) {
        proximo = atual->next;
        free(atual->operacao);
        free(atual->arg1);
        free(atual->arg2);
        free(atual);
        atual = proximo;
    }

    lista_expressoes = NULL; // Define o ponteiro global para NULL após liberar
}

void dump_lista() {
    list_expressoes *atual = lista_expressoes;

    while (atual != NULL) {
        printf("Operacao: %s, Arg1: %s, Arg2: %s, Resultado: %d, Tipo Associado: %d\n",
               atual->operacao ? atual->operacao : "NULL",
               atual->arg1 ? atual->arg1 : "NULL",
               atual->arg2 ? atual->arg2 : "NULL",
               atual->resultado,
               atual->tipo_associado);
        atual = atual->next;
    }
}

// Função para imprimir um elemento específico da lista
void dump_expr_element(const list_expressoes *element) {
    if (element == NULL) {
        printf("Elemento é NULL.\n");
        return;
    }
    printf("Elemento:\n");
    printf("Operacao: %s\n", element->operacao ? element->operacao : "NULL");
    printf("Arg1: %s\n", element->arg1 ? element->arg1 : "NULL");
    printf("Arg2: %s\n", element->arg2 ? element->arg2 : "NULL");
    printf("Resultado: %d\n", element->resultado);
    printf("Tipo Associado: %d\n\n", element->tipo_associado);
}