local IsOnDepartment = false
local IsOnStaff = false
local DepartmentName = nil
local Callsign = nil

RegisterNetEvent('SiriusDuty:onDuty')
AddEventHandler('SiriusDuty:onDuty', function(data)
    
    
    if data.department ~= "STAFF" then
        DepartmentName = data.shortname
        Callsign = data.callsign
        IsOnDepartment = true
    else
        IsOnStaff = true
    end
    
    unitdata = {
        department = DepartmentName,
        callsign = Callsign,
    }

    if IsOnDepartment and not IsOnStaff then
        unitdata.department = DepartmentName
        unitdata.callsign = Callsign
    elseif IsOnStaff then
        unitdata.department = "STAFF"
        unitdata.callsign = "N/A"
    elseif IsOnDepartment and IsOnStaff then
        unitdata.department = DepartmentName .. " / " .. data.department
        unitdata.callsign = Callsign
    end

    TriggerServerEvent('SiriusDuty:nex:on', unitdata.department, unitdata.callsign)
end)

RegisterNetEvent('SiriusDuty:offDuty')
AddEventHandler('SiriusDuty:offDuty', function(type)
    TriggerServerEvent('SiriusDuty:nex:on', GetPlayerServerId(PlayerId()), nil)
end)
