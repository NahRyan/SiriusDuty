local Enabled = false

local Tags = {}

SetMpGamerTagsUseVehicleBehavior(false)
LocalPlayer.state:set("chat:hiddenname", "no", true)

local function GetPlayerDisplayName(ServerId)
    local State = Player(ServerId).state
    local ThisPlayer = GetPlayerFromServerId(ServerId)
    local ThisName = GetPlayerName(ThisPlayer)
    local DisplayName = string.format("%s [%d]", ThisName, ServerId)
    local Crew = ""
    local HiddenRank = "no"
    local StaffRank = State["SD:StaffRank"]
    local CustomColour = 0
    if StaffRank and StaffRank ~= nil then
        if HiddenRank ~= "yes" then
            DisplayName = string.format("%s [%s]", DisplayName, StaffRank)
            print(DisplayName)
        end
    end

    if State["SD:DeptType"] ~= nil then
        if State["SD:IsManagement"] == "true" then
            Crew = "MNGT"
        elseif State["SD:Department"] ~= nil then
            Crew = State["SD:Department"]
        end
    end
    if State["SD:IsManagement"] == "true" then
        Crew = "MNGT"
        CustomColour = 26
    end
    if State["SD:IsStaff"] == "true" then
        CustomColour = 18
    end
    return DisplayName, Crew, CustomColour
end

local function CreateTag(ServerId)
    local PlayerX = GetPlayerFromServerId(ServerId)
    local DisplayName, Crew, Colour = GetPlayerDisplayName(ServerId)
    local State = Player(ServerId).state
    if IsMpGamerTagActive(PlayerX) then
        RemoveMpGamerTag(PlayerX)
        repeat
            Wait(0)
        until IsMpGamerTagFree(PlayerX)
    end

    CreateMpGamerTagWithCrewColor(PlayerX, DisplayName, false, false, Crew, 0, 255, 255, 255)

    SetMpGamerTagVisibility(PlayerX, 0, true) -- Name
    if State["SD:Department"] == nil then
        SetMpGamerTagColour(PlayerX, 0, Colour)
        SetMpGamerTagVisibility(PlayerX, 1, Crew ~= "")
    elseif State["SD:IsManagement"] == "true" then
        SetMpGamerTagColour(PlayerX, 0, Colour)
        SetMpGamerTagVisibility(PlayerX, 1, Crew ~= "")
    end
    
    if State["SD:DeptType"] ~= nil then
        SetMpGamerTagVisibility(PlayerX, 1, Crew ~= "")
    end

    if Colour ~= 0 then
        SetMpGamerTagColour(PlayerX, 0, Colour)
    end

    Tags[ServerId] = true
end

local function TagsThread()
    while Enabled do
        local me = cache.ped
        local coords = GetEntityCoords(me)
        for _, index in pairs(GetActivePlayers()) do
            local them = GetPlayerPed(index)
            if them ~= 0 and them ~= me and them ~= -1 then
                local them_id = GetPlayerServerId(index)
                local them_coords = GetEntityCoords(them)

                if #(coords - them_coords) <= 50.0 then
                    if not Tags[them_id] or not IsMpGamerTagActive(index) then
                        CreateTag(them_id)
                    end
                else
                    if Tags[them_id] then
                        RemoveMpGamerTag(index)
                        Tags[them_id] = nil
                    end
                end
            end
        end

        Wait(500)
    end
end

RegisterNetEvent(
    "Sirius:vMenu:TogglePlayerNames",
    function(bool)
        print(Player(GetPlayerServerId(PlayerId())).state['SD:IsStaff'])
        if bool and (not exports["SiriusDuty"]:IsPlayerStaff()) then
            if not exports["SiriusDuty"]:IsPlayerManagement() then
                return 
            end
        end

        Enabled = bool
        if Enabled then
            CreateThread(TagsThread)
        else
            for k, _ in pairs(Tags) do
                local PlayerId = GetPlayerFromServerId(k)
                RemoveMpGamerTag(PlayerId)
            end
            Tags = {}
        end
    end
)

AddStateBagChangeHandler(
    "SD:IsStaff",
    nil,
    function(bagName, key, value)
        local StaffPlayer = GetPlayerFromStateBagName(bagName)
        if StaffPlayer == 0 then
            return
        end

        local PlayerServerId = GetPlayerServerId(StaffPlayer)
        if value == "true" then
            OnDuty[PlayerServerId] = true
            if Enabled then
                CreateTag(PlayerServerId)
            end
        elseif value == "false" then
            if PlayerServerId == cache.serverId then
                if Enabled then
                    TriggerEvent("Sirius:vMenu:TogglePlayerNames", false)
                end
            end
            OnDuty[PlayerServerId] = nil
            if Player(PlayerServerId).state["SD:IsStaff"] == "true" and value == "false" and Enabled then
                CreateTag(PlayerServerId)
            end
        end
    end
)

RegisterCommand(
    "vmenutest",
    function()
        if Enabled then
            TriggerEvent("Sirius:vMenu:TogglePlayerNames", false)
        else
            TriggerEvent("Sirius:vMenu:TogglePlayerNames", true)
        end
    end
)