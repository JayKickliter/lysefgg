-module(msg_imp).

-export([start_server/0, server/0, logon/1, logoff/0, message/2, client/2]).

server_node() ->
    'messenger@jks76.local'.

server() ->
    process_flag(trap_exit, true),
    server([]).

server(User_List) ->
    New_User_List =
        receive
            {From, logon, Name} ->
                server_logon(From, Name, User_List);
            {'EXIT', From, Reason} ->
                io:format("~p exited because ~p~n", [From, Reason]),
                server_logoff(From, User_List);
            {From, message_to, To, Message} ->
                server_transfer(From, To, Message, User_List),
                io:format("list is now ~p~n", [User_List]),
                User_List
        end,
    server(New_User_List).


start_server() ->
    register(?MODULE, spawn(?MODULE, server, [])).

server_logon(From, Name, User_List) ->
    case lists:keymember(Name, 2, User_List) of
        true ->
            From ! {?MODULE, stop, user_exists_at_other_node},
            User_List;
        false ->
            From ! {?MODULE, logged_on},
            link(From),
            [{From, Name} | User_List]
    end.

server_logoff(From, User_List) ->
    lists:keydelete(From, 1, User_List).

server_transfer(From, To, Message, User_List) ->
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {?MODULE, stop, you_are_not_logged_on};
        {value, {_, Name}} ->
            server_transfer(From, Name, To, Message, User_List)
    end.

server_transfer(From, Name, To, Message, User_List) ->
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {?MODULE, receiver_not_found};
        {value, {ToPid, _To}} ->
            ToPid ! {message_from, Name, Message},
            From ! {?MODULE, sent}
    end.

logon(Name) ->
    case whereis(mess_client) of
        undefined ->
            register(mess_client, spawn(?MODULE, client, [server_node(), Name]));
        _ ->
            already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

message(ToName, Message) ->
    case whereis(mess_client) of
        undefined ->
            not_logged_on;
        _ -> mess_client ! {message_to, ToName, Message},
             ok
    end.

client(Server_Node, Name) ->
    {?MODULE, Server_Node} ! {self(), logon, Name},
    await_result(),
    client(Server_Node).

client(Server_Node) ->
    receive
        logoff ->
            exit(normal);
        {message_to, ToName, Message} ->
            {?MODULE, Server_Node} ! {self(), message_to, ToName, Message},
            await_result();
        {message_from, FromName, Message} ->
            io:format("Message from ~p: ~p~n", [FromName, Message])
    end,
    client(Server_Node).

await_result() ->
    receive
        {?MODULE, stop, Why} ->
            io:format("~p~n", [Why]),
            exit(normal);
        {?MODULE, What} ->
            io:format("~p~n", [What])
    after 5000 ->
            io:format("No response from server~n"),
            exit(timeout)
    end.
