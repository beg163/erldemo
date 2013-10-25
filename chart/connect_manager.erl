-module(connect_manager).
-compile(export_all).

start()->
	io:format("[connect_manager][~p] connect manager starting.~n",[time()]),
	loop([]).

loop(Sockets)->
	receive
		{connect, Socket}->
			NewSockets = [Socket | Sockets],
			{ok,{IP,Port}} = inet:peername(Socket),
			io:format("[connect_manager][~p]->connect from ~p:~p~n",[time(),IP,Port]);
		%{disconnect, Socket}->
		{disconnect, Socket}->
			NewSockets = lists:delete(Socket,Sockets),
			io:format("[connect_manager][~p]->disconnect!~n",[time()]);
		{timeout, _}->
		%{timeout, Socket}->
			NewSockets = Sockets,	
			io:format("[connect_manager][~p]->timeout!~n",[time()]);
		{data, _, Data}->
			io:format("[connect_manager][~p]->receive data!~p~n",
				[time(),binary_to_list(Data)]),
			gateway:send(Sockets, binary_to_list(Data)),
			NewSockets = Sockets;
		Other->
			NewSockets = Sockets,
			io:format("[connect_manager][~p]->other: ~p~n",[time(),Other])
	end,
	loop(NewSockets).


			
