local PlaneSmokeConfig = {}
local config = PlaneSmokeConfig

config.perf    = true -- Prestazioni: disabilita fumo a terra o senza pilota
config.dev     = false

config.keybind = 'z' -- Tasto per attivare/disattivare il fumo (personalizzabile)

config.maxsize = 2.0
config.maxdist = 750.0

RegisterCommand('smokemaxsize', function(src, args)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not QBCore.Functions.HasPermission(src, 'owner') then
        print('Accesso negato: permessi insufficienti.')
        return
    end
    local val = tonumber(args[1])
    if val then
        config.maxsize = val
        print(('PlaneSmoke: dimensione massima impostata su %s'):format(val))
    end
end, false)

RegisterCommand('smokemaxdist', function(src, args)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not QBCore.Functions.HasPermission(src, 'owner') then
        print('Accesso negato: permessi insufficienti.')
        return
    end
    local val = tonumber(args[1])
    if val then
        config.maxdist = val
        print(('PlaneSmoke: distanza massima impostata su %s'):format(val))
    end
end, false)

exports('GetSmokeConfig', function() return config end)

config.defaults = {
  r    = 255,
  g    =   0,
  b    =   0,
  size = 1.0,
}

-- Offset per punto di emissione fumo, per modello
config.offsets = {
  [`cuban800`]   = {  0.0,  -3.0, -0.3 },
  [`mogul`]      = {  0.0,  -5.0,  0.7 },
  [`rogue`]      = {  0.0,  -7.0,  0.6 },
  [`starling`]   = {  0.0,  -3.0,  0.6 },
  [`seabreeze`]  = {  0.0,  -3.0,  0.2 },
  [`tula`]       = {  0.0,  -5.0,  0.7 },
  [`bombushka`]  = {  0.0, -21.0,  4.5 },
  [`hunter`]     = {  0.0,  -6.0,  0.0 },
  [`nokota`]     = {  0.0,  -4.0,  0.0 },
  [`pyro`]       = {  0.0,  -3.0,  0.3 },
  [`molotok`]    = {  0.0,  -5.0,  0.3 },
  [`havok`]      = {  0.0,  -4.0,  0.3 },
  [`alphaz1`]    = {  0.0,  -2.5, -0.2 },
  [`microlight`] = {  0.0,  -2.0,  0.5 },
  [`howard`]     = {  0.0,  -3.5,  0.5 },
  [`avenger`]    = {  0.0, -10.0,  1.0 },
  [`akula`]      = {  0.0,  -6.0,  0.0 },
  [`thruster`]   = {  0.0,  -0.5,  0.0 },
  [`oppressor2`] = {  0.0,  -1.2, -0.1 },
  [`volatol`]    = {  0.0, -20.0,  1.0 },
}