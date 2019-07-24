local kraneMorphVsSeekerPassive = {}

kraneMorphVsSeekerPassive.IsEnabled = Menu.AddOption({"Utility", "KRANE", "Morph vs Seeker"}, "Morph vs Blood Seeker", "This script will allow Morphling to morph to strength\nso it will evade being seen on the map")
local shouldMorph = false
local lastTime = nil
local continueTheScript = false

--algo (25/100*totalHp) < currentHp then seen on the map so morph to str

function kraneMorphVsSeekerPassive.OnUpdate()
    if Menu.IsEnabled(kraneMorphVsSeekerPassive.IsEnabled) == true then
        local myHero = Heroes.GetLocal()
        local AllHeroes = Heroes.GetAll()
        if Entity.GetClassName(myHero) == "C_DOTA_Unit_Hero_Morphling" then

            for k, v in pairs(AllHeroes) do
                if Entity.GetClassName(v) == "C_DOTA_Unit_Hero_Bloodseeker" then
                    if Entity.IsSameTeam(myHero, v) then
                        --same team seeker
                        continueTheScript = false
                    else
                        --enemy team seeker
                        continueTheScript = true
                    end    
                end                
            end

            if continueTheScript then
                -- if all conditions above are met, continue the script
                local ability_StrMorph = NPC.GetAbilityByIndex(myHero, 4)
                local maxHp = Entity.GetMaxHealth(myHero)
                local currentHp = Entity.GetHealth(myHero)
                --250 is for the safe so you will NEVER get seen
                if (25/100*maxHp) > currentHp-250 then
                    --activate str
                    shouldMorph = true
                end
                local secondsPassed = os ~= nil and os.time() or tick()
                

                if shouldMorph == true then
                    if Ability.IsReady(ability_StrMorph) and lastTime ~= secondsPassed then
                        Ability.Toggle(ability_StrMorph)
                        shouldMorph = false
                    end
                end
            
                lastTime = secondsPassed
            end
        end
    end
end


return kraneMorphVsSeekerPassive
