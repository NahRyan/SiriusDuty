local Authed = false
local toggled = GetResourceKvpInt("bodycam_toggled") == 1


RegisterNetEvent("SiriusDuty:bodyCam")
AddEventHandler("SiriusDuty:bodyCam", function(boolean)
	if boolean then
		toggled = true
		SendNuiMessage(json.encode({ action = "open" }))
		SetResourceKvpInt("bodycam_toggled", 1)
	else
		toggled = false
		SendNuiMessage(json.encode({ action = "close" }))
		SetResourceKvpInt("bodycam_toggled", 0)
	end
end)

RegisterNetEvent("SiriusDuty:bodyCamReturnData")
AddEventHandler("SiriusDuty:bodyCamReturnData", function(data)
	Authed = data.authed
	SendNuiMessage(json.encode({
		action = "data",
		department = data.department,
		callsign = data.callsign,
		playerName = data.name,
	}))
end)

RegisterCommand("bodycam", function(source, args, rawCommand)
	if Authed then
		toggled = not toggled
		if toggled then
			TriggerEvent("SiriusDuty:bodyCam", true)
			TriggerServerEvent('SiriusDuty:message', 'You have enabled bodycam.')
		else
			TriggerEvent("SiriusDuty:bodyCam", false)
			TriggerServerEvent('SiriusDuty:message', 'You have disabled bodycam.')
		end
	else
		TriggerServerEvent('SiriusDuty:message', 'You are not authorized to use this bodycam.')
	end
end, false)