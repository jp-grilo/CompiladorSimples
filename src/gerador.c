#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.h"
#include "gerador.h"

int flag_gerador=0;
int numero_constante=0;;

void iniciaGerador() {
    if(!flag_gerador) {
        geraParametros();
        geraVariaveis();
        geraConstantes();
        flag_gerador++;
    }
    else geraFim();
}

void geraParametros() {
    FILE *geradorout;
    int first_param = 0; // Flag para controlar a impressão da vírgula
    geradorout = fopen("OUT_GERADO.txt", "a");
    if (geradorout == NULL) {
        perror("Erro ao abrir o arquivo");
        return;
    }
    fprintf(geradorout, "@main( ");
    for (int tamanho = 0; tamanho < SIZE; ++tamanho) {
        list_t *token = get_hash_table_entry(tamanho);
        while (token != NULL) {
            if (token->declaracao == PARAMETRO) { // Verificação se é parâmetro para impressão no @main()
                if (first_param) {
                    fprintf(geradorout, ", ");
                }
                first_param++;
                fprintf(geradorout, "%s: ", token->nome_token);
                if (token->tipo_token == TIPO_INT) fprintf(geradorout, "int");
                else if (token->tipo_token == TIPO_REAL) fprintf(geradorout, "real");
                else if (token->tipo_token == TIPO_LITERAL) fprintf(geradorout, "char");
            }
            token = token->next;
        }
    }
    fprintf(geradorout, ") {\n");
    fclose(geradorout);
}

void geraVariaveis() {
    FILE *geradorout;
    geradorout = fopen("OUT_GERADO.txt", "a");
    if (geradorout == NULL) {
        perror("Erro ao abrir o arquivo");
        return;
    }
    for (int tamanho = 0; tamanho < SIZE; ++tamanho) {
        list_t *token = get_hash_table_entry(tamanho);
        while (token != NULL) {
            if (token->declaracao == VARIAVEL) { // Verificação se é variável pra sua declaração
                fprintf(geradorout, "%s: ", token->nome_token);
                if (token->tipo_token == TIPO_INT) fprintf(geradorout, "int = const -1;\n");
                else if (token->tipo_token == TIPO_REAL) fprintf(geradorout, "real = const -1.0;\n");
                else if (token->tipo_token == TIPO_LITERAL) fprintf(geradorout, "char = const 'a';\n");
            }
            token = token->next;
        }
    }
    fclose(geradorout);
}

void geraConstantes(){
    FILE *geradorout;
    geradorout = fopen("OUT_GERADO.txt", "a");
    if (geradorout == NULL) {
        perror("Erro ao abrir o arquivo");
        return;
    }
    char *nome_constante = (char *)malloc(10 * sizeof(char));
    list_t **tabela = get_hash_table();

            
    for (int index=0; index < SIZE; ++index){ 
    if (tabela[index] != NULL){ 
        list_t *token = tabela[index];
        while (token != NULL){ 
            if(token->declaracao==CONSTANTE){
                sprintf(nome_constante, "%s%d", "AUX", numero_constante);
                if(token->tipo_token==CONST_INT)
                    fprintf(geradorout, "%s: int = const %s;\n", nome_constante, token->nome_token);
                else if(token->tipo_token==CONST_REAL)
                    fprintf(geradorout, "%s: float = constf %s;\n", nome_constante, token->nome_token);
                numero_constante++;
            }
            token = token->next;
        }
    }
  }
    free(nome_constante);
    fclose(geradorout);
}

void geraFim(){
    FILE *geradorout;
    geradorout = fopen("OUT_GERADO.txt", "a");
    if (geradorout == NULL) {
        perror("Erro ao abrir o arquivo");
        return;
    }
    fprintf(geradorout, "}");
    fclose(geradorout);
}