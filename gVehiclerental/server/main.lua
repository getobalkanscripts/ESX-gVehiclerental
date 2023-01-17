ESX.RegisterServerCallback('ybn_vehiclerental:CheckMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= 500 then
        xPlayer.removeMoney(500)
        xPlayer.showNotification('Iznajmio si vozilo za $500.')
        cb(true)
    else
        xPlayer.showNotification('Ne mozes priustiti ovo vozilo.')
        cb(false)
    end
end)
