local kraneCourier = {}

kraneCourier.IsToggled = Menu.AddOption({"Utility", "KRANE", "Courier"}, "Enable Courier Control", "")
kraneCourier.AntiRecall = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Ignore recalls", 0)
kraneCourier.LockAtBase = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Lock at base", 0)
kraneCourier.SecretShop = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Secret Shop", 0)
kraneCourier.MoveToMouse = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Move to mouse", 0)

local toggleState = false
local toggleStateLockAtBase = false
local toggleStateSecretShop = false
local toggleMoveToMouse = false

local myCourier = nil
function kraneCourier.OnDraw()
    --space time complexity
    if Menu.IsEnabled(kraneCourier.IsToggled) then
        if toggleState then
            Renderer.SetDrawColor(0, 153, 51, 255)
            Renderer.DrawText(1, 30, 200, "K-Courier: Ignoring recalls", 1)
        end

        if toggleStateLockAtBase then
            Renderer.SetDrawColor(0, 153, 51, 255)
            Renderer.DrawText(1, 30, 200, "K-Courier: Lock at base", 1)
        end

        if toggleStateSecretShop then
            Renderer.SetDrawColor(0, 153, 51, 255)
            Renderer.DrawText(1, 30, 200, "K-Courier: Secret Shop", 1)
        end

        
        if toggleStateSecretShop then
            Renderer.SetDrawColor(0, 153, 51, 255)
            Renderer.DrawText(1, 30, 200, "K-Courier: Following Mouse", 1)
        end
    end
end


function kraneCourier.OnUpdate()
    if Menu.IsEnabled(kraneCourier.IsToggled) then
        if Menu.IsKeyDownOnce(kraneCourier.AntiRecall) then
            toggleState = not toggleState
        end
        if Menu.IsKeyDownOnce(kraneCourier.LockAtBase) then
            toggleStateLockAtBase = not toggleStateLockAtBase
        end
        if Menu.IsKeyDownOnce(kraneCourier.SecretShop) then
            toggleStateSecretShop = not toggleStateSecretShop
        end
        if Menu.IsKeyDownOnce(kraneCourier.MoveToMouse) then
            toggleMoveToMouse = not toggleMoveToMouse
        end

        --add if the script is enabled
        local npcs = NPCs.GetAll()
        for k, v in pairs(npcs) do
            if NPC.IsCourier(v) and Entity.IsSameTeam(Heroes.GetLocal(),v) then
                myCourier = v
            end
        end
                    --
        --      DELIVERY COURIER
        --
        if toggleState then
            Engine.ExecuteCommand("dota_courier_deliver") --im stoopid :[D
        end

            --[[
            local npcs = NPCs.GetAll()
        --go thru all the npcs and check if there is a courier, if it is then keep calling
        --it with transfer items until the script is stopped
            for k, v in pairs(npcs) do
                if NPC.IsCourier(v) and Entity.IsSameTeam(Heroes.GetLocal(),v) then
                    local courier = v
                    --Log.Write("the courier" .. tostring(courier))
                    --NPC.GetAbilityByIndex(courier, 4)
                    --NPC.MoveTo(courier, Vector(0,0,0))
                    local ability = NPC.GetAbility(courier, "courier_transfer_items")
                    local ability_take_items = NPC.GetAbilityByIndex(courier, 3)
                    local myHero = Heroes.GetLocal()
                    
                    if Ability.IsReady(ability) then
                        local currentItem = NPC.GetItemByIndex(courier, 0)
                        if currentItem == nil then
                            Ability.CastNoTarget(ability_take_items)
                        
                        else
                            Log.Write(Item.GetPlayerOwnerID(currentItem))
                        
                        end
                    
                        Ability.CastNoTarget(ability)
                    end
                end
            end
        end
        --]]
        --
        --      LOCK AT BASE
        --
        if toggleStateLockAtBase then
            local ability = NPC.GetAbilityByIndex(myCourier, 0)
            if Ability.IsReady(ability) then
                Ability.CastNoTarget(ability)
                
            end    
        end
        --
        --      SECRET SHOP
        --
        if toggleStateSecretShop then
            local ability = NPC.GetAbilityByIndex(myCourier, 1)
            if Ability.IsReady(ability) then
                Ability.CastNoTarget(ability)
            end    
        end
        --
        --      MOVE TO MOUSE   
        --
        
        if toggleMoveToMouse then
            local cursorPos = Input.GetWorldCursorPos()
            NPC.MoveTo(myCourier, cursorPos, false, true)
        end
    end
end
return kraneCourier
