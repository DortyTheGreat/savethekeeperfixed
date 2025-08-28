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



-- This function can only be called midgame
function GetFromServer()

    print('getting data from server...')

    local req = CreateHTTPRequestScriptVM(
        "POST",
        SUPABASE_URL .. "/rest/v1/rpc/get_player_stats"
    )

    req:SetHTTPRequestHeaderValue("apikey", SUPABASE_KEY)
    req:SetHTTPRequestHeaderValue("Authorization", "Bearer " .. SUPABASE_KEY)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")


    local playerIDs = {}
    for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:IsValidPlayerID(i) then
            table.insert(playerIDs, PlayerResource:GetSteamAccountID(i))
        end
    end



    local body = {
        _key = GetDedicatedServerKeyV3("authKey"),
        ids = playerIDs
    }

    req:SetHTTPRequestRawPostBody("application/json", json.encode(body))
    req:Send(function(res)
        print("Supabase responded get: " .. res.StatusCode)
        print("Body: " .. res.Body) -- JSON со статистикой игроков
        --return res.Body
        LoadStats(json.decode(res.Body))
    end)
end

-- This function can only be called midgame
function LoadStats(stats_json)
    local WIN_MODIFIER = "modifier_stats_wins"
    local LOSS_MODIFIER = "modifier_stats_losses"

    for _, player_stats in ipairs(stats_json) do
        local steamID = player_stats.player_id
        
        print('steamID loaded ' .. steamID)
        print('wins loaded ' .. player_stats.wins)

        -- находим ID игрока в игре
        local playerID = nil
        for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:IsValidPlayerID(i) then
                if PlayerResource:GetSteamAccountID(i) == steamID then
                    playerID = i
                    break
                end
            end
        end

        if playerID then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                -- выдаём победы
                local win_mod = hero:AddNewModifier(hero, nil, WIN_MODIFIER, {})
                if win_mod then
                    win_mod:SetStackCount(player_stats.wins)
                end

                --[[ выдаём поражения
                local loss_mod = hero:AddNewModifier(hero, nil, LOSS_MODIFIER, {})
                if loss_mod then
                    loss_mod:SetStackCount(player_stats.losses)
                end
                ]]
            end
        end
    end
end

ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GameMode, "OnGameStateChanged_rating"), self)

--DOTA_GAMERULES_STATE_PRE_GAME = 4,
--DOTA_GAMERULES_STATE_GAME_IN_PROGRESS = 5,
-- require('libraries/timers')
function GameMode:OnGameStateChanged_rating()
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_PRE_GAME  then
        -- проверим всех игроков
        Timers:CreateTimer(2.0,function()
            GetFromServer()
        end)
        
    end
end

