default:
	clear
	flex lexico.l
	bison -dv parser.y
	gcc parser.tab.c lex.yy.c gerador.c -o parser
