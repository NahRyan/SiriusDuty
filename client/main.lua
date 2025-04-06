
local afkTimer = 0
local afkTimeLimit = 600
local lastPosition = GetEntityCoords(PlayerPedId())
local OnDutyPlayerBlips = {}

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local currentPosition = GetEntityCoords(PlayerPedId())

        if #(currentPosition - lastPosition) > 0.1 then
            afkTimer = 0
            lastPosition = currentPosition
        else
            local isInputDetected = IsControlPressed(0, 32) or
                                   IsControlPressed(0, 34) or
                                   IsControlPressed(0, 44) or
                                   IsControlPressed(0, 36) or
                                   IsControlPressed(0, 20) or
                                   IsControlPressed(0, 24) or
                                   IsControlPressed(0, 21)

            if isInputDetected then
                afkTimer = 0
            else
                afkTimer = afkTimer + 1
                
                if afkTimer >= afkTimeLimit then
                    TriggerServerEvent('SiriusDuty:checkAFK')
                    afkTimer = 0
                end
            end
        end
    end
end)

CreateThread(function()
    TriggerServerEvent("SiriusDuty:Management")
    TriggerServerEvent("SiriusDuty:PlayerLoaded")
    TriggerServerEvent("SiriusDuty:GetRank")
    
    TriggerEvent('chat:addSuggestion', '/kickoffduty', 'Opens the menu to send users off duty.')
    TriggerEvent('chat:addSuggestion', '/clockin', 'Go on duty as a Staff Member')
    TriggerEvent('chat:addSuggestion', '/duty', 'Opens the Department Duty Menu.')
end)

RegisterNetEvent('SiriusDuty:enableblips')
AddEventHandler('SiriusDuty:enableblips', function(selectedCategory)
    dptCategory = selectedCategory
end)

RegisterNetEvent('SiriusDuty:disableblips')
AddEventHandler('SiriusDuty:disableblips', function()
    dptCategory = 'none'
    for _,info in pairs(OnDutyPlayerBlips) do
        if info.blip then
            RemoveBlip(info.blip)
        end
    end
    OnDutyPlayerBlips = {}
end)

RegisterNetEvent('SiriusDuty:updateblips')
AddEventHandler('SiriusDuty:updateblips', function(list)
    local idsOnline = {}
    for i = 1, #list do
        local add = true
        local myID = GetPlayerServerId(PlayerId())
        local pID = list[i]['svid']
        if tonumber(pID) == myID then
            add = false
        end
        if add then
            table.insert(idsOnline,pID)
            local pName = list[i]['name']
            local pX = list[i]['x']
            local pY = list[i]['y']
            local pZ = list[i]['z']
            local hdg = list[i]['hdg']
            local color = list[i]['color']
            local category = list[i]['category']
            if "STAFF" == dptCategory then
                if not OnDutyPlayerBlips[pID] then
                    OnDutyPlayerBlips[pID] = {}
                    OnDutyPlayerBlips[pID] = {title = pName, colour = color, id = 1, x = pX, y = pY, z = pZ, heading = hdg}
                    newBlip(pID, OnDutyPlayerBlips[pID])
                else
                    updateBlip(pID,pX,pY,pZ,hdg)
                end
            else
                if not (category == "STAFF") then
                    if not OnDutyPlayerBlips[pID] then
                        OnDutyPlayerBlips[pID] = {}
                        OnDutyPlayerBlips[pID] = {title = pName, colour = color, id = 1, x = pX, y = pY, z = pZ, heading = hdg}
                        newBlip(pID, OnDutyPlayerBlips[pID])
                    else
                        updateBlip(pID,pX,pY,pZ,hdg)
                    end
                end
            end
            
        end
    end
    for id, _ in pairs(OnDutyPlayerBlips) do
        local found = false
        for _, id2 in pairs(idsOnline) do
            if id2 == id then
                found = true
            end
        end
        if not found then
            RemoveBlip(OnDutyPlayerBlips[id]['blip'])
            OnDutyPlayerBlips[id] = nil
        end
    end
end)

function updateBlip(id,x,y,z,hdg)
    if OnDutyPlayerBlips[id] then
        SetBlipCoords(OnDutyPlayerBlips[id]['blip'],x,y,z)
        OnDutyPlayerBlips[id].x = x
        OnDutyPlayerBlips[id].y = y
        OnDutyPlayerBlips[id].z = z
        SetBlipRotation(OnDutyPlayerBlips[id]['blip'], hdg)
    end
end


function newBlip(id, info)
    CreateThread(function()
        OnDutyPlayerBlips[id]['blip'] = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(OnDutyPlayerBlips[id]['blip'], info.id)
        SetBlipCategory(OnDutyPlayerBlips[id]['blip'], 7)
        SetBlipDisplay(OnDutyPlayerBlips[id]['blip'], 4)
        SetBlipShowCone(OnDutyPlayerBlips[id]['blip'], true)
        SetBlipScale(OnDutyPlayerBlips[id]['blip'], 0.9)
        SetBlipColour(OnDutyPlayerBlips[id]['blip'], info.colour)
        SetBlipAsShortRange(OnDutyPlayerBlips[id]['blip'], true)
        ShowHeadingIndicatorOnBlip(OnDutyPlayerBlips[id]['blip'], true)
        SetBlipRotation(OnDutyPlayerBlips[id]['blip'], info.heading)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(OnDutyPlayerBlips[id]['blip'])
    end)
end