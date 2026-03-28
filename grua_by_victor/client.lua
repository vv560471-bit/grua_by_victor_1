-- 🔒 PROTECCIÓN ANTI-RENOMBRE
local resourceName = GetCurrentResourceName()
local avisoEnviado = false

if resourceName ~= 'grua_by_victor' then
    local msg = '[GRUA] ERROR: No cambies el nombre del recurso. Debe ser: grua_by_victor'

    -- Mostrar solo una vez
    if not avisoEnviado then
        avisoEnviado = true

        -- Consola cliente
        print('^1' .. msg .. '^0')

        -- Avisar al servidor una sola vez
        TriggerServerEvent('grua:checkNombre')
    end

    -- Bloqueo total
    CreateThread(function()
        while true do
            Wait(0)
        end
    end)

    return
end

-- =====================================

local gruaMenuActive = false
local tiempoGrua = 1

RegisterCommand('gruaadmin', function()
    if gruaMenuActive then return end
    gruaMenuActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'abrirMenu',
        tiempo = tiempoGrua
    })
end, false)

RegisterNUICallback('cerrar', function(data, cb)
    gruaMenuActive = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('llamarGrua', function(data, cb)
    tiempoGrua = tonumber(data.tiempo) or 5
    gruaMenuActive = false
    SetNuiFocus(false, false)

    TriggerServerEvent('grua:llamar', tiempoGrua)
    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(0)
        if gruaMenuActive and IsControlJustPressed(0, 322) then
            gruaMenuActive = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'cerrar' })
        end
    end
end)

RegisterNetEvent('grua:mostrarNotificacion', function(tiempo)
    local tiempoTotal = tiempo * 60
    local tiempoRestante = tiempoTotal

    SendNUIMessage({
        action = 'abrirNotify',
        tiempo = tiempo,
        tiempoTotal = tiempoTotal
    })

    CreateThread(function()
        while tiempoRestante > 0 do
            Wait(1000)
            tiempoRestante -= 1
            SendNUIMessage({
                action = 'actualizarNotify',
                tiempo = tiempoRestante,
                tiempoTotal = tiempoTotal
            })
        end

        for vehicle in EnumerateVehicles() do
            if DoesEntityExist(vehicle) then
                local driver = GetPedInVehicleSeat(vehicle, -1)
                local occupied = false

                for seat = 0, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                    if GetPedInVehicleSeat(vehicle, seat) ~= 0 then
                        occupied = true
                        break
                    end
                end

                if driver == 0 and not occupied then
                    DeleteEntity(vehicle)
                end
            end
        end

        SendNUIMessage({ action = 'cerrarNotify' })
    end)
end)

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        if not handle or handle == -1 then return end
        local done = false
        repeat
            coroutine.yield(veh)
            done, veh = FindNextVehicle(handle)
        until not done
        EndFindVehicle(handle)
    end)
end