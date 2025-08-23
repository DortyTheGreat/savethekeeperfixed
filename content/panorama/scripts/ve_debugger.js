
GameEvents.Subscribe( "error_debuger", OnErrorDebug);

function OnErrorDebug(data)
{
	$.Msg("[VE error] "+data.g_error);
}