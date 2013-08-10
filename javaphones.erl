-module(javaphones).
-compile(export_all).

% Main Function
main(FileInput, FileOutput) ->
	case filelib:is_regular(FileInput) of
		true ->
			write_to_file(get_phones(FileInput), FileOutput);
		false ->
			io:fwrite("~p does not exist.~n", [FileInput])
	end.

% Get Phone List.
get_phones(FileName) ->
		{ok, Device} = file:open(FileName, [read, write]),
		get_phones_from_stream(Device, [], get_symbian_regular_phones()).

get_phones_from_stream(Device, Accum, JavaPhones) ->
	case io:get_line(Device, "") of
		eof ->
			file:close(Device),
			lists:reverse(lists:keysort(2, Accum));
		Line ->
			LineValues = get_line_values(Line),
			{Model, Count} = LineValues,
			case lists:member(Model, JavaPhones) of
				true ->
					get_phones_from_stream(Device, increment_key(Accum, Model, Count), JavaPhones);
				false ->
					get_phones_from_stream(Device, Accum, JavaPhones)
			end
	end.

% Write String to File.
write_to_file(List, FileName) ->
	{ok, FileHandler} = file:open(FileName, [raw, append]),
	write_to_file(List, FileHandler, FileName).

write_to_file([First | Rest], FileHandler, FileName) ->
	{PhoneModel, PhoneCount} = First,
	StringLine = io_lib:format("~p,~p~n", [PhoneModel, PhoneCount]),
	ok = file:write(FileHandler, StringLine),
	write_to_file(Rest, FileHandler, FileName);

write_to_file([], _, FileName) ->
	io:fwrite("Contents have been successfully written to ~p.~n", [FileName]).

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

get_line_values(Line) ->
	Token = string:str(Line, ","),
	NewLine = string:rstr(Line, "\n"),
	NumberToken = Token - 1,
	ModelToken = Token + 1,
	ModelValue = string:sub_string(Line, 1, NumberToken),
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

% Get the list of java regular phones.
get_java_regular_phones () ->
	["Nokia_3110c","Nokia_3110","Nokia_3500c","Nokia_5200","Nokia_5220","Nokia_5310_XpressMusic","Nokia_5610_XpressMusic","Nokia_5610d-1","Nokia_6230i","Nokia_6230","Nokia_6233",
	"Nokia_6300","Nokia_6301","Nokia_6301b","Nokia_6500s","Nokia_6500c","Nokia_6620","Nokia_6600Slide","Nokia_6600s-1c","Nokia_6212c","Nokia_7510supernova","Nokia_7510a","Nokia_7100supernova",
	"Nokia_7100s._7100s-2","Nokia_7310supernova","Nokia_7310c","Nokia_7610supernova","Nokia_7610s","Nokia_7210supernova","Nokia_7210c","Nokia_5130XpressMusic","Nokia_5130","Nokia_6600Fold",
	"Nokia_7070","Nokia_7070_Prism","Samsung_SGH-Z400","Sony_Ericsson_K610c","Sony_Ericsson_K610i/610c","Sony_Ericsson_K610i_and_K610c","Sony_Ericsson_K610iv",
	"Sony_Ericsson_K610i","Sony_Ericsson_K610","Sony_Ericsson_K800c","Sony_Ericsson_K800iK800c","Sony_Ericsson_K800i_and_K800c","Sony_Ericsson_K800iv",
	"Sony_Ericsson_K800i","Sony_Ericsson_K800", "Sony_Ericsson_W810a","Sony_Ericsson_W810c","Sony_Ericsson_W810i","Sony_Ericsson_W810","Sony_Ericsson_W810i/W810c",
	"Sony_Ericsson_W200a","Sony_Ericsson_W200i","Sony_Ericsson_W200c","Sony_Ericsson_W200iv","Sony_Ericsson_W200i/c","Sony_Ericsson_W200i/W200c","Sony_Ericsson_W200i/c",
	"Sony_Ericsson_Z710","Sony_Ericsson_Z710c","Sony_Ericsson_Z710ic","Sony_Ericsson_Z710i","Sony_Ericsson_Z770i","Sony_Ericsson_K700i","Sony_Ericsson_K700c",
	"Sony_Ericsson_K700","Sony_Ericsson_K700i_and_K700c"].
	
get_symbian_regular_phones () ->
	["Ericsson_R380", "Fujitsu_docomo SMART series F-04 A", "Fujitsu_FOMA F205i", "Fujitsu_FOMA F700i", "Fujitsu_FOMA F702iD", "Fujitsu_FOMA F703i", 
	"Fujitsu_FOMA F704i", "Fujitsu_FOMA F705i", "Fujitsu_FOMA F706i", "Fujitsu_FOMA F801i", "Fujitsu_FOMA F900i", "Fujitsu_FOMA F901iC", 
	"Fujitsu_FOMA F903i", "Fujitsu_FOMA F905i", "Fujitsu_FOMA F906i", "Fujitsu_FOMA Raku-Raku Phone", "Fujitsu_FOMA Raku-Raku Phone Basic", 
	"Fujitsu_FOMA Raku-Raku Phone III", "Fujitsu_FOMA Raku-Raku Phone IV", "Fujitsu_FOMA Raku-Raku Phone Premium", "Mitsubishi_FOMA D701i", 
	"Mitsubishi_FOMA D702iF", "Mitsubishi_FOMA D703i", "Mitsubishi_FOMA D704i", "Mitsubishi_FOMA D705i", "Mitsubishi_FOMA D903i", 
	"Mitsubishi_FOMA D904i", "Mitsubishi_FOMA D905i", "Mitsubishi_Raku-Raku Phone SIMPLE", "Motorola_RIZR Z10 UIQ v3", "Motorola_RIZR Z8", 
	"Motorola_FOMA M1000", "Motorola_A1000", "Nokia_3230", "Nokia_3250", "Nokia_3600", "Nokia_3620", "Nokia_3650", "Nokia_3660", "Nokia_5230", 
	"Nokia_5500", "Nokia_5630", "Nokia_5700", "Nokia_6121", "Nokia_6220", "Nokia_6260", "Nokia_6290", "Nokia_6600", "Nokia_6620", "Nokia_6630", 
	"Nokia_6670", "Nokia_6680", "Nokia_6681", "Nokia_6682", "Nokia_7610", "Nokia_7650", "Nokia_9210", "Nokia_5320_XpressMusic", 
	"Nokia_5530_XpressMusic", "Nokia_5730 XpressMusic", "Nokia_5800_XpressMusic", "Nokia_6110_Navigator", "Nokia_6120c", "Nokia_6210_Navigator", 
	"Nokia_6710_Navigator", "Nokia_6720_Classic", "Nokia_E50", "Nokia_E51", "Nokia_E52", "Nokia_E55", "Nokia_E60", "Nokia_E61", "Nokia_E61i", 
	"Nokia_E62", "Nokia_E65", "Nokia_E66", "Nokia_E70", "Nokia_E71", "Nokia_E75", "Nokia_E90", "Nokia_NM705i", "Nokia_NM706i", "Nokia_N70", 
	"Nokia_N71", "Nokia_N72", "Nokia_N73", "Nokia_N75", "Nokia_N76", "Nokia_N77", "Nokia_N78", "Nokia_N79", "Nokia_N80", "Nokia_N81", 
	"Nokia_N81 8GB", "Nokia_N82", "Nokia_N85", "Nokia_N86", "Nokia_N86", "Nokia_N90", "Nokia_N91", "Nokia_N91 8GB", "Nokia_N92", "Nokia_N93", 
	"Nokia_N93i", "Nokia_N95", "Nokia_N95 8GB", "Nokia_N96", "Nokia_N97", "Nokia_N-Gage", "Nokia_N-Gage QD", "Nokia_i8910 HD", "Nokia_i7110", 
	"Nokia_SGH-L870", "Nokia_i8510", "Nokia_SGH-i400", "Nokia_SGH-i450", "Nokia_SGH-i520", "Nokia_SGH-i550", "Nokia_SGH-i560", "Nokia_SGH-g810", 
	"Nokia_SGH-D710", "Nokia_SGH-D720", "Nokia_SGH-D730", "Nokia_SGH-D700", "Nokia_X", "Nokia_FOMA SH704i", "Nokia_FOMA SH705i", "Nokia_FOMA SH706i", 
	"Nokia_FOMA SH902i", "Nokia_FOMA SH903i", "Nokia_FOMA SH903iTV", "Nokia_FOMA SH904i", "Nokia_FOMA SH905iTV", "Nokia_FOMA SH906i", 
	"Nokia_FOMA SH906iTV", "Siemens_P1c", "Sony_Ericsson_FOMA SO703i", "Sony_Ericsson_FOMA SO704i", "Sony_Ericsson_FOMA SO902i", 
	"Sony_Ericsson_FOMA SO903i", "Sony_Ericsson_FOMA SO905i", "Sony_Ericsson_FOMA SO906i", "Sony_Ericsson_G700", "Sony_Ericsson_G900", 
	"Sony_Ericsson_M600i/M600c", "Sony_Ericsson_P1c", "Sony_Ericsson_P800", "Sony_Ericsson_P900", "Sony_Ericsson_P910", "Sony_Ericsson_P990i", 
	"Sony_Ericsson_Satio", "Sony_Ericsson_W950", "Sony_Ericsson_W960i", "Samsung_i8910 HD", "Samsung_i7110", "Samsung_SGH-L870", "Samsung_i8510",
	"Samsung_SGH-i400", "Samsung_SGH-i450", "Samsung_SGH-i520", "Samsung_SGH-i550", "Samsung_SGH-i560", "Samsung_SGH-g810", "Samsung_SGH-D710",
	"Samsung_SGH-D720", "Samsung_SGH-D730", "Samsung_SGH-D700", "Sendo_X", "Sharp_FOMA SH704i", "Sharp_FOMA SH705i", "Sharp_FOMA SH706i",
	"Sharp_FOMA SH902i", "Sharp_FOMA SH903i", "Sharp_FOMA SH903iTV", "Sharp_FOMA SH904i", "Sharp_FOMA SH905iTV", "Sharp_FOMA SH906i", 
	"Sharp_FOMA SH906iTV"].
