local RNE = RegisterNetEvent

RNE('mining:mined', function(index)
    local item = Config.items[index]
    local amount = math.random(3, 5)
    if item == 'diamond' then
        amount = 1
    end
    if exports.ox_inventory:CanCarryItem(source, item, amount) then
        exports.ox_inventory:AddItem(source, item, amount)
    end
end)