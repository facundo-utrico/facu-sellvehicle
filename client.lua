QBCore = exports['qb-core']:GetCoreObject()

local ActiveSells = {}
local VehicleObjects = {}


RegisterNetEvent('facu-sellvehicle:client:sellvehicle')
AddEventHandler('facu-sellvehicle:client:sellvehicle', function(price)
	local _source = source
	local PlayerData = QBCore.Functions.GetPlayerData()
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
    	local vehicle = GetVehiclePedIsIn(playerPed)
    	local plate = GetVehicleNumberPlateText(vehicle)

    	QBCore.Functions.TriggerCallback('facu-sellvehicle:checkOwner', function(isOwner)
        	if isOwner then
                TriggerEvent('facu-sellvehicle:client:sellevent', vehicle, plate, price)
        	else
        		TriggerEvent('QBCore:Notify', 'Thats not your vehicle.', 'error')
        	end
        end, plate)
    end
end)

RegisterNetEvent('facu-sellvehicle:finishTransfer')
AddEventHandler('facu-sellvehicle:finishTransfer', function(vehiclePos, vehiclePlate)
	local playerPed = PlayerPedId()
	while not IsPedInAnyVehicle(PlayerPedId(), false) do
    	local playerPos = GetEntityCoords(playerPed)
				
    	if #(vehiclePos - playerPos) < 5 then
    		DrawClaimText(vehiclePos.x, vehiclePos.y, vehiclePos.z + 0.45)
    	end
    	Wait(0)
   	end

   	local vehicle = GetVehiclePedIsIn(playerPed)
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate == vehiclePlate then
    	FreezeEntityPosition(vehicle, false)
    end
end)

local HoldE = 600
Citizen.CreateThread(function()
	while true do
    	Citizen.Wait(0)

    	for k, v in pairs(ActiveSells) do
    		if v ~= nil then
				local player = GetPlayerFromServerId(ActiveSells[k].src)
				if ActiveSells[k].owned then
					local txt = "Vehicle Plate : " .. ActiveSells[k].plate .. " | Model : " .. ActiveSells[k].modelname .. "\nPrice : ~g~" .. ActiveSells[k].price .. "$~b~ [ Press H To Cancel ]"
    				local vehicle = ActiveSells[k].vehicle
		
    				local vehiclePosition = vehicle
    				local playerPed = PlayerPedId()
					local playerPosition = GetEntityCoords(playerPed)
					
					if #(vehiclePosition - playerPosition) < 5 then
						DrawText3Ds(vehiclePosition.x, vehiclePosition.y, vehiclePosition.z + 0.5 , txt)
						if IsDisabledControlJustPressed(0, 74) then
							TriggerServerEvent('facu-sellvehicle:removeList', ActiveSells[k].plate, true)
							TriggerEvent('facu-sellvehicle:finishTransfer', ActiveSells[k].vehicle, ActiveSells[k].plate)
							TriggerEvent('QBCore:Notify', 'Vehicle removed from the selling list')
						end
					end
    			elseif NetworkIsPlayerActive(player) then
    				local txt = "Vehicle Plate : " .. ActiveSells[k].plate .. " | Model : " .. ActiveSells[k].modelname .. "\nPrice : ~g~" .. ActiveSells[k].price .. "$~b~ [ Hold H (" .. math.floor(HoldE/100) .. ") To Buy ]"
    				local vehicle = ActiveSells[k].vehicle
		
    				local vehiclePosition = vehicle
    				local playerPed = PlayerPedId()
    				local playerPosition = GetEntityCoords(playerPed)
			
    				if #(vehiclePosition - playerPosition) < 5 then
						DrawText3Ds(vehiclePosition.x, vehiclePosition.y, vehiclePosition.z + 0.5 , txt)
						if IsDisabledControlPressed(0, 74) then
							if HoldE < 100 then
								HoldE = 600
								local vehiclePosition = ActiveSells[k].vehicle
								local playerPed = PlayerPedId()
								local playerPosition = GetEntityCoords(playerPed)
					
								if #(vehiclePosition - playerPosition) < 5 then
									QBCore.Functions.TriggerCallback('facu-sellvehicle:checkOwner', function(isOwner)
										if not isOwner then
											QBCore.Functions.TriggerCallback('facu-sellvehicle:checkMoney', function(hasMoney)
												if hasMoney == true then
													TriggerEvent('QBCore:Notify', 'You bought a car!')
													
        											TriggerEvent("vehiclekeys:client:SetOwner", ActiveSells[k].plate, ActiveSells[k].vehicle)
													TriggerEvent('facu-sellvehicle:finishTransfer', ActiveSells[k].vehicle, ActiveSells[k].plate)
													TriggerServerEvent('facu-sellvehicle:removeList', ActiveSells[k].plate)
													TriggerServerEvent('facu-sellvehicle:transferVehicle', ActiveSells[k].plate, ActiveSells[k].src, tonumber(ActiveSells[k].price)) --  GetPlayerFromServerId(ActiveSells[k].src)
												else
													TriggerEvent('QBCore:Notify', 'You dont have enough money', 'error')
												end
											end, ActiveSells[k].price)
										else
											TriggerEvent('QBCore:Notify', 'You cant buy your own car', 'error')
										end
									end, k)
								end
							else
								HoldE = HoldE - 1
							end
						elseif HoldE ~= 600 then
							HoldE = 600
						end
    				end
    			else
    				TriggerServerEvent('facu-sellvehicle:removeList', ActiveSells[k].plate)
    			end
    		end
    	end

  	end
end)


function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0225, 0.015+ factor, 0.04, 0, 0, 0, 68)
end

function DrawClaimText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString("You bought this car! ~g~[ Get in to claim it ]")
    DrawText(_x,_y)
    local factor = (string.len("You bought this car! ~g~[ Get in to claim it ]")) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.02, 0, 0, 0, 68)
end

RegisterNetEvent('facu-sellvehicle:client:updateList')
AddEventHandler('facu-sellvehicle:client:updateList', function(plate, name, model, price, vehicle, src, citizenID)
	ActiveSells[plate] = {
		plate = plate,
		name = name,
		modelname = model,
		price = price,
		vehicle = vehicle,
		src = src,
		owned = citizenID == QBCore.Functions.GetPlayerData().citizenid
	}
end)

RegisterNetEvent('facu-sellvehicle:client:removeList')
AddEventHandler('facu-sellvehicle:client:removeList', function(plate)
	ActiveSells[plate] = nil
end)

RegisterNetEvent('facu-sellvehicle:client:sellevent')
AddEventHandler('facu-sellvehicle:client:sellevent', function(vehicle, plate, price)
	if price then
		VehicleObjects[plate] = vehicle
        TriggerServerEvent('facu-sellvehicle:updateList', plate, GetPlayerName(PlayerId()), GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))), price, GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine")))
		FreezeEntityPosition(vehicle, true)
		
    	TriggerEvent('QBCore:Notify', 'Your vehicle added to the Active Sells List', 'error')
	end
end)