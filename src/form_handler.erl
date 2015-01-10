-module(form_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {}).

init(_, Req, _Opts) ->
    io:format("Form handler init~n"),
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->
    HasBody = cowboy_req:has_body(Req),
    io:format("Has body? ~p~n", [atom_to_list(HasBody)]),

    {Headers, Req2} = cowboy_req:headers(Req),
    io:format("Headers:~n\t~p~n", [Headers]),
    BinHeaders = lists:flatten([["<br>Key: ",K,"; Val: ", V] || {K, V} <- Headers]),

    {Host, Req3} = cowboy_req:host(Req2),
    {HostURL, Req4} = cowboy_req:host_url(Req3),
    {ok, Body, Req5} = cowboy_req:body(Req4),
    {ok, QsKVs, Req6} = cowboy_req:body_qs(Req5),
    io:format("Query string KV pairs:~n\t~p~n", [QsKVs]),

    {Path, Req7} = cowboy_req:path(Req6),
    {Peer, Req8} = cowboy_req:peer(Req7),
    {Port, Req9} = cowboy_req:port(Req8),
    io:format("Path: ~p~n", [Path]),
    io:format("Peer: ~p~n", [Peer]),
    io:format("Port: ~p~n", [Port]),


    {ok, Req10} = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/html">>}],
        ["<html><body>Has body: ",
         atom_to_list(HasBody), "<br>",
         BinHeaders, "<br>",
         "Host: ", Host, "<br>",
         "Host URL: ", HostURL, "<br>",
         "Body: ", Body, "<br>",
         "Path: ", Path, "<br>",
         "Peer: ", peer_to_list(Peer), "<br>",
         "Port: ", integer_to_list(Port), "<br>",
         "</body></html>"],
        Req9),
    {ok, Req10, State}.

terminate(_Reason, _Req, _State) ->
	ok.

peer_to_list({{IP1,IP2,IP3,IP4}, PeerPort}) ->
    [integer_to_list(IP1),
     ".",
     integer_to_list(IP2),
     ".",
     integer_to_list(IP3),
     ".",
     integer_to_list(IP4),
     ":",
     integer_to_list(PeerPort)].