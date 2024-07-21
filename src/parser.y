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
	
    TipoToken tipo;
 
	// for declarations
	int tipo_var;
	int tipo_const;

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
%type<tipo_var> TIPO_VAR


%%

PROGRAMA:
    INICIOPROG LISTA_PARAM FIMPROG             { parser_log("PROGRAMA -> INICIOPROG LISTA_PARAM FIMPROG"); }
    | 
    error { temErro= 1;  yyerror("\nPROGRAMA -> error"); }
;

LISTA_PARAM:
    INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR    { parser_log("LISTA_PARAM -> INICIOARGS DECLARA_VAR FIMARGS LISTA_VAR"); }
    |
    LISTA_VAR                                   { parser_log("LISTA_PARAM -> LISTA_VAR"); }
    | 
    error { temErro= 1;  yyerror("\nLISTA_PARAM -> error"); }
;

LISTA_VAR:
    INICIOVARS DECLARA_VAR FIMVARS CODIGO       { parser_log("LISTA_VAR -> INICIOVARS DECLARA_VAR FIMVARS CODIGO"); }
    |
    CODIGO                                      { parser_log("LISTA_VAR -> CODIGO"); }
    | 
    error { temErro= 1;  yyerror("\nLISTA_VAR -> error"); }
;

DECLARA_VAR:
    TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR     { parser_log("DECLARA_VAR -> TIPO_VAR NOMES PONTO_E_VIRG DECLARA_VAR"); }
    |

    | 
    error { temErro= 1;  yyerror("\nDECLARA_VAR -> error"); }
;

NOMES:
    IDENTIFICADOR VIRGULA NOMES { 

        printf("Dec id: %s\t\tlinha: %d\n", $1->nome_token, lineno);
        parser_log("NOMES -> IDENTIFICADOR VIRGULA NOMES"); 
    }
    |
    IDENTIFICADOR { 
        printf("Dec id: %s\t\tlinha: %d\n", $1->nome_token, lineno); 
        parser_log("NOMES -> IDENTIFICADOR"); 
    }
    | 
    error { temErro= 1;  yyerror("\nNOMES -> error"); }
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
    error { temErro= 1;  yyerror("\nTIPO_VAR -> error"); }
;

CODIGO:
    COMANDO CODIGO                              { parser_log("CODIGO -> COMANDO CODIGO"); }
    |

;

COMANDO:
    IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG { 
        parser_log("COMANDO -> IDENTIFICADOR ATRIBUICAO EXPRESSAO PONTO_E_VIRG"); 

    
    }
    |
    ESCREVA CORPO_ESCREVA PONTO_E_VIRG { parser_log("COMANDO -> ESCREVA CORPO_ESCREVA PONTO_E_VIRG"); }
    |
    SE CONDICAO ENTAO CODIGO FIM_SE { parser_log("COMANDO -> SE CONDICAO ENTAO CODIGO FIM_SE"); }
    |
    ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO { parser_log("COMANDO -> ENQUANTO CONDICAO FACA CODIGO FIM_ENQUANTO"); }
;

CORPO_ESCREVA:
    EXPRESSAO { parser_log("CORPO_ESCREVA -> EXPRESSAO"); }
;

CONDICAO:
    ABRE_PAR ID_OR_NUMBER OP_RELACIONAL ID_OR_NUMBER FECHA_PAR { parser_log("CONDICAO -> ABRE_PAR ID_OR_NUMBER OP_RELACIONAL IDENTIFICADOR FECHA_PAR"); }
    | 
    error { temErro= 1;  yyerror("\nCONDICAO -> error"); }
;

EXPRESSAO : 
    EXPRESSAO SOMA EXPRESSAO {  parser_log("EXPRESSAO -> EXPRESSAO SOMA EXPRESSAO"); } 
    | 
    EXPRESSAO SUB EXPRESSAO {  parser_log("EXPRESSAO -> EXPRESSAO SUB EXPRESSAO");}
    | 
    EXPRESSAO MULT EXPRESSAO { parser_log("EXPRESSAO -> EXPRESSAO MULT EXPRESSAO");}
    | 
    EXPRESSAO DIV EXPRESSAO { parser_log("EXPRESSAO -> EXPRESSAO DIV EXPRESSAO");}
    | 
    ABRE_PAR EXPRESSAO FECHA_PAR { parser_log("EXPRESSAO -> ABRE_PAR EXPRESSAO FECHA_PAR");}
    | 
    SUB EXPRESSAO %prec UMINUS { parser_log("EXPRESSAO -> '-' EXPRESSAO \%prec UMINUS");}
    | 
    IDENTIFICADOR {
        printf("Id expr: %s\t\tlinha: %d\n", $1->nome_token, lineno);  
        parser_log("EXPRESSAO -> IDENTIFICADOR");
        }
    |
    INTEGER { 
        printf("Int expr: %d\t\tlinha: %d\n", $1.int_val, lineno);  
        parser_log("EXPRESSAO -> INTEGER");
        }
    |
    DOUBLE { 
        printf("Real expr: %f\t\tlinha: %d\n", $1.real_val, lineno);  
        parser_log("EXPRESSAO -> DOUBLE");
        }
    |
    STRING {
        printf("Str expr: %s\t\tlinha: %d\n", $1.str_val, lineno);  
        parser_log("EXPRESSAO -> STRING");}
    |
    error { temErro= 1;  yyerror("\nEXPRESSAO -> error"); }
;

ID_OR_NUMBER:
    IDENTIFICADOR   {parser_log("ID_OR_NUMBER -> IDENTIFICADOR");}
    |
    INTEGER          {parser_log("ID_OR_NUMBER -> INTEGER");}
    |
    DOUBLE          {parser_log("EXPRESSAO -> DOUBLE");}
    |
    error { temErro= 1;  yyerror("\nID_OR_NUMBER_OR_STRING -> error"); }
;

%%

void yyerror(char *producao){
    printf("%s\t\tnro linha: %d\n", producao, lineno);
}

void parser_log(char *producao){
    //printf("%s\t\tnro linha: %d\n", producao, lineno);
}

int resultado ()
{
    if (temErro == 0){
        printf("\n\n------------------------ Programa aceito! ------------------------\n");
        return 1;
    } 
    printf("\n\n------------------------ Programa rejeitado! ------------------------\n");
    return 0;
}

int main (){
    // apagando log anterior
    remove("printf.txt");
    
    // iniciando tabelas
    init_hash_table();
    init_lista_expr();
    init_lista_lex();

    // parsing
	int flag;
	yyin = fopen("input.txt", "r");
	flag = yyparse();
	fclose(yyin);

    // symbol table dump
    yyout = fopen("symtab_dump.txt", "w") ;
    tabsimb_dump(yyout);
    fclose(yyout); 	
    
    //dump_lista_lex(num_lexema);
    if ( resultado() ) 
        iniciaGerador();
	
    return flag;

}