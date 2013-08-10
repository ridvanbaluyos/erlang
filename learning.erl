-module(learning).
-compile(export_all).

% Power
power(B, 1) -> 
	B;

power(B, E) -> 
	B * power(B, (E - 1)).

% Triangular
triangular(1) ->
	1;
	
triangular(N) ->
	N + triangular(N - 1).

% But Last
but_last([]) ->
	[];

but_last(List) ->
	but_last(List, []).

but_last([Head | Rest], New_list) when length(Rest) > 0 ->
	but_last(Rest, New_list ++ [Head]);

but_last(List, New_list) when length(List) == 1 ->
	New_list.

% Fast Triangular
fast_triangular(1) ->
	1;

fast_triangular(N) ->
	fast_triangular(N, 1).

fast_triangular(N, A) when N > 1 ->
	fast_triangular((N - 1), (N + A));

fast_triangular(1, A) ->
	A.

% Fast Power
fast_power(B, 1) -> 
	B;

fast_power(B, E) ->
	fast_power(B, E, 1).

fast_power(B, E, A) when E > 0 ->
	fast_power(B, (E - 1), (B * A));

fast_power(_, 0, A) ->
	A.

% Fast Recursive List Length
fast_recursive_list_length([]) ->
	0;

fast_recursive_list_length(L) ->
	fast_recursive_list_length(L, 0).

fast_recursive_list_length([_ | Rest], A) ->
	fast_recursive_list_length(Rest, (A + 1));

fast_recursive_list_length(L, A) when length(L) == 0 ->
	A.

% Min, Max, Average
min_max_ave(L) ->
	min_max_ave(L, 0, 0, 0, 0).

min_max_ave([Head | Rest], Min, Max, Summation, Counter) -> 
	Temp_min = if
		Counter == 0 ->
			Head;
		Head < Min ->
			Head;
		true ->
			Min
	end,
	Temp_max = if
		Counter == 0 ->
			Head;
		Head > Max ->
			Head;
		true ->
			Max
		end,
	New_counter = Counter + 1,
	New_summation = (Summation + Head),
	min_max_ave(Rest, Temp_min, Temp_max, New_summation, New_counter);

min_max_ave([], Min, Max, Summation, Counter) -> 
	Average = Summation / Counter,
	[{min_value,Min}, {max_value,Max}, {average,Average}].

% Read File to List Alternate
readfile(FileName) ->
	{ok, Binary} = file:read_file(FileName),
	string:tokens(erlang:binary_to_list(Binary), "\n").
