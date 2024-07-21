%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.c"
#include "gerador.h"
#include "semantico.h"

extern FILE *yyin;
extern FILE *yyout;

extern int lineno;
extern char *lexema;
extern int yylex();

void yyerror(char *producao);
void parser_log(char *producao);

int temErro = 0;
int num_lexema=0;

%}

%union{
	// different types of values
	Valores val;   
	
	// structures
	list_t* item_tabela;
 
	// for declarations
	int tipo_associado;

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
%type<tipo_associado> TIPO_VAR EXPRESSAO ID_OR_NUMBER


%%

PROGRAMA:
    INICIOPROG LISTA_PARAM FIMPROG             { parser_log("PROGRAMA -> INICIOPROG LISTA_PARAM FIMPROG"); }
    | 
    error { temErro= 1; yyerror("-  Erro na inicializacao ou finalizacao do codigo"); }
;

LISTA_PARAM:
    INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR    { parser_log("LISTA_PARAM -> INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR"); }
    |
    LISTA_VAR                                   { parser_log("LISTA_PARAM -> LISTA_VAR"); }
    | 
    error { temErro= 1;  yyerror("-  Erro na estrutura de declaracao de argumentos"); }
;

LISTA_VAR:
    INICIOVARS DECLARA_VAR FIMVARS CODIGO       { parser_log("LISTA_VAR -> INICIOVARS DECLARA_VAR FIMVARS CODIGO"); }
    |
    CODIGO                                      { parser_log("LISTA_VAR -> CODIGO"); }
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

        //printf("Dec id: %s\t\tlinha: %d\n", $1->nome_token, lineno);
        parser_log("NOMES -> IDENTIFICADOR VIRGULA NOMES"); 
    }
    |
    IDENTIFICADOR { 
        //printf("Dec id: %s\t\tlinha: %d\n", $1->nome_token, lineno); 
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
    COMANDO CODIGO                              { parser_log("CODIGO -> COMANDO CODIGO"); }
    |

;

COMANDO:
    IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG { 
        if( ($1->tipo_token == TIPO_LITERAL && ($3 == TIPO_REAL || $3 == TIPO_INT)) || 
            ( ($1->tipo_token == TIPO_REAL || $1->tipo_token == TIPO_INT) && $3 == TIPO_LITERAL) 
        ){
            temErro=1;
            printf("ERRO:\n  - A atribuicao contem conflito de tipo.\n   Variavel: %s, Expressao: %s, na linha %d.\n", return_type($1->tipo_token), return_type($3), lineno);
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
        if($1==TIPO_LITERAL || $3==TIPO_LITERAL){
            temErro=1;
            printf("ERRO:\n  - A operação de soma não pode conter literais. Var1:%s, Var2:%s, na linha %d.\n", return_type($1), return_type($3), lineno);
            $$ = ERRO;
        }
        else if($1==TIPO_REAL || $3==TIPO_REAL){
            $$ = TIPO_REAL;
        }
        parser_log("EXPRESSAO -> EXPRESSAO SOMA EXPRESSAO");
        } 
    | 
    EXPRESSAO SUB EXPRESSAO { 
        if($1==TIPO_LITERAL || $3==TIPO_LITERAL){
            temErro=1;
            printf("ERRO:\n  - A operação de subtracao não pode conter literais. Var1:%s, Var2:%s, na linha %d.\n", return_type($1), return_type($3), lineno);
            $$ = ERRO;
        }
        else if($1==TIPO_REAL || $3==TIPO_REAL){
            $$ = TIPO_REAL;
        }
        parser_log("EXPRESSAO -> EXPRESSAO SUB EXPRESSAO");
        }
    | 
    EXPRESSAO MULT EXPRESSAO { 
        if($1==TIPO_LITERAL || $3==TIPO_LITERAL){
            temErro=1;
            printf("ERRO:\n  - A operação de multiplicacao não pode conter literais. Var1:%s, Var2:%s, na linha %d.\n", return_type($1), return_type($3), lineno);
            $$ = ERRO;
        }
        else if($1==TIPO_REAL || $3==TIPO_REAL){
            $$ = TIPO_REAL;
        }
        parser_log("EXPRESSAO -> EXPRESSAO MULT EXPRESSAO");
        }
    | 
    EXPRESSAO DIV EXPRESSAO { 
        if($1==TIPO_LITERAL || $3==TIPO_LITERAL){
            temErro=1;
            printf("ERRO:\n  - A operação de divisao não pode conter literais. Var1:%s, Var2:%s, na linha %d.\n", return_type($1), return_type($3), lineno);
            $$ = ERRO;
        }
        else if($1==TIPO_REAL || $3==TIPO_REAL){
            $$ = TIPO_REAL;
        }
        parser_log("EXPRESSAO -> EXPRESSAO DIV EXPRESSAO");
        }
    | 
    ABRE_PAR EXPRESSAO FECHA_PAR { 
        $$ = $2;
        parser_log("EXPRESSAO -> ABRE_PAR EXPRESSAO FECHA_PAR");
        }
    | 
    SUB EXPRESSAO %prec UMINUS { 
        if($2==TIPO_LITERAL){
            temErro=1;
            printf("ERRO:\n  - A operação de negacao não pode conter literal. Var1:%s, na linha %d.\n", return_type($2), lineno);
            $$ = ERRO;
        }
        $$ = $2;
        parser_log("EXPRESSAO -> '-' EXPRESSAO \%prec UMINUS");
        }
    | 
    IDENTIFICADOR {
        $$ = $1->tipo_token;
        parser_log("EXPRESSAO -> IDENTIFICADOR");
    }
    |
    INTEGER {
        $$ = type_lookup($1.str_val); 
        parser_log("EXPRESSAO -> INTEGER");
    }
    |
    DOUBLE { 
        $$ = type_lookup($1.str_val);
        parser_log("EXPRESSAO -> DOUBLE");
    }
    |
    STRING {
        $$ = type_lookup($1.str_val);
        //printf("Str expr: %s\t\ttipo associado: %d\n", $1.str_val, $$);  
        parser_log("EXPRESSAO -> STRING");}
    |
    error { temErro= 1;  yyerror("-  Expressão invalida"); }
;

ID_OR_NUMBER:
    IDENTIFICADOR {
        $$ = $1->tipo_token;
        parser_log("EXPRESSAO -> IDENTIFICADOR");
    }
    |
    INTEGER {
        $$ = type_lookup($1.str_val); 
        parser_log("EXPRESSAO -> INTEGER");
    }
    |
    DOUBLE { 
        $$ = type_lookup($1.str_val);
        parser_log("EXPRESSAO -> DOUBLE");
    }
    |
    error { temErro= 1;  yyerror("-  Elemento da comparacao invalido"); }
;

%%

void yyerror(char *producao){
    printf("%s. \tLinha: %d\n", producao, lineno);
}

void parser_log(char *producao){
    //printf("%s\t\tnro linha: %d\n", producao, lineno);
}

int resultado ()
{
    if (temErro == 0){
        printf("\n------------------------ Programa aceito! ------------------------\n");
        return 1;
    } 
    printf("\n------------------------ Programa rejeitado! ------------------------\n");
    return 0;
}

int main (){
    // apagando log anterior
    remove("printf.txt");
    
    // iniciando tabelas
    init_hash_table();

    // parsing
	int flag;
	yyin = fopen("input.txt", "r");
	flag = yyparse();
	fclose(yyin);

    // symbol table dump
    yyout = fopen("symtab_dump.txt", "w") ;
    tabsimb_dump(yyout);
    fclose(yyout); 	
    
    if ( resultado() ) 
        iniciaGerador();
	
    return flag;

}