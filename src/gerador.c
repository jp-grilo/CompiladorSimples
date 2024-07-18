#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.h"
#include "gerador.h"

void iniciaGerador() {
    remove("codigo_gerado.txt");
    FILE *geradorout;
    geradorout = fopen("codigo_gerado.txt", "a");
    if (geradorout == NULL) {
        perror("Erro ao abrir o arquivo");
        return;
    }
    fprintf(geradorout, "@main(");
    for (int tamanho = 0; tamanho < SIZE; ++tamanho) {
        list_t *token = get_hash_table_entry(tamanho);
        while (token != NULL) {
            if (token->declaracao == PARAMETRO){
                fprintf(geradorout, "%s: ", token->nome_token);
                if (token->tipo_token == TIPO_INT) fprintf(geradorout, "%s", "inteiro");
                else if (token->tipo_token == TIPO_REAL) fprintf(geradorout, "%s", "real");
                else if (token->tipo_token == TIPO_LITERAL) fprintf(geradorout, "%s", "literal");
                fprintf(geradorout, ", ");
            }
            token = token->next; 
        }
    }
    fprintf(geradorout, ") {\n");
    fclose(geradorout);
}
