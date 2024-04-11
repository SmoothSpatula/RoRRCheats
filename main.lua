-- ChatConsole v1.0.0 (placeholder name)
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- Work In Progress
-- SmoothSpatula

-- ========== Parameters ==========

local lvlToGive = 0

-- <> is a mandatory field
-- [] is an optional field
match_strings = {
    kill_username = { 
        usage =  '<y>/kill <b>username',
        help_str = 'kill'
    },
    give_item = { 
        usage = '<y>/give <b>amount <w>item_name or item_id <b>username',
        help_str = 'give'
    },
    give_gold = {
        usage = '<y>/gold <w>amount <b>username',
        help_str = 'gold'
    },
    give_lvl = {
        usage = '<y>/lvl <w>number <b>username',
        help_str = 'lvl'
    },
    remove_item = { 
        usage = '<y>/remove <b>amount <w>item_name or item_id <b>username',
        help_str = 'remove'
    },
    set_field = { 
        usage = '<y>/set field_name <w>value <b>username',
        help_str = 'set'
    },
    set_skill_id = { 
        usage = '<y>/skill <w>bar_slot <w>skill_id <b>username',
        help_str = 'set'
    },
    set_skill_name = { 
        usage = '<y>/skill <w>bar_slot <w>skill_name <b>username',
        help_str  = 'skill'
    },
    spawn_tp = { 
        usage = '<y>/spawntp',
        help_str = 'spawntp'
    },
    kick = { 
        usage = '<y>/kick <b>username',
        help_str = 'kick'
    },
    help = { 
        usage = '<y>/help <b>username',
        help_str = 'help'
    }
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
        help_list[pattern.help_str] = 0
    end
    for help_str, x in pairs(help_list) do 
        s = s.."/"..help_str.." "      
    end
    add_chat_message(s)
end

local function help_print_command(command)
    local s = '<r>Usage <w> : Mandatory <b> Optional\n'
    local matched_commands = 0
    for command_name, pattern in pairs(match_strings) do
        if string.find(string.lower(command), pattern.help_str) ~= nil then
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
    if not username then
        username = actor.user_name
    else
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                break
            end
        end
    end

    -- Item ID
    if tonumber(item) then 
        gm.item_give(giveActor, tonumber(item), tonumber(amount), false)
        print( "given "..amount.." "..item.." to "..username)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_give(giveActor, i-1, tonumber(amount), false)
            print( "given "..amount.." "..items[i][2].." to "..username)
            return
        end
    end

end

functions['give_gold'] = function(actor, amount, username)
    local giveActor = actor

    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                break
            end
        end
    end

    -- giveActor.gold = giveActor.gold + tonumber(amount)
    -- print(gm.oEfGold.script_name)
    -- gm.player_get_gold(giveActor, 1000)
    for i = 1, tonumber(amount) do
        gm.item_drop_object(gm.constants.oEfGold, giveActor.x, giveActor.y, 0, false)
    end
    print(giveActor.gold)
    print( "given "..amount.." gold to "..giveActor.user_name)

end

functions['give_lvl'] = function(actor, number, username)
    local giveActor = actor

    if username then
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                break
            end
        end
    end
    
    lvlToGive = tonumber(number)
    print( "given "..number.." level to "..giveActor.user_name)

end

functions['remove_item'] = function(actor, amount, item, username)
    local giveActor = actor
    if not username then
        username = actor.user_name
    else
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.object_index == gm.constants.oP and inst.user_name == username then
                giveActor = inst
                break
            end
        end
    end

    -- Item ID
    if tonumber(item) then 
        gm.item_take(giveActor, tonumber(item), tonumber(amount), false)
        print( "taken "..amount.." "..item.." to "..username)
        return
    end

    -- Item Name
    local items = gm.variable_global_get("class_item")
    for i=1, #items do
        local lowerItemNameRequest = string.lower(item)
        local lowerItemName = string.lower(items[i][2])

        if lowerItemNameRequest == lowerItemName or string.find(lowerItemNameRequest, lowerItemName) or string.find(lowerItemName, lowerItemNameRequest) then
            gm.item_take(giveActor, i-1, tonumber(amount), false)
            print( "taken "..amount.." "..items[i][2].." to "..username)
            return
        end
    end

end

functions['spawn_tp'] = function(actor)
    gm.instance_create_depth(actor.x, actor.y, 1, gm.constants.oTrialsFinalShortcutTeleporter)
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

-- function match_command(actor, command)
--     for command_name, pattern in pairs(match_strings) do
--         if string.match(command, pattern['regex']) then
--             functions[command_name] (actor, string.match(command, pattern['regex']))
--             return 0
--         end
--     end
--     if string.match(command, '/') then
--         print("wrong command")
--     end
--     return 1
-- end

function match_command(actor, command)
    for command_name, pattern in pairs(match_strings) do
        local prefix = '/'..pattern['help_str']
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

gm.post_script_hook(gm.constants.draw_chat, function(self, other, result, args)
    --print(result.type)
end)

gm.post_script_hook(gm.constants.__input_system_tick, function()
    if lvlToGive ~= 0 then
        local director = gm._mod_game_getDirector()
        director.player_exp = director.player_exp_required+0.1
        lvlToGive = lvlToGive - 1
    end
end)
