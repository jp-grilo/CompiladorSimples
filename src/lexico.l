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
    int lineno = 1;     // número da linha
%}

/* Define os lexemas */
L    [a-zA-Z]
D    [0-9]
S    [~\`\!\@\#\$\%\^\&\*\(\)\_\-\+\\\/\[\]\|\‘\?\>\<\.\,\:\;]

/* Regras para os lexemas fornecidos */
NUMERO              {D}+(\.{D}+)?((E|e)(\+|\-)?{D}+)?
LITERAL             \"({L}|{D}|{S}|" "|\t)*\"
IDENTIFICADOR       {L}({L}|{D}|_)*
OP_RELACIONAL       \<|\>|\>\=|\<\=|\=\=|\<\>
OP_ARITIMETICO      \+|\-|\*|\/
ATRIBUICAO          =
ABRE_PAR            \(
FECHA_PAR           \)
VIRGULA             ,
PONTO_E_VIRG        ;
VAZIO               (" "|\t|\r|\\n)+
COMENTARIO          \{({L}|{D}|{S}|" "|\t)*\}

%%

"inicioprog"            {  ret_print("INICIOPROG"); return INICIOPROG ; }
"fimprog"               {  ret_print("FIMPROG"); return FIMPROG ;}
"inicioargs"            {  ret_print("INICIOARGS"); return INICIOARGS ;}
"fimargs"               {  ret_print("FIMARGS"); return FIMARGS ;}
"iniciovars"            {  ret_print("INICIOVARS"); return INICIOVARS ;}
"fimvars"               {  ret_print("FIMVARS"); return FIMVARS ;}
"escreva"               {   ret_print("ESCREVA"); return ESCREVA ;}
"se"                    {   ret_print("SE"); return SE ;}
"entao"                 {   ret_print("ENTAO"); return ENTAO ;}
"fimse"                 {   ret_print("FIM_SE"); return FIM_SE ;}
"enquanto"              {   ret_print("ENQUANTO"); return ENQUANTO ;}
"faca"                  {   ret_print("FACA"); return FACA ;}
"fimenquanto"           {   ret_print("FIM_ENQUANTO"); return FIM_ENQUANTO ;}

"inteiro"               { ret_print("INTEIRO"); return INTEIRO; }
"real"                  { ret_print("REAL"); return REAL; }
"literal"               { ret_print("LITERAL"); return LITERAL; }

{NUMERO}                { ret_print("NUMERO"); return NUMERO; }
{LITERAL}               { ret_print("STRING"); return STRING; }
{IDENTIFICADOR}         { insert(yytext, strlen(yytext), INDEF, lineno);
                        ret_print("IDENTIFICADOR"); return IDENTIFICADOR; }
{OP_RELACIONAL}         { ret_print("OP_RELACIONAL"); return OP_RELACIONAL; }
{OP_ARITIMETICO}        { ret_print("OP_ARITIMETICO"); return OP_ARITIMETICO; }
{ATRIBUICAO}            { ret_print("ATRIBUICAO"); return ATRIBUICAO; }
{ABRE_PAR}              { ret_print("ABRE_PAR"); return ABRE_PAR; }
{FECHA_PAR}             { ret_print("FECHA_PAR"); return FECHA_PAR; }
{VIRGULA}               { ret_print("VIRGULA"); return VIRGULA; }
{PONTO_E_VIRG}          { ret_print("PONTO_E_VIRG"); return PONTO_E_VIRG; }
{VAZIO}                 { ret_print("VAZIO");  }
{COMENTARIO}            { ret_print("COMENTARIO"); }

"\n"                    { lineno += 1; }
.                       { ret_print("ERROR"); return ERROR; }


%%


void ret_print(char *token_type){
    FILE *pout;
    pout = fopen("printf.txt", "a") ;
    fprintf(pout, "%s\n", token_type);
}