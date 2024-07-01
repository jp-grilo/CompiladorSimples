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

"inicioprog"            { return INICIOPROG ; }
"fimprog"               { return FIMPROG ; }
"inicioargs"            { return INICIOARGS ; }
"fimargs"               { return FIMARGS ; }
"iniciovars"            { return INICIOVARS ; }
"fimvars"               { return FIMVARS ; }
"escreva"               { return ESCREVA ; }
"se"                    { return SE ; }
"entao"                 { return ENTAO ; }
"fimse"                 { return FIM_SE ; }
"enquanto"              { return ENQUANTO ; }
"faca"                  { return FACA ; }
"fimenquanto"           { return FIM_ENQUANTO ; }

"inteiro"               { return INTEIRO ; }
"real"                  { return REAL ; }
"literal"               { return LITERAL ; }

{NUMERO}                { return NUMERO ; }
{LITERAL}               { return STRING ; }
{IDENTIFICADOR}         { insert(yytext, strlen(yytext), INDEF, lineno);
                        return IDENTIFICADOR ; }
{OP_RELACIONAL}         { return OP_RELACIONAL ; }
{OP_ARITIMETICO}        { return OP_ARITIMETICO ; }
{ATRIBUICAO}            { return ATRIBUICAO ; }
{ABRE_PAR}              { return ABRE_PAR ; }
{FECHA_PAR}             { return FECHA_PAR ; }
{VIRGULA}               { return VIRGULA ; }
{PONTO_E_VIRG}          { return PONTO_E_VIRG ; }
{VAZIO}                 { return VAZIO ;}
{COMENTARIO}            { return COMENTARIO ; }

"\n"                    { lineno += 1; }
.                       { yyerror("Caracter nao reconhecido") ; }

%%