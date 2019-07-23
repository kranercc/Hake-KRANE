local kraneCourier = {}

--kraneCourier.IsToggled = Menu.AddOption({"Utility", "KRANE"}, "Krane Courier", "")
kraneCourier.AntiRecall = Menu.AddKeyOption({"Utility", "KRANE", "Courier"}, "Ignore recalls", 0)

local toggleState = false

function kraneCourier.OnUpdate()
    if Menu.IsKeyDownOnce(kraneCourier.AntiRecall) then
        toggleState = not toggleState
    end
    if toggleState then
        Renderer.DrawText(0, 100, 200, "Ignore recalls: Running", 0)
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
end
return kraneCourier