function GetAllOnDutyPlayers()
    local data = lib.callback.await('SiriusDuty:GetAllOnDutyPlayers', false)
    return data
end

exports("GetAllOnDutyPlayers", GetAllOnDutyPlayers)

function GetPlayerDepartment()
    local data = lib.callback.await('SiriusDuty:GetPlayerDepartment', false)
    return data
end

exports("GetPlayerDepartment", GetPlayerDepartment)

function IsPlayerManagement()
    local data = lib.callback.await('SiriusDuty:IsPlayerManagement', false)
    return data
end

exports("IsPlayerManagement", IsPlayerManagement)

function IsPlayerStaff()
    local data = lib.callback.await('SiriusDuty:IsPlayerStaff', false)
    return data
end

exports("IsPlayerStaff", IsPlayerStaff)

function GetPlayerCallsign()
    local data = lib.callback.await('SiriusDuty:GetPlayerCallsign', false)
    return data
end

exports("GetPlayerCallsign", GetPlayerCallsign)

function GetDepartmentLogo()
    local data = lib.callback.await('SiriusDuty:GetDepartmentLogo', false)
    return data
end

exports("GetDepartmentLogo", GetDepartmentLogo)

function GetDeptLongName(name)
    local data = lib.callback.await('SiriusDuty:GetDeptLongName', false, name)
    return data
end

exports("GetDeptLongName", GetDeptLongName)