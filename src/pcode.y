/* pcode.y  17/01/2016  D.J.Whale */

%token ASSIGN LPAREN RPAREN LSQUARE WHEN
%token RSQUARE COMMA COLON

%token IF THEN ELSE ENDIF WHILE
%token ENDWHILE CASE OF ENDCASE FOR
%token TO ENDFOR REPEAT UNTIL FUNCTION
%token ENDFUNCTION RETURN PROCEDURE ENDPROCEDURE READLINE
%token WRITELINE OUTPUT USERINPUT LEN
%token NOT FALSE TRUE

%token ID NUMBER STRING

%left OR
%left AND
%left XOR
%left EQUAL NOTEQUAL
%left LESS GREATER LESSEQUAL GREATEREQUAL
%left PLUS MINUS
%left TIMES DIVIDE MOD
%left UNARY

%start program

%%

program:
    statements
    ;

statements:
    /* empty */
    {p[0] = ""}
    | statements statement
//    {backend.concat(p, 1, 2)}
    ;

statement:
    output_statement
    | var_assignment_statement
    | array_assignment_statement
    | if_statement
    | while_statement
    | repeat_statement
    | for_statement
    | proc_def_statement
    | proc_call_statement
    | function_def_statement
    | return_statement
    | writeline_statement
    | array2d_assignment_statement
    | array_initialiser_statement
    | case_statement
    ;

output_statement:
    OUTPUT expr
    {backend.OUTPUT(p, 2)}
    ;

var_assignment_statement:
    ID ASSIGN expr
    {backend.assign(p, 1, 3)}
    ;

array_assignment_statement:
    ID LSQUARE expr RSQUARE ASSIGN expr
    {backend.array1assign(p, 1, 3, 6)}
    ;

array2d_assignment_statement:
    ID LSQUARE expr RSQUARE LSQUARE expr RSQUARE ASSIGN expr
    {backend.array2assign(p, 1, 3, 6, 9)}
    ;

initialiser_expr:
    /* empty */
    {p[0]=""}
    | expr
    | initialiser_expr COMMA expr
    {backend.concat(p, 1, 3)}
    ;

array_initialiser_statement:
    ID ASSIGN LSQUARE initialiser_expr RSQUARE
    {backend.arrayinit(p, 1, 4)}
    ;

file:
    expr
    ;

readline_expr:
    READLINE LPAREN file COMMA expr RPAREN
    {backend.READLINE(p, 3, 5)}
    ;

writeline_statement:
    WRITELINE LPAREN file COMMA expr COMMA expr RPAREN
    {backend.WRITELINE(p, 3, 5, 7)}
    ;

//TODO must resolve the conflict here with the grammar
//dangling else solution might solve this??
if_statement:
    IF expr THEN statements ENDIF
    | IF expr THEN statements ELSE statements ENDIF
    ;

while_statement:
    WHILE expr      {backend.WHILE(p, -1)}
    statements
    ENDWHILE        {backend.ENDWHILE(p)}
    ;

repeat_statement:
    REPEAT {}
    statements
    UNTIL expr {}
//    {backend.REPEAT(p, 2, 4)}
    ;

for_statement:
    FOR ID ASSIGN expr TO expr {}
    statements
    ENDFOR {}
//    {backend.FOR(p, 2, 4, 6, 7)}
    ;

case_option:
    WHEN expr COLON {} statements // <-- 'WHEN' added to resolve grammar ambiguity
//    {backend.caseoption(p, 2, 4)}
    ;

case_options:
    /* empty */
    {p[0]=""}
    | case_options case_option
//    {backend.concat(p, 1, 2)}
    ;

case_statement:
    CASE expr OF {}
    case_options
    ELSE {}
    statements
    ENDCASE {}
//    {backend.CASE(p, 2, 4, 6)}
    ;

fnproc_def_params:
    /* empty */
    {p[0]=""}
    | ID
    | fnproc_def_params COMMA ID
//    {backend.defparams(p, 1, 3)} // concat?
    ;

function_def_statement:
    FUNCTION ID LPAREN fnproc_def_params RPAREN {}
    statements
    ENDFUNCTION {}
//    {backend.FUNCTION(p, 2, 4, 6)}
    ;

return_statement:
    RETURN expr
    {backend.RETURN(p, 2)}
    ;

proc_def_statement:
    PROCEDURE ID LPAREN fnproc_def_params RPAREN {}
    statements
    ENDPROCEDURE {}
//    {backend.PROCEDURE(p, 2, 4, 6)}
    ;

fnproc_call_params:
    /* empty */
    {p[0]=""}
    | expr
    | fnproc_call_params COMMA expr
//    {backend.callparams(p, 1, 3)} // concat?
    ;

proc_call_statement:
    ID LPAREN fnproc_call_params RPAREN
    {backend.proccall(p, 1, 3)}
    ;

fn_call_expr:
    ID LPAREN fnproc_call_params RPAREN
    {backend.fncall(p, 1, 3)}
    ;

expr:
      TRUE
    | FALSE
    | NUMBER                    {backend.number(p, 1)}
    | ID                        {backend.id(p, 1)}
    | STRING                    {backend.string(p, 1)}
    | LPAREN expr RPAREN        {p[0] = p[2]}
    | USERINPUT                 {backend.USERINPUT(p)}
    | LEN LPAREN ID RPAREN      {backend.LEN(p, 3)}
    | expr PLUS expr            {backend.plus(p, 1, 3)}
    | expr MINUS expr           {backend.minus(p, 1, 3)}
    | expr TIMES expr           {backend.times(p, 1, 3)}
    | expr DIVIDE expr          {backend.divide(p, 1, 3)}
    | expr MOD expr             {backend.MOD(p, 1, 3)}
    | MINUS expr %prec UNARY    {backend.uminus(p,2)}
    | PLUS expr                 {backend.uplus(p, 2)}
    | NOT expr %prec UNARY      {backend.NOT(p, 2)}
    | expr EQUAL expr           {backend.equal(p, 1, 3)}
    | expr NOTEQUAL expr        {backend.notequal(p, 1, 3)}
    | expr LESSEQUAL expr       {backend.lessequal(p, 1, 3)}
    | expr GREATEREQUAL expr    {backend.greaterequal(p, 1, 3)}
    | expr GREATER expr         {backend.greater(p, 1, 3)}
    | expr LESS expr            {backend.less(p, 1, 3)}
    | expr AND expr             {backend.AND(p, 1, 3)}
    | expr OR expr              {backend.OR(p, 1, 3)}
    | expr XOR expr             {backend.XOR(p, 1, 3)}
    | readline_expr
    | fn_call_expr
    ;


%%

backend = None
def set_backend(b):
    global backend
    backend = b
