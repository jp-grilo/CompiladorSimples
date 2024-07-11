%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista_t.c"

extern FILE *yyin;
extern FILE *yyout;
extern FILE *pout;

extern int lineno;
extern int yylex();

void yyerror();
void parser_log(char *producao);

%}

/* token definition */
%token INICIOPROG FIMPROG INICIOARGS FIMARGS INICIOVARS FIMVARS
%token ESCREVA SE ENTAO FIM_SE ENQUANTO FACA FIM_ENQUANTO
%token INTEIRO REAL LITERAL
%token NUMERO STRING IDENTIFICADOR
%token OP_RELACIONAL OP_ARITIMETICO ATRIBUICAO
%token ABRE_PAR FECHA_PAR VIRGULA PONTO_E_VIRG VAZIO
%token COMENTARIO ERROR

/* expression priorities and rules */
%left '+' '-'
%left '*' '/'
%right UMINUS

%%

PROGRAMA:
    INICIOPROG LISTA_PARAM FIMPROG             { parser_log("PROGRAMA -> INICIOPROG LISTA_PARAM FIMPROG"); }
    | 
    error { parser_log("\nPROGRAMA -> error"); }
;

LISTA_PARAM:
    INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR    { parser_log("LISTA_PARAM -> INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR"); }
    |
    LISTA_VAR                                   { parser_log("LISTA_PARAM -> LISTA_VAR"); }
    | 
    error { parser_log("\nLISTA_PARAM -> error"); }
;

LISTA_VAR:
    INICIOVARS DECLARA_VAR FIMVARS CODIGO       { parser_log("LISTA_VAR -> INICIOVARS DECLARA_VAR FIMVARS CODIGO"); }
    |
    CODIGO                                      { parser_log("LISTA_VAR -> CODIGO"); }
    | 
    error { parser_log("\nLISTA_VAR -> error"); }
;

DECLARA_VAR:
    TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR     { parser_log("DECLARA_VAR -> TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR"); }
    |

    | 
    error { parser_log("\nDECLARA_VAR -> error"); }
;

NOMES:
    IDENTIFICADOR VIRGULA NOMES                 { parser_log("NOMES -> IDENTIFICADOR VIRGULA NOMES"); }
    |
    IDENTIFICADOR                               { parser_log("NOMES -> IDENTIFICADOR"); }
    | 
    error { parser_log("\nNOMES -> error"); }
;

TIPO_VAR:
    INTEIRO                                     { parser_log("TIPO_VAR -> INTEIRO"); }
    |
    REAL                                        { parser_log("TIPO_VAR -> REAL"); }
    |
    LITERAL                                     { parser_log("TIPO_VAR -> LITERAL"); }
    | 
    error { parser_log("\nTIPO_VAR -> error"); }
;

CODIGO:
    COMANDO CODIGO                              { parser_log("CODIGO -> COMANDO CODIGO"); }
    |

    | 
    error { parser_log("\nCODIGO -> error"); }
;

COMANDO:
    IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG { $1 = $3; parser_log("COMANDO -> IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG"); }
    |
    IDENTIFICADOR ATRIBUICAO STRING PONTO_E_VIRG { $1 = $3; parser_log("COMANDO -> IDENTIFICADOR ATRIBUICAO STRING PONTO_E_VIRG"); }
    |
    ESCREVA CORPO_ESCREVA PONTO_E_VIRG { parser_log("COMANDO -> ESCREVA CORPO_ESCREVA PONTO_E_VIRG"); }
    |
    SE CONDICAO ENTAO CODIGO FIM_SE { parser_log("COMANDO -> SE CONDICAO ENTAO CODIGO FIM_SE"); }
    |
    ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO { parser_log("COMANDO -> ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO"); }
    | 
    error { parser_log("\nCOMANDO -> error"); }
;

CORPO_ESCREVA:
    STRING  { parser_log("CORPO_ESCREVA -> STRING"); }
    |
    IDENTIFICADOR { parser_log("CORPO_ESCREVA -> IDENTIFICADOR"); }
    |
    EXPRESSAO { parser_log("CORPO_ESCREVA -> EXPRESSAO"); }
    | 
    error { parser_log("\nCORPO_ESCREVA -> error"); }
;

CONDICAO:
    ABRE_PAR ID_OR_NUMBER OP_RELACIONAL ID_OR_NUMBER FECHA_PAR { parser_log("CONDICAO -> ABRE_PAR ID_OR_NUMBER OP_RELACIONAL IDENTIFICADOR FECHA_PAR"); }
    | 
    error { parser_log("\nCONDICAO -> error"); }
;

ID_OR_NUMBER:
    IDENTIFICADOR
    |
    NUMERO
;

EXPRESSAO : 
    EXPRESSAO '+' EXPRESSAO { $$ = $1 + $3;  parser_log("EXPRESSAO -> EXPRESSAO '+' EXPRESSAO"); } 
    | 
    EXPRESSAO '-' EXPRESSAO { $$ = $1 - $3; parser_log("EXPRESSAO -> EXPRESSAO '-' EXPRESSAO");}
    | 
    EXPRESSAO '*' EXPRESSAO { $$ = $1 * $3; parser_log("EXPRESSAO -> EXPRESSAO '*' EXPRESSAO");}
    | 
    EXPRESSAO '/' EXPRESSAO { $$ = $1 / $3; parser_log("EXPRESSAO -> EXPRESSAO '/' EXPRESSAO");}
    | 
    ABRE_PAR EXPRESSAO FECHA_PAR { $$ = $2; parser_log("EXPRESSAO -> ABRE_PAR EXPRESSAO FECHA_PAR");}
    | 
    '-' EXPRESSAO %prec UMINUS { $$ = -$2; parser_log("EXPRESSAO -> '-' EXPRESSAO \%prec UMINUS");}
    | 
    NUMERO {parser_log("EXPRESSAO -> NUMERO");}
    | 
    error { parser_log("\nEXPRESSAO -> error"); }
;

%%

void yyerror (char *producao)
{

}

void parser_log(char *producao){
    printf("%s\t\tnro linha: %d\n", producao, lineno);
    //FILE *pout;
    //pout = fopen("printf.txt", "a") ;
    //fprintf(pout, "%s\n", producao);
}

int main (int argc, char *argv[]){
    // apagando log anterior
    remove("printf.txt");
    
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

    fclose(pout);
    return 0;
}