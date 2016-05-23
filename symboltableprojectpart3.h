
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* SYMBOL STRUCT */
typedef struct symbol {
  char *name;
  char type; /* i = integer, r = real, u = unassigned */
  char stype; /* secondary type for a = array f = function p = procedure */
  int scope;
  struct symbol *next; /* each symbol struct is part of a linked list */
  struct symbol *parameters;
} SYM;

/* GLOBALS */
SYM* hash[50]; /* Symbol table */
SYM* stackTop; /* Top of temporary stack */
SYM* funcTop; /* Top of temporary stack for functions and procedures */
int scope;
int arrayFlag;

/* Let print_symbol() know that print_symbol_list exists */
void print_symbol_list(SYM *head);


// function 1
SYM* new_symbol(){

  struct SYM *s = malloc(sizeof((struct SYM)));

  s->next = NULL;

  return s;

  /* malloc() a new symbol, set its ->next to NULL, and return it */
  // your code
}

/* fill the fields of a symbol struct */
void set_symbol(SYM* symbol, char *name, char type, char stype, int scope){
  symbol->name = (char*)malloc(sizeof(char) * (strlen(name)));
  strcpy(symbol->name, name);
  symbol->type = type;
  symbol->stype = stype;
  symbol->scope = scope;
}

void print_symbol(SYM *symbol) {
  /* Cannot print a symbol which does not exist */
  if (!symbol) {
    printf("Symbol does not exist.\n");
  }
  else {
    printf("Symbol %s / Type %c / Stype %c / Scope %d\n", symbol->name, symbol->type, symbol->stype, symbol->scope);
    printf("     parameters: ");
    print_symbol_list(symbol->parameters);
  }
}

/* SYMBOL LIST-RELATED FUNCTIONS */
/* add a new symbol to the hash table/symbol table */
void add_symbol(SYM **head, SYM *new_sym) {
  SYM *p;

  /* Add a new symbol to the end of the list */
  if (!new_sym) {
    printf("Error: illegal argument; symbol does not exist.\n");
    return;
  }

  /* If the list is empty, new_sym is now the only member */
  if (!(*head)) {
    *head = new_sym;
    return;
  }

  /* Iterate to the end of the list */
  p = *head;

  while (p->next) {
    p = p->next;
  }

  /* Now we can place new_sym at the end */
  p->next = new_sym;
}

// function 2
/* print an entire list of symbols */
void print_symbol_list(SYM *head) {
  // your code

  struct SYM *sy = head;

  while(sy->next != NULL) {
    print_symbol(sy);
    sy = sy->next;
  }

}

// fucntion 3
/* apply the hash function to an input string */
int hasher(char *str) {
  // your code
  int length = strlen(str);
  int i;
  int j;

  for(i=0; i<50; i++) {
    for(j=0; j<length; j++) {
      
      if(strcmp(hash[i]->name, strchr(str, j) == 0) {
        return 1;
      }
    }
  }

  return 0;
}

/* initialize the hash table */
void init_table(SYM *hash[])
{
  int i;
  for (i = 0; i < 50; i++)
  {
    hash[i] = NULL;
  }
  stackTop = NULL;
  funcTop = NULL;

  scope = 0;
  arrayFlag = 0;
}

// function 4
/* returns 1 if there is a symbol with the same name and value and scope */
int check_find_sym(SYM *hash[], SYM *sym) {
  // your code
  int i;

  for(i=0; i<50; i++) {
    if((sym->scope == hash[i]->scope)) && (strcmp(sym->name, hash[i]->name) == 0) {
      return 1;
    }
  }

  return 0;

}

// function 5
/* if there is a symbol with the same value and scope, returns it, otherwise return NULL */
SYM* get_sym(SYM *hash[], SYM *sym) {
  // your code
  int i;

  for(i=0; i<50; i++) {
    if(sym->scope == hash[i]->scope) {
      return sym;
    }
  }

  return NULL;
}

/* go through the hash table and remove any variable with a certain scope */
int empty_table(SYM* hash[], int scope) {
  int i;
  SYM *p, *q;

  for (i = 0; i < 50; i++) {
  check_first:
    p = hash[i];


    if (p) {
      /* check the first element because it needs to specially modify hash[i] */
      if (p->scope == scope) {
        hash[i] = p->next;
        free(p);
        goto check_first;
      }

      /* check the rest of the list */
      while (p->next) {
        if (p->next->scope == scope) {
          /* p->next must be removed */
          q = p->next;
          p->next = q->next;
          free(q);
        }
        else {
          /* p->next does not need to be removed, so move on */
          p = p->next;
        }
      }
    }
  }
}

// function 6
/* add a symbol to the hash table, returns 1 if there is no conflict, otherwise return 0 */
int add_symbol_to_hash(SYM *hash[], SYM *sym) {
  //your code

  int i;

  for(i=0; i<50; i++) {
    if(hash[i] == NULL) {
      hash[i] = sym;
      return 1;
    }
  }

  return 0;
}

// function 7
/* print the entire hash table */
void print_hash(SYM *hash[]) {
  /* Print out every list in the table */
  // your code

  int i;

  for(i=0; i<50; i++) {
    printf();
    SYM *psymbol = hash[i];
    print_symbol_list(psymbol);
  }
}

/* STACK-RELATED FUNCTONS */
/* push a new symbol onto a stack */
void push(SYM **head, SYM *sym) {
  /* We cannot really push the symbol to the head like a real stack,
  so we "push" the symbol to the tail */
  add_symbol(head, sym);
}

/* pop a symbol from a stack */
SYM* pop(SYM **head) {
  SYM *s = *head;
  SYM *sprev;

  if (!(*head)) {
    printf("ERROR: stack empty\n");
    return NULL;
  }

  if (!((*head)->next)) {
    s = *head;
    *head = NULL;
    return(s);
  }

  while (s->next) {
    sprev = s;
    s = s->next;
  }

  sprev->next = NULL;
  return s;
}

int compare(double a, int relop, double b) {
   switch(relop) {
      
      case 1:
        if(a <= b) {
          return 1;
        }
        break;

      case 2:
        if(a >= b) {
          return 1;
        }
        break;

      case 3:
        if(a != b) {
          return 1;
        }
        break;

      case 4:
        if(a < b) {
          return 1;
        }
        break;

      case 5:
        if(a > b) {
          return 1;
        }
        break;

      case 6:
        if(a == b) {
          return 1;
        } 
        break;

      default:
        return 0;
   }
}