--formula : AB = sqrt((x2-x1)^2 + (y2-y1)^2)
local easyChase = {}
local currentTree = nil
local closestTree = nil
local triggerTime = nil
local myPos = nil



easyChase.Enabled = Menu.AddOption({"KRANE", "Utility", "Easy Chase"}, "Activate EasyChase", "")


function easyChase.OnUpdate()
    if Menu.IsEnabled(easyChase.Enabled) then
        local treesAround = {}
        

        local list_results = {}

        treesAround = Entity.GetTreesInRadius(Heroes.GetLocal(), 300, true)

        myPos = Entity.GetAbsOrigin(Heroes.GetLocal())

        for k, v in pairs(treesAround) do
            local xNow = Entity.GetAbsOrigin(v):GetX()
            local yNow = Entity.GetAbsOrigin(v):GetY()

            local xDiff = (xNow - myPos:GetX()) * (xNow - myPos:GetX())
            local yDiff = (yNow - myPos:GetY()) * (yNow - myPos:GetY())

            table.insert(list_results, math.sqrt( xDiff + yDiff ) )

            
            --Log.Write("Comapring: "..tostring(currentTree:GetX()) .. " <-> ".. tostring(currentTree:GetY()) .." to: ".. tostring(lastTree:GetX()) .. " <-> "..tostring(lastTree:GetY())) --and currentTree:GetZ() < lastTree:GetZ()
            
        end
    
        local temp = 999999999
        for k,v in pairs(list_results) do
            if v < temp then
                closestTree = treesAround[k]
            end
            temp = v
        end
    

        

        
    
        



        
        if triggerTime == nil then
            triggerTime = os.clock() + 0.15
        end
        if os.clock() >= triggerTime then
            --NPC.MoveTo(Heroes.GetLocal(), Entity.GetAbsOrigin(closestTree), false, true)
            if NPC.HasItem(Heroes.GetLocal(), "item_tango", false) then
                 Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET_TREE, closestTree, Vector(0, 0, 0), - , Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, nil, nil, nil)
            end
            triggerTime = nil
            closestTree = nil
        end
        
    end

end

    

return easyChase
