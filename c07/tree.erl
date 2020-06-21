-module(tree).
-export([empty/0, insert/3, tsize/1, depth/1, lookup/2]).

empty() ->
    {node, nil}.

insert(Key, Val, {node, nil}) ->
    {node, Key, Val, empty(), empty()};
insert(Key, Val, {node, K, V, L, R}) when Key < K ->
    {node, K, V, insert(Key, Val, L), R};
insert(Key, Val, {node, K, V, L, R}) when Key > K ->
    {node, K, V, L, insert(Key, Val, R)};
insert(Key, Val, {node, Key, _, L, R}) ->
    {node, Key, Val, L, R}.

tsize({node, nil}) ->
    0;
tsize({node, _Key, _Val, L, R}) ->
    1 + tsize(L) + tsize(R).

depth({node, nil}) ->
    0;
depth({node, _Key, _Val, L, R}) ->
    1 + max(depth(L), depth(R)).

lookup(Key, Tree) ->
    try lookup1(Key, Tree) of
        undefined -> undefined
    catch
        Val -> Val
    end.

lookup1(_, {node, nil}) ->
    undefined;
lookup1(Key, {node, Key, Val, _, _})  ->
    throw(Val);
lookup1(Key, {node, K, _, L, _}) when Key < K ->
    lookup1(Key, L);
lookup1(Key, {node, K, _, _, R}) when Key > K ->
    lookup1(Key, R).
