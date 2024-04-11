-- RoRRConsole v1.0.0 (placeholder name)
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- Work In Progress
-- SmoothSpatula

-- ========== Parameters ==========

o_user = '%s*([^%s]*)%s*' -- optional username
m_user = '%s*([^%s]+)%s*' -- mandatory username
o_nb = '%s*(%d*)%s*' -- optional number
m_nb = '%s*(%d+)%s*' -- mandatory number
o_wrd = '%s*(%a*)%s*' -- optional word
m_wrd = '%s*(%a+)%s*' -- mandatory word



-- <> is a mandatory field
-- [] is an optional field
match_strings = {
    kill_username = { 
        regex = '/kill'.. o_user, 
        usage =  '<y>/kill <b>username',
        help_str = 'kill'
    },
    give_item_id = { 
        regex = '/give'..o_nb..m_nb..o_user, 
        usage = '<y>/give <b>amount <w>item_id <b>username',
        help_str = 'give'
    },
    give_item_name = { 
        regex = '/give'..o_nb..m_wrd..o_user, 
        usage = '<y>/give <b>amount <w>item_name <b>username',
        help_str = 'give'
    },
    remove_item_id = { 
        regex = '/remove'..o_nb..m_nb..o_user, 
        usage = '<y>/remove <b>amount <w>item_id <b>username',
        help_str = 'remove'
    },
    remove_item_name = { 
        regex = '/remove'..o_nb..m_wrd..o_user, 
        usage = '<y>/remove <b>amount <w>item_name <b>username',
        help_str = 'remove'
    },
    set_field = { 
        regex = '/set'..m_wrd..m_nb..o_user, 
        usage = '<y>/set field_name <w>value <b>username',
        help_str = 'set'
    },
    set_skill_id = { 
        regex = '/skill'..m_nb..m_nb..o_user, 
        usage = '<y>/skill <w>bar_slot <w>skill_id <b>username',
        help_str = 'set'
    },
    set_skill_name = { 
        regex = '/skill'..m_nb..m_wrd..o_user, 
        usage = '<y>/skill <w>bar_slot <w>skill_name <b>username',
        help_str  = 'skill'
    },
    spawn_tp = { 
        regex = '/spawntp', 
        usage = '<y>/spawntp',
        help_str = 'spawntp'
    },
    kick = { 
        regex = '/kick'..m_user, 
        usage = '<y>/kick <b>username',
        help_str = 'kick'
    },
    help = { 
        regex = '/help'..o_user, --using this so people can type /help /give
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
        if username == '' then
            print(actor.user_name.. " killed themselves.")
        else
            print("kill "..username)
        end
    end
}

-- add functions after
functions['give_item_name'] = function(actor, amount, item_name, username)
    if amount == '' then amount = 1 end
    if username == '' then username = actor.user_name end
    print( "given "..amount.." "..item_name.." to "..username)
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
    for command_name, pattern in pairs(match_strings) do
        if string.match(command, pattern['regex']) then
            functions[command_name] (actor, string.match(command, pattern['regex']))
            return 0
        end
    end
    if string.match(command, '/') then
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
