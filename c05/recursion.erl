-module(recursion).
-export([dup/2, dup_tr/2, len/1, fac/1, fac_tr/1]).

%% Naive term to list duplicator.
dup(0, _) ->
    [];
dup(N, Term) when N > 0 ->
    [Term | dup(N-1, Term)].

%% Tail recursiveterm to list duplicator.
dup_tr(0, _) ->
    [];
dup_tr(N, Term) ->
    dup_tr(N, Term, []).
dup_tr(N, Term, Acc) when N > 0 ->
    dup_tr(N-1, Term, [Acc | Term]).


%% Naive list length.
len([]) ->
    0;
len([_]) ->
    1;
len([_|T]) ->
    1 + len(T).


%% Naive factorial.
fac(0) ->
    1;
fac(N) when N > 0 ->
    N * fac(N-1).

%% Tail recursive
fac_tr(N) ->
    fac_tr(N, 1).
fac_tr(0, Acc) ->
    Acc;
fac_tr(N, Acc) when N > 0 ->
    fac_tr(N-1, N*Acc).
