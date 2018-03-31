%{
  #include <stdio.h>
  #include <string.h>  
  #include "cgen.h"
  #include "fc_bison.tab.h"
  int lineNum = 1;
%}

DIGIT       [0-9]
NUMBER      {DIGIT}{DIGIT}* 
DECIMAL     ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
ID          [a-zA-Z_][0-9a-zA-Z_]*
REAL	    {DECIMAL}([eE][+-]?{NUMBER})?
STRING      \"(\\.|[^\\"])*\"
CHAR	    \'(\\.|[^\\"\'])*\'
       
%%

begin		  {printf("Line %d: Token KEYWORD_BEGIN: %s\n",  lineNum, yytext); return KW_BEGIN;}
end		  {printf("Line %d: Token KEYWORD_END: %s\n",  lineNum, yytext); return KW_END;}
return		  {printf("Line %d: Token KEYWORD_RETURN: %s\n",  lineNum, yytext); return KW_RETURN;}
integer		  {printf("Line %d: Token KEYWORD_INTEGER: %s\n",  lineNum, yytext); return KW_INTEGER;}
static		  {printf("Line %d: Token KEYWORD_STATIC: %s\n",  lineNum, yytext); return KW_STATIC;}
boolean		  {printf("Line %d: Token KEYWORD_BOOLEAN: %s\n",  lineNum, yytext); return KW_BOOLEAN;}
char		  {printf("Line %d: Token KEYWORD_CHAR: %s\n",  lineNum, yytext); return KW_CHAR;}
real		  {printf("Line %d: Token KEYWORD_REAL: %s\n",  lineNum, yytext); return KW_REAL;}
true		  {printf("Line %d: Token KEYWORD_TRUE: %s\n",  lineNum, yytext); yylval.str = strdup("1"); return INTEGER;}
false		  {printf("Line %d: Token KEYWORD_FALSE: %s\n",  lineNum, yytext); yylval.str = strdup("0"); return INTEGER;}
string		  {printf("Line %d: Token KEYWORD_STRING: %s\n",  lineNum, yytext); return KW_STRING;}
void		  {printf("Line %d: Token KEYWORD_VOID: %s\n",  lineNum, yytext); return KW_VOID;}
for		  {printf("Line %d: Token KEYWORD_FOR: %s\n",  lineNum, yytext); return KW_FOR;}
while		  {printf("Line %d: Token KEYWORD_WHILE: %s\n",  lineNum, yytext); return KW_WHILE;}
do		  {printf("Line %d: Token KEYWORD_DO: %s\n",  lineNum, yytext); return KW_DO;}
continue	  {printf("Line %d: Token KEYWORD_CONTINUE: %s\n",  lineNum, yytext); return KW_CONTINUE;}
break		  {printf("Line %d: Token KEYWORD_BREAK: %s\n",  lineNum, yytext); return KW_BREAK;}
if		  {printf("Line %d: Token KEYWORD_IF: %s\n",  lineNum, yytext); return KW_IF;}
else		  {printf("Line %d: Token KEYWORD_ELSE: %s\n",  lineNum, yytext); return KW_ELSE;}

")"		  {printf("Line %d: Token PARENTHESIS_RIGHT: %s\n",  lineNum, yytext); return PAR_RIGHT;}
"("		  {printf("Line %d: Token PARENTHESIS_LEFT: %s\n",  lineNum, yytext); return PAR_LEFT;}
"["		  {printf("Line %d: Token BRACKET_LEFT: %s\n",  lineNum, yytext); return BR_LEFT;}
"]"		  {printf("Line %d: Token BRACKET_RIGHT: %s\n",  lineNum, yytext); return BR_RIGHT;}
"not"|"!"         {printf("Line %d: Token OP_NOT: %s\n",  lineNum, yytext); return OP_NOT;}
"+"   		  {printf("Line %d: Token OP_PLUS: %s\n",  lineNum, yytext); return OP_PLUS;}
"-"   		  {printf("Line %d: Token OP_MINUS: %s\n",  lineNum, yytext); return OP_MINUS;}
"++"		  {printf("Line %d: Token OP_INCREMENT: %s\n",  lineNum, yytext); return(OP_INC); }
"--"		  {printf("Line %d: Token OP_DECREMENT: %s\n",  lineNum, yytext); return(OP_DEC); }
"*"   		  {printf("Line %d: Token OP_MULT: %s\n",  lineNum, yytext); return OP_MULT;}
"/"   		  {printf("Line %d: Token OP_DIV: %s\n",  lineNum, yytext); return OP_DIV;}
"mod"             {printf("Line %d: Token OP_MOD: %s\n",  lineNum, yytext); return OP_MOD;}
"="   		  {printf("Line %d: Token OP_EQUAL: %s\n",  lineNum, yytext); return OP_EQ;}
"!="   		  {printf("Line %d: Token OP_NOT_EQUAL: %s\n",  lineNum, yytext); return OP_NEQ;}
"<"   		  {printf("Line %d: Token OP_LESS: %s\n",  lineNum, yytext); return OP_LESS;}
">"   		  {printf("Line %d: Token OP_GREATER: %s\n",  lineNum, yytext); return OP_GREATER;}
"<="   		  {printf("Line %d: Token OP_LEQ: %s\n",  lineNum, yytext); return OP_LEQ;}
">="   		  {printf("Line %d: Token OP_GEQ: %s\n",  lineNum, yytext); return OP_GEQ;}
"and"|"&&"        {printf("Line %d: Token OP_AND: %s\n",  lineNum, yytext); return OP_AND;}
"or"|"||"         {printf("Line %d: Token OP_OR: %s\n",  lineNum, yytext); return OP_OR;}
":="   		  {printf("Line %d: Token ASSIGNMENT: %s\n",  lineNum, yytext); return OP_ASSIGNMENT;}
";"   		  {printf("Line %d: Token SEMICOLON %s\n",  lineNum, yytext); return OP_SEMICOLON;}
","		  {printf("Line %d: Token COMMA %s\n",  lineNum, yytext); return OP_COMMA;}

{NUMBER}          {yylval.str = strdup(yytext); printf("Line %d: Token CONST_INTEGER: %s\n", lineNum, yytext); return INTEGER;}
{REAL}            {yylval.str = strdup(yytext); printf("Line %d: Token CONST_REAL: %s\n", lineNum, yytext); return FLOAT;}
{ID}              {yylval.str = strdup(yytext); printf("Line %d: Token IDENTIFIER: %s\n", lineNum, yytext); return IDENTIFIER;}
{STRING}          {yylval.str = strdup(yytext); printf("Line %d: Token STRING: %s\n", lineNum, yytext); return STRING;}
{CHAR}            {yylval.str = strdup(yytext); printf("Line %d: Token CHAR: %s\n", lineNum, yytext); return CHAR;}

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] {printf("Line %d: Token MULTILINE_COMMENT:\n%s\n", lineNum, yytext);}	/* multiline comment */
"//".*				    {printf("Line %d: Token LINE_COMMENT: %s\n", lineNum, yytext);} 		/* eat one line comments */

[ \r\t]+	  /* skip whitespace */
\n 		  ++lineNum;
<<EOF>> 	  return EOF;
.           	  {printf("Unrecognized token %s in line %d.\n", yytext, lineNum); exit(0);}
