local kunkka = {}

kunkka.ComboKey = Menu.AddKeyOption({"KRANE", "Hero Scripts", "Kunkka", "Combo"}, "Combo key", 0)
kunkka.AutoArmletForTideBringer = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Misc"}, "Auto Armlet for Tidebringer", "automaticly enables the armlet when you order a tidebringer attack")

kunkka.xTorrent = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Combo"}, "X + Torrent", "Only X + Torrent")
kunkka.xTorrentBoat = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Combo"}, "X + Torrent + Boat", "Full Combo")
kunkka.xSmart = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Combo"}, "Smart combo", "It will use the optimum combo (if the enemy is low it will ony use torrent.. etc)")

kunkka.campSelector = Menu.AddKeyOption({"KRANE", "Hero Scripts", "Kunkka", "Farm"}, "Select camp", 0)
kunkka.campAutoRemove = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Farm"}, "Camp auto remove", "Auto remove the camp if you are not in range to cast the spell")
kunkka.campSameCamp = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka", "Farm"}, "Farm same camp", "If enabled, it will stack the same camp, if not you will have to manually select the same camp every time.")

kunkka.Enabled = Menu.AddOption({"KRANE", "Hero Scripts", "Kunkka"}, "Enable Kunkka", "Enable the script")

--delays
local x_delay = nil
local torrent_delay = nil
local boat_delay = nil

--globals 
local enemy = nil
local startTime = nil
local ticking = nil

local myhero = nil

local isEnemySelected = false

local trigger_stackTimer = nil
local campToStack = nil

local trigger_startTicking = false

local runTheScript = true
local comboChosen = 0

local trigger_outOfRange = false

--abilities
local ab_x_origin = nil

local ab_xmarks = nil
local ab_torrent = nil
local ab_boat = nil
local ab_tidebringer = nil

--items
local armlet_item_from_inventory = nil


--triggers
local trigger_Armlet = true


local function log(param)
    Log.Write(tostring(param))
end

local function selectEnemy()
    enemy = Heroes.InRadius(Input.GetWorldCursorPos(), 250, Entity.GetTeamNum(Heroes.GetLocal()), Enum.TeamType.TEAM_ENEMY) 
    enemy = enemy[next(enemy)]
    if enemy ~= nil then
        isEnemySelected = true
    end
end

local AllCampstoStack = {}
local function stackCamps(camps, myhero)
    local distance = nil

    if Menu.IsKeyDownOnce(kunkka.campSelector) then
        campToStack = Input.GetWorldCursorPos()

        --multiple camps
        
        table.insert (AllCampstoStack, campToStack)

        

    end
    
    if campToStack ~= nil then
        
        local lastDistance = nil
        for key,value in pairs(AllCampstoStack) do
            --take my distance, compare to all the camps and select the closest one
            distance = Entity.GetAbsOrigin(myhero):Distance(value):Length2D()
            
            
            if lastDistance ~= nil then
                if distance < lastDistance then
                    if campToStack ~= nil then
                        lastDistance = Entity.GetAbsOrigin(myhero):Distance(campToStack):Length2D()
    
                        if distance < lastDistance then
                            campToStack = AllCampstoStack[key]
                        end
                    else
                        campToStack = AllCampstoStack[key]
                    end
                end
            end
            
            
            lastDistance = distance
        end
    
        local trigger_stack = (GameRules.GetGameTime() - GameRules.GetGameStartTime()) % 60 > 57.40 and (GameRules.GetGameTime() - GameRules.GetGameStartTime()) % 60 < 57.46
        trigger_stackTimer = (GameRules.GetGameTime() - GameRules.GetGameStartTime()) % 60

        if trigger_stackTimer > 0 then
            distance = Entity.GetAbsOrigin(myhero):Distance(campToStack):Length2D()

            if distance > Ability.GetCastRange(ab_torrent) then
                trigger_outOfRange = true

                if Menu.IsEnabled(kunkka.campAutoRemove) then
                    if trigger_stackTimer > 56 then
                        campToStack = nil
                        trigger_outOfRange = false
                    end
                end
            else
                trigger_outOfRange = false
            end
        
        end
        

        if trigger_stack then

            if trigger_outOfRange == false then
                Ability.CastPosition(ab_torrent, campToStack, false)
                trigger_outOfRange = false
            end
            if Menu.IsEnabled(kunkka.campSameCamp) then return end
            campToStack = nil
        end
        
    end

    --draw on the map 

end

local function init()
    isEnemySelected = false
    startTime = nil
    trigger_startTicking = false
    ticking = nil
    enemy = nil
    runTheScript = true
    comboChosen = 0
    campToStack = nil
    myhero = Heroes.GetLocal()
    if myhero == nil then return end
    if NPC.GetUnitName(myhero) ~= "npc_dota_hero_kunkka" then runTheScript = false return end
    ab_xmarks = NPC.GetAbility(myhero, "kunkka_x_marks_the_spot")
    ab_torrent = NPC.GetAbility(myhero, "kunkka_torrent")
    ab_boat = NPC.GetAbility(myhero, "kunkka_ghostship")
    ab_tidebringer = NPC.GetAbility(myhero, "kunkka_tidebringer")  
    x_delay = (4 + Ability.GetCastPoint(ab_xmarks))
    torrent_delay = (1.6 + Ability.GetCastPoint(ab_torrent))
    boat_delay = (3.1 + Ability.GetCastPoint(ab_boat))

    --items
    
    Log.Write("-> Kunkka reloaded.")
end

local function checkItemsOnHero()
    armlet_item_from_inventory = NPC.GetItem(Heroes.GetLocal(), "item_armlet", true)
end


function kunkka.OnGameEnd()
    init()
end

function kunkka.OnGameStart()
    init()
end

function kunkka.OnScriptLoad()
    init()
end

local function activateArmlet()
    if not trigger_Armlet then return end
    --activate armlet
    checkItemsOnHero()
    if armlet_item_from_inventory == nil then return end
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TOGGLE, armlet_item_from_inventory, Vector(0, 0, 0), armlet_item_from_inventory, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Heroes.GetLocal(), false, true)
    trigger_Armlet = false
end

local function xTorrentCombo()
    if ticking >= 4 - torrent_delay and Ability.GetCooldown(ab_torrent) == 0.0 then
        Ability.CastPosition(ab_torrent, ab_x_origin, false)
        activateArmlet()
        
    end
end

local function xBoatCombo()
    if ticking >= 4 - boat_delay  and Ability.GetCooldown(ab_boat) == 0.0 then
        Ability.CastPosition(ab_boat, ab_x_origin, false)
        activateArmlet()
    end
end


local function xSmartCombo()
    if enemy == nil then return end
    
    local enemyHp = Entity.GetHealth(enemy)

    local magicReistance = NPC.GetMagicalArmorValue(enemy) * 100
    local phisicalResistance = NPC.GetPhysicalDamageReduction(enemy) * 100

    local boatDamage = Ability.GetDamage(ab_boat, Ability.GetDamageType(ab_boat))
    local torrentDamage = Ability.GetLevelSpecialValueFor(ab_torrent, "torrent_damage")
    local tidebringerDamage = 0
    local hitDamage = NPC.GetTrueDamage(myhero)

    

    boatDamage = boatDamage - (magicReistance / 100 ) * boatDamage
    torrentDamage = torrentDamage - (magicReistance / 100 ) * torrentDamage
    tidebringerDamage = tidebringerDamage - (phisicalResistance / 100) * tidebringerDamage
    hitDamage = hitDamage - ( phisicalResistance / 100 ) * hitDamage
    tidebringerDamage = tidebringerDamage + hitDamage

    local boatTorrentTide = boatDamage + tidebringerDamage + torrentDamage
    
    local boatTide = boatDamage + tidebringerDamage
    local torrentTide = torrentDamage + tidebringerDamage
    
    local boatTorrent = boatDamage + torrentDamage
    
    if comboChosen ~= nil then
        if comboChosen == 1 then
            activateArmlet()
        end
        if comboChosen == 2 then
            xTorrentCombo()
        end
        if comboChosen == 3 then
            xBoatCombo()
        end
        if comboChosen == 4 then
            activateArmlet()
            xTorrentCombo()
        end
        if comboChosen == 5 then
            xBoatCombo()
            activateArmlet()
        end
        if comboChosen == 6 then
            xBoatCombo()
            xTorrentCombo()
        end
        if comboChosen == 7 then
            xBoatCombo()
            xTorrentCombo()
            activateArmlet()
        end
        
    end

    --Log.Write( "Combo Chosen: " .. tonumber(comboChosen) .. "   ----   " .. "Enemy hp: " .. tostring(enemyHp))
    if comboChosen ~= 0 then return end
    if enemyHp < tidebringerDamage and Ability.GetCooldown(ab_tidebringer) < 1 then
        comboChosen = 1
    else
        if enemyHp < torrentDamage and Ability.GetCooldown(ab_torrent) < 1 then
            comboChosen = 2
        else
            if enemyHp < boatDamage and Ability.GetCooldown(ab_boat) < 1 then
                comboChosen = 3
            else
                if enemyHp < torrentTide and Ability.GetCooldown(ab_torrent) < 1 then
                    comboChosen = 4
                else
                    if enemyHp < boatTide and Ability.GetCooldown(ab_boat) < 1 then
                        comboChosen = 5
                    else
                        if enemyHp < boatTorrent and Ability.GetCooldown(ab_boat) < 1 and Ability.GetCooldown(ab_torrent) < 1 then
                            comboChosen = 6
                        else
                            comboChosen = 7
                        end
                    end
                end
            end
        end
    end

    

    --Log.Write("Boat damage: " .. tostring(boatDamage) .. "  Torrent: " .. tostring(torrentDamage) .. "  TideBringer: " .. tostring(tidebringerDamage))


end

local function harass_tidebringer()

end

local initiated = false
function kunkka.OnUpdate()
    if not Menu.IsEnabled(kunkka.Enabled) then return end
    if not initiated then init() initiated = true end
    if not runTheScript then return end

    if Menu.IsKeyDownOnce(kunkka.ComboKey) then

        isEnemySelected = false -- every time its pressed select a new enemy
        if not isEnemySelected then
            selectEnemy()
            trigger_Armlet = true
            
        end
    end
        
    if enemy ~= nil then

        if not Entity.IsDormant(enemy) then
            if Ability.GetCooldown(ab_xmarks) == 0.0 then 
                Ability.CastTarget(ab_xmarks, enemy, false)
            end
        else
            if Ability.GetCooldown(ab_xmarks) > 0.0 == false then
                init()
                return
            end
        end

        if trigger_startTicking then
            ticking = GameRules.GetGameTime() - startTime
        end

        if ticking ~= nil then 
            
            if Menu.IsEnabled(kunkka.xTorrent) then
                xTorrentCombo()
            end
            
            if Menu.IsEnabled(kunkka.xTorrentBoat) then
                xTorrentCombo()
                xBoatCombo()
            end
            
            if Menu.IsEnabled(kunkka.xSmart) then
                xSmartCombo()
            end

            if ticking >= 4 then
                init()
                return
            end


        end

        --Log.Write(tostring(startTime) .. "----" .. tostring(enemy) .. "----" .. tostring(Entity.IsDormant(enemy)))
    end

    
    stackCamps(camps, Heroes.GetLocal())

    --local a = (GameRules.GetGameTime() - GameRules.GetGameStartTime()) % 60 

   --Log.Write(tostring(a))


end


function kunkka.OnModifierGained(npc,modifier)
    if enemy ~= nil then
        
        if npc == enemy and Modifier.GetName(modifier) == "modifier_kunkka_x_marks_the_spot" then
            --get location
            ab_x_origin = Entity.GetAbsOrigin(npc)
            startTime = GameRules.GetGameTime()
            trigger_startTicking = true

        end

    end

end


function kunkka.OnDraw()
    if not runTheScript then return end
    if campToStack == nil or trigger_stackTimer == nil then return end
    local x, y, vis = Renderer.WorldToScreen(campToStack)
    


    for key,value in pairs(AllCampstoStack) do
        local x2, y2, vis2 = Renderer.WorldToScreen(value)

        if vis2 then    
            if x2 ~= x and y2 ~= y then 
            Renderer.SetDrawColor(59, 204, 6, 100)
            Renderer.DrawFilledRect(x2 - 25, y2 - 25, 50, 50)
        
            Renderer.SetDrawColor(0, 0, 0, 255)  
            Renderer.DrawText(1, x2-20, y2-15, tostring(trigger_stackTimer // 1), -1)
        end
        end
           
    end

    if vis then 
        if trigger_outOfRange then
            Renderer.SetDrawColor(194, 2, 24, 100)
            Renderer.DrawFilledRect(x - 25, y - 25, 50, 50)
        else
            Renderer.SetDrawColor(23, 202, 238, 100)
            Renderer.DrawFilledRect(x - 25, y - 25, 50, 50)
        end
        Renderer.SetDrawColor(0, 0, 0, 255)  
        Renderer.DrawText(1, x-20, y-15, tostring(trigger_stackTimer // 1), -1)
    
    end


end

function kunkka.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(kunkka.Enabled) then return true end
    local playerName = Player.GetName(orders.player)
    local abilityName = Ability.GetName(orders.ability) 
    --orders.player
    --orders.order -- Смотрите Enums.UnitOrder.
    --orders.target
    --orders.position
    --orders.ability
    --orders.orderIssuer -- Смотрите Enums.PlayerOrderIssuer.
    --orders.npc
    --orders.queue
    --orders.showEffects
    if Menu.IsEnabled(kunkka.AutoArmletForTideBringer) then
        if abilityName == "kunkka_tidebringer" then
            activateArmlet()
            trigger_Armlet = true
        end
    end

    return true
end

return kunkka
