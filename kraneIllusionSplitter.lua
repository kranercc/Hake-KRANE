local kraneIllusionSplitter = {}

kraneIllusionSplitter.Enabled = Menu.AddOption({"KRANE", "Illusions", "Illusion Splitter"}, "Illusion Splitter", "SUPPORTED HEROES:\n↓↓↓↓\nEVERYONE WITH AT LEAST MANTA STYLE")
kraneIllusionSplitter.Trigger = Menu.AddKeyOption({"KRANE", "Illusions", "Illusion Splitter"}, "Key bind", 0)
kraneIllusionSplitter.SplitUpEnabled = Menu.AddOption({"KRANE", "Illusions", "Illusion Splitter"}, "Split Up / Don\'t focuse main hero", "")

--vars
local everyBodyInRadius = nil
local myHero = nil
local myPosition = nil
local randomX = 0
local randomY = 0
local PossiblePosition = nil

function kraneIllusionSplitter.OnUpdate()
    if Menu.IsEnabled(kraneIllusionSplitter.Enabled) then
        if Menu.IsKeyDown(kraneIllusionSplitter.Trigger) then

            myHero = Heroes.GetLocal()
            
            --get all the illusions
            everyBodyInRadius = Entity.GetHeroesInRadius(myHero, 1200, Enum.TeamType.TEAM_FRIEND, true)
            
            for k, v in pairs(everyBodyInRadius) do
                --Log.Write(tostring(NPC.GetUnitName(v))) -- npc_dota_hero_phantom_lancer
                    --generate random number for every new entity 
                
                local asRandomAsItGets = os.clock()%1
                randomX = math.random(-600, 600)*asRandomAsItGets   
                randomY = math.random(-600, 600)*asRandomAsItGets
                --so you can just make a vector holding all the heroes in dota or something like this to basicly control manta illusions but i think thats an exageration since 2 illusions are not really that important
                if NPC.GetUnitName(v) == NPC.GetUnitName(Heroes.GetLocal()) then
                    if Menu.IsEnabled(kraneIllusionSplitter.SplitUpEnabled) then
                        myPosition = Entity.GetOrigin(v)
                    else
                        myPosition = Entity.GetOrigin(myHero)
                    end
                    PossiblePosition = Vector(myPosition:GetX()+randomX, myPosition:GetY()+randomY, myPosition:GetZ())
                    --Log.Write(tostring(PossiblePosition))
                    
                    if NPC.IsAttacking(v) == true or NPC.IsRunning(v) == false then
                        NPC.MoveTo(v, PossiblePosition, false, false)
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
