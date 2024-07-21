%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.c"
#include "gerador.h"

extern FILE *yyin;
extern FILE *yyout;
extern FILE *LEXOUT;

extern int lineno;
extern char *lexema;
extern int yylex();

void yyerror(char *producao);
void parser_log(char *producao);
int analise_passou();

int temErro = 0;
int numExpressao = 0;
int leitura=0;

FILE *PARSEROUT;

%}

%union{
	// Diferentes tipos de valores
	Valores val;   
	
	// Token da tabela de simbolos
	list_t* item_tabela;
 
	// Tipo associado
	int tipo_associado;

    // Quadruplas da tabela de expressoes
    list_expressoes* expressao;

}

/* definição dos tokens */
%token<item_tabela> IDENTIFICADOR
%token<val> INTEIRO REAL LITERAL
%token<val> INTEGER DOUBLE STRING
%token<val> INICIOPROG FIMPROG INICIOARGS FIMARGS INICIOVARS FIMVARS
%token<val> ESCREVA SE ENTAO FIM_SE ENQUANTO FACA FIM_ENQUANTO
%token<val> OP_RELACIONAL SOMA SUB MULT DIV ATRIBUICAO
%token<val> ABRE_PAR FECHA_PAR VIRGULA PONTO_E_VIRG 
%token<val> VAZIO COMENTARIO ERROR


/* prioridade */
%right ATRIBUICAO
%left OP_RELACIONAL
%left SOMA SUB 
%left MULT DIV
%right UMINUS
%left ABRE_PAR FECHA_PAR

/* definição de não terminais */
%type<tipo_associado> TIPO_VAR ID_OR_NUMBER
%type<expressao> EXPRESSAO 

%%

PROGRAMA:
    INICIOPROG LISTA_PARAM{
        iniciaGerador();
        parser_log("PROGRAMA -> INICIOPROG LISTA_PARAM"); 
    }
    | 
    error { temErro= 1; yyerror("-  Erro na inicializacao ou finalizacao do codigo"); }
;

LISTA_PARAM:
    INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR{     
        parser_log("LISTA_PARAM -> INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR");
    }
    |
    LISTA_VAR                                   { parser_log("LISTA_PARAM -> LISTA_VAR"); }
    | 
    error { temErro= 1;  yyerror("-  Erro na estrutura de declaracao de argumentos"); }
;

LISTA_VAR:
    INICIOVARS DECLARA_VAR FIMVARS CODIGO {
        parser_log("LISTA_VAR -> INICIOVARS DECLARA_VAR FIMVARS CODIGO"); }
    |
    error { temErro= 1;  yyerror("-  Erro na estrutura de declaracao de variaveis"); }
;

DECLARA_VAR:
    TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR     { parser_log("DECLARA_VAR -> TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR"); }
    |

    | 
    error { temErro= 1;  yyerror("-  Erro na declaracao dos identificadores"); }
;

NOMES:
    IDENTIFICADOR VIRGULA NOMES {
        parser_log("NOMES -> IDENTIFICADOR VIRGULA NOMES"); 
    }
    |
    IDENTIFICADOR { 
        parser_log("NOMES -> IDENTIFICADOR"); 
    }
    | 
    error { temErro= 1;  yyerror("-  Erro na declaracao dos identificadores"); }
;

TIPO_VAR:
    INTEIRO {
        $$ = TIPO_INT;
        parser_log("TIPO_VAR -> INTEIRO");
        }
    |
    REAL {
        $$ = TIPO_REAL;
        parser_log("TIPO_VAR -> INTEIRO");
        }
    |
    LITERAL {
        $$ = TIPO_LITERAL;
        parser_log("TIPO_VAR -> INTEIRO");
        }
    | 
    error { temErro= 1;  yyerror("-  Tipo invalido na declaracao dos identificadores"); }
;

CODIGO:
    COMANDO CODIGO
    |

    |
    FIMPROG { parser_log("CODIGO -> FIMPROG"); }
;

COMANDO:
    IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG { 
        if (($1->tipo_token == TIPO_LITERAL && ($3->tipo_associado == TIPO_REAL || $3->tipo_associado == TIPO_INT)) || 
            (($1->tipo_token == TIPO_REAL || $1->tipo_token == TIPO_INT) && $3->tipo_associado == TIPO_LITERAL)) {
            temErro = 1;
            printf("ERRO:\n  - A atribuição contém conflito de tipo.\n   Variável: %s, Expressão: %s, na linha %d.\n", return_type($1->tipo_token), return_type($3->tipo_associado), lineno);
        }
        parser_log("COMANDO -> IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG"); 
    }
    |
    ESCREVA EXPRESSAO PONTO_E_VIRG { 
        parser_log("COMANDO -> ESCREVA CORPO_ESCREVA PONTO_E_VIRG"); 
    }
    |
    SE CONDICAO ENTAO CODIGO FIM_SE {
        parser_log("COMANDO -> SE CONDICAO ENTAO CODIGO FIM_SE"); 
    }
    |
    ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO { 
        parser_log("COMANDO -> ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO");
    }
;

CONDICAO:
    ABRE_PAR ID_OR_NUMBER OP_RELACIONAL ID_OR_NUMBER FECHA_PAR {
        parser_log("COMANDO -> IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG"); 
    }
    | 
    error { temErro=1;  yyerror("\nCONDICAO -> error"); }
;

EXPRESSAO : 
    EXPRESSAO SOMA EXPRESSAO { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        if($1->tipo_associado == TIPO_LITERAL || $3->tipo_associado == TIPO_LITERAL){
            temErro = 1;
            printf("ERRO:\n  - A operação de soma não pode conter literais. \n   Var1: %s, Var2: %s, na linha %d.\n", return_type($1->tipo_associado), return_type($3->tipo_associado), lineno);
            $$->tipo_associado = ERRO;
        }
        else if($1->tipo_associado == TIPO_REAL || $3->tipo_associado == TIPO_REAL){
            $$->tipo_associado = TIPO_REAL;
        } else {
            $$->tipo_associado = TIPO_INT;
        }
        parser_log("EXPRESSAO -> EXPRESSAO SOMA EXPRESSAO");
    } 
    | 
    EXPRESSAO SUB EXPRESSAO { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        if($1->tipo_associado == TIPO_LITERAL || $3->tipo_associado == TIPO_LITERAL){
            temErro = 1;
            printf("ERRO:\n  - A operação de subtração não pode conter literais. \n   Var1: %s, Var2: %s, na linha %d.\n", return_type($1->tipo_associado), return_type($3->tipo_associado), lineno);
            $$->tipo_associado = ERRO;
        }
        else if($1->tipo_associado == TIPO_REAL || $3->tipo_associado == TIPO_REAL){
            $$->tipo_associado = TIPO_REAL;
        } else {
            $$->tipo_associado = TIPO_INT;
        }
        parser_log("EXPRESSAO -> EXPRESSAO SUB EXPRESSAO");
    }
    | 
    EXPRESSAO MULT EXPRESSAO { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        if($1->tipo_associado == TIPO_LITERAL || $3->tipo_associado == TIPO_LITERAL){
            temErro = 1;
            printf("ERRO:\n  - A operação de multiplicação não pode conter literais. \n   Var1: %s, Var2: %s, na linha %d.\n", return_type($1->tipo_associado), return_type($3->tipo_associado), lineno);
            $$->tipo_associado = ERRO;
        }
        else if($1->tipo_associado == TIPO_REAL || $3->tipo_associado == TIPO_REAL){
            $$->tipo_associado = TIPO_REAL;
        } else {
            $$->tipo_associado = TIPO_INT;
        }
        parser_log("EXPRESSAO -> EXPRESSAO MULT EXPRESSAO");
    }
    | 
    EXPRESSAO DIV EXPRESSAO { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        if($1->tipo_associado == TIPO_LITERAL || $3->tipo_associado == TIPO_LITERAL){
            temErro = 1;
            printf("ERRO:\n  - A operação de divisão não pode conter literais. \n   Var1: %s, Var2: %s, na linha %d.\n", return_type($1->tipo_associado), return_type($3->tipo_associado), lineno);
            $$->tipo_associado = ERRO;
        }
        else if($1->tipo_associado == TIPO_REAL || $3->tipo_associado == TIPO_REAL){
            $$->tipo_associado = TIPO_REAL;
        } else {
            $$->tipo_associado = TIPO_INT;
        }
        parser_log("EXPRESSAO -> EXPRESSAO DIV EXPRESSAO");
    }
    | 
    ABRE_PAR EXPRESSAO FECHA_PAR { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        $$->tipo_associado = $2->tipo_associado;
        parser_log("EXPRESSAO -> ABRE_PAR EXPRESSAO FECHA_PAR");
    }
    | 
    SUB EXPRESSAO %prec UMINUS { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        if($2->tipo_associado == TIPO_LITERAL){
            temErro = 1;
            printf("ERRO:\n  - A operação de negação não pode conter literal.\n   Var1: %s, na linha %d.\n", return_type($2->tipo_associado), lineno);
            $$->tipo_associado = ERRO;
        }
        else {
            $$->operacao = "MINUS";
            $$->arg1 = $2->arg1;
            $$->arg2 = NULL; // Não há argumento 2 para esse caso
            $$->resultado = numExpressao++;
            $$->tipo_associado = $2->tipo_associado;
            //dump_expr_element($$);
        }
        parser_log("EXPRESSAO -> '-' EXPRESSAO \%prec UMINUS");
    }
    | 
    IDENTIFICADOR {
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        $$->operacao = "=";
        $$->arg1 = $1->nome_token;
        $$->arg2 = NULL; // Não há argumento 2 para esse caso
        $$->resultado = numExpressao++;
        $$->tipo_associado = $1->tipo_token;
          
        parser_log("EXPRESSAO -> IDENTIFICADOR");
    }
    |
    INTEGER {
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        $$->operacao = "=";
        $$->arg1 = $1.str_val; // str_val é um char*
        $$->arg2 = NULL; // Não há argumento 2 para esse caso
        $$->resultado = numExpressao++;
        $$->tipo_associado = type_lookup($1.str_val);
        
        parser_log("EXPRESSAO -> INTEGER");
    }
    |
    DOUBLE { 
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        $$->operacao = "=";
        $$->arg1 = $1.str_val; // str_val é um char*
        $$->arg2 = NULL; // Não há argumento 2 para esse caso
        $$->resultado = numExpressao++;
        $$->tipo_associado = type_lookup($1.str_val);
          
        parser_log("EXPRESSAO -> DOUBLE");
    }
    |
    STRING {
        $$ = (list_expressoes*) malloc(sizeof(list_expressoes));
        $$->operacao = "=";
        $$->arg1 = $1.str_val; // str_val é um char*
        $$->arg2 = NULL; // Não há argumento 2 para esse caso
        $$->resultado = numExpressao++;
        $$->tipo_associado = type_lookup($1.str_val);
          
        parser_log("EXPRESSAO -> STRING");
    }
    |
    error { 
        temErro = 1;  
        yyerror("- Expressão inválida"); 
    }
;

ID_OR_NUMBER:
    IDENTIFICADOR {
          
        parser_log("ID_OR_NUMBER -> IDENTIFICADOR");
    }
    |
    INTEGER {
          
        parser_log("ID_OR_NUMBER -> INTEGER");
    }
    |
    DOUBLE {
          
        parser_log("ID_OR_NUMBER -> DOUBLE");
    }
    |
    error { temErro= 1;  yyerror("-  Elemento da comparacao invalido"); }
;

%%

void yyerror(char *producao){
    printf("%s. \tLinha: %d\n", producao, lineno);
}

void parser_log(char *producao){
    if(leitura) return;
    FILE *PARSEROUT;
    PARSEROUT = fopen("OUTPARSER.txt", "a") ;
    fprintf(PARSEROUT, "%s\t linha %d\n", producao, lineno);
}

int analise_passou (){
    if (temErro == 0){
        printf("\n------------------------ Programa aceito! ------------------------\n");
        return 1;
    } 
    printf("\n------------------------ Programa rejeitado! ------------------------\n");
    return 0;
}

void limpa_logs(int passou){

    // apagando logs anteriores
    if(passou==0){
        remove("OUTLEX.txt");
        remove("OUTPARSER.txt");
        remove("OUT_GERADO.txt");
        remove("OUT_TABSIMB.txt");
    } else {
        remove("OUT_GERADO.txt");
    }
}

int main (){
    limpa_logs(0);

    // iniciando tabelas
    init_hash_table();

    // parsing
	yyin = fopen("input.txt", "r");
    yyparse();
    leitura=1;
    yyin = fopen("input.txt", "r");
    yyparse();

    // symbol table dump
    yyout = fopen("OUT_TABSIMB.txt", "w") ;
    tabsimb_dump(yyout);

    if (!analise_passou()) limpa_logs(1);

	fclose(yyin);
    fclose(yyout); 	
    fclose(PARSEROUT);
    fclose(LEXOUT);
    return temErro;
}