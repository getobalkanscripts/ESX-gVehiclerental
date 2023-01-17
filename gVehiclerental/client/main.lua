Citizen.CreateThread(function()
	local PedsTarget = {}
	for k,v in pairs (Config.NPC) do
		PedsTarget = {v.model}
	end
	exports[Config.Target]:AddTargetModel(PedsTarget, {
		options = {
			{
				event = "ybn_vehiclerental:vehiclelist",
				icon = "fas fa-calendar-check",
				label = "Iznajmi Vozilo",
			},
		},
		distance = 1.5
	})
end)

Citizen.CreateThread(function()
	Citizen.Wait(100)
	for k,v in pairs (Config.NPC) do
		if DoesEntityExist(ped) then
			DeletePed(ped)
		end
		Wait(250)
		ped = CreatingPed(v.model, v.coords, v.heading, v.animDict, v.animName)
	end
end)

RegisterNetEvent('ybn_vehiclerental:vehiclelist', function()
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CLIPBOARD", 0, false)
    local rentals = {}
    for k,v in pairs (Config.Vehicles) do
        table.insert(rentals, {
            id = k, 
            header = v.vehicle,
            txt = '',
            params = {
                event = 'ybn_vehiclerental:c:spawnvehicle',
                args = {
                    rental = v.vehicle
                }
            }
        })
    end
	
    TriggerEvent('nh-context:sendMenu', rentals)
end)

function SpawnRentalVehicle(model, x,y,z,h)
    local vehicleHash = GetHashKey(model)
    
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
    Citizen.Wait(0)
    end
    rentalVehicle = CreateVehicle(vehicleHash, x, y, z, h, true, false)
    TriggerServerEvent('garage:addKeys', plate)
    ClearPedTasks(PlayerPedId())
end

RegisterNetEvent('ybn_vehiclerental:c:spawnvehicle')
AddEventHandler('ybn_vehiclerental:c:spawnvehicle', function(data)
    ESX.TriggerServerCallback('ybn_vehiclerental:CheckMoney', function(state)
        if state then
            for k, v in pairs(Config.SpawnVehicles) do
                local model = data.rental
                SpawnRentalVehicle(model, v.x, v.y, v.z, v.h)
                break
            end
        end
    end)
end)

function CreatingPed(hash, coords, heading, animDict, animName)
    RequestModel(GetHashKey(hash))
    while not HasModelLoaded(GetHashKey(hash)) do
        Wait(5)
    end

    local ped = CreatePed(5, hash, coords, false, false)
    SetEntityHeading(ped, heading)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetPedAlertness(ped, 0.0)
    SetPedFleeAttributes(ped, 0, 0)
	FreezeEntityPosition(ped, true) 
	SetEntityInvincible(ped, true) 
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, 0)
	while not TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 17, 0, 0, 0, 0) do
		Wait(1000)
	end
    return ped
end

function ParkingSpot(spots)
    for id,v in pairs(spots) do 
        if GetClosestVehicle(v.x, v.y, v.z, 3.0, 0, 70) == 0 then  
            return true, v
        end
    end 
    exports['mythic_notify']:SendAlert('inform', 'Mjesto za vozilo je zauzeto.', 10000)
 end