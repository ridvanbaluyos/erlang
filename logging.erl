-module(logging).
-compile(export_all).

% Read File to List Alternate
readfile(FileName) ->
	{ok, Binary} = file:read_file(FileName),
	string:tokens(erlang:binary_to_list(Binary), "\n").

% Get the list of Users with their Status.
get_users(List) ->
	get_users(List, []).

get_users([First | Rest], Users) ->
	User = list_to_atom(get_node_value(First, "USER:")),
	Status = list_to_atom(get_node_value(First, "STATUS:")),
	get_users(Rest, Users ++ [{User, Status}]);

get_users([], Users) ->
	Users.

% Get the list of Buddies filtered by the status.
get_buddies(List, Status) ->
	get_buddies(List, Status, []).

get_buddies([First | Rest], Status, Users) ->
	{UserId, UserStatus} = First,
	case Status == UserStatus of
		true ->
			get_buddies(Status, Rest, Users ++ [UserId]);
		false ->
			get_buddies(Status, Rest, Users)
	end;

get_buddies([], _, Users) ->
	Users.

% Get the Per User Activity
get_per_user_activity(List) ->
	get_per_user_activity(List, []).

get_per_user_activity([First | Rest], UserActivities) ->
	get_per_user_activity(Rest, assemble_per_user_activity(UserActivities, First));

get_per_user_activity([], UserActivities) ->
	UserActivities.

% Assemble Per User Activity
assemble_per_user_activity(UserActivities, Line) ->
	UserId = list_to_atom(get_node_value(Line, "FROM:")),
	Type = list_to_atom(get_node_value(Line, "TYPE:")),
	FoundUserId = find_key(UserActivities, UserId),
	case FoundUserId == [] of
		true ->
			UserActivities ++ [[UserId, [{Type, 1}]]];
		false ->
			[_ | RestActivities] = FoundUserId,
			[Activities | _] = RestActivities,
			FoundType = find_key(Activities, Type),
			case FoundType == [] of
				true ->
					replace_key(UserActivities, UserId, Activities ++ [{Type, 1}]);
				false ->
					replace_key(UserActivities, UserId, increment_key(Activities, Type, 1))
			end
	end.

% Get Statistics
get_statistics(List) ->
	get_statistics(List, []).

get_statistics([First | Rest], Statistics) ->
	get_statistics(Rest, increment_key(Statistics, get_timestamp(First), 1));

get_statistics([], Statistics) ->
	Statistics.

% Increment Key
increment_key(List, Key, Count) ->
	FindKey = find_key(List, Key),
	case FindKey == [] of
		true ->
			List ++ [{Key, Count}];
		false ->	
			{_, PrevCount} = FindKey,
			replace_key(List, Key, (PrevCount + Count), [])
	end.

% Replace Key
replace_key(List, KeyFilter, ValueFilter) ->
	replace_key(List, KeyFilter, ValueFilter, []).

replace_key([First | Rest], KeyFilter, ValueFilter, NewList) ->
	KeyPairCandidate = First,
	case is_tuple(KeyPairCandidate) of
		true ->
			{KeyCurrent, ValueCurrent} = KeyPairCandidate,
			case KeyFilter == KeyCurrent of
				true -> 
					replace_key(Rest, KeyFilter, ValueFilter, NewList ++ [{KeyFilter, ValueFilter}]);
				false ->
					replace_key(Rest, KeyFilter, ValueFilter, NewList ++ [{KeyCurrent, ValueCurrent}])
			end;
		false ->
			[KeyCurrent | _] = KeyPairCandidate,
			case KeyFilter == KeyCurrent of
				true ->
					replace_key(Rest, KeyFilter, ValueFilter, NewList ++ [[KeyFilter, ValueFilter]]);
				false -> 
					replace_key(Rest, KeyFilter, ValueFilter, NewList ++ [First])
			end
	end;

replace_key([], _, _, NewList) ->
	NewList.

% Find Key in the List, return the Key if found.
find_key([First | Rest], KeyNeedle) ->
	KeyPairCandidate = First,
	case is_tuple(KeyPairCandidate) of
		true ->
			{KeyCurrent, _} = KeyPairCandidate;		
		false ->
			[KeyCurrent | _] = KeyPairCandidate
	end,
	case KeyCurrent == KeyNeedle of
		true -> KeyPairCandidate;
		false -> find_key(Rest, KeyNeedle)
	end;

% Just return a blank list if the key is not found.
find_key([], _) ->
	[].

% Get the Node Value
get_node_value(Line, Node) ->
	NodeStartToken = string:str(Line, Node),
	NodeRemString = string:sub_string(Line, NodeStartToken),
	ValueStartToken = string:str(NodeRemString, ":") + 1,
	BlankToken = string:str(NodeRemString, " "),
	ValueEndToken = if %string:str(NodeRemString, " ") - 1,
		BlankToken > 0 ->
			BlankToken - 1;
		true ->
			string:len(NodeRemString)
	end,
	string:sub_string(NodeRemString, ValueStartToken, ValueEndToken).

% Get the Session Time Value
get_timestamp(Line) ->
	SquareBracketStart = string:str(Line, "[") + 1,
	SquareBracketEnd = string:str(Line, "]") -1,
	string:sub_string(Line, SquareBracketStart, SquareBracketEnd).

