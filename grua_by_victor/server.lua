local avisoMostrado = false
local updateCheckDone = false

-- ============================================
-- 🔒 ANTI-RENOMBRE (UNA SOLA VEZ)
-- ============================================
RegisterNetEvent('grua:checkNombre', function()
    if avisoMostrado then return end
    avisoMostrado = true

    print('^1[GRUA] ERROR: El recurso fue renombrado. Debe llamarse: grua_by_victor^0')
end)

-- ============================================
-- 🛠️ COMANDO ADMIN
-- ============================================
RegisterCommand('gruaadmin', function(source)
    if IsPlayerAceAllowed(source, "admin") then
        TriggerClientEvent('grua:abrirMenu', source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1No tienes permisos para abrir el menú de grúa"}
        })
    end
end)

-- ============================================
-- 🚛 LLAMAR GRÚA
-- ============================================
RegisterNetEvent('grua:llamar', function(tiempo)
    TriggerClientEvent('grua:mostrarNotificacion', -1, tiempo)
end)

-- ============================================
-- 🔄 SISTEMA DE ACTUALIZACIONES (FIXED)
-- ============================================
CreateThread(function()
    Wait(2000) -- 🔥 IMPORTANTE: espera a que cargue todo

    if updateCheckDone then return end
    updateCheckDone = true

    local resourceName = GetCurrentResourceName()

    if resourceName ~= 'grua_by_victor' then
        print('^1[GRUA] Update check cancelado (nombre incorrecto)^0')
        return
    end

    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

    if not currentVersion then
        print('^1[GRUA] ERROR: No tienes "version" en fxmanifest.lua^0')
        return
    end

    print('^3[GRUA] Buscando actualizaciones...^0')

    -- ⚠️ PON TU LINK REAL AQUÍ
    local versionUrl = "https://raw.githubusercontent.com/vv560471-bit/grua_by_victor/version.txt"

    PerformHttpRequest(versionUrl, function(statusCode, result)
        if statusCode ~= 200 or not result then
            print('^1[GRUA] ERROR al comprobar actualización (URL mala o privada)^0')
            return
        end

        local latestVersion = result:gsub("%s+", "")

        print('^3[GRUA] Versión actual: ' .. currentVersion .. '^0')
        print('^3[GRUA] Versión online: ' .. latestVersion .. '^0')

        if latestVersion ~= currentVersion then
            print('^1[GRUA] ⚠️ HAY UNA ACTUALIZACIÓN DISPONIBLE^0')
        else
            print('^2[GRUA] ✔ Script actualizado^0')
        end
    end, 'GET')
end)