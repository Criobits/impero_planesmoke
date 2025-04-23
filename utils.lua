function decodeSmoke(int)
  local r = (int >> 16) & 0xFF
  local g = (int >> 8)  & 0xFF
  local b = int         & 0xFF
  return r, g, b
end

function encodeSmoke(r, g, b)
  return ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
end

function stopSmoke(veh)
  DecorSetBool(veh, "smoke_active", false)
  if currentPtfx[veh] then
    StopParticleFxLooped(currentPtfx[veh], 0)
    currentPtfx[veh] = nil
  end
end

function shouldPedHaveSmoke(ped)
  local veh = GetVehiclePedIsIn(ped, false)
  if not veh or veh == 0 then return false end
  local model = GetEntityModel(veh)
  return IsPedInAnyPlane(ped) or (config.offsets[model] ~= nil)
end