%{

#include "token.h"
#include "parser.h"
#include <string.h>
#include <math.h>

Token tok;

%}

%%

"AND"         { return AND; }
"OR"         { return OR; }

\$[0-9]{1} {    
                tok.intval = atoi(yytext+1); 
                return ENUMERATOR; 
}
 
[0-9]*\.[0-9]+    {  
                    tok.dval = atof(yytext); 
                    return FLOAT; 
}

[\-\+]?[0-9]+    {   
  tok.intval = atoi(yytext); 
  return INTEGER; 
}

\"[^\"]*\"     {

  *(yytext+strlen(yytext)-1) = '\0';
  tok.strval = yytext+1; 
  return STRING; 
}

                                                                                               
"="           {  return EQ; }
"!="           {  return NE; }
">="           {  return GE; }
"<="           {  return LE; }
">"           {  return GT; }
"<"           {  return LT; }
"("           { return LP; }
")"           { return RP; }

%%


/**
 * yyerror() is invoked when the lexer or the parser encounter
 * an error. The error message is passed via *s
 *
 *
 */
void yyerror(char *s)
{
  printf("error: %s at line: %d\n",s,yylineno);
}

int yywrap(void)
{
  return 1;
}
