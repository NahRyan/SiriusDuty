RegisterNetEvent("SiriusDuty:Menu")
AddEventHandler("SiriusDuty:Menu", function()
    TriggerServerEvent("SiriusDuty:GetDpts")
end)

RegisterNetEvent("SiriusDuty:sendDpts")
AddEventHandler("SiriusDuty:sendDpts", function(validDepartments)
    if validDepartments and #validDepartments > 0 then
        local options = {}
        for _, dep in ipairs(validDepartments) do
            table.insert(options, {label = dep, value = dep})
        end

        local KVPName = GetResourceKvpString("SD:DutyName")
        local KVPCallsign = GetResourceKvpString("SD:DutyCallsign")
        local KVPSave = GetResourceKvpString("SD:Save")

        if KVPSave == "true" then
            KVPSave = true
        else
            KVPSave = false
        end

        if not KVPName then
            KVPName = ""
        end

        if not KVPCallsign then
            KVPCallsign = ""
        end

        local input = lib.inputDialog('Duty Menu', {
            {type = 'input', label = 'Name', default = KVPName, description = 'Enter Your Name (1-20 characters)', required = true, min = 1, max = 20},
            {type = 'input', label = 'Callsign', default = KVPCallsign, description = 'Enter your callsign (1-10 characters)', icon = 'hashtag', required = true, min = 1, max = 10},
            {type = 'select', label = 'Department', description = 'Select your department', required = true, options = options},
            {type = 'checkbox', label = 'Save Information', checked = KVPSave},
        })

        if input then
            local name = input[1]
            local department = input[2]
            local callsign = input[3]
            local saveInfo = input[4]

            if saveInfo then
                SetResourceKvp("SD:DutyName", name)
                SetResourceKvp("SD:DutyCallsign", callsign)
                SetResourceKvp("SD:Save", "true")
            else
                SetResourceKvp("SD:Save", "false")
            end

            TriggerServerEvent("SiriusDuty:onDuty", department, callsign, name)
        else
            TriggerEvent('codem-notification', "You need to specify a valid department and callsign.", 4500, "error")
        end
    else
        TriggerEvent('codem-notification', "You do not have access to any departments.", 4500, "error")
    end
end) 