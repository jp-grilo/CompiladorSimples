#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.h"
#include "gerador.h"

void iniciaGerador() {
    remove("codigo_gerado.txt");
    geraParametros();
    geraVariaveis();
}

void geraParametros() {
    FILE *geradorout;
    int first_param = 0; // Flag para controlar a impressão da vírgula
    geradorout = fopen("codigo_gerado.txt", "a");
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
    geradorout = fopen("codigo_gerado.txt", "a");
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
