/* tamanho da tabela hash */
#define SIZE 211
/* tamanho máximo do identificador do token  */
#define MAXIDSIZE 100
/* tamanho máximo do conteúdo do token  */
#define MAXCONTENTSIZE 300


/* parametro ou variável */
#define PARAMETRO 0
#define VARIAVEL 1

/* tipos de token */
#define INDEF 0
#define TIPO_INT 1
#define TIPO_REAL 2
#define TIPO_LITERAL 3
#define TIPO_STRING 4
#define TIPO_COMENTARIO 5

/* lista de linhas em que o token foi mencionado */
typedef struct RefList{ 
    int lineno;
    struct RefList *next;
    int type;
}RefList;

// struct that represents a list node
typedef struct list_t{
    
    char nome_token[MAXIDSIZE];
    int tipo_token;
    int declaracao;
    /* armazenamento de possíveis valores */
    int token_ival; double token_fval; char *token_sval;
    RefList *lines;
    // pointer to next item in the list
    struct list_t *next;
}list_t;
 
/* the hash table */
static list_t **hash_table;
 
typedef struct expressoes
{
    int num_expressao;
    int tipo_elem_esquerdo, tipo_elem_direito;
    int val_int_elem_esquerdo, val_int_elem_direito;
    double val_real_elem_esquerdo, val_real_elem_direito;

    struct expressoes *next;
    } expressoes;

static expressoes **lista_expr;

// Estrutura para armazenar um lexema
typedef struct lexemas {
    char lexema[MAXIDSIZE];
    struct lexemas *next;
} lexemas;

// Funções para tabela de simbolos
void init_hash_table(); // Inicializa a tabela hash.
unsigned int hash(char *key); // Calcula o índice hash para uma chave dada.
void insert(char *name, int len, int type, int declaracao, int lineno); // Insere um símbolo na tabela hash.
list_t *lookup(char *name); // Procura por um símbolo na tabela hash.
void tabsimb_dump(FILE *of); // Imprime o conteúdo da tabela de símbolos em um arquivo.
list_t **get_hash_table(); // Retorna a tabela hash inteira.
list_t *get_hash_table_entry(int index); // Retorna uma entrada específica da tabela hash.

 // Funções para lista de expressões
void init_lista_expr(); // Inicializa a lista de expressões.
// void inserir_expressao(expressoes *expr); // Insere uma nova expressão na lista.
// expressoes *buscar_expressao(int num_expressao); // Busca uma expressão específica na lista.

// Funções para lista de lexemas
void init_lista_lex();            // Inicializa a lista de lexemas
void insert_lex(int index, const char* lexema); // Insere um novo lexema na lista na posição especificada
char* lookup_lex(int index);      // Retorna o lexema na posição especificada
void dump_lista_lex(int declarados);            // Imprime o conteúdo da lista de lexemas