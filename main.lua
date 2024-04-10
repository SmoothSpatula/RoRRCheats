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
  set_skill_id = '/set'..nb..nb..usrn, -- /skill <bar_slot> <skill_id> [username]
  set_skill_name = '/set'..nb..wrd..usrn, -- /skill <bar_slot> <skill_name> [username]
  spawn_tp = '/spawntp' -- /spawntp
}

-- ========== Commands ==========

function kill_username(username)
    if username == '' then
      print("kill your own character")
    else
      print("kill "..username)
    end
end

function give_item_name(item_name, username, amount)
  if amount == nil then amount = 1 end
  print( "given "..amount.." "..item_name.." to "..username)
end

-- ========== Main ==========

command = "/give GoatHoof Umigatari 12"
--command = "/kill"
for command_name, pattern in pairs(match_strings) do
  if string.match(command, pattern) then
    _G[command_name] (string.match(command, pattern))
  end
end
