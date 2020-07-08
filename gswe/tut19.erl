-module(tut19).

-export([start_ping/1, start_pong/0, ping/2, pong/0]).

ping(0, _Pong_Node) ->
    io:format("ping finished~n");
ping(N, Pong_Node) ->
    {pong, Pong_Node} ! {ping, self()},
    receive pong ->
            io:format("Ping received pong~n")
    end,
    ping(N - 1, Pong_Node).

pong() ->
    receive
        {ping, Ping_Pid} ->
            io:format("Pong received ping~n"),
            Ping_Pid ! pong,
            pong()
    after 5000 ->
            io:format("Pong timed out~n")
    end.

start_pong() ->
    register(pong, spawn(?MODULE, pong, [])).

start_ping(Pong_Node) ->
    spawn(?MODULE, ping, [3, Pong_Node]).
