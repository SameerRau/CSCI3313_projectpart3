#include "symbol_table.h"
%}

%union{
	int integer;
	double real;
	char* string;
	char character;
};

%start program
%token <integer> INT
%token <real> REALNO
%token <integer> RELOP
%token <string> ID
%token ASSIGNOP SEQUENCE ADDOP MULOP DOT
%token COMMA SEMICOLON COLON OPAR CPAR OBRAC CBRAC
%token ARRAY BEG DO ELSE END FUNCTION
%token IF INTEGER NOT OF PROCEDURE PROGRAM REAL THEN
%token VAR WHILE
%type <character> type factor term simple_expression expression_list variable standard_type expression procedure_statement statement

%%

program:
  PROGRAM ID { 
	/* Add ID to hash table. It cannot possibly be already here. */
	SYM *symbol = new_symbol();
	set_symbol(symbol, $2, 'u','f',0);
	add_symbol_to_hash(hash, symbol);
}
  OPAR identifier_list {
	/* Pop every ID off stack, set their scope to 0 and type to 'o',
		and add them to hash table if they don't already exist */
	SYM *s;
	while (stackTop) {
		s = pop(&stackTop);
		s->type = 'o';
		s->scope = 0;
		
		if(!(add_symbol_to_hash(hash, s))) {
			printf("Error 1: redeclaration of variable within the same block./n");
		}
	}
}
  CPAR SEMICOLON declarations subprogram_declarations compound_statement DOT { 
	printf("Done parsing program.\n");
}
;

identifier_list:
   ID {
   	/* Make a new struct and push it to the stack. */
	SYM *symbol = new_symbol();
	set_symbol(symbol, $1, 'u', 'u', -1);
	push(&stackTop, symbol);
}
| identifier_list COMMA ID {
	/* Make a new struct and push it to the stack. */
	SYM *symbol = new_symbol();
	set_symbol(symbol, $3, 'u', 'u', -1);
	push(&stackTop, symbol);
}
;

declarations:
  /* empty */
| declarations VAR identifier_list COLON type SEMICOLON {
	/* Take all IDs from identifier_list stack and put them in the table, if they do not already exist. */
	SYM *symbol;
    while (stackTop) {
		symbol = pop(&stackTop);
		
		/* Set their type and scope to be the current type and scope */
		symbol->type = $5;
		symbol->scope = scope; 
		
		/* Set array? */
		if (arrayFlag) {
			symbol->stype = 'a';
		}
		
		if (!add_symbol_to_hash(hash, symbol)) {
			printf("Error 1: redeclaration of a variable within the same block\n");
		}
	}
	
	arrayFlag = 0;
}
;

type:
  standard_type {
	/* Set "type" to whatever is returned from standard_type */
	$$ = $1;
}
| ARRAY OBRAC INT SEQUENCE INT CBRAC OF standard_type {
	/* Set "type" to whatever is returned from standard_type */
	$$ = $8;
	
	/* Set the flag to alert that we have found an array */
	arrayFlag = 1;
}
;

standard_type:
  INTEGER {
	$$ = 'i';
}
| REAL {
	$$ = 'r';
}
;

subprogram_declarations:
  /* empty */
| subprogram_declarations subprogram_declaration SEMICOLON
;

subprogram_declaration:
  subprogram_head declarations compound_statement {
	
	/* Remove all symbols from the old scope from the table */
	empty_table(hash, scope);
	
	/* Decrement the scope */
	scope--;
}
;

subprogram_head:
  FUNCTION ID arguments COLON standard_type SEMICOLON {
	SYM* function_sym = new_symbol();
	SYM* argument = new_symbol();
	set_symbol(function_sym, $2, $5, 'f', scope);
	
	/* Make a SYM* for the function itself */
	if(!add_symbol_to_hash(hash, function_sym)) {
		printf("Error 1: redeclaration of a variable within the same block\n");
		free(function_sym);
		goto fail_subhead1;
	}
  
	/* All its parameters should have one higher scope than it */
	scope++;
	
	/* Add all parameters to the table in their own right */
	while (funcTop) {
		argument = pop(&funcTop);	
		argument->scope = scope;
		
		if (arrayFlag) {
			argument->stype = 'a';
		}
		
		if (!add_symbol_to_hash(hash, argument)) {
			printf("Error 1: redeclaration of a variable within the same block: %s\n", argument->name);
			goto fail_subhead1;
		} else {
			/* Add this symbol to the parameters of this function */
			add_symbol(&(function_sym->parameters), argument);
		}
	}

	fail_subhead1:
		arrayFlag = 0;
}
| PROCEDURE ID arguments SEMICOLON {
	SYM* procedure_sym = new_symbol();
	SYM* argument = new_symbol();
	set_symbol(procedure_sym, $2, 'u', 'p', scope);
	
	/* Make a SYM* for the function itself */
	if(!add_symbol_to_hash(hash, procedure_sym)) {
		printf("Error 1: redeclaration of a variable within the same block\n");
		free(procedure_sym);
		goto fail_subhead2;
	}
  
	/* All its parameters should have one higher scope than it */
	scope++;
	
	/* Add all parameters to the table in their own right */
	while (funcTop) {
		argument = pop(&funcTop);	
		argument->scope = scope;

		if (arrayFlag) {
			argument->stype = 'a';
		}
		
		if (!add_symbol_to_hash(hash, argument)) {
			printf("Error 1: redeclaration of a variable within the same block: %s\n", argument->name);
			goto fail_subhead2;
		} else {
			/* Add this symbol to the parameters of this function */
			add_symbol(&(procedure_sym->parameters), argument);
		}
	}
	
	fail_subhead2:
		arrayFlag = 0;
}
;

arguments:
  /* empty */
| OPAR parameter_list CPAR
;

parameter_list:
  identifier_list COLON type {
	/* For every ID on stack, pop it off, give it a type $3, and push it onto the new stack */		
	SYM* symbol;
		
	while (stackTop) {
		symbol = pop(&stackTop);
		symbol->type = $3;
		push(&funcTop, symbol);
	}
}
| parameter_list SEMICOLON identifier_list COLON type {
	/* For every ID on stack, pop it off, give it a type $3, and push it onto the new stack */		
	SYM* symbol;
		
	while (stackTop) {
		symbol = pop(&stackTop);
		symbol->type = $5;
		push(&funcTop, symbol);
	}
}
;

compound_statement:
  BEG optional_statements END
;

optional_statements:
  /* empty */
| statement_list
;

statement_list:
  statement
| statement_list SEMICOLON statement
;

statement:
  variable ASSIGNOP expression {

  	if($$ == 't') {
		if (!(($1 == 'r') || ($1 == 'i'))) {
			printf("Error 3: Type mismatch: cannot assign value to variable of type other than integer or real.\n");
		} 

		else if ((($1 == 'i') && !($3 == 'i')) || (($1 == 'r') && !($3 == 'r'))) {
			printf("Error 3: Type mismatch: must assign expression to variable of the same type.\n");
		}
	}
} 
| procedure_statement
| compound_statement
| IF expression THEN statement ELSE statement {
	if($2 == 0) {$4 = 'f'; $6 = 't';}
	else($4 = 't'; $6 = 'f';)	
}
| WHILE expression DO statement
;

variable:
  ID {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);

	/* Check if this ID exists for every scope between the current scope and 0 (global) */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_var1;
			}
		}
	}

	/* if we reach here, it does not exist */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_var1;
	
	/* Return its proper type */
	end_var1:
		this_symbol = get_sym(hash, this_symbol);
		
		if ((!(this_symbol->type == 'i') || (this_symbol->type == 'r')) || (this_symbol->stype != 'u')) {
			printf("Error 3: type mismatch: cannot use any type except integer or real as a variable.\n");
			goto fail_var1;
		}
		
		$$ = this_symbol->type;
	fail_var1:
		free(this_symbol);
}
| ID OBRAC expression CBRAC {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);
	
	/* 'expression' MUST evaluate to an integer, since it is an index. */
	if (!($3 == 'i')) {
		printf("Error 3: type mismatch: cannot access non-integer index in an array.\n");
		goto fail_var2;
	}

	/* Look for the symbol in every scope from here to global */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_var2;
			}
		}
	}

	/* If we do not find it, error. */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_var2;
	
	end_var2:
		this_symbol = get_sym(hash, this_symbol);
		
		if (!(this_symbol->stype == 'a')) {
			printf("Error 3: type mismatch: cannot access element of non-array variable.\n");
			goto fail_var2;
		}
		
		$$ = this_symbol->type;
	fail_var2:
		free(this_symbol);
}
;

procedure_statement:
ID {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);
	
	/* Look for the symbol in every scope from here to global */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_proc1;
			}
		}
	}

	/* If we do not find it, error. */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_proc1;
	
	end_proc1:
		this_symbol = get_sym(hash, this_symbol);
		
		if (!((this_symbol->stype == 'f') || (this_symbol->stype == 'p'))) {
			printf("Error 3: type mismatch: must be accessing procedure.\n");
			goto fail_proc1;
		}
		
		$$ = this_symbol->type;
	fail_proc1:
		free(this_symbol);
}
| ID OPAR expression_list CPAR {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'x', 'x', scope);
	
	/* Look for the symbol in every scope from here to global */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_proc2;
			}
		}
	}

	/* If we do not find it, error. */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_proc2;
	
	/* Return its proper type */
	end_proc2:
		this_symbol = get_sym(hash, this_symbol);
		
		if (!((this_symbol->stype == 'f') || (this_symbol->stype == 'p'))) {
			printf("Error 3: type mismatch: cannot send parameters to non-function identifier.\n");
			goto fail_proc2;
		}
		
		$$ = this_symbol->type;
	fail_proc2:
		free(this_symbol);
}
;

expression_list:
  expression {
	$$ = $1;
}
| expression_list COMMA expression {
	/* Return the "lowest common denominator" for the type of this expression, integer or real */
	if (($1 == 'r') || ($3 == 'r')) {
		$$ = 'r';
	} else {
		$$ = 'i';
	}
}
;

expression:
  simple_expression {
	$$ = $1;
}
| simple_expression RELOP simple_expression {
	$$ = 'i';
	{$$ = compare($1, $2, $3);}
}
;

simple_expression:
  term {
	$$ = $1;
}
| sign term {
	$$ = $2;
}
| simple_expression ADDOP term {
	/* Make sure $1 is a number */
	if (($1 != 'i') && ($1 != 'r')) {
		printf("Error 3: type mismatch: operand 1 in add expression must be of type integer or real.\n");
	}
	
	/* Make sure $3 is a number */
	if (($3 != 'i') && ($3 != 'r')) {
		printf("Error 3: type mismatch: operand 2 in add expression must be of types integer or real.\n");
	}
	
	/* Return the "lowest common denominator" between the two types of $1 and $3 */
	if (($1 == 'i') && ($3 == 'i')) {
		$$ = 'i';
	} else {
		$$ = 'r';
	}
}
;

term:
  factor {
	$$ = $1;
}
| term MULOP factor {
	/* Make sure $1 is a number */
	if (($1 != 'i') && ($1 != 'r')) {
		printf("Error 3: type mismatch: operand 1 in mulop expression must be of type integer or real.\n");
	}
	
	/* Make sure $3 is a number */
	if (($3 != 'i') && ($3 != 'r')) {
		printf("Error 3: type mismatch: operand 2 in mulop expression must be of type integer or real.\n");
	}
	
	/* Return the "lowest common denominator" between the two types of $1 and $3 */
	if (($1 == 'i') && ($3 == 'i')) {
		$$ = 'i';
	} else {
		$$ = 'r';
	}
}
;

factor:
  ID {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);

	/* Check every scope from here to global to see if ID exists */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_fac1;
			}
		}
	}

	/* Return error if it does not */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_fac1;
	
	end_fac1:
		this_symbol = get_sym(hash, this_symbol);
		
		if ((!(this_symbol->stype == 'i') || (this_symbol->stype == 'r'))) {
			printf("Error 3: type mismatch: cannot use any type except integer or real as a variable.\n");
			goto fail_fac1;
		}
		
		$$ = this_symbol->type;
		free(this_symbol);
	fail_fac1:
		printf("Ended checking validity of ID.");
}
| ID OPAR expression_list CPAR {
	/* TODO: ARGUMENTSSSSS */

	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);
	
	/* Look for the symbol in every scope from here to global */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_fac2;
			}
		}
	}

	/* If we do not find it, error. */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_fac2;
	
	end_fac2:
		this_symbol = get_sym(hash, this_symbol);
		
		if (!(this_symbol->stype == 'f')) {
			printf("Error 3: type mismatch: cannot send parameters to non-function identifier.\n");
			goto fail_fac2;
		}
		
		$$ = this_symbol->type;
	fail_fac2:
		free(this_symbol);
}
| ID OBRAC expression CBRAC {
	SYM *this_symbol = new_symbol();
	set_symbol(this_symbol, $1, 'u', 'u', scope);
	
	/* 'expression' MUST evaluate to an integer, since it is an index. */
	if (!($3 == 'i')) {
		printf("Error 3: type mismatch: cannot access non-integer index in an array.\n");
		goto fail_fac3;
	}

	/* Look for the symbol in every scope from here to global */
	if (!check_find_sym(hash, this_symbol)) {
		while (this_symbol->scope > 0) {
			(this_symbol->scope)--;
			
			if (check_find_sym(hash, this_symbol)) {
				goto end_fac3;
			}
		}
	}

	/* If we do not find it, error. */
	printf("Error 2: usage of undeclared variable\n");
	goto fail_fac3;
	
	end_fac3:
		this_symbol = get_sym(hash, this_symbol);
		
		if (!(this_symbol->stype == 'a')) {
			printf("Error 3: type mismatch: cannot access element of non-array variable.\n");
			goto fail_fac3;
		}
		
		$$ = this_symbol->type;
	fail_fac3:
		free(this_symbol);
}
| INT {
	$$ = 'i';
}
| REALNO {
	$$ = 'r';
}
| OPAR expression CPAR {
	$$ = $2;
}
| NOT factor {
	$$ = $2;
}
;

sign:
  ADDOP
;

%%

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}

main(int argc, char *argv[]) 
{
  extern FILE *yyin;
  ++argv; --argc;
  yyin = fopen(argv[0], "r");
    
	/* Initialize the hash table */
	init_table(hash);
	yyparse();
  print_hash(hash);

}

