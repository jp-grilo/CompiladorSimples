/* tamanho da tabela hash */
#define SIZE 211
/* tamanho máximo do identificador do token  */
#define MAXIDSIZE 100
/* tamanho máximo do conteúdo do token  */
#define MAXCONTENTSIZE 300

#define ERRO 500

/* parametro ou variável */
#define PARAMETRO 1
#define VARIAVEL 2

/* tipos de token */
#define INDEF 0
#define TIPO_INT 1
#define TIPO_REAL 2
#define TIPO_LITERAL 3


/* Tipos de valores */
typedef union Valores{
	int int_val;
	double real_val;
	char *str_val;
}Valores;

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
    // armazenar o valor
    Valores valor;
    RefList *lines;
    // ponteiro para as próximas ocorrências do token
    struct list_t *next;
}list_t;
 
/* the hash table */
static list_t **hash_table;
 

// Funções para tabela de simbolos
void init_hash_table(); // Inicializa a tabela hash.
unsigned int hash(char *key); // Calcula o índice hash para uma chave dada.
void insert(char *name, int len, int type, int declaracao, int lineno); // Insere um símbolo na tabela hash.
list_t *lookup(char *name); // Procura por um símbolo na tabela hash.
int type_lookup(char *name);// Procura por um símbolo na tabela hash e retorna o seu tipo.
void tabsimb_dump(FILE *of); // Imprime o conteúdo da tabela de símbolos em um arquivo.
list_t **get_hash_table(); // Retorna a tabela hash inteira.
list_t *get_hash_table_entry(int index); // Retorna uma entrada específica da tabela hash.
char *return_type(int type);