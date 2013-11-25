%%This could be the air traffic control tower
%%Others would be the airplanes
-module(aircontoll).
-compile(export_all).

% initialize it,creating one town and some planes
run()->
	Tower	= tower(),
	createPlane(Tower,1,5,5,2000),
	createPlane(Tower,2,1,1,4000),
	createPlane(Tower,3,1,5,6000),
	createPlane(Tower,4,5,3,10000),
	createPlane(Tower,5,5,1,5000).

% all planes survive here
fastfun()->
	Tower	= tower(),
	createPlane(Tower,1,5,5,30),
	createPlane(Tower,2,1,1,10),
	createPlane(Tower,3,1,5,30),
	createPlane(Tower,4,5,3,10),
	createPlane(Tower,5,5,1,10).

%---------------------Tower methods--------------------%
tower()->
	io:format("Tower ready for duty~n"),
	spawn(fun()->tower(lists:duplicate(25,null)) end).

tower(Occupied)->
	receive
		{arrive,{Plane,Id,3,3}} ->
			io:format("Tower: Flight ~p,welcome home.~n",[Id]),
			tower(removePlane(Plane,Occupied));
		{arrive,{Plane,Id,X,Y}} ->
			{NewX,NewY} = getBearing(X,Y),
			io:format("Tower: Flight ~p,please head to bearing (~p, ~p)~n",
				[Id, NewX, NewY]),
			Plane ! {bearing, getBearing(X,Y)},
			tower(addPlane(Plane,((Y-1)*5)+X, removePlane(Plane, Occupied)));
		_ -> io:format("tower: I don't understand.~n'")
	end.
removePlane(Plane,List) ->
	lists:map(
		fun(X)->
				if
					X==Plane ->null;
					true -> X
				end
		end
		,List).

addPlane(Plane, Index, List)->
	Occupant = lists:nth(Index, List),
	if
		Occupant /= null ->
			Occupant ! crash,
			Plane ! crash,
			removePlane(Occupant, List);
		true ->
			lists:append([lists:sublist(List, Index-1), [Plane], lists:sublist(List, Index+1, 25)])
	end.

%get the next bearing as an X,Y tuple
getBearing(X,Y) ->
	if
		Y /= 3 -> {X, getBearing(Y)};
		true -> {getBearing(X),Y}
	end.

getBearing(Num) ->
	case Num of
		1 -> 2;
		2 -> 3;
		3 -> 3;
		4 -> 3;
		5 -> 4
	end.


%--------------------- Plane methods--------------------%
createPlane(Tower, Id, X, Y, Speed) ->
	Plane = spawn(fun() -> plane(Tower, Id, Speed) end),
	Plane ! {new, {X, Y}}.

plane(Tower, Id, Speed) ->
	receive
		{new, {X,Y}} ->
			io:format("Flight ~p created at (~p, ~p)~n",[Id, X, Y]),
			Tower ! {arrive, {self(), Id, X, Y}},
			plane(Tower, Id, Speed);
		{bearing, {X,Y}} ->
			io:format("Roger that tower, Flight ~p heading to bearing (~p, ~p)~n", [Id, X, Y]),
			timer:sleep(Speed),
			Tower ! {arrive, {self(), Id, X, Y}},
			plane(Tower, Id, Speed);
		crash ->
			io:format("Mayday! Mayday!, Flight ~p is going down!~n", [Id])
	end.
