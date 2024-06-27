/* tamanho da tabela hash */
#define SIZE 211
/* tamanho máximo do identificador do token  */
#define MAXIDSIZE 100
/* tamanho máximo do conteúdo do token  */
#define MAXCONTENTSIZE 300



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
    /* armazenamento de possíveis valores */
    int token_ival; double token_fval; char *token_sval;
    RefList *lines;
    // pointer to next item in the list
    struct list_t *next;
}list_t;
 
/* the hash table */
static list_t **hash_table;
 
// Function Declarations
void init_hash_table(); // initialize hash table
unsigned int hash(char *key); // hash function 
void insert(char *name, int len, int type, int lineno); // insert entry
list_t *lookup(char *name); // search for entry
void tabsimb_dump(FILE *of); // dump file