-- RoRRConsole v1.0.0 (placeholder name)
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

-- ========== Parameters ==========

local lvlToGive = 0

-- <> is a mandatory field
-- [] is an optional field
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
        usage = '<y>/set field_name <w>value <b>username',
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
    kick = { 
        usage = '<y>/kick <b>username',
        cmd_name = 'kick'
    },
    help = { 
        usage = '<y>/help <b>username',
        cmd_name = 'help'
    }
}

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

-- ========== Functions Associated With Commands ==========

functions = {
    kill_username = function(actor, username)
        local killActor = actor
        if not username then
            print(actor.user_name.. " killed themselves.")
        else
            for i = 1, #gm.CInstance.instances_active do
                local inst = gm.CInstance.instances_active[i]
                if inst.object_index == gm.constants.oP and inst.user_name == username then
                    killActor = inst
                    break
                end
            end
            print(actor.user_name.." killed "..username)
        end
        killActor.force_death = 1
        gm.actor_set_dead(killActor, true)
    end
}

-- add functions after
functions['give_item'] = function(actor, amount, item, username)
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

    -- Item ID
    if tonumber(item) then 
        gm.item_give(giveActor, tonumber(item), tonumber(amount), false)
        print( "given "..amount.." "..item.." to "..giveActor.user_name)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_give(giveActor, i-1, tonumber(amount), false)
            print( "given "..amount.." "..items[i][2].." to "..giveActor.user_name)
            return
        end
    end

end

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

    gm.item_drop_object(gm.constants.oEfGold, giveActor.x, giveActor.y, 0, false)
    local goldObj = Helper.find_active_instance(gm.constants.oEfGold)
    goldObj.value = goldObj.value + tonumber(amount)
    print( "given "..amount.." gold to "..giveActor.user_name)

end

functions['give_lvl'] = function(actor, number, username)
    local giveActor = actor
    local isFound = false

    if not tonumber(number) then return end
    
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
    
    lvlToGive = tonumber(number)
    print( "given "..number.." level to "..giveActor.user_name)

end

functions['remove_item'] = function(actor, amount, item, username)
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

    -- Item ID
    if tonumber(item) then 
        gm.item_take(giveActor, tonumber(item), tonumber(amount), false)
        print( "taken "..amount.." "..item.." to "..giveActor.user_name)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_take(giveActor, i-1, tonumber(amount), false)
            print( "taken "..amount.." "..items[i][2].." to "..giveActor.user_name)
            return
        end
    end

end

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
        
    for _, field in ipairs(fields) do
        if field == field_name then
            fieldActor[field_name] = fieldValue
            return
        end
    end

    for _, comp_field in ipairs(composite_fields) do
        if comp_field == field_name then
            if not fieldActor[field_name.."_level"] then
                fieldActor[field_name] = fieldValue
                fieldActor[field_name.."_base"] = fieldValue
                fieldActor[field_name:gsub('max', '')] = fieldValue
                return
            end
            
            fieldActor[field_name..'_base'] = fieldValue - (fieldActor.level-1) * fieldActor[field_name..'_level']
            fieldActor[field_name] = fieldValue

            if field_name == 'maxhp' then fieldActor.hp = fieldValue end

        end
    end
end

-- gm.post_script_hook(gm.constants.step_player, function()
--     print("step_player")
-- end)

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
        print( "Set skill "..skill.." in bar slot "..bar_slot.." to "..skillActor.user_name)
        return
    end

    -- Skill Name
    local skills = gm.variable_global_get("class_skill")
    for i=1, 185 do
        if string.lower(skill) == string.lower(skills[i][2]) then
            gm.actor_skill_set(skillActor, tonumber(bar_slot)-1, i-1)
            print( "Set skill "..skills[i][2].." in bar slot "..bar_slot.." to "..skillActor.user_name)
            return
        end
    end
    
end

functions['spawn_tp'] = function(actor)
    local tpObj = Helper.find_active_instance_all(gm.constants.oTrialsFinalShortcutTeleporter)
    if #tpObj > 0 then 
        for i = 1, #tpObj do
            gm.instance_destroy(tpObj[i])
        end
    end

    gm.instance_create_depth(actor.x, actor.y, 1, gm.constants.oTrialsFinalShortcutTeleporter)
end

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
    
    if not godActor.intangible then godActor.intangible = 0 end
    godActor.intangible = (godActor.intangible + 1) % 2
end

functions['kick'] = function(actor, username)
    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oP and inst.user_name == username then
            print(inst.user_name)
            print(gm._mod_net_isAuthority(inst))
            print(gm._mod_net_isHost(inst))
            print(gm._mod_net_isClient(inst))
            print(gm._mod_net_isOnline(inst))
            -- gm.disconnect_player(inst)
        end
    end
end

functions['help'] = function(actor, command)
    if command == '' or command == nil then 
        help_print_all() 
    return end
    help_print_command(command)
end

        
-- ========== ImGui ==========

-- Console in ImGui, Work In Progress
local text = ""
gui.add_imgui(function()
    if ImGui.Begin("Console") then
        text, selected = ImGui.InputText("", text, 200)
        if selected then 
            print(text)
        end
        ImGui.TextColored(0.5, 0, 0, 1, text)
    end
end)

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
                print(param)
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

gm.post_script_hook(gm.constants.__input_system_tick, function()
    if lvlToGive > 0 then
        local director = gm._mod_game_getDirector()
        director.player_exp = director.player_exp_required+0.1
        lvlToGive = lvlToGive - 1
    end
end)
