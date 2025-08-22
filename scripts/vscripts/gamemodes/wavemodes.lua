require('libraries/timers')

-- Gotta send a message a bit later in order to avoid chat deletion 
function SendCustomMessageWithDelay(delay, text)
	--print('debug123472 printed ')
	--GameRules:SendCustomMessage(text, 0, 0)
	Timers:CreateTimer(delay,function()
		GameRules:SendCustomMessage(text, 0, 0)
		print('debug91824 printed ')
	end)
end


function init_classic_wavemode()
	SendCustomMessageWithDelay(1,"Был выбран режим <font color='gold'>".. "Классический" .."</font>")
	ROUND_DELAY = 30.0 				-- время между каждым раундом (волной).
	INCOME_COUNT = 10				-- коэффициент дохода (во сколько раз будет увеличен базовый доход от покупки юнитов).
	INCOME_DELAY = 15.0				-- время между получением дохода.
	BONUS_FOOD = 5
end


function init_fast_wavemode()
	SendCustomMessageWithDelay(1, "Был выбран режим <font color='green'>".. "Быстрый" .."</font>")
	ROUND_DELAY = 10.0 				-- время между каждым раундом (волной).
	INCOME_COUNT = 30				-- коэффициент дохода (во сколько раз будет увеличен базовый доход от покупки юнитов).
	INCOME_DELAY = 10.0				-- время между получением дохода.
	BONUS_FOOD = 15					-- количество еды, даваемое за стадию (BONUS_FOOD умножается на GAME_STATE_NUMBER и прибавляется к текущему максимальному значению еды игрока).
end


function init_long_wavemode()
	SendCustomMessageWithDelay(1, "Был выбран режим <font color='red'>".. "Долгий" .."</font>")
	ROUND_DELAY = 45.0 				-- время между каждым раундом (волной).
	INCOME_COUNT = 15				-- коэффициент дохода (во сколько раз будет увеличен базовый доход от покупки юнитов).
	INCOME_DELAY = 45.0				-- время между получением дохода.
	BONUS_FOOD = 5
end


function init_modern_wavemode()
	SendCustomMessageWithDelay(1, "Был выбран режим <font color='purple'>".. "Modern" .."</font>")
	ROUND_DELAY = 30.0 				-- время между каждым раундом (волной).
	INCOME_COUNT = 20				-- коэффициент дохода (во сколько раз будет увеличен базовый доход от покупки юнитов).
	INCOME_DELAY = 30.0				-- время между получением дохода.
	BONUS_FOOD = 5
end