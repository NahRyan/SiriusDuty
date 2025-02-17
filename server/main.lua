---@diagnostic disable: need-check-nil
local onDutyPlayers = {}
local MangementPlayers = {}
local AFKPlayers = {}
local BlipUpdateTime = 1;
local OnDutyStaff = {}
local SpawnedPlayers = {}

RegisterCommand("duty", function(source, args, rawCommand)
    local src = source

    local isAlreadyOnDuty = false
    for _, player in ipairs(onDutyPlayers) do
        if player.src == src then
            isAlreadyOnDuty = true
            break
        end
    end

    if isAlreadyOnDuty then
        handlePlayerOffDuty(src)
    else
        TriggerClientEvent("SiriusDuty:Menu", src)
    end
end)

RegisterCommand("clockin", function(source, args, rawCommand)
    local src = source

    local isAlreadyOnDuty = false
    for _, player in ipairs(OnDutyStaff) do
        if player.src == src then
            isAlreadyOnDuty = true
            break
        end
    end

    if Player(src).state['SD:IsManagement'] ~= "true" then
        if isAlreadyOnDuty then
            handleStaffOffDuty(src)
        else
            TriggerEvent("SiriusDuty:StaffDuty", src)
        end
    else
        TriggerClientEvent('codem-notification', src, "You do not have permission to go on duty as staff.", 4500, "error")
    end
end)

RegisterServerEvent("SiriusDuty:GetRank")
AddEventHandler("SiriusDuty:GetRank", function()
    local src = source
    local PlayerRoles = exports.Badger_Discord_API:GetDiscordRoles(src)
	
    if PlayerRoles == nil or type(PlayerRoles) ~= "table" then
        print("Error: Invalid or empty PlayerRoles for playerId: " .. src)
        return
    end

    local hasStaff = false
    local staffName = "N/A"
    for _, roleID in ipairs(PlayerRoles) do
        roleID = tonumber(roleID)

        if staff[roleID] then
            hasStaff = true
            staffName = staff[roleID]
            roleFound = true
        end
    end

    if roleFound then
        Player(src).state["SD:StaffRank"] = staffName
    else
        print("Error: No matching roles found for playerId: " .. src)
    end
end)

RegisterNetEvent('SiriusDuty:PlayerLoaded')
AddEventHandler('SiriusDuty:PlayerLoaded', function()
    local src = source
    Player(src).state['SD:IsOnDept'] = nil
    Player(src).state['SD:DeptLogo'] = nil
    Player(src).state['SD:DeptCallsign'] = nil
    Player(src).state['SD:OfficerName'] = nil
    Player(src).state['SD:Department'] = nil
    Player(src).state['SD:IsManagement'] = nil
    Player(src).state['SD:IsStaff'] = nil
end)

RegisterNetEvent('SiriusDuty:Management')
AddEventHandler('SiriusDuty:Management', function()
    local src = source
    if IsPlayerAceAllowed(src, Config.Management.Ace) then
        Wait(1000)
        MangementPlayers[src] = true

        Player(src).state['SD:IsManagement'] = "true"
        Player(src).state['SD:IsStaff'] = "true"
    else
        MangementPlayers[src] = false
    end
end)

RegisterServerEvent("SiriusDuty:GetDpts")
AddEventHandler("SiriusDuty:GetDpts", function()
    local src = source
    local playerDpts = {}

    for dep, data in pairs(Config.Departments) do
        if IsPlayerAceAllowed(src, data.Ace) then
            table.insert(playerDpts, dep)
        end
    end

    table.sort(playerDpts, function(a, b)
        return a < b
    end)

    if #playerDpts > 0 then
        TriggerClientEvent("SiriusDuty:sendDpts", src, playerDpts)
    else
        TriggerClientEvent('codem-notification', src, "There seems to be no departments you can go on as.", 4500, "error")
    end
end)

RegisterServerEvent('SiriusDuty:onDuty')
AddEventHandler('SiriusDuty:onDuty', function(department, callsign, Dutyname)
    local src = source

    if department == nil or callsign == nil then
        return
    end

    department = string.upper(department)
    callsign = string.upper(callsign)

    print("Player " .. src .. " is on duty as " .. department .. " with callsign " .. callsign)

    local hasPermission = false     
    if Config.Departments[department] and Config.Departments[department].Ace then
        hasPermission = IsPlayerAceAllowed(src, Config.Departments[department].Ace)
    end

    if hasPermission then
        local startTime = os.time()
        Player(src).state['SD:IsOnDept'] = "true"
        Player(src).state['SD:DeptLogo'] = Config.Departments[department].Logo
        Player(src).state['SD:DeptCallsign'] = callsign
        Player(src).state['SD:OfficerName'] = Dutyname
        Player(src).state['SD:Department'] = department
        Player(src).state['SD:DeptType'] = Config.Departments[department].Type
        
        table.insert(onDutyPlayers, {src = src, time = startTime, department = department, callsign = callsign, blip = Config.Departments[department].BlipColor, category = Config.Departments[department].Type})
        TriggerClientEvent('SiriusDuty:enableblips', src, Config.Departments[department].Type)

        local identifiers = ExtractIdentifiers(src)
        local playerData = {
            discordId = identifiers.discord and identifiers.discord:gsub("discord:", "") or nil,
            playerId = src,
            department = department,
            callsign = callsign,
            timeOnDuty = 0
        }

        if Config.Departments[department].Bodycam then
            TriggerClientEvent('SiriusDuty:bodyCam', src, true)
            TriggerClientEvent('SiriusDuty:bodyCamReturnData', src, {
                department = longName(department),
                callsign = callsign,
                name = Dutyname,
                authed = true
            })
        end

        TriggerEvent('SiriusDuty:API:Event', 'onDuty', playerData)

        if AFKPlayers[src] then
            AFKPlayers[src] = nil
            TriggerClientEvent('SiriusDuty:resetAFKStatus', src)
        end

        unitdata = {
            type = Config.Departments[department].Type,
            department = longName(department),
            shortname = Config.Departments[department].ShortName,
            name = Dutyname,
            callsign = callsign,
        }

        TriggerClientEvent('SiriusDuty:onDuty', src, unitdata)

        MySQL.Async.execute("INSERT INTO activedutyunits (discord, id, name, dpt, onDutySince) VALUES (@discord, @id, @name, @dpt, @onDutySince)", {
            ['@discord'] = ExtractIdentifiers(src).discord:gsub("discord:", ""),
            ['@id'] = src,
            ['@name'] = GetPlayerName(src),
            ['@dpt'] = department,
            ['@onDutySince'] = os.date("%c", os.time())
        })

    else
        TriggerClientEvent('codem-notification', src, "You do not have permission to go on duty as this department.", 4500, "error")
    end
end)

RegisterServerEvent('SiriusDuty:StaffDuty')
AddEventHandler('SiriusDuty:StaffDuty', function(source)
    local src = source

    department = "STAFF"
    callsign = "N/A"

    if IsPlayerAceAllowed(src, Config.Staff.Ace) then
        local startTime = os.time()

        table.insert(OnDutyStaff, {src = src, time = startTime, department = department, callsign = callsign, category = "STAFF"})

        local identifiers = ExtractIdentifiers(src)
        local playerData = {
            discordId = identifiers.discord and identifiers.discord:gsub("discord:", "") or nil,
            playerId = src,
            department = department,
            callsign = callsign,
            timeOnDuty = 0
        }

        TriggerEvent('SiriusDuty:API:Event', 'onDuty', playerData)
        
        if AFKPlayers[src] then
            AFKPlayers[src] = nil
            TriggerClientEvent('SiriusDuty:resetAFKStatus', src)
        end

        unitdata = {
            type = "STAFF",
            department = "STAFF",
        }

        TriggerClientEvent('SiriusDuty:onDuty', src, unitdata)

        MySQL.Async.execute("INSERT INTO activedutyunits (discord, id, name, dpt, onDutySince) VALUES (@discord, @id, @name, @dpt, @onDutySince)", {
            ['@discord'] = identifiers.discord:gsub("discord:", ""),
            ['@id'] = src,
            ['@name'] = GetPlayerName(src),
            ['@dpt'] = department,
            ['@onDutySince'] = os.date("%c", startTime)
        })

        if Player(src).state['SD:IsManagement'] ~= "true" then
            Player(src).state['SD:IsStaff'] = "true"
            print("ON duty staff")
        end
    else
        TriggerClientEvent('codem-notification', src, "You do not have permission to go on duty as staff.", 4500, "error")
    end
end)

function handlePlayerOffDuty(src)
    local identifiers = ExtractIdentifiers(src)
    local discordId = identifiers.discord:gsub("discord:", "")
    local playerIndex = nil

    for i = 1, #onDutyPlayers do
        if onDutyPlayers[i].src == src then
            playerIndex = i
            break
        end
    end

    if playerIndex then
        local startTime = onDutyPlayers[playerIndex].time
        if not startTime then
            return
        end
        
        local timeOnDuty = os.difftime(os.time(), startTime) / 60 
        timeOnDuty = math.max(0, timeOnDuty)

        local lastClockin = os.date('%Y-%m-%d %H:%M:%S')
        local department = onDutyPlayers[playerIndex].department
        local callsign = onDutyPlayers[playerIndex].callsign
        local departmentLongName = Config.Departments[department].LongName
        local badge = Config.Departments[department].Logo
        local type = Config.Departments[department].Type

        table.remove(onDutyPlayers, playerIndex)

        MySQL.Async.execute('INSERT INTO dutylogs (`id`, `name`, `dept`, `time`, `lastclockin`, `type`) VALUES (@id, @name, @dept, @time, @lastseen, @type);', {
            ['@id'] = discordId,
            ['@name'] = callsign,
            ['@dept'] = department,
            ['@time'] = timeOnDuty,
            ['@lastseen'] = lastClockin,
            ['@type'] = type
        })

        Player(src).state['SD:IsOnDept'] = nil
        Player(src).state['SD:DeptLogo'] = nil
        Player(src).state['SD:DeptCallsign'] = nil
        Player(src).state['SD:OfficerName'] = nil
        Player(src).state['SD:Department'] = nil

        TriggerClientEvent('SiriusDuty:bodyCam', src, false)

        MySQL.Async.execute("DELETE FROM activedutyunits WHERE discord = @discord", {
            ['@discord'] = discordId
        })

        TriggerClientEvent('SiriusDuty:disableblips', tonumber(src))
        TriggerClientEvent("SiriusDuty:CreateBlips", -1, onDutyPlayers)

        local playerData = {
            discordId = discordId,
            playerId = src,
            departmentLongName = departmentLongName,
            department = department,
            callsign = callsign,
            timeOnDuty = timeOnDuty,
            badge = badge
        }

        TriggerEvent('SiriusDuty:API:Event', 'offDuty', playerData)
        TriggerClientEvent("SiriusDuty:offDuty", src, "DEPT")
    else
        print("ERROR: Player not found in onDutyPlayers list.")
    end
end

function handleStaffOffDuty(src)
    local identifiers = ExtractIdentifiers(src)
    local discordId = identifiers.discord:gsub("discord:", "")
    local playerIndex = nil

    for i = 1, #OnDutyStaff do
        if OnDutyStaff[i].src == src then
            playerIndex = i
            break
        end
    end

    if playerIndex then
        local timeOnDuty = os.difftime(os.time(), OnDutyStaff[playerIndex].time) / 60
        timeOnDuty = math.max(0, timeOnDuty)
        local lastClockin = os.date('%Y-%m-%d %H:%M:%S')

        table.remove(OnDutyStaff, playerIndex)

        MySQL.Async.execute('INSERT INTO dutylogs (`id`, `name`, `dept`, `time`, `lastclockin`, `type`) VALUES (@id, @name, @dept, @time, @lastseen, @type);', {
            ['@id'] = discordId,
            ['@name'] = callsign,
            ['@dept'] = "STAFF",
            ['@time'] = timeOnDuty,
            ['@lastseen'] = lastClockin,
            ['@type'] = "STAFF"
        })

        Player(src).state['SD:IsStaff'] = nil

        MySQL.Async.execute("DELETE FROM activedutyunits WHERE discord = @discord", {
            ['@discord'] = discordId
        })

        TriggerClientEvent('SiriusDuty:disableblips', tonumber(src))
        TriggerClientEvent("SiriusDuty:CreateBlips", -1, OnDutyStaff)

        local playerData = {
            discordId = discordId,
            playerId = src,
            departmentLongName = "Staff Team",
            department = "STAFF",
            callsign = "N/A",
            timeOnDuty = timeOnDuty,
            badge = Config.Staff.Logo
        }

        TriggerEvent('SiriusDuty:API:Event', 'offDuty', playerData)
        TriggerClientEvent("SiriusDuty:offDuty", src, "STAFF")
    end
end

AddEventHandler('playerDropped', function()
    local src = source
    if AFKPlayers[src] then
        AFKPlayers[src] = nil
    end

    for _, player in ipairs(onDutyPlayers) do
        if player.src == src then
            handlePlayerOffDuty(src)
            break
        end
    end

    for _, player in ipairs(OnDutyStaff) do
        if player.src == src then
            handleStaffOffDuty(src)
            break
        end
    end
end)

CreateThread(function()
    while true do
        Wait(100)
        local list = {}
        for id, info in pairs(onDutyPlayers) do
            if GetPlayerPed(info.src) then
                local coordsForONDP = GetEntityCoords(GetPlayerPed(info.src))
                table.insert(list, {
                    ['svid'] = info.src,
                    ['x'] = coordsForONDP.x,
                    ['y'] = coordsForONDP.y,
                    ['z'] = coordsForONDP.z,
                    ['name'] = '['..info.callsign..'] '..GetPlayerName(info.src),
                    ['hdg'] = math.floor(tonumber(GetEntityHeading(GetPlayerPed(info.src)))),
                    ['color'] = info.blip,
                    ['category'] = info.category
                })
            end
        end
        for id, info in pairs(onDutyPlayers) do
            TriggerClientEvent('SiriusDuty:updateblips', tonumber(info.src), list)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60 * 1000)
        for _, player in ipairs(onDutyPlayers) do
            player.time = player.time + 1
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60 * 1000)
        for _, player in ipairs(OnDutyStaff) do
            player.time = player.time + 1
        end
    end
end)

---comment
---@param src any Player ID
---@return table any Identifiers table
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end
    return identifiers
end


---comment
---@param department any The department short name
---@return string
function longName(department)
    return Config.Departments[department].LongName
end

exports("GetDepartmentName", longName)

function GetAllOnDutyPlayers()
    return onDutyPlayers
end

exports("GetAllOnDutyPlayers", GetAllOnDutyPlayers)

function GetPlayerDepartment(src)
    for _, player in ipairs(onDutyPlayers) do
        if player.src == src then
            return player.department
        end
    end
    return false
end

exports("GetPlayerDepartment", GetPlayerDepartment)

---comment
---@param src any Player ID ex. Source
---@return boolean
function IsPlayerManagement(src)
    if MangementPlayers[src] then
        return true
    end
    return false
end

exports("IsPlayerManagement", IsPlayerManagement)

---comment
---@param src any Player ID ex. Source
---@return boolean
function IsPlayerStaff(src)
    for _, player in ipairs(OnDutyStaff) do
        if player.src == src then
            return true
        end
    end
    return false
end

exports("IsPlayerStaff", IsPlayerStaff)

---comment
---@param src any Player ID ex. Source
---@return any any Users Callsign or False
function GetPlayerCallsign(src)
    for _, player in ipairs(onDutyPlayers) do
        if player.src == src then
            return player.callsign
        end
    end
    return false
end

exports("GetPlayerCallsign", GetPlayerCallsign)

---comment
---@param src any Player ID ex. Source
---@return any any Users Callsign or False
function GetDeptartmentType(src)
    for _, player in ipairs(onDutyPlayers) do
        if player.src == src then
            return player.type
        end
    end
    return false
end

exports("GetDeptartmentType", GetDeptartmentType)

lib.callback.register('SiriusDuty:GetAllOnDutyPlayers', function(source)
    return onDutyPlayers
end)

lib.callback.register('SiriusDuty:GetPlayerDepartment', function(source)
    return GetPlayerDepartment(source)
end)

lib.callback.register('SiriusDuty:IsPlayerManagement', function(source)
    return IsPlayerManagement(source)
end)

lib.callback.register('SiriusDuty:IsPlayerStaff', function(source)
    return IsPlayerStaff(source)
end)

lib.callback.register('SiriusDuty:GetPlayerCallsign', function(source)
    return GetPlayerCallsign(source)
end)

lib.callback.register('SiriusDuty:GetDeptartmentType', function(source)
    return GetDeptartmentType(source)
end)

lib.callback.register('SiriusDuty:GetDepartmentLogo', function(source)
    return Player(source).state['SD:DeptLogo']
end)

lib.callback.register('SiriusDuty:GetDeptLongName', function(source, dname)
    return longName(dname)
end)

