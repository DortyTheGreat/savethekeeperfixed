var selectedType = 1;

var playerVotes = [];

function chooseType(value, name)
{
	selectedType = value;
	GameEvents.SendCustomGameEventToServer("player_vote_ready", {type : selectedType, typeName : name}); 
}
OnPlayerPanoramaReady();

function OnPlayerPanoramaReady()
{
	GameEvents.Subscribe( "preload_configs", OnConfigsLoaded);	
	GameEvents.Subscribe( "vote_load", OnVoteLoad);	
	GameEvents.SendCustomGameEventToServer("player_vote_ready", {type : 1, typeName : 'classic'}); 
}

function OnConfigsLoaded(data)
{
	
}

function OnVoteLoad(data)
{
	var fastCount = data.fastCount;
	var classicCount = data.classicCount;
	var longCount = data.longCount;
	
	var sum = fastCount + classicCount + longCount;
	
	$('#typeFastCount').text = fastCount + " голосов (" + (fastCount/sum*100).toFixed(0) + "%)"; 
	$('#typeClassicCount').text = classicCount + " голосов (" + (classicCount/sum*100).toFixed(0) + "%)"; 
	$('#typeLongCount').text = longCount + " голосов (" + (longCount/sum*100).toFixed(0) + "%)"; 
}


