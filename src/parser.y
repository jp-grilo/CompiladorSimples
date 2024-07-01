%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.c"

extern FILE *yyin;
extern FILE *yyout;
extern int lineno;
extern int yylex();

void yyerror();

%}

/* token definition */
%token INICIOPROG FIMPROG INICIOARGS FIMARGS INICIOVARS FIMVARS
%token ESCREVA SE ENTAO FIM_SE ENQUANTO FACA FIM_ENQUANTO
%token INTEIRO REAL LITERAL
%token NUMERO STRING IDENTIFICADOR
%token OP_RELACIONAL OP_ARITIMETICO ATRIBUICAO
%token ABRE_PAR FECHA_PAR VIRGULA PONTO_E_VIRG VAZIO
%token COMENTARIO

%start PROGRAMA

/* expression priorities and rules */

%%

PROGRAMA:
    INICIOPROG LISTA_PARAM FIMPROG
;

LISTA_PARAM:
    INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR
    |
    LISTA_VAR
;

LISTA_VAR:
    INICIOVARS DECLARA_VAR FIMVARS CODIGO
    |
    CODIGO
;

DECLARA_VAR:
    TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR
    |
    VAZIO
;

NOMES:
    IDENTIFICADOR VIRGULA NOMES
    |
    IDENTIFICADOR
;

TIPO_VAR:
    INTEIRO
    |
    REAL
    |
    LITERAL
;

CODIGO:
    COMANDO CODIGO 
    |
    COMENTARIO CODIGO
    |
    VAZIO
;

COMANDO:
    IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG CODIGO
    |
    ESCREVA CORPO_ESCREVA PONTO_E_VIRG
    |
    SE CONDICAO ENTAO CODIGO FIM_SE
    |
    ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO
;

CORPO_ESCREVA:
    STRING
    |
    IDENTIFICADOR
    |
    EXPRESSAO
;

CONDICAO:
    ABRE_PAR IDENTIFICADOR OP_RELACIONAL IDENTIFICADOR FECHA_PAR
;

EXPRESSAO : 
    EXPRESSAO OP_ARITIMETICO EXPRESSAO { $$ = $1 + $3; }
    | ABRE_PAR EXPRESSAO FECHA_PAR { $$ = $2; }
    | '-' EXPRESSAO %prec UMINUS { $$ = -$2; }
    | NUMERO
;

%%

void yyerror ()
{
    fprintf(stderr, "Syntax error at line %d\n", lineno);
    exit(1);
}

int main (int argc, char *argv[]){
    // initialize symbol table
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
 
	return flag;

    return 0;
}