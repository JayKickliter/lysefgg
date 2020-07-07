-module(tut17).

-export([start_ping/1, start_pong/0, ping/2, pong/0]).

ping(0, Pong_NODE) ->
    {pong, Pong_NODE} ! finished,
    io:format("ping finished~n", []);
ping(N, Pong_NODE) ->
    {pong, Pong_NODE} ! {ping, self()},
    receive
        pong ->
            io:format("Ping received pong~n", [])
    end,
    ping(N - 1, Pong_NODE).

pong() ->
    receive
        finished ->
            io:format("Pong finished~n", []);
        {ping, Ping_PID} ->
            io:format("Pong received ping~n", []),
            Ping_PID ! pong,
            pong()
    end.


start_pong() ->
    register(pong, spawn(?MODULE, pong, [])).

start_ping(Pong_NODE) ->
    spawn(?MODULE, ping, [3, Pong_NODE]).
