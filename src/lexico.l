%option noyywrap
 
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "lista_t.h"
    #include "parser.tab.h"

    extern FILE *yyin;
    extern FILE *yyout;

    void yyerror();
    void ret_print(char *token_type);
    
    int type;
    int declaracao;
    int lineno=1;     // número da linha
    int index_lexema=0;
    char *lexema;
%}

/* Define os lexemas */
L    [a-zA-Z]
D    [0-9]
S    [~\`\!\@\#\$\%\^\&\*\(\)\_\-\+\\\/\[\]\|\‘\?\>\<\.\,\:\;]

/* Regras para os lexemas fornecidos */
INTEGER             {D}+
DOUBLE              {D}+(\.{D}+)((E|e)(\+|\-)?{D}+)?
LITERAL             \"({L}|{D}|{S}|" "|\t)*\"
IDENTIFICADOR       {L}({L}|{D}|_)*
OP_RELACIONAL       \<|\>|\>\=|\<\=|\=\=|\<\>
SOMA                \+
SUB                 \-
MULT                \*
DIV                 \/
ATRIBUICAO          =
ABRE_PAR            \(
FECHA_PAR           \)
VIRGULA             ,
PONTO_E_VIRG        ;
VAZIO               (" "|\t|\r|\\n)+
COMENTARIO          \{({L}|{D}|{S}|" "|\t)*\}

%%

"inicioprog"            {   ret_print("INICIOPROG"); return INICIOPROG ; }
"fimprog"               {   ret_print("FIMPROG"); return FIMPROG ;}
"inicioargs"            {   declaracao=PARAMETRO; ret_print("INICIOARGS"); return INICIOARGS ;}
"fimargs"               {   ret_print("FIMARGS"); return FIMARGS ;}
"iniciovars"            {   declaracao=VARIAVEL; ret_print("INICIOVARS"); return INICIOVARS ;}
"fimvars"               {   ret_print("FIMVARS"); return FIMVARS ;}
"escreva"               {   ret_print("ESCREVA"); return ESCREVA ;}
"se"                    {   ret_print("SE"); return SE ;}
"entao"                 {   ret_print("ENTAO"); return ENTAO ;}
"fimse"                 {   ret_print("FIM_SE"); return FIM_SE ;}
"enquanto"              {   ret_print("ENQUANTO"); return ENQUANTO ;}
"faca"                  {   ret_print("FACA"); return FACA ;}
"fimenquanto"           {   ret_print("FIM_ENQUANTO"); return FIM_ENQUANTO ;}

"inteiro"               {   type=TIPO_INT; ret_print("INTEIRO"); return INTEIRO; }
"real"                  {   type=TIPO_REAL; ret_print("REAL"); return REAL; }
"literal"               {   type=TIPO_LITERAL; ret_print("LITERAL"); return LITERAL; }

{INTEGER}                {  
                            ret_print("INTEGER");
                            //printf("Valor int expr: %s\t\tlinha: %d\n", yytext, lineno);
                            insert(yytext, strlen(yytext), TIPO_INT, INDEF, lineno);
                            yylval.val.int_val = atoi(yytext);
                            return INTEGER; 
                        }

{DOUBLE}                {   
                            ret_print("DOUBLE"); 
                            //printf("Valor real expr: %s\t\tlinha: %d\n", yytext, lineno);
                            insert(yytext, strlen(yytext), TIPO_REAL, INDEF, lineno);
                            yylval.val.real_val = atof(yytext);
                            return DOUBLE; 
                        }

{LITERAL}               {   
                            ret_print("STRING");
                            //printf("Valor str expr: %s\t\tlinha: %d\n", yytext, lineno);
                            insert(yytext, strlen(yytext), TIPO_LITERAL, INDEF, lineno);
                            yylval.val.str_val = malloc(yyleng * sizeof(char));
				            strcpy(yylval.val.str_val, yytext);  
                            return STRING; 
                        }

{IDENTIFICADOR}         {   
                            ret_print("IDENTIFICADOR"); 
                            //printf("Valor id expr: %s\t\tlinha: %d\n", yytext, lineno);
                            insert(yytext, strlen(yytext), type, declaracao, lineno);
                            yylval.item_tabela = lookup(yytext);
                            return IDENTIFICADOR; 
                        }

{OP_RELACIONAL}         {   ret_print("OP_RELACIONAL"); return OP_RELACIONAL; }
{SOMA}                  {   ret_print("SOMA"); return SOMA; }
{SUB}                   {   ret_print("SUB"); return SUB; }
{MULT}                  {   ret_print("MULT"); return MULT; }
{DIV}                   {   ret_print("DIV"); return DIV; }
{ATRIBUICAO}            {   ret_print("ATRIBUICAO"); return ATRIBUICAO; }
{ABRE_PAR}              {   ret_print("ABRE_PAR"); return ABRE_PAR; }
{FECHA_PAR}             {   ret_print("FECHA_PAR"); return FECHA_PAR; }
{VIRGULA}               {   ret_print("VIRGULA"); return VIRGULA; }
{PONTO_E_VIRG}          {   ret_print("PONTO_E_VIRG"); return PONTO_E_VIRG; }
{VAZIO}                 {   }
{COMENTARIO}            {   ret_print("COMENTARIO"); }

"\n"                    {   lineno += 1; }
.                       {   ret_print("ERROR"); return ERROR; }


%%


void ret_print(char *token_type){
    FILE *pout;
    pout = fopen("printf.txt", "a") ;
    fprintf(pout, "%s\t ->\t %s linha %d\n", token_type, yytext, lineno);
}