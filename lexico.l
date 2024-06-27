%option noyywrap
 
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "lista_t.c"

    extern FILE *yyin;
    extern FILE *yyout;

    int lineno = 1;     // número da linha

    void ret_print(char *token_type);
    void ret_printt(char *token_type);

    void yyerror();
    void token_dump(char *token_type);
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

"inicioprog"            { ret_print("INICIOPROG"); }
"fimprog"               { ret_print("FIMPROG"); }
"inicioargs"            { ret_print("INICIOARGS"); }
"fimargs"               { ret_print("FIMARGS"); }
"iniciovars"            { ret_print("INICIOVARS"); }
"fimvars"               { ret_print("FIMVARS"); }
"escreva"               { ret_print("COMANDO_ESCREVA"); }
"se"                    { ret_print("CONDICIONAL_SE"); }
"entao"                 { ret_print("CONDICIONAL_ENTAO"); }
"fimse"                 { ret_print("CONDICIONAL_FIM_SE"); }
"enquanto"              { ret_print("CONDICIONAL_ENQUANTO"); }
"faca"                  { ret_print("COMANDO_FACA"); }
"fimenquanto"           { ret_print("CONDICIONAL_FIM_ENQUANTO"); }

"inteiro"               { ret_print("INTEIRO"); }
"real"                  { ret_print("REAL"); }
"literal"               { ret_print("LITERAL"); }

{NUMERO}                { ret_print("NUMERO"); }
{LITERAL}               { ret_print("STRING"); }
{IDENTIFICADOR}         { ret_print("IDENTIFICADOR"); 
                          insert(yytext, strlen(yytext), INDEF, lineno);
}
{OP_RELACIONAL}         { ret_print("OP_RELACIONAL"); }
{OP_ARITIMETICO}        { ret_print("OP_ARITMETICO"); }
{ATRIBUICAO}            { ret_print("ATRIBUICAO"); }
{ABRE_PAR}              { ret_print("ABRE_PAR"); }
{FECHA_PAR}             { ret_print("FECHA_PAR"); }
{VIRGULA}               { ret_print("VIRGULA"); }
{PONTO_E_VIRG}          { ret_print("PONTO_E_VIRG"); }
{VAZIO}                 {  }
{COMENTARIO}            { ret_print("COMENTARIO"); }

"\n"                    { lineno += 1; }
.              { yyerror("Caracter nao reconhecido"); }

%%
 
void ret_print(char *token_type){
    printf("'valor': %s\ttoken: %s\tlinha nro: %d\n", yytext, token_type, lineno);
}

void yyerror(char *message){
    printf("Error: \"%s\" in line %d. Token = %s\n", message, lineno, yytext);
}

int main(int argc, char *argv[]){

    // initialize symbol table
    init_hash_table();

	// open input file
	yyin = fopen("input.txt", "r");
	
	// lexical analysis
	yylex();
	fclose(yyin);

    // symbol table dump
    yyout = fopen("symtab_dump.txt", "w");
    tabsimb_dump(yyout);
    fclose(yyout);  
	
	return 0;
}