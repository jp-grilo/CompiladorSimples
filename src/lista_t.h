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

/* Struct de um token da tabela de símbolos */ 
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
 
/* Hash da tabela de símbolos */
static list_t **hash_table;
 

// Funções para tabela de simbolos
// Inicializa a tabela hash.
void init_hash_table(); 
// Calcula o índice hash para uma chave dada.
unsigned int hash(char *key); 
// Insere um símbolo na tabela hash.
void insert(char *name, int len, int type, int declaracao, int lineno); 
// Procura por um símbolo na tabela hash.
list_t *lookup(char *name); 
// Procura por um símbolo na tabela hash e retorna o seu tipo.
int type_lookup(char *name); 
// Retorna o tipo em formato de string.
char *return_type(int type); 
// Imprime o conteúdo da tabela de símbolos em um arquivo.
void tabsimb_dump(FILE *OUTTABELA); 
// Retorna a tabela hash inteira.
list_t **get_hash_table(); 
// Retorna uma entrada específica da tabela hash.
list_t *get_hash_table_entry(int index); 


// Definição da estrutura de uma quadrupla
typedef struct list_expressoes {
    char *operacao;
    char *arg1;
    char *arg2;
    int resultado;
    int tipo_associado;
    struct list_expressoes *next;
} list_expressoes;

// Ponteiro global para a lista de quadruplas
extern list_expressoes *lista_expressoes;

// Função para criar e inicializar uma nova quadrupla
list_expressoes* criar_expressoes(char *operacao, char *arg1, char *arg2, int resultado, int tipo_associado);

// Função para adicionar uma nova quadrupla ao final da lista
void adicionar_expressoes(char *operacao, char *arg1, char *arg2, int resultado, int tipo_associado);

// Função para encontrar uma quadrupla na lista com base no resultado
list_expressoes* buscar_expressoes_por_resultado(int resultado);

// Função para liberar a memória alocada para a lista
void liberar_lista();

// Função para imprimir todas as quadruplas da lista
void dump_lista();