local Authed = false
local toggled = GetResourceKvpInt("bodycam_toggled") == 1


RegisterNetEvent("SiriusDuty:bodyCam")
AddEventHandler("SiriusDuty:bodyCam", function(boolean)
	if boolean then
		toggled = true
        print("opening")
		SendNuiMessage(json.encode({ action = "open" }))
		SetResourceKvpInt("bodycam_toggled", 1)
	else
        print("closing")
		toggled = false
		SendNuiMessage(json.encode({ action = "close" }))
		SetResourceKvpInt("bodycam_toggled", 0)
	end
end)

RegisterNetEvent("SiriusDuty:bodyCamReturnData")
AddEventHandler("SiriusDuty:bodyCamReturnData", function(data)
	print(json.encode(data))
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
            print("toggled")
			TriggerEvent("SiriusDuty:bodyCam", true)
			TriggerEvent('codem-notification', 'You have enabled <b>bodycam</b>.', 4500, 'dutydoj')
		else
			TriggerEvent("SiriusDuty:bodyCam", false)
			TriggerEvent('codem-notification', 'You have disabled <b>bodycam</b>.', 4500, 'dutydoj')
		end
	else
		TriggerEvent('codem-notification', 'You are not authorized to use this <b>bodycam</b>.', 4500, 'error')
	end
end, false)