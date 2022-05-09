QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)


QBCore.Functions.CreateCallback('facu-sellvehicle:checkOwner', function(source, cb, plate)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local citizenid = xPlayer.PlayerData['citizenid']
    local fixedplate = plate:gsub(" ", "")
    exports['ghmattimysql']:execute("SELECT * FROM `player_vehicles` WHERE `citizenid` = '" .. citizenid .. "' AND `plate` = '" .. fixedplate .. "'", {}, function(results)
        cb(#results > 0)
    end)
end)

RegisterServerEvent('facu-sellvehicle:transferVehicle')
AddEventHandler('facu-sellvehicle:transferVehicle', function(plate, sellerID, amount)
    local buyer, seller = source, sellerID
    local xBuyer, xSeller = QBCore.Functions.GetPlayer(buyer), QBCore.Functions.GetPlayer(seller)
    local buyerCitizenID = xBuyer.PlayerData['citizenid']
    local buyerIdentifier = GetPlayerIdentifiers(source)[1]
    local fixedplate = plate:gsub(" ", "")

    xBuyer.Functions.RemoveMoney('cash', amount)
    xSeller.Functions.AddMoney('cash', amount)

    exports['ghmattimysql']:execute("UPDATE `player_vehicles` SET `citizenid` = '" .. buyerCitizenID .. "', `steam` = '" .. buyerIdentifier .. "' WHERE `plate` = '" .. fixedplate .. "'", {}, function(rows)
        print(rows)
    end)
	
    TriggerClientEvent('QBCore:Notify', seller, 'Someone bought your car!')
end)

QBCore.Functions.CreateCallback('facu-sellvehicle:checkMoney', function(source, cb, count)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local money = xPlayer.PlayerData['money']['cash']
    if money ~= nil then
        if money >= count then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

RegisterServerEvent('facu-sellvehicle:updateList')
AddEventHandler('facu-sellvehicle:updateList', function(plate, name, model, price, vehicle)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('facu-sellvehicle:client:updateList', -1, plate, name, model, price, vehicle, tonumber(src), xPlayer.PlayerData['citizenid'])
end)

RegisterServerEvent('facu-sellvehicle:removeList')
AddEventHandler('facu-sellvehicle:removeList', function(plate, canceled)
    TriggerClientEvent('facu-sellvehicle:client:removeList', -1, plate)
end)

QBCore.Commands.Add("sellvehicle", "Sell owned vehicle", {{name="price", help="Price"}}, false, function(source, args)
    local price = tonumber(args[1])
    TriggerClientEvent('facu-sellvehicle:client:sellvehicle', source, price)
end)