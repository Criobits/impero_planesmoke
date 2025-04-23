local QBCore = exports['qb-core']:GetCoreObject()
local sr, sg, sb = config.defaults.r, config.defaults.g, config.defaults.b
local ss      = config.defaults.size
currentPtfx   = {}

AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  DecorRegister("smoke_active",   2)
  DecorRegister("smoke_color",    3)
  DecorRegister("smoke_size",     1)
  DecorRegister("smoke_unlocked", 2)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  for veh, ptfx in pairs(currentPtfx) do
    StopParticleFxLooped(ptfx, 0)
  end
  currentPtfx = {}
end)

local fxDict, fxName = "scr_ar_planes", "scr_ar_trail_smoke"
RequestNamedPtfxAsset(fxDict)
local ptfxLoaded = false
local startTime = GetGameTimer()
while not HasNamedPtfxAssetLoaded(fxDict) and (GetGameTimer() - startTime) < 5000 do
  Wait(0)
end
if HasNamedPtfxAssetLoaded(fxDict) then
  ptfxLoaded = true
else
  QBCore.Functions.Notify("Caricamento asset fumo fallito: " .. fxDict .. ", fumo disabilitato.", "error")
end

Citizen.CreateThread(function()
  local Wait, ipairs, GetPlayers = Wait, ipairs, GetActivePlayers
  local GetCoords, GetPed, IsPlane, GetVeh = GetEntityCoords, GetPlayerPed, IsPedInAnyPlane, GetVehiclePedIsIn
  local DecorGetActive, DecorGetColor, DecorGetSize = DecorGetBool, DecorGetInt, DecorGetFloat
  while true do
    Wait(500)
    local meCoords = GetEntityCoords(PlayerPedId())

    local vehicles = {}
    for _, pid in ipairs(GetPlayers()) do
      local ped = GetPlayerPed(pid)
      if shouldPedHaveSmoke(ped) then
        local veh = GetVehiclePedIsIn(ped, false)
        table.insert(vehicles, veh)
      end
    end
    for i = 1, math.min(#vehicles, 5) do
      local veh = vehicles[i]
      local dist = #(meCoords - GetEntityCoords(veh))
      if DecorGetBool(veh, "smoke_active") and dist < config.maxdist then
        manageSmoke(veh)
      else
        stopSmoke(veh)
      end
    end

    if config.perf then
      for veh, _ in pairs(currentPtfx) do
        local bad = IsEntityDead(veh)
                 or not DoesEntityExist(veh)
                 or IsVehicleSeatFree(veh, -1)
                 or GetEntityHeightAboveGround(veh) <= 1.5
                 or not IsEntityInAir(veh)
                 or (#(meCoords - GetEntityCoords(veh)) > config.maxdist)
        if bad then stopSmoke(veh) end
      end
    end
  end
end)

function manageSmoke(veh)
  if not DecorGetBool(veh, "smoke_unlocked") then return end
  local h    = currentPtfx[veh]
  local r,g,b= decodeSmoke(DecorGetInt(veh, "smoke_color"))
  local size = DecorGetFloat(veh, "smoke_size")
  local mdl  = GetEntityModel(veh)

  local pos
  if config.offsets[mdl] then
    local o = config.offsets[mdl]
    pos = vector3(o[1], o[2], o[3])
  else
    local mn,_ = GetModelDimensions(mdl)
    pos = vector3(0.0, mn.y, 0.0)
  end

  if not h then
    UseParticleFxAssetNextCall(fxDict)
    h = StartParticleFxLoopedOnEntityBone_2(fxName, veh, pos, 0,0,0, -1, size, pos)
    currentPtfx[veh] = h
  end

  SetParticleFxLoopedScale(h, size)
  SetParticleFxLoopedRange(h, 1000.0)
  SetParticleFxLoopedColour(h, r/255, g/255, b/255, 0)
end

RegisterNetEvent('smokester:requestUnlockPlate')
AddEventHandler('smokester:requestUnlockPlate', function(itemName)
  local ped = PlayerPedId()
  if not IsPedInAnyPlane(ped) then
    return QBCore.Functions.Notify('Devi essere dentro un aereo per usare questo.', 'error')
  end
  local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
  TriggerServerEvent('smokester:unlockPlaneForPlate', plate, itemName)
end)

RegisterNetEvent('smokester:unlockConfirmed')
AddEventHandler('smokester:unlockConfirmed', function(plate, r, g, b, size)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if GetVehicleNumberPlateText(veh) == plate then
    DecorSetBool(veh, 'smoke_unlocked', true)
    DecorSetInt(veh, 'smoke_color',    encodeSmoke(r, g, b))
    DecorSetFloat(veh, 'smoke_size',     size)
    sr, sg, sb, ss = r, g, b, size
    QBCore.Functions.Notify('Fumo aereo sbloccato!', 'success')
  end
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

function doToggle()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if shouldPedHaveSmoke(ped)
     and DecorGetBool(veh, 'smoke_unlocked')
     and GetPedInVehicleSeat(veh, -1) == ped
     and ((GetEntityHeightAboveGround(veh) >= 1.5 or IsEntityInAir(veh))
          and not IsVehicleOnAllWheels(veh)) then
    local newState = not DecorGetBool(veh, 'smoke_active')
    DecorSetBool(veh, 'smoke_active', newState)
    if newState then
      QBCore.Functions.Notify('Fumo ON', 'success')
    else
      QBCore.Functions.Notify('Fumo OFF', 'inform')
    end
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
  end
end

RegisterCommand('+togglesmoke', doToggle, false)
RegisterCommand('-togglesmoke', function() end, false)
RegisterKeyMapping('+togglesmoke', 'Attiva il fumo aereo', 'keyboard', config.keybind)
