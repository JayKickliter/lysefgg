-module(tut18).

-export([start/1, ping/2, pong/0]).

ping(0, Pong_Node) ->
    {pong, Pong_Node} ! finished,
    io:format("Ping finished~n", []);
ping(N, Pong_Node) ->
    {pong, Pong_Node} ! {ping, self()},
    receive
        pong ->
            io:format("ping <- pong~n", [])
    end,
    ping(N-1, Pong_Node).

pong() ->
    receive
        finished ->
            io:format("ping finished~n", []);
        {ping, Ping_PID} ->
            io:format("ping -> pong"),
            Ping_PID ! pong,
            pong()
    end.

start(Ping_Node) ->
    register(pong, spawn(?MODULE, pong, [])),
    spawn(Ping_Node, ?MODULE, ping, [3, node()]).
