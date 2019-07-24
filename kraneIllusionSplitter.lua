local kraneIllusionSplitter = {}

kraneIllusionSplitter.Enabled = Menu.AddOption({"KRANE", "Hero", "Phantom Lancer"}, "Illusion Splitter", "")
kraneIllusionSplitter.Trigger = Menu.AddKeyOption({"KRANE", "Hero", "Phantom Lancer"}, "Key bind", 0)

--vars
local everyBodyInRadius = nil
local myHero = nil
local myPosition = nil
local randomX = 0
local randomZ = 0
local randomY = 0
local PossiblePosition = nil

function kraneIllusionSplitter.OnUpdate()
    if Menu.IsEnabled(kraneIllusionSplitter.Enabled) then
        if Menu.IsKeyDown(kraneIllusionSplitter.Trigger) then

            myHero = Heroes.GetLocal()
            
            --get all the illusions
            everyBodyInRadius = Entity.GetHeroesInRadius(myHero, 600, Enum.TeamType.TEAM_FRIEND, true)
            
            for k, v in pairs(everyBodyInRadius) do
                --Log.Write(tostring(NPC.GetUnitName(v))) -- npc_dota_hero_phantom_lancer
                    --generate random number for every new entity 
                
                local asRandomAsItGets = os.clock()%1
                randomX = math.random(-1000, 1000)*asRandomAsItGets   
                randomZ =  math.random(-1000, 1000)*asRandomAsItGets
                randomY = math.random(-1000, 1000)*asRandomAsItGets
                
                if NPC.GetUnitName(v) == "npc_dota_hero_phantom_lancer" or NPC.GetUnitName(v) == "npc_dota_hero_terrorblade" then
                    myPosition = Entity.GetOrigin(myHero)
                    
                    PossiblePosition = Vector(myPosition:GetX()+randomX, myPosition:GetY()+randomY, myPosition:GetZ()+randomZ)
                    --Log.Write(tostring(PossiblePosition))
                    
                    if NPC.IsAttacking(v) == true or NPC.IsRunning(v) == false then
                        NPC.MoveTo(v, PossiblePosition, false, true)
                    end
                end     
            end

        end

    end

end

return kraneIllusionSplitter



--if NPC.IsIllusion(v) then
                    --the illusion is v
                --    if NPC.IsRunning(v) == false or NPC.IsAttacking(v) == true then
                        --add run script
                    --    Log.Write("v is attacking or not running")
                  --  end
                --end   