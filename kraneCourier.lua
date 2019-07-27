local kraneCourier = {}

kraneCourier.IsToggled = Menu.AddOption({"KRANE", "Courier"}, "Enable Courier Control", "")
kraneCourier.AntiRecall = Menu.AddKeyOption({"KRANE", "Courier"}, "Ignore recalls", 0)
kraneCourier.LockAtBase = Menu.AddKeyOption({"KRANE", "Courier"}, "Lock at base", 0)
kraneCourier.SecretShop = Menu.AddKeyOption({"KRANE", "Courier"}, "Secret Shop", 0)
kraneCourier.MoveToMouse = Menu.AddKeyOption({"KRANE", "Courier"}, "Move to mouse", 0)
kraneCourier.Speed = Menu.AddOption({"KRANE", "Courier"}, "Speed action", "The lower the value the faster it will do the action\nIf you put 0 it will be the fastest it can be", 0, 100, 1)
local toggleState = false
local toggleStateLockAtBase = false
local toggleStateSecretShop = false
local toggleMoveToMouse = false
local triggerTime = nil

local bool_damageShield = nil

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

        
        if toggleMoveToMouse then
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
        activateShieldConditions(myCourier)
                    --
        --      DELIVERY COURIER
        --
        if toggleState then
            --devliverAndGoHome(myCourier)
            if triggerTime == nil then
                triggerTime = os.clock() + Menu.GetValue(kraneCourier.Speed) / 10
            end
            if os.clock() >= triggerTime then
                Engine.ExecuteCommand("dota_courier_deliver")
                triggerTime = nil
            end
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
                if triggerTime == nil then
                    triggerTime = os.clock() + Menu.GetValue(kraneCourier.Speed) / 10
                end
                if os.clock() >= triggerTime then
                    
                    Ability.CastNoTarget(ability)
                    triggerTime = nil
                end   
            end 
        end
        --
        --      SECRET SHOP
        --
        if toggleStateSecretShop then
            local ability = NPC.GetAbilityByIndex(myCourier, 1)
            if Ability.IsReady(ability) then
                if triggerTime == nil then
                    triggerTime = os.clock() + Menu.GetValue(kraneCourier.Speed) / 10
                end
                if os.clock() >= triggerTime then
                    Ability.CastNoTarget(ability)
                end
            end    
        end
        --
        --      MOVE TO MOUSE   
        --
        
        if toggleMoveToMouse then
            local cursorPos = Input.GetWorldCursorPos()
            if triggerTime == nil then
                triggerTime = os.clock() + Menu.GetValue(kraneCourier.Speed) / 10
            end
            if os.clock() >= triggerTime then
                NPC.MoveTo(myCourier, cursorPos, false, true)
            end
        end
    end
end


--
--      SHIELD CONDITIONS whish i know to use clases lmao
--
function activateShieldConditions(courierNPC)
    local heroesInRange = {}
    local ability = NPC.GetAbilityByIndex(courierNPC, 5)                --this isnt working for just the team_enemy for some reason
    heroesInRange = Entity.GetHeroesInRadius( courierNPC, 900, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_BOTH)
    for k, v in pairs(heroesInRange) do
        --Log.Write(tostring(NPC.GetUnitName(v)))
        if Entity.IsSameTeam(courierNPC, v) == false then
           -- Log.Write("found an enemy")
            if Ability.IsReady(ability) then
                Ability.CastNoTarget(ability)
            end
        end
    end
    
    if Entity.GetHealth(courierNPC) ~= Entity.GetMaxHealth(courierNPC) and bool_damageShield == true then
        Log.Write("took damage, Star Wars Rebels -- The Rebels Activate The Base Shield's (1080p)" .. tostring(bool_damageShield))
        if Ability.IsReady(ability) then
            Ability.CastNoTarget(ability)
        end
        bool_damageShield = false
    end
    if Entity.GetHealth(courierNPC) == Entity.GetMaxHealth(courierNPC) then
        bool_damageShield = true
    end
end

--
--  DELIVER AND GO HOME
--
-----------------------------------------INACTIVE DUE TO BUG
function devliverAndGoHome(courierNPC)
    local goHome = false
    local currentItem = nil
    local ownerID = nil

    local ability_GoToBase = NPC.GetAbilityByIndex(myCourier, 0)
    
    if triggerTime == nil then
        triggerTime = os.clock() + Menu.GetValue(kraneCourier.Speed) / 10
    end
    if os.clock() >= triggerTime then
        --existing items loop ---HERE IS A BUG AND IT NEEDS TO BE FIXED, IT ONLY APPREASA IF THERE IS NO ITEM ON THE COURIER 
        for i=0, 6 do
            currentItem = NPC.GetItemByIndex(courierNPC, i)
            ownerID = Item.GetPlayerOwnerID(currentItem)
            
            if Player.GetPlayerID(Players.GetLocal()) == ownerID then
                goHome = false
                break
            else
                goHome = true
            end
        end   
        
        if not goHome then
            Engine.ExecuteCommand("dota_courier_deliver") --im stoopid :[D
            triggerTime = nil
        else
            --go home u r drunk
            if Ability.IsReady(ability_GoToBase) then
                Ability.CastNoTarget(ability_GoToBase)
            end
        end
    end

    
    
end



return kraneCourier
