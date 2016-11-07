
%left LP RP.
%nonassoc COMMA.
//%left PLUS MINUS.
//%right EXP NOT.

%token_type {Token}  
   

%syntax_error {  

    //yyerror(yytext);

    int len =strlen(yytext)+100; 
    char msg[len];

    snprintf(msg, len, "Syntax error in AGGREGATE line %d near '%s'", yylineno, yytext);

    ctx->ok = 0;
    ctx->errorMsg = strdup(msg);
}   
   
%include {   

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "token.h"
#include "parser.h"
#include "ast.h"
#include "../rmutil/alloc.h"

extern int yylineno;
extern char *yytext;

typedef struct {
    ParseNode *root;
    int ok;
    char *errorMsg;
}parseCtx;


void yyerror(char *s);
    
} // END %include  

%extra_argument { parseCtx *ctx }


query ::= func(A). { ctx->root = A; }

%type func {ParseNode*}
%destructor cond { FuncNode_Free($$); }

func(A) ::= ident(B) LP ident(C) RP. { 
    /* Terminal condition of a single predicate */
    A = NewFuncNode(B, C);
}

func(A) ::= ident(B) LP arglist(C) RP. { 
    /* Terminal condition of a single predicate */
    A = NewFuncNode(B, C);
}

%type value {SIValue}

// raw value tokens - int / string / float
value(A) ::= INTEGER(B). {  A = SI_LongVal(B.intval); }
value(A) ::= STRING(B). {  A = SI_StringValC(strdup(B.strval)); }
value(A) ::= FLOAT(B). {  A = SI_DoubleVal(B.dval); }
value(A) ::= TRUE. { A = SI_BoolVal(1); }
value(A) ::= FALSE. { A = SI_BoolVal(0); }

%type vallist {SIValueVector}
%type multivals {SIValueVector}
%destructor vallist {SIValueVector_Free(&$$);}
%destructor multivals {SIValueVector_Free(&$$);}

vallist(A) ::= LP multivals(B) RP. {
    A = B;
    
}
multivals(A) ::= value(B) COMMA value(C). {
      A = SI_NewValueVector(2);
      SIValueVector_Append(&A, B);
      SIValueVector_Append(&A, C);
}

multivals(A) ::= multivals(B) COMMA value(C). {
    SIValueVector_Append(&B, C);
    A = B;
}


%type prop {property}
%destructor prop {
     
    if ($$.name != NULL) { 
        free($$.name); 
        $$.name = NULL;
    } 
}
// property enumerator
prop(A) ::= ENUMERATOR(B). { A.id = B.intval; A.name = NULL;  }
prop(A) ::= IDENT(B). { A.name = B.strval; A.id = 0;  }

%code {

  /* Definitions of flex stuff */
 // extern FILE *yyin;
  typedef struct yy_buffer_state *YY_BUFFER_STATE;
  int             yylex( void );
  YY_BUFFER_STATE yy_scan_string( const char * );
  YY_BUFFER_STATE yy_scan_bytes( const char *, size_t );
  void            yy_delete_buffer( YY_BUFFER_STATE );
  
  


ParseNode *ParseQuery(const char *c, size_t len, char **err)  {

    //printf("Parsing query %s\n", c);
    yy_scan_bytes(c, len);
    void* pParser = ParseAlloc (malloc);        
    int t = 0;

    parseCtx ctx = {.root = NULL, .ok = 1, .errorMsg = NULL };
    //ParseNode *ret = NULL;
    //ParserFree(pParser);
    while (ctx.ok && 0 != (t = yylex())) {
        Parse(pParser, t, tok, &ctx);                
    }
    if (ctx.ok) {
        Parse (pParser, 0, tok, &ctx);
    }
    ParseFree(pParser, free);
    if (err) {
        *err = ctx.errorMsg;
    }
    return ctx.root;
  }
   


}
