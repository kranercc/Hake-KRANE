local kraneIllusionFarmer = {}

kraneIllusionFarmer.Enabled = Menu.AddOption({"KRANE", "Dynamic", "Farmer"}, "Activate Illusion Farmer", "")
kraneIllusionFarmer.EvadeHeroesEnabled = Menu.AddOption({"KRANE", "Dynamic", "Farmer" }, "Evade Heroes", "Will run away if there is any enemy in 950 range")
kraneIllusionFarmer.FarmClosestKey = Menu.AddKeyOption({"KRANE", "Dynamic", "Farmer"}, "Farm closest creep / neutral", 0)

local myPlayer = Players.GetLocal()
local myHero = nil
local myFountain = nil
local lastTime = nil
local toggle_FarmClosest = false
local triggerTime = nil
local triggerTimeForEvade = nil

function kraneIllusionFarmer.OnDraw()
    if toggle_FarmClosest == true then
        Renderer.DrawText(0, 100, 100, "SEARCHING TO ATTACK", 0)
    end

end

function kraneIllusionFarmer.OnUpdate()
    if Menu.IsEnabled(kraneIllusionFarmer.Enabled) then
        if Menu.IsEnabled(kraneIllusionFarmer.EvadeHeroesEnabled) then
            evadeHeroes()
        end
    end

    --
    --  FARM
    --
    if Menu.IsEnabled(kraneIllusionFarmer.Enabled) then
        if Menu.IsKeyDownOnce(kraneIllusionFarmer.FarmClosestKey) then
            toggle_FarmClosest = not toggle_FarmClosest
        end
    end

    if toggle_FarmClosest == true then
        farmEverything()
    end
end

--
--  EVADE RELATED
--
function evadeHeroes()
    --get all the treant entitys
    local enemiesInRadius = nil
    local bool_EnemyInRange = false
    myHero = Heroes.GetLocal()
    local NPC_LIST = NPCs.GetAll()
    
    for k, v in pairs(NPC_LIST) do
        if NPC.GetUnitName(v) == "dota_fountain" and Entity.IsSameTeam(v, myHero) then
            myFountain = Entity.GetAbsOrigin(v)
        end
        if NPC.GetUnitName(v) == NPC.GetUnitName(myHero) and NPC.IsIllusion(v) then
            enemiesInRadius = Entity.GetHeroesInRadius(v, 950, Enum.TeamType.TEAM_ENEMY)
            --check if there is at least 1 enemy
            for k, v2 in pairs(enemiesInRadius) do
                bool_EnemyInRange = true
                break                
            end
            --time algo
            --evade enemy
            if triggerTimeForEvade == nil then
                triggerTimeForEvade = os.clock() + 0.1
                triggerTime = os.clock() + 5 --go to base after 5 secounds check again
            end
            if bool_EnemyInRange == true and os.clock() >= triggerTimeForEvade then
                NPC.MoveTo(v, myFountain, false, false)
                triggerTimeForEvade = nil
            end
        end
    end
    
end

--
--  FARM RELATED
--
local i = 300
function farmEverything()
    local closestEntity = nil
    if i == 3000 then
        i = 300
    end
    myHero = Heroes.GetLocal()
    local myIllusions = {}

    --get all illusions
    local stopAT = 5
    for k, v in pairs(NPCs.GetAll()) do
        if NPC.GetUnitName(v) == NPC.GetUnitName(myHero) and NPC.IsIllusion(v) and NPC.IsAttacking(v) == false then
            table.insert(myIllusions, v)
            stopAT = stopAT - 1
            if stopAT == 0 then
                break
            end
        end
    end

    for k, v in pairs(myIllusions) do
        if NPC.IsAttacking(v) == false then
            --check for entities aroudn every o\ne
            closestEntity = Entity.GetUnitsInRadius(v, i, Enum.TeamType.TEAM_ENEMY)
            i = i + 200
            for k, entity in pairs(closestEntity) do
                --attack the entity
                if Entity.IsHero(entity) == false then
                    addDelay(0.10, AttackSomeone, entity, v)
                end
                break
            end        
        end
    end


end

--
--      UTILITY FUNCTIONS
--
function AttackSomeone(target, illusion)
    Player.PrepareUnitOrders(myPlayer, Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, illusion, false, true)   
    Log.Write("hitting this x") 
end

function addDelay(seconds, whatToExecute, param1, param2)
    if triggerTime == nil then
        triggerTime = os.clock() + seconds
    end
    if os.clock() >= triggerTime then
        whatToExecute(param1, param2)
        triggerTime = nil
    end
    

end

return kraneIllusionFarmer
