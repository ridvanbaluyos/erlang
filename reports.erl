-module(reports).
-compile(server_util).
-compile(export_all).

% Main Function
main(FileInput, FileOutput, PhoneType) ->
	case filelib:is_regular(FileInput) of
		true ->
			parsing_util:write_to_file(get_phones(FileInput, PhoneType), FileOutput);
		false ->
			io:fwrite("~p does not exist.~n", [FileInput])
	end.

% Get Phone List.
get_phones(FileName, PhoneType) ->
		PhoneList = if
			PhoneType == "symbian" ->
				parsing_util:get_symbian_regular_phones();
			PhoneType == "java" ->
				parsing_util:get_java_regular_phones()
		end,
		{ok, Device} = file:open(FileName, [read, write]),
		get_phones_from_stream(Device, [], PhoneList).

get_phones_from_stream(Device, Accum, PhoneList) ->
	case io:get_line(Device, "") of
		eof ->
			file:close(Device),
			lists:reverse(lists:keysort(2, Accum));
		Line ->
			LineValues = get_line_values(Line),
			{Model, Count} = LineValues,
			case lists:member(Model, PhoneList) of
				true ->
					get_phones_from_stream(Device, parsing_util:increment_key(Accum, Model, Count), PhoneList);
				false ->
					get_phones_from_stream(Device, Accum, PhoneList)
			end
	end.

get_line_values(Line) ->
	Token = string:str(Line, ","),
	NewLine = string:rstr(Line, "\n"),
	NumberToken = Token - 1,
	ModelToken = Token + 1,
	ModelValue = string:sub_string(Line, 1, NumberToken),
	io:fwrite("~p", [Line]),
	CountValue = if 
		NewLine == 0 ->
			list_to_integer(string:sub_string(Line, ModelToken));
		true ->
			LineLength = string:len(Line),
			list_to_integer(string:sub_string(Line, ModelToken, LineLength - 1))
	end,
	{ModelValue, CountValue}.

% Get the line values.
get_line_values2(Line) ->
	Token = string:str(Line, "|"),
	NewLine = string:rstr(Line, "\n"),
	NumberToken = Token - 2,
	ModelToken = Token + 2,
	NumberValue = string:sub_string(Line, 2, NumberToken),
	ModelValue = if 
		NewLine == 0 ->
			string:sub_string(Line, ModelToken);
		true ->
			LineLength = string:len(Line),
			string:sub_string(Line, ModelToken, LineLength - 1)
	end,
	{NumberValue, ModelValue}.

