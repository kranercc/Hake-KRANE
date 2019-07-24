local kraneMorphVsSeekerPassive = {}

kraneMorphVsSeekerPassive.IsEnabled = Menu.AddOption({"Utility", "KRANE", "Morph vs Seeker"}, "Morph vs Blood Seeker", "This script will allow Morphling to morph to strength\nso it will evade being seen on the map")
local shouldMorph = false
local lastTime = nil

--algo (25/100*totalHp) < currentHp then seen on the map so morph to str

function kraneMorphVsSeekerPassive.OnUpdate()
    if Menu.IsEnabled(kraneMorphVsSeekerPassive.IsEnabled) == true then
        local myHero = Heroes.GetLocal()
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


return kraneMorphVsSeekerPassive