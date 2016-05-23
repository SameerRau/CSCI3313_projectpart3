%{
#include "y.tab.h"
#include <string.h>
%}

%%

"<="	    {yylval.integer = 1; printf("RELOP: %s\n", yytext); return RELOP;}
">="	    {yylval.integer = 2; printf("RELOP: %s\n", yytext); return RELOP;}
"<>"	    {yylval.integer = 3; printf("RELOP: %s\n", yytext); return RELOP;}
"<"	      {yylval.integer = 4; printf("RELOP: %s\n", yytext); return RELOP;}
">"	      {yylval.integer = 5; printf("RELOP: %s\n", yytext); return RELOP;}
"="	      {yylval.integer = 6; printf("RELOP: %s\n", yytext); return RELOP;}
":="	    {printf("ASSIGNOP: %s\n", yytext); return ASSIGNOP;}
".."	    {printf("SEQUENCE: %s\n", yytext); return SEQUENCE;}
[+\-]	    {printf("ADDOP: %s\n", yytext); return ADDOP;}
[*/]	    {printf("MULOP: %s\n", yytext); return MULOP;}
"."	      {printf("DOT: %s\n", yytext); return DOT;}
","	      {printf("COMMA: %s\n", yytext); return COMMA;}
";" 	    {printf("SEMICOLON: %s\n", yytext); return SEMICOLON;}
":"	      {printf("COLON: %s\n", yytext); return COLON;}
"(" 	    {printf("OPAR: %s\n", yytext); return OPAR;}
")"      	{printf("CPAR: %s\n", yytext); return CPAR;}
"["      	{printf("OBRAC: %s\n", yytext); return OBRAC;}
"]"     	{printf("CBRAC: %s\n", yytext); return CBRAC;}
[0-9]+	  {yylval.integer = atoi(yytext); printf("INT: %s\n", yytext); return INT;}
[0-9]+"."[0-9]+	{yylval.real = atof(yytext); printf("REALNO: %s\n", yytext); return REALNO;}
and	      {printf("MULOP: %s\n", yytext); return MULOP;}
array	    {printf("ARRAY: %s\n", yytext); return ARRAY;}
begin	    {printf("BEG: %s\n", yytext); return BEG;}
div	      {printf("MULOP: %s\n", yytext); return MULOP;}
do	      {printf("DO: %s\n", yytext); return DO;}
else	    {printf("ELSE: %s\n", yytext); return ELSE;}
end	      {printf("END: %s\n", yytext); return END;}
function	{printf("FUNCTION: %s\n", yytext); return FUNCTION;}
if	      {printf("IF: %s\n", yytext); return IF;}
integer	  {printf("INTEGER: %s\n", yytext); return INTEGER;}
not	      {printf("NOT: %s\n", yytext); return NOT;}
of	      {printf("OF: %s\n", yytext); return OF;}
or	      {printf("MULOP: %s\n", yytext); return MULOP;}
procedure	{printf("PROCEDURE: %s\n", yytext); return PROCEDURE;}
program	  {printf("PROGRAM: %s\n", yytext); return PROGRAM;}
real	    {printf("REAL: %s\n", yytext); return REAL;}
then	    {printf("THEN: %s\n", yytext); return THEN;}
var	      {printf("VAR: %s\n", yytext); return VAR;}
while	    {printf("WHILE: %s\n", yytext); return WHILE;}
[a-z][a-zA-Z0-9]*	{yylval.string = (char*)strdup(yytext); printf("ID: %s\n", yytext); return ID;}
[ \t\r\n]+	{printf("Ignoring whitespace (or tab, newline).\n");}
.	{printf("Cannot tokenize unrecognized text: %s\n",yytext);}

%%
