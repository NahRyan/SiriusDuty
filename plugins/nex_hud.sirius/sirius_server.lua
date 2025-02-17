RegisterNetEvent('SiriusDuty:nex:on')
AddEventHandler('SiriusDuty:nex:on', function(job, callsign)
    print("Player " .. source .. " is on duty as " .. job .. " with sigma " .. callsign)
end)