-module(gateway).
-compile(export_all).

-define(PORT,10000).

%listen port 1000;
start()->
	io:format("[gateway][~p]->getway starting.",[time()]),
	{ok,Listen}	= gen_tcp:listen(?PORT,[binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
	register(connectmanager, spawn(fun connect_manager:start/0)),
	listen(Listen).

listen(Listen)->
	case gen_tcp:accept(Listen) of
		{ok, Socket} ->
			io:format("[gateway][~p]->socket connect succes ~n",[time()]),
			connectmanager ! {connect, Socket},
			spawn(fun()->recv(Socket) end),
			listen(Listen);
		{error, Reason} ->
			io:format("[gateway][~p]->socket connect failed ~p~n",[time(),Reason])
	end.

recv(Socket)->
	case gen_tcp:recv(Socket,0) of
		{ok, Data} ->
			io:format("[gateway][~p]->recv data:~p~n",[time(),binary_to_list(Data)]),
			connectmanager ! {data, Socket, Data},
			%send(Socket,"You said:"++binary_to_list(Data)),
			recv(Socket);
		{error, closed} ->
			io:format("[gateway][~p]->socket connect closed~n",[time()]);
		{error, timeout} ->
			io:format("[gateway][~p]->Socket connect timeout~n",[time()]);
		{'EXIT', _}->
			io:format("[gateway][~p]->Socket process exit~n",[time()]);
		Other ->
			io:format("[gateway][~p]->other:~p~n",[time(),Other])
	end.

send(Sockets, Data)->
	SendData = fun(Socket)->

			case gen_tcp:send(Socket, list_to_binary(Data)) of 
				{error, Reason} ->
					io:format("[gateway][~p]->send data faild:~p~n",[time(), Reason]);
				ok ->
					io:format("[gateway][~p]->send data:~p~n",[time(),Data])
			end
	end,
	lists:foreach(SendData,Sockets).
