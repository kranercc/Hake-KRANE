local kraneCourier = {}

--kraneCourier.IsToggled = Menu.AddOption({"Utility", "KRANE"}, "Krane Courier", "")
kraneCourier.AntiRecall = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Ignore recalls", 0)
kraneCourier.LockAtBase = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Lock at base", 0)
kraneCourier.SecretShop = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Secret Shop", 0)

local toggleState = false
local toggleStateLockAtBase = false
local toggleStateSecretShop = false

function kraneCourier.OnDraw()
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
end


function kraneCourier.OnUpdate()

    if Menu.IsKeyDownOnce(kraneCourier.AntiRecall) then
        toggleState = not toggleState
    end
    if Menu.IsKeyDownOnce(kraneCourier.LockAtBase) then
        toggleStateLockAtBase = not toggleStateLockAtBase
    end
    if Menu.IsKeyDownOnce(kraneCourier.SecretShop) then
        toggleStateSecretShop = not toggleStateSecretShop
    end
    --
    --      DELIVERY COURIER
    --
    if toggleState then
        local npcs = NPCs.GetAll()
    --go thru all the npcs and check if there is a courier, if it is then keep calling
    --it with transfer items until the script is stopped
            for k, v in pairs(npcs) do
                if NPC.IsCourier(v) and Entity.IsSameTeam(Heroes.GetLocal(),v) then
                    local courier = v
                    --Log.Write("the courier" .. tostring(courier))
                    --NPC.GetAbilityByIndex(courier, 4)
                    --NPC.MoveTo(courier, Vector(0,0,0))
                    --Ender_Wolf code
                    local ability = NPC.GetAbility(courier, "courier_transfer_items")
                    
                    if Ability.IsReady(ability) then
                        Ability.CastNoTarget(ability)
                    end
            end
        end
    end
    --
    --      LOCK AT BASE
    --
    if toggleStateLockAtBase then
        local npcs = NPCs.GetAll()
        for k, v in pairs(npcs) do
            if NPC.IsCourier(v) and Entity.IsSameTeam(Heroes.GetLocal(),v) then
                local courier = v
                --Log.Write("the courier" .. tostring(courier))
                --NPC.GetAbilityByIndex(courier, 4)
                --NPC.MoveTo(courier, Vector(0,0,0))
                --Ender_Wolf code
                local ability = NPC.GetAbilityByIndex(courier, 0)
                if Ability.IsReady(ability) then
                    Ability.CastNoTarget(ability)
                end
            end
        end    
    end
    --
    --      SECRET SHOP
    --
    if toggleStateSecretShop then
        local npcs = NPCs.GetAll()
        for k, v in pairs(npcs) do
            if NPC.IsCourier(v) and Entity.IsSameTeam(Heroes.GetLocal(),v) then
                local courier = v
                --Log.Write("the courier" .. tostring(courier))
                --NPC.GetAbilityByIndex(courier, 4)
                --NPC.MoveTo(courier, Vector(0,0,0))
                --Ender_Wolf code
                local ability = NPC.GetAbilityByIndex(courier, 1)
                if Ability.IsReady(ability) then
                    Ability.CastNoTarget(ability)
                end
            end
        end    
    end
end
return kraneCourier
