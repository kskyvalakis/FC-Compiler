%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "cgen.h"

  extern int yylex(void);
  extern int lineNum;
  
%}

%union
{
  char* str;
}

%define parse.trace
%debug

%right OP_NOT
%left OP_INC OP_DEC OP_MINUS OP_PLUS OP_MULT OP_DIV OP_MOD OP_AND OP_OR OP_EQ OP_LESS OP_GREATER OP_GEQ OP_LEQ OP_NEQ PAR_RIGHT PAR_LEFT BR_RIGHT BR_LEFT OP_SEMICOLON OP_COMMA OP_ASSIGNMENT

%nonassoc KW_ELSE

%token <str> IDENTIFIER
%token <str> INTEGER
%token <str> FLOAT
%token <str> STRING
%token <str> CHAR

%token KW_VOID KW_INTEGER KW_STATIC KW_BOOLEAN KW_CHAR KW_REAL KW_STRING RD_STR RD_INT RD_REAL WR_STR WR_INT WR_REAL
%token KW_BEGIN KW_END KW_RETURN KW_FOR KW_WHILE KW_DO KW_CONTINUE KW_BREAK KW_IF KW_THEN KW_ELSE KW_TRUE KW_FALSE

%type <str> data_types
%type <str> postfix_expression
%type <str> argument_list
%type <str> unary_operation
%type <str> operation_expression
%type <str> relational_expression
%type <str> assignment_expression
%type <str> expression

%type <str> statement
%type <str> begin_end_statement
%type <str> expression_statement
%type <str> for_expression_statement
%type <str> if_statement
%type <str> jump_statement
%type <str> loop_statement
%type <str> statement_list
%type <str> declaration_list

%type <str> declaration
%type <str> declaration_specifiers
%type <str> init_declarator
%type <str> type_specifier
%type <str> declarator
%type <str> parameter_list
%type <str> array_declare

%type <str> translation_unit
%type <str> global_declaration
%type <str> function_declaration
%type <str> program

%start program

%%
/*******************************************************************
* Expressions
*******************************************************************/

data_types
	: IDENTIFIER         { $$ = template("%s", $1); }
	| INTEGER            { $$ = template("%s", $1); }
	| FLOAT              { $$ = template("%s", $1); }
	| STRING             { $$ = template("%s", $1); }	
	| CHAR               { $$ = template("%s", $1); }	
	;

postfix_expression
	: data_types                                                      { $$ = template("%s",$1); }
	| PAR_LEFT expression PAR_RIGHT   				  { $$ = template("(%s)", $2); } 	
	| IDENTIFIER PAR_LEFT PAR_RIGHT                                   { $$ = template("%s()",$1); }
	| IDENTIFIER PAR_LEFT argument_list PAR_RIGHT                     { $$ = template("%s(%s)",$1,$3); }
	| IDENTIFIER BR_LEFT operation_expression BR_RIGHT array_declare  { $$ = template("%s[%s]%s",$1,$3,$5); }	
	;	

argument_list                                    
	: relational_expression                              	    { $$ = template("%s", $1); }
	| argument_list OP_COMMA relational_expression   	    { $$ = template("%s,%s", $1,$3); }
	;

unary_operation
	: postfix_expression               { $$ = template("%s",$1); }     
	| OP_PLUS unary_operation  	   { $$ = template("+%s",$2); }
	| OP_MINUS unary_operation  	   { $$ = template("-%s",$2); }
	| unary_operation OP_INC           { $$ = template("%s++",$1); }
	| unary_operation OP_DEC           { $$ = template("%s--",$1); }
	| OP_NOT unary_operation  	   { $$ = template("!%s",$2); }
	;

operation_expression
	: unary_operation                                      { $$ = template("%s", $1); }
	| operation_expression OP_PLUS operation_expression    { $$ = template("%s + %s", $1,$3); }
	| operation_expression OP_MINUS operation_expression   { $$ = template("%s - %s", $1,$3); }	
	| operation_expression OP_MULT operation_expression    { $$ = template("%s * %s", $1,$3); }
	| operation_expression OP_DIV operation_expression     { $$ = template("%s / %s", $1,$3); }
	| operation_expression OP_MOD operation_expression     { $$ = template("%s %c %s", $1,'%',$3); }
	;

relational_expression
	: operation_expression                                   { $$ = template("%s", $1); }
	| relational_expression OP_LESS relational_expression    { $$ = template("%s < %s", $1,$3); }
	| relational_expression OP_GREATER relational_expression { $$ = template("%s > %s", $1,$3); }
	| relational_expression OP_LEQ relational_expression     { $$ = template("%s <= %s", $1,$3); }
	| relational_expression OP_GEQ relational_expression     { $$ = template("%s >= %s", $1,$3); }
	| relational_expression OP_EQ relational_expression      { $$ = template("%s == %s", $1,$3); }
	| relational_expression OP_NEQ relational_expression     { $$ = template("%s != %s", $1,$3); }
	| relational_expression OP_AND relational_expression     { $$ = template("%s && %s", $1,$3); }
	| relational_expression OP_OR relational_expression      { $$ = template("%s || %s", $1,$3); }	
	;

assignment_expression
	: relational_expression                               	{ $$ = template("%s", $1); }
	| unary_operation OP_ASSIGNMENT assignment_expression   { $$ = template("%s = %s", $1,$3); }
	;

expression
	: assignment_expression                                { $$ = template("%s", $1); }
	| expression OP_COMMA assignment_expression            { $$ = template("%s , %s", $1,$3); }
	;


/*******************************************************************
* Statements
*******************************************************************/

statement
	: begin_end_statement      { $$ = template("%s",$1); }
	| expression_statement     { $$ = template("%s",$1); }
	| if_statement      	   { $$ = template("%s",$1); }
	| jump_statement           { $$ = template("%s",$1); }
	| loop_statement           { $$ = template("%s",$1); }
	;

statement_list
	: statement                { $$ = template("%s",$1); }
	| statement_list statement { $$ = template("%s %s",$1,$2); }
	;
	
declaration_list
	: declaration                { $$ = template("%s",$1); }
	| declaration_list declaration { $$ = template("%s %s",$1,$2); }
	;	

begin_end_statement
	: KW_BEGIN KW_END                       	       { $$ = template("\n{\n}\n\n"); }
	| KW_BEGIN statement_list KW_END                       { $$ = template("\n{\n %s}\n\n",$2); }
	| KW_BEGIN declaration_list KW_END       	       { $$ = template("\n{\n %s}\n\n",$2); }	
	| KW_BEGIN declaration_list statement_list KW_END      { $$ = template("{\n %s %s \n}\n",$2,$3); }	
	;

expression_statement
	: expression OP_SEMICOLON   { $$ = template("%s;\n",$1); }
	| OP_SEMICOLON              { $$ = template(";\n"); }
	;

for_expression_statement
	: expression OP_SEMICOLON   { $$ = template("%s;",$1); }
	| OP_SEMICOLON              { $$ = template(";"); }
	;

if_statement
	: KW_IF PAR_LEFT expression PAR_RIGHT statement                     { $$ = template("%s( %s ) %s","if",$3,$5); }
	| KW_IF PAR_LEFT expression PAR_RIGHT statement KW_ELSE statement   { $$ = template("%s( %s )\n %s %s %s\n","if",$3,$5,"else",$7); }
	;

jump_statement
	: KW_CONTINUE OP_SEMICOLON             { $$ = template("continue;\n"); }
	| KW_BREAK OP_SEMICOLON                { $$ = template("break;\n"); }
	| KW_RETURN OP_SEMICOLON               { $$ = template("return;\n"); }
	| KW_RETURN expression OP_SEMICOLON    { $$ = template("return %s;\n",$2); }
	;

loop_statement
	: KW_WHILE PAR_LEFT expression PAR_RIGHT statement                                           	     { $$ = template("%s( %s ) %s\n","while",$3,$5); }              
	| KW_DO statement KW_WHILE PAR_LEFT expression PAR_RIGHT OP_SEMICOLON                        	     { $$ = template("%s\n %s\n %s( %s );\n","do",$2,"while",$5); }
	| KW_FOR PAR_LEFT for_expression_statement for_expression_statement PAR_RIGHT statement              { $$ = template("%s(%s %s) %s","for",$3,$4,$6); }
	| KW_FOR PAR_LEFT for_expression_statement for_expression_statement expression PAR_RIGHT statement   { $$ = template("%s(%s %s %s) %s","for",$3,$4,$5,$7); }
	;
	

/*******************************************************************
* Declarations
*******************************************************************/

type_specifier
	: KW_VOID 	{ $$ = template("%s", "void"); }
	| KW_CHAR 	{ $$ = template("%s", "char"); }
	| KW_INTEGER    { $$ = template("%s", "int"); }
	| KW_BOOLEAN    { $$ = template("%s", "int"); }
	| KW_REAL 	{ $$ = template("%s", "double"); }
	| KW_STRING     { $$ = template("%s", "char*"); }
	;

parameter_list
	: declaration_specifiers declarator           				 { $$ = template("%s %s",$1,$2); }
	| parameter_list OP_COMMA declaration_specifiers declarator  		 { $$ = template("%s,%s %s",$1,$3,$4); }
	| parameter_list OP_COMMA declaration_specifiers 			 { $$ = template("%s,%s",$1,$3); }
	;

declarator
	: IDENTIFIER                                                      { $$ = template("%s",$1); }
	| IDENTIFIER PAR_LEFT PAR_RIGHT                                   { $$ = template("%s()",$1); }
	| IDENTIFIER PAR_LEFT parameter_list PAR_RIGHT                    { $$ = template("%s(%s)",$1,$3); }
	| IDENTIFIER BR_LEFT operation_expression BR_RIGHT array_declare  { $$ = template("%s[%s]%s",$1,$3,$5); }	
	;	

array_declare
	: %empty                                          	 { $$ = template(""); }
	| BR_LEFT operation_expression BR_RIGHT array_declare       { $$ = template("[%s]%s",$2,$4); }
	;
	
init_declarator
	: declarator                                           	 { $$ = template("%s",$1); }
	| declarator OP_ASSIGNMENT assignment_expression         { $$ = template("%s=%s",$1,$3); }
	| init_declarator OP_COMMA init_declarator               { $$ = template("%s,%s",$1,$3); }	
	;  

declaration_specifiers
	: KW_STATIC type_specifier            { $$ = template("static %s",$2); }
	| type_specifier                      { $$ = template("%s",$1); }
	;

declaration
	: declaration_specifiers init_declarator OP_SEMICOLON      { $$ = template("%s %s;\n", $1,$2); }
	;


/*******************************************************************
* Program
*******************************************************************/

program
    	: %empty                        { $$ = template(""); printf("Empty input .fc code file.\nPlease give a proper code file.\nResult: Rejected!\n"); exit(0);}
    	| translation_unit              
    	{ 
        	$$ = template("%s",$1); 
        	if (yyerror_count == 0) 
        	{
            		printf("\n********************** C Code ********************** \n");
            		printf("\n%s\n", $1);
            		printf("\n********************** C Code ********************** \n");
            		printf("\nSaving code in output.c for further use.\n");
            	        FILE *fp = fopen("output.c","w");
            	        fputs("#include <stdio.h>\n",fp);
		        fputs(c_prologue,fp);
            		fprintf(fp,"%s", $1); 
			fclose(fp);           		
        	}
        	else
        	{
            		printf("\nCompilation error!\n");
            		printf("\nResult: Rejected!\n");
            		exit(0); 
        	}
    	}                               
    	;
	
translation_unit
	: global_declaration                     { $$ = template("%s",$1); }
	| translation_unit global_declaration    { $$ = template("%s %s",$1,$2); }	
	;

global_declaration
	: function_declaration  { $$ = template("%s",$1); }
	| declaration           { $$ = template("%s",$1); } 
	;  

function_declaration
	: declaration_specifiers IDENTIFIER PAR_LEFT parameter_list PAR_RIGHT begin_end_statement       { $$ = template("%s %s(%s) %s",$1,$2,$4,$6); }
	| declaration_specifiers IDENTIFIER PAR_LEFT PAR_RIGHT begin_end_statement                      { $$ = template("%s %s() %s",$1,$2,$5);}	
	;


%%
int main ()
{
  if ( yyparse() == 0 )
    printf("\nResult: Accepted!\n");
  else  
    printf("\nResult: Rejected!\n");
}
