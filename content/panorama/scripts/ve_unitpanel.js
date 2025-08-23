
var unitHaved = {};

const maxPages = 6;
var currentPage = 1; 
var myincome = 1;
var myfood = 9;
var mymaxfood = 30;
var incomeconst;
var unitConf = [];

var creepDirection = 1;
var canChangeDirection = 0;

OnPlayerPanoramaReady();

Game.AddCommand( "+showFullListMenu", showFullListMenu, "", 0 );

function OnPlayerPanoramaReady()
{
	GameEvents.Subscribe( "unitbuy_success", OnUnitBuySuccess);
	GameEvents.Subscribe( "timer_going", OnTimerGoing);
	GameEvents.Subscribe( "player_newfood", OnPlayerNewFood); 
	
	GameEvents.Subscribe( "load_configs", OnConfigsLoaded);
	GameEvents.Subscribe( "load_allunits", OnAllUnitsLoad);
	GameEvents.Subscribe( "load_playerunits", OnPlayerUnitsLoad);
	GameEvents.Subscribe( "reverse_available", OnReverseAvailable);
	
	GameEvents.SendCustomGameEventToServer("player_panorama_ready", {}); 
	
	//GameEvents.Subscribe( "load_scoreboard", OnScoreboardLoaded);

}

function showFullListMenu(){
	$.Msg("SPACE Pressed");
}

function OnScoreboardLoaded(data)
{

	var sb_panel = $('#ve_scoreboard');
	//sb_panel.RemoveAndDeleteChildren();
	var players = Players.GetMaxPlayers();
	for(var i in players)
	{
		var thisclass = $.CreatePanel("Panel", sb_panel, "sb_block_"+i );
		thisclass.id = "sb_block_"+i;
		thisclass.enabled = true;
		var thislabel = $.CreatePanel("Label", thisclass, "sb_block_"+i+"_name");
		thislabel.text = DOTAUserName.accountid(data[i]);
		var thisavatar = $.CreatePanel("Image", thisclass, "sb_block_"+i+"_avatar");
		thisavatar.SetImage(DOTAAvatarImage.accountid(data[i]));

	}
}

function OnReverseAvailable(data)
{
	canChangeDirection = 1;
	$('#reverse-label').style.visibility = "visible";
	$('#reverse-label-no').style.visibility = "collapse";
	$('#direction-image').style.visibility = "visible";
}

function ChangeCreepDirection()
{
	if(canChangeDirection == 1)
	{
		if(creepDirection == 1)
		{
			creepDirection = 0;
			$('#direction-right').style.visibility = "collapse";
			$('#direction-left').style.visibility = "visible";
		}		
		else
		{
			creepDirection = 1;		
			$('#direction-right').style.visibility = "visible";
			$('#direction-left').style.visibility = "collapse";
		}		
		Game.EmitSound("ui.shortwhoosh");
	}	
	else 
	{
		Game.EmitSound("General.NoGold");
	}
	GameEvents.SendCustomGameEventToServer("change_direction", {direction : creepDirection}); 
}

function OnConfigsLoaded(data)
{
	incomeconst = data.income_count;
	myfood = data.food;
	mymaxfood = data.maxfood;
	//$.Msg("income: "+incomeconst+" food: "+myfood+" maxfood: "+mymaxfood);
}

function OnPlayerNewFood(data)
{
	myfood = data.food;
	mymaxfood = data.maxfood;
} 

function OnUnitBuySuccess(data)
{
	myincome = data.income;
	myfood = data.food;
	//$.Msg(data);
}
 
function onJavaTimerTick( )
{	
	if(Object.keys(unitConf).length == 0)
	{
		GameEvents.SendCustomGameEventToServer( "unitpanel_debug", {thisdata : 1} );
		//$.Msg(unitConf);
	}
	$('#income-label').GetChild(1).text = myincome*incomeconst;
	$('#food-label').GetChild(1).text = myfood+"/"+mymaxfood;
	for(var i in unitConf)
	{
		var thisclass = $(unitConf[i].unitclass);		
		if(Players.GetGold(Players.GetLocalPlayer()) < unitConf[i].cost || myfood + unitConf[i].food > mymaxfood)
		{ 
			thisclass.style.border = "5px solid #9b0000";
			thisclass.style.washColor = "rgba(0,0,0, 0.7);"
		}
		else
		{
			thisclass.style.border = "5px solid #199900";
			thisclass.style.washColor = "rgba(0,0,0, 0.0);"
			//Game.EmitSound("Quickbuy.Available");
		}	
	}
	$.Schedule(0.05, onJavaTimerTick);
}
 
onJavaTimerTick();

function SelectPage(value)
{
	if(currentPage + value > 0 && currentPage + value <= maxPages)
	{
		currentPage += value;
	}
	else if(currentPage + value == 0) currentPage = maxPages;
	else currentPage = 1;
	Game.EmitSound("ui.shortwhoosh");
	$('#PageLabelNumber').text = currentPage;
	RegeneratePageUnits()
}

function ShowAllUnits(isActive)
{
	var fulllist = $('#fulllist-panel');
	if(isActive)
	{
		fulllist.style.visibility = "visible";  
		$("#listleft").style.visibility = "visible";
		$("#listright").style.visibility = "collapse";
	}
	else
	{
		fulllist.style.visibility = "collapse"; 
		$("#listleft").style.visibility = "collapse";
		$("#listright").style.visibility = "visible"; 
	}
	RegeneratePageUnitFullList(isActive)
}

function RegeneratePageUnitFullList(isActive)
{
	var ownpanel = $('#unitlist-panel');
	var listpanel = $('#full-unitlist-panel');
	if(isActive)
	{
		$('#unitpanel-container').style.visibility = "collapse";
		for(var i in unitConf)
		{
			var thisclass = $(unitConf[i].unitclass);
			thisclass.SetParent(listpanel)
			thisclass.style.visibility = "visible"; 
			thisclass.style.margin = "5px"; 
		}		
	}
	else
	{
		$('#unitpanel-container').style.visibility = "visible";
		for(var i in unitConf)
		{
			$(unitConf[i].unitclass).SetParent(ownpanel)
		}
		RegeneratePageUnits()
	} 

}


function RegeneratePageUnits()
{
	
	for(var i in unitConf)
	{
		var thisclass = $(unitConf[i].unitclass);
		if(currentPage == unitConf[i].page) 
		{
			thisclass.style.visibility = "visible"; 
		}
		else thisclass.style.visibility = "collapse";	
	}
}

function QuickSort(list)
{
	var newarray = {};
	var intger = 0;
    for(var i in list)
	{
		intger++;
		for(var m in list)
		{
			if(list[m].unitindex == intger)
			{
				newarray[m] = list[m];
				break;
			}
		}
	}
	unitConf = newarray;
}

function OnAllUnitsLoad( event_data )
{	
	$('#unit-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#unit-timer'), $.Localize("#Game_tooltip_unit_timer"));});
	$('#unit-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#unit-timer'));});		
	
	$('#income-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#income-timer'), $.Localize("#Game_tooltip_income_timer"));});
	$('#income-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#income-timer'));});		
	
	$('#food-label').SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#food-timer'), $.Localize("#Game_tooltip_food_timer"));});
	$('#food-label').SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#food-timer'));});		
	
	var unitlist_panel = $('#unitlist-panel');
	unitlist_panel.RemoveAndDeleteChildren();
	unitConf = event_data;
	QuickSort(unitConf);
	for(var i in unitConf)
	{		
		(function() {
			var m = i;
			var thisclass = $.CreatePanel("Button", unitlist_panel, unitConf[m].unitclass.slice(1, 100) );
			thisclass.id = unitConf[m].unitclass;
			thisclass.enabled = true;
			var thislabel = $.CreatePanel("Label", thisclass, "label_"+unitConf[m].unitclass);
			thislabel.AddClass("unitPrice");
			thislabel.text = unitConf[m].cost;
			thisclass.style.backgroundSize = "100% 100%";
			thisclass.style.backgroundImage = "url('file://{images}/custom_game/avatar_"+m+".png')";
			thisclass.AddClass("unit");
			thisclass.SetPanelEvent("onactivate", function(){
				if(unitConf[m].ancient == 1) cmdBuyUnit(m, 0); 
				else cmdBuyUnit(m, 1);});
			var thislocal = "<font color='#aaa'>"+$.Localize("#tooltip_"+m)+"<br>"
					+$.Localize("#Game_tooltip_income") +"<font color='#ffee00'>"+unitConf[m].income*incomeconst+"</font><br>"					
					+$.Localize("#Game_tooltip_food")
					+"<font color='orange'>"+unitConf[m].food+"</font>"+"<br>"				
					+"<br>"+$.Localize("#Game_tooltip_health")+"<font color='red'>"+unitConf[m].health+"</font>"
					+"<br>"+$.Localize("#Game_tooltip_attackrange")+"<font color='lightgreen'>"+unitConf[m].attackrange+"</font>"
					+"<br>"+$.Localize("#Game_tooltip_damage")+"<font color='lightgreen'>"+unitConf[m].mindamage+"-"+unitConf[m].maxdamage+"</font>"
					+"<br>"+$.Localize("#Game_tooltip_armor")+"<font color='lightblue'>"+unitConf[m].armor+"</font>"
					+"<br>"+$.Localize("#Game_tooltip_gold")+"<font color='#ffee00'>"+unitConf[m].mingold+"</font>-"+"<font color='#ffee00'>"+unitConf[m].maxgold+"</font>"+"</font>";
					
			if(unitConf[m].ancient == 1) thislocal = $.Localize("#Game_tooltip_ancient") + thislocal;				 	
			if(unitConf[m].ability1 != "")
			{
				thislocal = thislocal+"<br>"+$.Localize("#Game_tooltip_ability") +"<font color='#ff0000'>"+$.Localize("#DOTA_Tooltip_ability_" + unitConf[m].ability1)+"</font>";
					if(unitConf[m].ability2 != "")
					{
						thislocal = thislocal+"<br><font color='#ff0000'>"+$.Localize("#DOTA_Tooltip_ability_" + unitConf[m].ability2)+"</font>";
						if(unitConf[m].ability3 != "")
						{
							thislocal = thislocal+"<br><font color='#ff0000'>"+$.Localize("#DOTA_Tooltip_ability_" + unitConf[m].ability3)+"</font>";
							if(unitConf[m].ability4 != "")
							{
								thislocal = thislocal+"<br><font color='#ff0000'>"+$.Localize("#DOTA_Tooltip_ability_" + unitConf[m].ability4)+"</font>";
								if(unitConf[m].ability5 != "")
								{
									thislocal = thislocal+"<br><font color='#ff0000'>"+$.Localize("#DOTA_Tooltip_ability_" + unitConf[m].ability5)+"</font>";
								}
							}
						}
					}
			}				
					
			thisclass.SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", thisclass, thislocal);});
			thisclass.SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", thisclass);});		
		})(); 
	}
	RegeneratePageUnits();
}

function OnPlayerUnitsLoad(data)
{
	//$.Msg(data);
	var newunits = {};
	for(var i in data)
	{
		(function() {
			var m = i;
			var name = data[m].name
			newunits[name] = {count: data[m].count, unitclass: "unitclass_"+name}
		})();
	}
	ReloadCurrentUnitsPanel(newunits);
}

function ReloadCurrentUnitsPanel(units)
{
	var unitlistlabel = $('#unitlist-label');
	unitlistlabel.RemoveAndDeleteChildren();	
	delete unitHaved;
	unitHaved = units;
	var sellLabel = $.CreatePanel("Label", unitlistlabel, "sell_label");
	sellLabel.text = "Продать";	
	sellLabel.style.color = "white";
	sellLabel.style.fontSize = "12px";
	
	for(i in unitHaved)
	{
		(function() {
			var m = i;
			if(unitHaved[m].count > 0)
			{
				var thispanel = $.CreatePanel("Button", unitlistlabel, unitHaved[m].unitclass );
				var thislabel = $.CreatePanel("Label", thispanel, "label_"+unitHaved[m].unitclass);
				thispanel.SetPanelEvent( 'onactivate', function(){ cmdSellUnit(m, 1);});
				thispanel.AddClass("currentunit_list");
				thislabel.AddClass("currentunit_list_label");
				thispanel.style.border = "2px solid gray"; 
				thislabel.text = "$";	
				thislabel.style.visibility = "collapse";
				thispanel.SetPanelEvent("onmouseover", function(){
					thislabel.style.visibility = "visible";
					thispanel.style.border = "3px solid yellow"; 
					var allunitcost = unitConf[m].cost*unitHaved[m].count;
					$.DispatchEvent("DOTAShowTextTooltip", thispanel, $.Localize("#Game_tooltip_sellunit")+" - <font color='#ffee00'>"+unitConf[m].cost+"</font><br>"+$.Localize("#tooltip_"+m)+"<br>"+ $.Localize("#Game_tooltip_currentunitcount") + unitHaved[m].count+" ("+"<font color='#ffee00'>"+ allunitcost +"</font>)");
				});
				thispanel.SetPanelEvent("onmouseout", function(){
					thislabel.style.visibility = "collapse";					
					thispanel.style.border = "2px solid white"; 
					$.DispatchEvent("DOTAHideTextTooltip", thispanel);
				});		
				
				thispanel.style.backgroundSize = "100% 100%";
				thispanel.style.backgroundImage = "url('file://{images}/custom_game/avatar_"+m+".png')";
			}	
		})();
	}
}
 
function cmdSellUnit(unitname, count)
{
	if(unitHaved[unitname].count > 0)
	{
		//$.Msg( "EVENT: unit_sell - true ");
		var unitcount = 0;
		for(var i in unitHaved)
		{
			(function(){
				var m = i;
				if(unitHaved[m].count > 0) unitcount += unitHaved[m].count;
				//$.Msg(unitcount);
			})();
		}
		if(unitcount > 4)
		{
			var data = {
				name: unitname,
				count: count
			};
			GameEvents.SendCustomGameEventToServer( "sell_unit", data );
			//$.Msg( "EVENT: unit_sell_success - true ");
			Game.EmitSound("General.Sell");
		}
		else 
		{
			Game.EmitSound("General.NoGold");
		}		
	}

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

function cmdBuyUnit(unitname, count)
{
	//$.Msg( "EVENT: unit_buy - true ");
	var needfood =  myfood + unitConf[unitname].food;
	if(Players.GetGold(Players.GetLocalPlayer()) >= unitConf[unitname].cost && needfood <= mymaxfood) 
	{
		
		var data = {
			name: unitname,
			count: count
		};
		GameEvents.SendCustomGameEventToServer( "buy_unit", data );
		//$.Msg( "EVENT: unit_buy_success - true ");
		Game.EmitSound("General.Buy");
	}
	else 
	{
		Game.EmitSound("General.NoGold");
	}
}
