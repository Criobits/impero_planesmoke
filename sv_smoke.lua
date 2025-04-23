local QBCore = exports['qb-core']:GetCoreObject()

local lastUnlockTime = {}

-- Mappa oggetto → {r,g,b,size}
local smokeItems = {
  smoke_red    = {255,   0,   0, 1.0},
  smoke_orange = {255, 165,   0, 1.0},
  smoke_yellow = {255, 255,   0, 1.0},
  smoke_green  = {  0, 255,   0, 1.0},
  smoke_blue   = {  0,   0, 255, 1.0},
  smoke_purple = {128,   0, 128, 1.0},
  smoke_white  = {255, 255, 255, 1.0},
  smoke_black  = {  0,   0,   0, 1.0},
}

for itemName, _ in pairs(smokeItems) do
  exports.ox_inventory:RegisterUsableItem(itemName, function(source)
    TriggerClientEvent('smokester:requestUnlockPlate', source, itemName)
    TriggerEvent('inventory:removeItem', source, itemName, 1)
  end)
end

RegisterNetEvent('smokester:unlockPlaneForPlate', function(plate, itemName)
  local src = source
  local now = os.time()
  if lastUnlockTime[src] and (now - lastUnlockTime[src]) < 5 then
    TriggerClientEvent('QBCore:Notify', src, 'Attendere prima di cambiare nuovamente il fumo.', 'error')
    return
  end
  lastUnlockTime[src] = now

  local cfg = smokeItems[itemName]
  if not cfg then
    TriggerClientEvent('QBCore:Notify', src, 'Oggetto fumo non valido.', 'error')
    return
  end

  if type(plate) ~= 'string' or plate:match('%W') or #plate > 8 then
    TriggerClientEvent('QBCore:Notify', src, 'Targa veicolo non valida.', 'error')
    return
  end

  local cid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
  local r, g, b, size = table.unpack(cfg)
  local colorInt = ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)

  exports.oxmysql:execute([[  
    INSERT INTO smokester_planes (plate, owner, smoke_color, smoke_size)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      owner       = VALUES(owner),
      smoke_color = VALUES(smoke_color),
      smoke_size  = VALUES(smoke_size)
  ]], { plate, cid, colorInt, size }, function()
    TriggerClientEvent('smokester:unlockConfirmed', src, plate, r, g, b, size)
  end)
end)

Citizen.CreateThread(function()
  local hasUnlocked = {}
  while true do
    Wait(500)
    local ped = PlayerPedId()
    if IsPedInAnyPlane(ped) then
      local veh = GetVehiclePedIsIn(ped, false)
      local plate = GetVehicleNumberPlateText(veh)
      if not hasUnlocked[plate] then
        QBCore.Functions.TriggerCallback('smokester:checkPlateUnlocked', function(unl, r, g, b, sz)
          if unl then
            DecorSetBool(veh,   'smoke_unlocked', true)
            DecorSetInt(veh,    'smoke_color',    encodeSmoke(r, g, b))
            DecorSetFloat(veh,  'smoke_size',     sz)
            sr, sg, sb, ss = r, g, b, sz
          end
        end, plate)
        hasUnlocked[plate] = true
      end
    else
      hasUnlocked = {}
    end
  end
end)