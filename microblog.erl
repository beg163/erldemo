-module(microblog).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

-define(ABOUT,?wxID_ABOUT).
-define(EXIT,?wxID_EXIT).

-define(APPEND,131).
-define(UNDO,132).
-define(OPEN,133).
-define(SAVE,134).
-define(NEW,135).

start()->
	wx:new(),
	Frame	= wxFrame:new(wx:null(), ?wxID_ANY, "MicroBlog"),
	Text	= wxTextCtrl:new(Frame, ?wxID_ANY,
		[{value,"MinBlog"},{style,?wxTE_MULTILINE}]),
	setup(Frame,Text),
	wxFrame:show(Frame),
	loop(Frame,Text),
	wx:destroy().

%% setup the graphic objects within the frame
setup(Frame, Text)->
	MenuBar	= wxMenuBar:new(),
	File	= wxMenu:new(),
	Help	= wxMenu:new(),
	Edit	= wxMenu:new(),

	wxMenu:append(Help, ?ABOUT, "About me"),
	wxMenu:append(File, ?EXIT, "Quite"),
	wxMenu:append(File, ?NEW, "New\tCtrl-N"),
	wxMenu:append(File, ?OPEN, "Open\tCtrl-O"),
	wxMenu:appendSeparator(File),
	wxMenu:append(File, ?SAVE, "Save\tCtrl-S"),

	wxMenu:append(Edit, ?APPEND, "Add en&try\tCtrl-T"),
	wxMenu:append(Edit, ?UNDO, "Undo latest\tCtrl-U"),

	wxMenuBar:append(MenuBar, File, "&File"),
	wxMenuBar:append(MenuBar, Help, "&Help"),
	wxMenuBar:append(MenuBar, Edit, "&Edit"),

	wxTextCtrl:setEditable(Text, false),

	wxFrame:setMenuBar(Frame, MenuBar),

	wxFrame:createStatusBar(Frame),
	wxFrame:setStatusText(Frame, "Welcome to microblog"),

	wxFrame:connect(Frame, command_menu_selected),
	wxFrame:connect(Frame, close_window).

loop(Frame)->
	receive
		#wx{id=?ABOUT, event=#wxCommand{}}->
			Str	= "MicroBlog is a minimal WxElang example",
			MD	= wxMessageDialog:new(Frame, Str, 
				[{style, ?wxOK bor ?wxICON_INFORMATION},{caption, "About MicroBlog"}]),
			wxDialog:showModal(MD),
			wxDialog:destroy(MD),
			loop(Frame);

		#wx{id=?EXIT, event=#wxCommand{type=command_menu_selected}}->
			wxWindow:close(Frame, [])
	end.

loop(Frame, Text)->
	receive
		#wx{id=?ABOUT, event=#wxCommand{}}->
			Str	= "MicroBlog is a minimal WxElang example",
			MD	= wxMessageDialog:new(Frame, Str, 
				[{style, ?wxOK bor ?wxICON_INFORMATION},{caption, "About MicroBlog"}]),
			wxDialog:showModal(MD),
			wxDialog:destroy(MD),
			loop(Frame);

		#wx{id=?EXIT, event=#wxCommand{type=command_menu_selected}}->
			wxWindow:close(Frame, []);

		#wx{id=?APPEND, event=#wxCommand{type=command_menu_selected}}->
			Prompt	= "Please enter text here",
			MD	= wxTextEntryDialog:new(Frame, Prompt, [{caption, "New Dialog entry"}]),
			case wxTextEntryDialog:showModal(MD) of
				?wxID_OK ->
					Str	= wxTextEntryDialog:getValue(MD),
					wxTextCtrl:appendText(Text, [10]++tuple_to_atom(now())++Str);
				_->ok
			end,
			wxDialog:destroy(MD),
			loop(Frame, Text);

		#wx{id=?UNDO, event=#wxCommand{type=command_menu_selected}}->
			{StartPos, EndPos}	= lastLineRange(Text),
			wxTextCtrl:remove(Text, StartPos-2, EndPos-1),
			loop(Frame, Text);

		#wx{id=?OPEN, event=#wxCommand{type=command_menu_selected}}->
			wxTextCtrl:loadFile(Text, "BLOG"),
			loop(Frame, Text);

		#wx{id=?SAVE, event=#wxCommand{type=command_menu_selected}}->
			wxTextCtrl:saveFile(Text, [{file,"BLOG"}]),
			loop(Frame, Text);

		#wx{id=?NEW, event=#wxCommand{type=command_menu_selected}}->
			{_,EndPos}	= lastLineRange(Text),
			StartPos	= wxTextCtrl:xYToPosition(Text,0,0),
			wxTextCtrl:replace(Text, StartPos, EndPos, "MinBlog"),
			loop(Frame, Text)
	end.

lastLineRange(T) ->
	{ wxTextCtrl:xYToPosition(T,0,wxTextCtrl:getNumberOfLines(T)-1),
		wxTextCtrl:getLastPosition(T) }.
