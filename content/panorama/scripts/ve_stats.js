
OnPlayerPanoramaReady();
 
onJavaTimerTick();

function OnPlayerPanoramaReady()
{
	GameEvents.Subscribe( "unitbuy_success", OnUnitBuySuccess);
	GameEvents.Subscribe( "timer_going", OnTimerGoing);
	GameEvents.Subscribe( "player_newfood", OnPlayerNewFood);
	
	GameEvents.Subscribe( "load_configs", OnConfigsLoaded);
	GameEvents.Subscribe( "load_allunits", OnAllUnitsLoad);
	GameEvents.Subscribe( "load_playerunits", OnPlayerUnitsLoad);
	
	GameEvents.SendCustomGameEventToServer("player_panorama_ready", {}); 
	
	//GameEvents.Subscribe( "load_scoreboard", OnScoreboardLoaded);
	}


function OnTimerGoing(data)
{
	var minutes = Math.floor(data.state_time/60);
	var seconds = data.state_time - minutes*60;
	
	if(seconds > 9){ $('#food-timer').text = "(0"+minutes+":"+seconds+")";}
	else { $('#food-timer').text = "(0"+minutes+":0"+seconds+")";}
	if(data.income_time > 9){ $('#income-timer').text = "(00:" + data.income_time +")";}
	else {$('#income-timer').text = "(00:0" + data.income_time +")";}
	
	if(data.round_time > 9){ $('#unit-timer').text = "00:" + data.round_time;}
	else {$('#unit-timer').text = "00:0" + data.round_time;}
	
	var dota_time = Game.GetDOTATime(false, true);
	minutes = Math.floor(dota_time/60);
	if(minutes < 0) minutes = 0;
	seconds = Math.abs(Math.floor(dota_time - minutes*60));
	if(seconds < 10) {seconds = "0"+seconds;}
	if(minutes < 10){ $('#game-timer').text = "0"+minutes+":"+seconds;}
	else { $('#game-timer').text = minutes+":"+seconds;}
	
}

function OnAllUnitsLoad( event_data )
{	
	$('#unit-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#unit-timer'), $.Localize("#Game_tooltip_unit_timer"));});
	$('#unit-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#unit-timer'));});		
	
	$('#income-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#income-timer'), $.Localize("#Game_tooltip_income_timer"));});
	$('#income-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#income-timer'));});		
	
	$('#food-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#food-timer'), $.Localize("#Game_tooltip_food_timer"));});
	$('#food-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#food-timer'));});	
} 

function onJavaTimerTick( )
{	

	$('#income-label').GetChild(1).text = myincome*incomeconst;
	$('#food-label').GetChild(1).text = myfood+"/"+mymaxfood;
	$.Schedule(0.05, onJavaTimerTick);
}