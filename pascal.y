%{
  #include <stdio.h>
  #include "custom.h" 
  int yylex(void);
  void yyerror(char *);
%}

%union{
	int num;
	char* str;
}

%token <num> CONST_INTEGER
%token BLOCK_BEGIN
%token BLOCK_END
%token DEF_INTEGER
%token SEMICOLON
%token ASSIGNMENT
%token START_PROGRAM
%token PERIOD
%token COLON
%token DOUBLE_QUOTES
%token <str> VARIABLE


%type <str> program block math definition assignment stmt stmt_list main_block program_definition function var_list const_string
%type <num> const_val

%%
 
program:
	program_definition				{ printf("%s\n", $1); }
	;

program_definition:	
	START_PROGRAM VARIABLE SEMICOLON main_block	{ $$ = strconcat("int main() ", $4);}
	;

main_block:
	BLOCK_BEGIN stmt_list BLOCK_END PERIOD		{ $$ = strconcat("{", strconcat($2,"}")); }

const_val:
	CONST_INTEGER						{ $$ = $1; }

block:
	BLOCK_BEGIN stmt_list BLOCK_END	SEMICOLON	{ $$ = strconcat("{", strconcat($2,"}")); }

stmt_list:
	stmt						{ $$ = $1; }
	| stmt_list stmt				{ $$ = strconcat($1, $2); }
stmt:
	math						{ $$ = $1; }
	| definition	 				{ $$ = $1; }
	| assignment 					{ $$ = $1; }
	| function					{ $$ = $1; }
	| block						{ $$ = $1; }
math:
	const_val SEMICOLON				{ $$ = strconcat(intToStr($1), ";"); }
	| const_val '+' const_val SEMICOLON		{ $$ = strconcat(intToStr($1), strconcat("+", strconcat(intToStr($3), ";"))); }
	| const_val '-' const_val SEMICOLON		{ $$ = strconcat(intToStr($1), strconcat("-", strconcat(intToStr($3), ";"))); }
	| const_val '*' const_val SEMICOLON		{ $$ = strconcat(intToStr($1), strconcat("*", strconcat(intToStr($3), ";"))); }
	| const_val '/' const_val SEMICOLON		{ $$ = strconcat(intToStr($1), strconcat("/", strconcat(intToStr($3), ";"))); }

definition:
	VARIABLE COLON DEF_INTEGER SEMICOLON		{ $$ = strconcat("int ", strconcat($1, ";"));}

assignment:
	VARIABLE ASSIGNMENT math			{ $$ = strconcat($1, strconcat("=",$3)); }

function:
	VARIABLE '(' VARIABLE ')' SEMICOLON		{ $$ = strconcat(findCVariant($1), strconcat("(", strconcat($3, strconcat(")", ";")))); }
	| VARIABLE '(' const_string ')' SEMICOLON	{ $$ = strconcat(findCVariant($1), strconcat("(", strconcat($3, strconcat(")", ";")))); }

var_list:
	VARIABLE					{ $$ = $1; }
	| var_list VARIABLE				{ $$ = strconcat($1, strconcat(" ",$2)); }

const_string:
	DOUBLE_QUOTES var_list DOUBLE_QUOTES 		{ $$ = strconcat("\"", strconcat($2, "\"")); }


%%
void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

int main(void) {
	generateHeader();
	yyparse();
	return 0;
}

