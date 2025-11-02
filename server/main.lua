local vehicles = {}

Net.AddEvent("spawn", function(id, position, rotation, player)
    local netPlayer = player:GetNetPlayer()
    local pId = netPlayer:GetNetId()
    local interval = netPlayer:GetVehicle() and 500 or 0

    if vehicles[pId] then
        World.Destroy(vehicles[pId])
        vehicles[pId] = nil
    end

    Timer.Set(function()
        local veh = World.SpawnVehicle(id, position)

        veh:SetPrimaryColor(math.random(0.0, 1.0), math.random(0.0, 1.0), math.random(0.0, 1.0))
        veh:SetSecondaryColor(math.random(0.0, 1.0), math.random(0.0, 1.0), math.random(0.0, 1.0))
        veh:SetTertiaryColor(math.random(0.0, 1.0), math.random(0.0, 1.0), math.random(0.0, 1.0))
        veh:SetMetallic(math.random(0.0, 100.0) / 100.0)
        veh:SetRotation(rotation)

        vehicles[pId] = veh

        netPlayer:WarpIntoVehicle(veh, VehicleSeat.DriverSeat)
    end, interval, 1)
end)

Net.AddEvent("spawnMg", function(id, position)
    World.SpawnMountedGun(id, position)
end)

Net.AddEvent("weapon", function(weapon_id, player)
    player:GetNetPlayer():GiveWeapon(weapon_id, 500, WeaponSlot.Primary)
end)

Event.Add("OnPlayerQuit", function(player)
    local pId = player:GetNetId()

    if vehicles[pId] then
        World.Destroy(vehicles[pId])
        vehicles[pId] = nil
    end
end)