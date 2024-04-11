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
wrd = '%s*(%a+)%s*' -- word


-- <> is a mandatory field
-- [] is an optional field
match_strings = {
    kill_username = '/kill'..o_user, -- /kill [username]
    give_item_id = '/give'..o_nb..m_nb..o_user, -- /give [amount] <item_id> [username] 
    give_item_name = '/give'..o_nb..wrd..o_user, -- /give [amount] <item_name>  [username] 
    remove_item_id = '/remove'..o_nb..m_nb..o_user, -- /remove [amount] <item_id> [username]
    remove_item_name = '/remove'..o_nb..wrd..o_user, -- /remove  [amount] <item_name> [username]
    set_field = '/set'..wrd..m_nb..o_user, -- /set <field_name> <value> [username]
    set_skill_id = '/set'..m_nb..m_nb..o_user, -- /skill <bar_slot> <skill_id> [username]
    set_skill_name = '/set'..m_nb..wrd..o_user, -- /skill <bar_slot> <skill_name> [username]
    spawn_tp = '/spawntp', -- /spawntp
    kick = '/kick'..m_user
}

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
        if string.match(command, pattern) then
            functions[command_name] (actor, string.match(command, pattern))
            return 0
        end
    end
    return 1
end

gm.post_script_hook(gm.constants.chat_add_user_message, function(self, other, result, args)
    match_command(args[1].value, args[2].value) -- pass actor instance and message
end)

gm.post_script_hook(gm.constants.draw_chat, function(self, other, result, args)
    --print(result.type)
end)
gm.post_script_hook(gm.constants.chat_add_user_message, function(self, other, result, args)
    match_command(args[1].value, args[2].value) -- pass actor instance and message
end)
