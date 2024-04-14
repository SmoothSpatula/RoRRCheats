-- ChatConsole v1.0.0
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

-- ========== Data ==========

chatconsole = true

-- ========== Parameters ==========

local lvlToGive = 0
local togglePeace = false
local togglePVP = false

match_strings = {
    kill_username = { 
        usage =  '<y>/kill <b>username',
        cmd_name = 'kill'
    },
    give_item = { 
        usage = '<y>/give <b>amount <w>item_name or item_id <b>username',
        cmd_name = 'give'
    },
    give_gold = {
        usage = '<y>/gold <w>amount <b>username',
        cmd_name = 'gold'
    },
    give_lvl = {
        usage = '<y>/lvl <w>number <b>username',
        cmd_name = 'lvl'
    },
    remove_item = { 
        usage = '<y>/remove <b>amount <w>item_name or item_id <b>username',
        cmd_name = 'remove'
    },
    set_field = { 
        usage = '<y>/set <w>field_name <w>value <b>username\n <r>Possible fields : <w>armor attack_speed critical_chance damage hp_regen maxhp maxbarrier maxshield armor_level attack_speed_level critical_chance_level damage_level hp_regen_level maxhp_cap maxhp_level',
        cmd_name = 'set'
    },
    set_skill = { 
        usage = '<y>/skill <w>bar_slot <w>skill_name or skill_id <b>username',
        cmd_name = 'skill'
    },
    spawn_tp = { 
        usage = '<y>/spawntp',
        cmd_name = 'spawntp'
    },
    god = { 
        usage = '<y>/god <b>username',
        cmd_name = 'god'
    },
    pvp = { 
        usage = '<y>/pvp',
        cmd_name = 'pvp'
    },
    peaceful = { 
        usage = '<y>/peaceful',
        cmd_name = 'peaceful'
    },
    kick = { 
        usage = '<y>/kick <b>username',
        cmd_name = 'kick'
    },
    help = { 
        usage = '<y>/help <b>username',
        cmd_name = 'help'
    }
}

-- Fields that need to have other fields set
composite_fields = {
    'armor',
    'attack_speed',
    'critical_chance',
    'damage',
    'hp_regen',
    'maxhp',
    'maxbarrier',
    'maxshield'
}

-- Fields that can be modified directly
fields = {
    'armor_level',
    'attack_speed_level',
    'critical_chance_level',
    'damage_level',
    'hp_regen_level',
    'maxhp_cap',
    'maxhp_level'
}

-- ========== Utils ==========

local function add_chat_message(text)
    gm.chat_add_message(gm["@@NewGMLObject@@"](gm.constants.ChatMessage, text))
end


local function help_print_all()
    local s = "<r>List of all commands <w>: "
    local help_list = {}
    -- remove duplicates
    for command_name, pattern in pairs(match_strings) do
        help_list[pattern.cmd_name] = 0
    end
    for cmd_name, x in pairs(help_list) do 
        s = s.."/"..cmd_name.." "      
    end
    add_chat_message(s)
end

local function help_print_command(command)
    local s = '<r>Usage <w> : Mandatory <b> Optional\n'
    local matched_commands = 0
    for command_name, pattern in pairs(match_strings) do
        if string.find(string.lower(command), pattern.cmd_name) ~= nil then
            if matched_commands>0 then s = s..'\n' end
            s = s..pattern.usage
            matched_commands = matched_commands + 1
        end
    end
    add_chat_message(s)
    if matched_commands<1 then 
        add_chat_message("<r> Did not recognize command")
        help_print_all()
    end
end

function add_function(ref, func, name, usage)
    functions[ref] = func
    match_strings[ref] = {
        usage = use,
        cmd_name = name
    }
end

-- ========== Functions Associated With Commands ==========

functions = {}

-- add functions after

-- Kills the specified player or all monsters from the specified monstertype
-- Do not work instantly with the One shot protection mod
functions['kill_username'] = function(actor, username)
    local killActor = actor
    local isMonster = false

    -- Kill yourself
    if not username then 
        add_chat_message(actor.user_name.. " killed themselves.")
        actor.hp = -1
        return
    end

    -- Kill the specified player
    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oP and inst.user_name == username then
            add_chat_message(actor.user_name.." killed "..username) 
            inst.hp = -1
            return
        end
    end
    
    -- Find if the provided name is the name of a monster
    local monsters = gm.variable_global_get("class_monster_card")
    local lowerMonsterNameRequest = string.lower(username)
    local monster = nil

    for i = 1, #monsters do
        local lowerMonsterName = string.lower(monsters[i][2])
        
        if lowerMonsterNameRequest == lowerMonsterName or string.find(lowerMonsterNameRequest, lowerMonsterName) or string.find(lowerMonsterName, lowerMonsterNameRequest) then
            monster = lowerMonsterName
            break
        end
    end

    -- Find and kill all instances with the provided name
    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]

        if inst.name then
            local lowerMonsterName = string.lower(inst.name)
            if inst.team == 2 and (lowerMonsterName == monster or string.find(monster, lowerMonsterName) or string.find(lowerMonsterName, monster))then
                inst.hp = -1
                isMonster = true
            end
        end
    end
    
    if isMonster then 
        add_chat_message(actor.user_name.." killed all "..monster) 
        return 
    end
    
    -- Careful, do not make any mistakes
    if not monster then
        add_chat_message(actor.user_name.." has been judged") 
        actor.hp = -1
    end
end

-- Gives the specified player any number of one item. Default amount is 1
functions['give_item'] = function(actor, item, amount, username)
    local giveActor = actor
    local giveAmount = tonumber(amount)
    local isFound = false

    if not username and not tonumber(amount) then 
        username = amount
        giveAmount = 1
    end
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end

    -- Item ID
    if tonumber(item) then 
        gm.item_give(giveActor, tonumber(item), giveAmount, false)
        add_chat_message("Given "..amount.." "..item.." to "..giveActor.user_name)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_give(giveActor, i-1, giveAmount, false)
            add_chat_message("Given "..amount.." "..items[i][2].." to "..giveActor.user_name)
            return
        end
    end

end

-- Gives the specified player gold
functions['give_gold'] = function(actor, amount, username)
    local giveActor = actor
    local isFound = false

    if not tonumber(amount) then return end
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end

    -- Did not find a way to spawn a gold directly with a custom value
    -- So we spawn a gold and try to find it and modify its value
    gm.item_drop_object(gm.constants.oEfGold, giveActor.x, giveActor.y, 0, false)
    local goldObj = Helper.find_active_instance(gm.constants.oEfGold)
    goldObj.value = goldObj.value + tonumber(amount)

    add_chat_message("Given "..amount.." gold to "..giveActor.user_name)
end

-- Gives levels to all players (exp is shared in RoRR)
functions['give_lvl'] = function(actor, number)
    if not tonumber(number) then return end
    
    lvlToGive = tonumber(number)
    add_chat_message("Given "..number.." level to all player")
end

-- Remove the any number of one item from the specified player. Default amount is 1
functions['remove_item'] = function(actor, item, amount, username)
    local removeActor = actor
    local removeAmount = tonumber(amount)
    local isFound = false

    if not username and not removeAmount then 
        username = amount
        removeAmount = 1
    end
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                removeActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end

    -- Item ID
    if tonumber(item) then 
        gm.item_take(removeActor, tonumber(item), removeAmount, false)
        add_chat_message("Taken "..amount.." "..item.." to "..removeActor.user_name)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_take(removeActor, i-1, removeAmount, false)
            add_chat_message("Taken "..amount.." "..items[i][2].." from "..removeActor.user_name)
            return
        end
    end

end

-- Sets an attribute field for the player
functions['set_field'] = function(actor, field_name, value, username)
    local fieldActor = actor
    local fieldValue = tonumber(value)
    local isFound = false

    if tonumber(field_name) or not fieldValue then return end
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                fieldActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end
        
    -- Fields that can be directly changed
    for _, field in ipairs(fields) do
        if field == field_name then
            fieldActor[field_name] = fieldValue
            add_chat_message("Set "..field_name.." of "..fieldActor.user_name.." to "..fieldValue)
            return
        end
    end
    
    -- Fields that need to have multiple value changed to work
    for _, comp_field in ipairs(composite_fields) do
        if comp_field == field_name then
            if not fieldActor[field_name.."_level"] then
                fieldActor[field_name] = fieldValue
                fieldActor[field_name.."_base"] = fieldValue
                fieldActor[field_name:gsub('max', '')] = fieldValue
                add_chat_message("Set "..field_name.." of "..fieldActor.user_name.." to "..fieldValue)
                return
            end
            
            fieldActor[field_name..'_base'] = fieldValue - (fieldActor.level-1) * fieldActor[field_name..'_level']
            fieldActor[field_name] = fieldValue
            add_chat_message("Set "..field_name.." of "..fieldActor.user_name.." to "..fieldValue)

            if field_name == 'maxhp' then fieldActor.hp = fieldValue end

        end
    end
end

-- Replace a skill by another in your skillbar. The skillbar slots are numbered 1-4
functions['set_skill'] = function(actor, bar_slot, skill, username)
    local skillActor = actor
    local isFound = false

    if not tonumber(bar_slot) then return end
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                skillActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end

    -- Skill ID
    if tonumber(skill) then 
        gm.actor_skill_set(skillActor, tonumber(bar_slot)-1, tonumber(skill))
        add_chat_message("Set skill "..skill.." in bar slot "..bar_slot.." to "..skillActor.user_name)
        return
    end

    -- Skill Name
    local skills = gm.variable_global_get("class_skill")
    for i=1, 185 do
        if string.lower(skill) == string.lower(skills[i][2]) then
            gm.actor_skill_set(skillActor, tonumber(bar_slot)-1, i-1)
            add_chat_message( "Set skill "..skills[i][2].." in bar slot "..bar_slot.." to "..skillActor.user_name)
            return
        end
    end
    
end

-- Spawns a teleporter at your location that sends you to the next stage (it cannot make you go to the final stage)
functions['spawn_tp'] = function(actor)
    local tpObj = Helper.find_active_instance_all(gm.constants.oTrialsFinalShortcutTeleporter)
    if #tpObj > 0 then 
        for i = 1, #tpObj do
            gm.instance_destroy(tpObj[i])
        end
    end

    gm.instance_create_depth(actor.x, actor.y, 1, gm.constants.oTrialsFinalShortcutTeleporter)
    add_chat_message("Spawned teleporter at "..actor.user_name)
end

-- Make the specified player invulnerable
functions['god'] = function(actor, username)
    local godActor = actor
    local isFound = false
    
    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                godActor = inst
                isFound = true
                break
            end
        end

        if not isFound then return end
    end
    
    -- Just here to fix the boolean that transform into an integer
    if not godActor.intangible then godActor.intangible = 0 end 

    -- Switch intangibility of the player
    godActor.intangible = (godActor.intangible + 1) % 2

    if godActor.intangible == 1 then
        add_chat_message(godActor.user_name.." became a god")
    else
        add_chat_message(godActor.user_name.." became a mortal")
    end

end

-- Enables pvp mode in multiplayer, setting each player to different teams. You can still be damaged by monsters
functions['pvp'] = function(actor)
    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oP then
            if togglePVP then
                inst.team = 1
            else
                inst.team = inst.m_id + 3 -- +3 because those teams are already taken
            end
        end
    end

    togglePVP = not togglePVP

    if togglePVP then
        add_chat_message("PVP mode activated")
    else
        add_chat_message("PVP mode deactivated")
    end
end

-- Prevent monster from spawning (does not work for TP boss)
functions['peaceful'] = function(actor)
    togglePeace = not togglePeace

    if togglePeace then
        add_chat_message("Peaceful mode activated")
    else
        add_chat_message("Peaceful mode deactivated")
    end
end

-- Kick the specified user from the game
functions['kick'] = function(actor, username)
    if actor.m_id ~= 1 or actor.user_name == username then return end

    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oP and inst.user_name == username then
            add_chat_message(inst.user_name.." has been kicked")
            gm.disconnect_player(inst)
        end
    end
end

-- Gives you a list of all commands or information on a specified command
functions['help'] = function(actor, command)
    if command == '' or command == nil then 
        help_print_all() 
    return end
    help_print_command(command)
end

-- ========== Main ==========

--command examples
-- /give GoatHoof Umigatari 12
-- /kill

function match_command(actor, command)
    command = command..' '
    for command_name, pattern in pairs(match_strings) do
        local prefix = '/'..pattern['cmd_name']..' '
        if string.find(command,prefix) == 1 then
            command = command:gsub(prefix, '')
            local func_params = {}
            for param in command:gmatch('([^%s]+)') do
                func_params[#func_params+1] = param
            end
            functions[command_name](actor, table.unpack(func_params))
            return
        end
    end
    
    if string.find(command, '/') == 1 then
        print("wrong command")
    end
    return 1
end

gm.post_script_hook(gm.constants.chat_add_user_message, function(self, other, result, args)
    match_command(args[1].value, args[2].value) -- pass actor instance and message
end)

-- Used for the peace command
gm.pre_code_execute(function(self, other, code, result, flags)
    if code.name:match("oDirectorControl_Alarm_1") and togglePeace then
        self:alarm_set(1, 60)
        return false
    end
end)

-- Used for the level command
gm.post_script_hook(gm.constants.__input_system_tick, function()
    if lvlToGive > 0 then
        local director = gm._mod_game_getDirector()
        director.player_exp = director.player_exp_required+0.1
        lvlToGive = lvlToGive - 1
    end
end)

-- Reset the toggle variables
gm.post_script_hook(gm.constants.run_destroy, function()
    togglePeace = false
    togglePVP = false
end)
