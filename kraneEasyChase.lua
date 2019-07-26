local easyChase = {}
local currentTree = nil
local lastTree = Vector(9999, 9999, 9999)
local closestTree = nil
function easyChase.OnUpdate()
    local treesAround = {}

    treesAround = Entity.GetTreesInRadius(Heroes.GetLocal(), 300, true)
    for k, v in pairs(treesAround) do
        currentTree = Entity.GetAbsOrigin(v)
        --Log.Write("Comapring: "..tostring(currentTree:GetX()) .. " <-> ".. tostring(currentTree:GetY()) .." to: ".. tostring(lastTree:GetX()) .. " <-> "..tostring(lastTree:GetY())) --and currentTree:GetZ() < lastTree:GetZ()
        if currentTree:GetX() < lastTree:GetX() and currentTree:GetY() < lastTree:GetY()  then
            --we found a closer tree
            closestTree = v
  --          cutTheTree(closestTree)
    
        end
        lastTree = currentTree
        
    end
    Log.Write("closest tree".. tostring(Entity.GetAbsOrigin(closestTree)))
    
    
    
    

end

function cutTheTree(treeToCut)
--    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE, treeToCut, Vector(0, 0, 0), "item_tango", Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, nil, nil, nil)

end

    

return easyChase