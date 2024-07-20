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
 
/* print to stdout by default */ 
void tabsimb_dump(FILE * of){  
  int i;
  fprintf(of,"------------ ------- -----------\n");
  fprintf(of,"Name         Type    Declaration\n");
  fprintf(of,"------------ ------- -----------\n");
  for (i=0; i < SIZE; ++i){ 
    if (hash_table[i] != NULL){ 
        list_t *token = hash_table[i];
        while (token != NULL){ 

            fprintf(of,"%-12s ",token->nome_token);
            if (token->tipo_token == TIPO_INT) fprintf(of,"%-8s","inteiro");
            else if (token->tipo_token == TIPO_REAL) fprintf(of,"%-8s","real");
            else if (token->tipo_token == TIPO_LITERAL) fprintf(of,"%-8s","literal");
            else fprintf(of,"%-7s","undef"); // if UNDEF or 0
            if (token->declaracao == PARAMETRO) fprintf(of,"%-10s","parametro");
            if (token->declaracao == VARIAVEL) fprintf(of,"%-10s","variavel");
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


static expressoes *lista_expr[SIZE];  // Lista global e estática

// Inicializa a lista de expressões
void init_lista_expr() {
    for (int i = 0; i < SIZE; i++) {
        lista_expr[i] = NULL;
    }
}

// Insere uma nova expressão na lista na posição especificada
void insert_expr(int index, int num_expressao, int tipo_elem_esquerdo, int tipo_elem_direito, 
                 int val_int_elem_esquerdo, int val_int_elem_direito, 
                 double val_real_elem_esquerdo, double val_real_elem_direito) {
    if (index < 0 || index >= SIZE) {
        fprintf(stderr, "Índice %d fora dos limites.\n", index);
        return;
    }

    // Aloca memória para a nova expressão
    expressoes *nova_expr = (expressoes*) malloc(sizeof(expressoes));
    if (nova_expr == NULL) {
        fprintf(stderr, "Falha na alocação de memória.\n");
        return;
    }

    // Preenche a nova estrutura de expressão
    nova_expr->num_expressao = num_expressao;
    nova_expr->tipo_elem_esquerdo = tipo_elem_esquerdo;
    nova_expr->tipo_elem_direito = tipo_elem_direito;
    nova_expr->val_int_elem_esquerdo = val_int_elem_esquerdo;
    nova_expr->val_int_elem_direito = val_int_elem_direito;
    nova_expr->val_real_elem_esquerdo = val_real_elem_esquerdo;
    nova_expr->val_real_elem_direito = val_real_elem_direito;

    // Substitui o conteúdo da posição especificada
    free(lista_expr[index]); // Libera o antigo valor se houver
    lista_expr[index] = nova_expr;
}

// Busca uma expressão específica na lista
expressoes* lookup_expr(int index) {
    if (index < 0 || index >= SIZE) {
        fprintf(stderr, "Índice %d fora dos limites.\n", index);
        return NULL;
    }

    return lista_expr[index];
}

// Imprime o conteúdo da lista de expressões
void dump_lista_expr(int declarados) {
    for (int i = 0; i < declarados; i++) {
        if (lista_expr[i] != NULL) {
            printf("Posição %d: Expressão %d\n", i, lista_expr[i]->num_expressao);
            printf("  Tipo Esquerdo: %d, Tipo Direito: %d\n", lista_expr[i]->tipo_elem_esquerdo, lista_expr[i]->tipo_elem_direito);
            printf("  Valor Int Esquerdo: %d, Valor Int Direito: %d\n", lista_expr[i]->val_int_elem_esquerdo, lista_expr[i]->val_int_elem_direito);
            printf("  Valor Real Esquerdo: %lf, Valor Real Direito: %lf\n", lista_expr[i]->val_real_elem_esquerdo, lista_expr[i]->val_real_elem_direito);
        } else {
            printf("Posição %d: Vazia\n", i);
        }
    }
}

static lexemas *lista_lex[SIZE];  // Lista global e estática


void init_lista_lex() {
    for (int i = 0; i < SIZE; i++) {
        lista_lex[i] = NULL;
    }
}

void insert_lex(int index, const char* lexema) {

    if (index < 0 || index >= SIZE) {
        fprintf(stderr, "Índice %d fora dos limites.\n", index);
        return;
    }

    // Aloca memória para o novo lexema
    lexemas *novo_lexema = (lexemas*) malloc(sizeof(lexemas));
    if (novo_lexema == NULL) {
        fprintf(stderr, "Falha na alocação de memória.\n");
        return;
    }

    // Copia o lexema para a nova estrutura
    strcpy(novo_lexema->lexema, lexema);
    // Insere o novo lexema na posição especificada
    lista_lex[index] = novo_lexema;
}


char* lookup_lex(int index) {
    if (index < 0 || index >= SIZE) {
        fprintf(stderr, "Índice %d fora dos limites.\n", index);
        return NULL;
    }

    if (lista_lex[index] != NULL) {
        return lista_lex[index]->lexema;
    }

    return NULL; // Não encontrado
}

void dump_lista_lex(int declarados) {
    for (int i = 0; i < declarados; i++) {
        if (lista_lex[i] != NULL) {
            printf("Posição %d: %s\n", i, lista_lex[i]->lexema);
        } else {
            printf("Posição %d: Vazia\n", i);
        }
    }
}