%% @author Jay Kickliter
%% @doc Implementation of a reverse polish notation calculator.

-module(calc).
-export([rpn/1, test_rpn/0]).

rpn(L) when is_list(L) ->
    [Res] = lists:foldl(fun rpn/2, [], string:lexemes(L, " ")),
    Res.

rpn("+",[X,Y|S]) ->
    [Y + X|S];
rpn("*",[X,Y|S]) ->
    [Y * X|S];
rpn("/",[X,Y|S]) ->
    [Y / X|S];
rpn("^",[X,Y|S]) ->
    [math:pow(Y,X)|S];
rpn("ln",[X|S]) ->
    [math:log(X)|S];
rpn("log",[X|S]) ->
    [math:log10(X)|S];
rpn("dup",[X|S]) ->
    [X,X|S];
rpn("swap",[X,Y|S]) ->
    [Y,X|S];
rpn(X,Stack) ->
    [parse_num(X)|Stack].

parse_num(N) ->
    case string:to_float(N) of
        {error,no_float} -> list_to_integer(N);
        {F,[]} -> F
    end.

test_rpn() ->
    2+3 = rpn("2 3 +"),
    (100*7+3) = rpn("100 7 * 3 +"),
    true = math:log(105) =:= rpn("105 ln"),
    ok.
