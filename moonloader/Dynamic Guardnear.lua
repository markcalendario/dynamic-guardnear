script_name("Dynamic Guardnear")
script_author("akacross, Maku Kenesu")
script_version("0.3.2")

require"lib.moonloader"
require"lib.sampfuncs"

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	sampAddChatMessage("{FFFFFF}Dynamic Guard Near by Maku Kenesu. [/guardnear.cmds]")

	sampRegisterChatCommand("guardnear", cmd_guardnear)
	sampRegisterChatCommand("guardnear.cmds", cmd_guardnear_cmds)
	sampRegisterChatCommand("guardnear.cooldown", cmd_guardnear_cooldown)
	sampRegisterChatCommand("vest.price", cmd_vest_price)
	sampRegisterChatCommand("vest.level", cmd_vest_level)
	sampRegisterChatCommand("armorcheck", cmd_armorcheck)
	sampRegisterChatCommand("ignore.add", cmd_ignore_add)
	sampRegisterChatCommand("ignore.remove", cmd_ignore_remove)
	sampRegisterChatCommand("ignore.list", cmd_ignore_list)

	price = 200
	isenabled = true
	armorlvl = 40
	isarmorcheckenabled = true
	ignorelist = {}
	cooldown = 11000

	while true do
		wait(100)

		playerid = getClosestPlayerId(7, isarmorcheckenabled)
		
		if sampIsPlayerConnected(playerid) and isenabled and not inignorelist then 
			sampSendChat(string.format("/guard %d %d", playerid, price))
			wait(cooldown)
		end
	end	
end

function getClosestPlayerId(maxdist, ArmorCheck)
	local i = -1
	local maxplayerid = sampGetMaxPlayerId(false)
    for i = 0, maxplayerid do
		if sampIsPlayerConnected(i) then
			local result, ped = sampGetCharHandleBySampPlayerId(i)
			if result and not sampIsPlayerPaused(i) and not isPlayerInIgnoreList(i) then
				local dist = get_distance_to_player(i)
				if dist < maxdist then
					if ArmorCheck then
						if sampGetPlayerArmor(i) < armorlvl then
							return i
						end
					else
						return i
					end
				end
			end
		end
    end
	return i
end

function isPlayerInIgnoreList(id)
	local found = false

	for _, v in ipairs(ignorelist) do
		if v == id then
			return true
		end
	end

	return false
end

function get_distance_to_player(playerId)
	local dist = -1
	if sampIsPlayerConnected(playerId) then
		local result, ped = sampGetCharHandleBySampPlayerId(playerId)
		if result then
			local myX, myY, myZ = getCharCoordinates(playerPed)
			local playerX, playerY, playerZ = getCharCoordinates(ped)
			dist = getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
			return dist
		end
	end
	return dist
end

function cmd_guardnear()
	if isenabled == true then
		isenabled = false
		sampAddChatMessage("{FFFFFF}Guard Near: You disabled the guard near.")
	elseif isenabled == false then
		isenabled = true
		sampAddChatMessage("{FFFFFF}Guard Near: You enabled the guard near.")
	end
end

function cmd_vest_price(params)
	if #params == 0 then
		sampAddChatMessage("{FFFFFF}Guard Near: Set a price /vest.price [price]")
		do return end
	end

	setprice = tonumber(params)

	if setprice == nil or setprice < 200 or setprice > 1000 then
		sampAddChatMessage("{FFFFFF}Guard Near: Price must be 200 - 1000.")
		do return end
	end

	price = setprice
	sampAddChatMessage(string.format("{FFFFFF}Guard Near: Vest price is now %d.", price))
end

function cmd_armorcheck()
	if isarmorcheckenabled then
		isarmorcheckenabled = false
		sampAddChatMessage("{FFFFFF}Guard Near: You have turned off armor checking")
	else
		isarmorcheckenabled = true
		sampAddChatMessage("{FFFFFF}Guard Near: You have turned on armor checking")
	end
end

function cmd_ignore_add(params)
	if #params == 0 then
		sampAddChatMessage("{FFFFFF}Guard Near: Add player to ignore list. /ignore.add [id]")
		do return end
	end

	id = tonumber(params)

	if id == nil or id > sampGetMaxPlayerId(false) then
		sampAddChatMessage("{FFFFFF}Guard Near: Insert a valid player id.")
		do return end
	end

	for i, v in ipairs(ignorelist) do
		if v == id then
			sampAddChatMessage(string.format("{FFFFFF}Guard Near: Player %d is already in the ignore list.", id))
			do return end
			break
		end
	end

	table.insert(ignorelist, id)
	sampAddChatMessage("{FFFFFF}Guard Near: Player %d has been added to the ignore list.", id)
end

function cmd_ignore_remove(params)
	if #params == 0 then
		sampAddChatMessage("{FFFFFF}Guard Near: Remove player from ignore list. /ignore.remove [id]")
		do return end
	end

	id = tonumber(params)

	if id == nil then
		sampAddChatMessage("{FFFFFF}Guard Near: Insert a valid player id.")
		do return end
	end

	for i, v in ipairs(ignorelist) do
		if v == id then
			table.remove(ignorelist, i)
			sampAddChatMessage(string.format("{FFFFFF}Guard Near: Player %d has been removed from the ignore list.", id))
			do return end
			break
		end
	end

	sampAddChatMessage(string.format("{FFFFFF}Guard Near: Player %d is not in the ignore list.", id))
end

function cmd_ignore_list(params)
	sampAddChatMessage("{FFFFFF}Guard Near: List of players in ignore list.")
	sampAddChatMessage("{FFFFFF}============================================")
	for i, v in ipairs(ignorelist) do
		sampAddChatMessage("{FFFFFF}ID: %d", v)
	end
	sampAddChatMessage("{FFFFFF}============================================")
end

function cmd_vest_level(params)
	if #params == 0 then
		sampAddChatMessage("{FFFFFF}Guard Near: Set a vest level /vest.level [armor]")
		do return end
	end

	level = tonumber(params)

	if level == nil or level < 1 or level > 100 then
		sampAddChatMessage("{FFFFFF}Guard Near: Armor level must be 1 - 100.")
		do return end
	end

	armorlvl = level
	sampAddChatMessage(string.format("{FFFFFF}Guard Near: You will now start vesting players with armor level below %d.", armorlvl))
end

function cmd_guardnear_cmds()
	sampAddChatMessage("{FFFFFF}Guard Near: List of commands.")
	sampAddChatMessage("{00D6F7}/guardnear {FFFFFF} - Toggles guardnear on or off.")
	sampAddChatMessage("{00D6F7}/guardnear.cmds {FFFFFF} - List of commands.")
	sampAddChatMessage("{00D6F7}/guardnear.cooldown {FFFFFF} - Set the cooldown of auto vest.")
	sampAddChatMessage("{00D6F7}/vest.price [price] {FFFFFF} - Sets the price of the vest.")
	sampAddChatMessage("{00D6F7}/vest.level [armor] {FFFFFF} - Limits the highest armor level of players you will offer the vest.")
	sampAddChatMessage("{00D6F7}/armorcheck {FFFFFF} - Toggles armor checking on or off.")
	sampAddChatMessage("{00D6F7}/ignore.add [id] {FFFFFF} - Add player on the ignore list.")
	sampAddChatMessage("{00D6F7}/ignore.remove [id] {FFFFFF} - Remove player from the ignore list.")
	sampAddChatMessage("{00D6F7}/ignore.list {FFFFFF} - List all players from the ignore list.")
end

function cmd_guardnear_cooldown(params)
	if #params == 0 then
		sampAddChatMessage("{FFFFFF}Guard Near: Set auto vest cooldown /guardnear.cooldown [milliseconds]")
		do return end
	end

	cd = tonumber(params)

	if cd == nil or cd < 1 or cd > 3600 then
		sampAddChatMessage("{FFFFFF}Guard Near: Auto vest cooldown must be 1 - 3600 seconds.")
		do return end
	end

	cooldown = cd * 1000 + 1000
	sampAddChatMessage(string.format("{FFFFFF}Guard Near: You will now start vesting players with %d seconds of cooldown.", cd))
end