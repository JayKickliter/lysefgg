-module(tut14).

-export([start/0, say_something/2]).

say_something(_What, 0) ->
    done;
say_something(What, Times) ->
    io:format("~p~n", [What]),
    say_something(What, Times - 1).

start() ->
    A = spawn(?MODULE, say_something, [hello, 3]),
    B = spawn(?MODULE, say_something, [goodbye, 3]),
    {A, B}.
