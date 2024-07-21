
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IDENTIFICADOR = 258,
     INTEIRO = 259,
     REAL = 260,
     LITERAL = 261,
     INTEGER = 262,
     DOUBLE = 263,
     STRING = 264,
     INICIOPROG = 265,
     FIMPROG = 266,
     INICIOARGS = 267,
     FIMARGS = 268,
     INICIOVARS = 269,
     FIMVARS = 270,
     ESCREVA = 271,
     SE = 272,
     ENTAO = 273,
     FIM_SE = 274,
     ENQUANTO = 275,
     FACA = 276,
     FIM_ENQUANTO = 277,
     OP_RELACIONAL = 278,
     SOMA = 279,
     SUB = 280,
     MULT = 281,
     DIV = 282,
     ATRIBUICAO = 283,
     ABRE_PAR = 284,
     FECHA_PAR = 285,
     VIRGULA = 286,
     PONTO_E_VIRG = 287,
     VAZIO = 288,
     COMENTARIO = 289,
     ERROR = 290,
     UMINUS = 291
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 24 "parser.y"

	// different types of values
	Valores val;   
	
	// structures
	list_t* item_tabela;
	
    TipoToken tipo;
 
	// for declarations
	int tipo_associado;




/* Line 1676 of yacc.c  */
#line 104 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


