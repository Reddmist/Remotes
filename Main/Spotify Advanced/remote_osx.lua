local server = libs.server;
local utf8 = libs.utf8;

include("common.lua")
include("playlists.lua")

PlayingID = "";

function update()
	local volume = os.script("tell application \"Spotify\" to set out to sound volume") + 0;
	local pos = os.script("tell application \"Spotify\" to set out to player position") + 0;
	pos = math.ceil(pos);

	local repeating = os.script("tell application \"Spotify\" to set out to repeating");
	local shuffling = os.script("tell application \"Spotify\" to set out to shuffling");
	local playing = os.script("tell application \"Spotify\" to set out to player state");
	local id = os.script("tell application \"Spotify\" to set out to id of current track");

	local duration = os.script("tell application \"Spotify\" to set out to duration of current track") + 0;
	duration = math.ceil(duration);

	local name = os.script("tell application \"Spotify\" to set out to name of current track");

	if id ~= PlayingID then
		PlayingID = id;
		local imagepath = os.script(
			"tell application \"Spotify\"", 
				"set a to artwork in current track",
			"end tell",
			"tell current application",
				"set temp to (path to temporary items from user domain as text) & \"img.png\"",
				"set fileRef to (open for access temp with write permission)",
					"write a to fileRef",
				"close access fileRef",
				"tell application \"Image Events\"",
					"set theImage to open temp",
					"save theImage as PNG with replacing",
				"end tell",
				"set out to POSIX path of temp",
			"end tell");
			
		server.update({id = "currimg", image = imagepath });
	end
	
	local icon = "play";
	if (playing == "playing") then
		icon = "pause";
	end
	
	server.update(
		{ id = "currtitle", text = name },
		{ id = "currvol", progress = volume },
		{ id = "currpos", progress = pos, text = libs.data.sec2span(pos) .. " / " .. libs.data.sec2span(duration) },
		{ id = "currpos", progressMax = duration },
		{ id = "repeat", checked = repeating },
		{ id = "suffle", checked = shuffling },
		{ id = "play", icon = icon }
	);
end

function play(track, context)
	print("play " .. track .. " " .. context);
	out,err = os.script("tell application \"Spotify\" to play track \"" .. track .. "\" in context \"" .. context .. "\"");
	print(out .. " " .. err);
end

actions.poschange = function (pos)
	os.script("tell application \"Spotify\" to set player position to " .. pos);
end

actions.volchange = function (vol)
	os.script("tell application \"Spotify\" to set sound volume to " .. vol);
end

actions.next = function ()
	os.script("tell application \"Spotify\" to next track");
	actions.update();
end

actions.previous = function ()
	os.script("tell application \"Spotify\" to previous track");
	actions.update();
end

actions.repeating = function (checked)
	if checked then 
		os.script("tell application \"Spotify\" to set repeating to true");
	else
		os.script("tell application \"Spotify\" to set repeating to false");
	end
end

actions.play = function ()
	os.script("tell application \"Spotify\" to playpause");
	actions.update();
end

actions.suffle = function (checked)
	if checked then 
		os.script("tell application \"Spotify\" to set shuffling to true");
	else
		os.script("tell application \"Spotify\" to set shuffling to false");
	end
end