var upgradeConf = {};

GameEvents.Subscribe( "load_allupgrades", OnAllUpgradesLoad);
GameEvents.Subscribe( "upgradebuy_success", BuySuccess);

 
function onJavaTimerTick( )
{	
	if(Object.keys(upgradeConf).length == 0)
	{
		GameEvents.SendCustomGameEventToServer( "unitpanel_debug", {thisdata : 1} );
	}
	for(var i in upgradeConf)
	{
		var thisclass = $('#'+i);		
		if(Players.GetGold(Players.GetLocalPlayer()) < upgradeConf[i].cost )
		{ 
			thisclass.style.washColor = "#777";
		}
		else 
		{
			thisclass.style.washColor = "#fff";
			//Game.EmitSound("Quickbuy.Available");
		}	
	}
	$.Schedule(0.05, onJavaTimerTick);
	
}

onJavaTimerTick();

function HideUpgradePanel()
{
	$('#global_panel').style.visibility = "collapse";
	Game.EmitSound("ui.shortwhoosh");
}

function SeeUpgradePanel()
{
	if($('#global_panel').style.visibility == "visible") {$('#global_panel').style.visibility = "collapse";}
	else {$('#global_panel').style.visibility = "visible";}
	Game.EmitSound("ui.shortwhoosh");
	 
}

function BuyUpgrade(upgrade_name)
{
	if(Players.GetGold(Players.GetLocalPlayer()) >= upgradeConf[upgrade_name].cost) 
	{
		
		var data = {
			name: upgrade_name
		};
		GameEvents.SendCustomGameEventToServer( "buy_upgrade", data );
		//$.Msg( "EVENT: unit_buy_success - true ");
		Game.EmitSound("General.Buy");
	}
	else 
	{
		Game.EmitSound("General.NoGold");
	}
}

function BuySuccess(data)
{
	upgradeConf = data;
	for(var i in upgradeConf)
	{
	
		(function() {
			var m = i;
			$('#'+m).GetChild(1).text = upgradeConf[m].cost;
			$('#'+m).GetChild(2).text = upgradeConf[m].level;
		})(); 
	}
}

function OnAllUpgradesLoad( event_data )
{	

	upgradeConf = event_data;
	for(var i in upgradeConf)
	{		
		(function() {
			var m = i;

			var thislocal = $.Localize("#Upgrade_tooltip_name") 
					+$.Localize("#Upgrade_tooltip_"+m)+"<br>"
					+$.Localize("#Upgrade_tooltip_desc_"+m);
			$('#'+m).GetChild(1).text = upgradeConf[m].cost;
			$('#'+m).SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowTextTooltip", $('#'+m), thislocal);});
			$('#'+m).SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideTextTooltip", $('#'+m));});				
		})(); 
	}
}