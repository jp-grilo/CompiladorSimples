# Makefile para compilar e executar o analisador léxico

# Variáveis
LEX = flex
CC = gcc
LEX_INPUT = lexico.l
LEX_OUTPUT = lex.yy.c
EXECUTABLE = lexico

# Regras
all: $(EXECUTABLE) run

$(LEX_OUTPUT): $(LEX_INPUT)
	$(LEX) $(LEX_INPUT)

$(EXECUTABLE): $(LEX_OUTPUT)
	$(CC) $(LEX_OUTPUT) -o $(EXECUTABLE)

run: $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	rm -f $(LEX_OUTPUT) $(EXECUTABLE)

.PHONY: all clean run
