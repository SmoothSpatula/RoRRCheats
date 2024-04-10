-- RoRRConsole v1.0.0 (placeholder name)
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- Work In Progress
-- SmoothSpatula

-- ========== Parameters ==========

usrn = '%s*([^%s]*)%s*' -- username
nb = '%s*(%d+)%s*' -- number
wrd = '%s*(%a+)%s*' -- word


-- <> is a mandatory field
-- [] is an optional field
match_strings = {
    kill_username = '/kill'..usrn, -- /kill [username]
    give_item_id = '/give'..nb..usrn..nb, -- /give <item_id> <username> [amount]
    give_item_name = '/give'..wrd..usrn..nb, -- /give <item_name> <username> [amount]
    remove_item_id = '/remove'..nb..usrn..nb, -- /remove <item_id> <username> [amount]
    remove_item_name = '/remove'..wrd..usrn..nb, -- /remove <item_name> <username> [amount]
    set_field = '/set'..wrd..nb..usrn, -- /set <field_name> <value> [username]
    set_skill_id = '/skill'..nb..nb..usrn, -- /skill <bar_slot> <skill_id> [username]
    set_skill_name = '/skill'..nb..wrd..usrn, -- /skill <bar_slot> <skill_name> [username]
    spawn_tp = '/spawntp' -- /spawntp
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
functions['give_item_name'] = function(actor, item_name, username, amount)
    if amount == nil then amount = 1 end
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
