local SUPABASE_URL = "https://yntomhkoofcbfgdsejpu.supabase.co"
local SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InludG9taGtvb2ZjYmZnZHNlanB1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNzIzNjYsImV4cCI6MjA3MTk0ODM2Nn0.3s0LPwJJl8HI0l99SA7ZcwUQkTi9BMuUwfvptiBot2A" -- anon public key

dkjson = require ("dkjson")

function SendToServer(WinnerTeam)
    print('saving data to server...')
    local data = {
        winner = WinnerTeam,
        players = {}
    }

    for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:IsValidPlayerID(i) then
            local steam_id = PlayerResource:GetSteamAccountID(i)
            local team = PlayerResource:GetTeam(i)
            table.insert(data.players, {id = steam_id, team = team})
        end
    end

    print('data to server')
    DeepPrintTable(data)

    local json = dkjson.encode({
        winner = data.winner,
        players = data.players,
        auth_key = GetDedicatedServerKeyV3("authKey")
    })

    local req = CreateHTTPRequestScriptVM("POST", SUPABASE_URL .. "/rest/v1/matches")
    req:SetHTTPRequestHeaderValue("apikey", SUPABASE_KEY)
    req:SetHTTPRequestHeaderValue("Authorization", "Bearer " .. SUPABASE_KEY)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    req:SetHTTPRequestRawPostBody("application/json", json)
    
    req:Send(function(res)
        print("Supabase responded: " .. res.StatusCode)
        print("Body: " .. res.Body)
    end)
    --print("Body: " .. req.Body)
end