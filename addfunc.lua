-- TestMod
-- SmoothSpatula


log.info("Successfully loaded ".._ENV["!guid"]..".")


examplemod = true -- this lets you locate your own mod later
-- actor instance who wrote the command
-- args1... the words separated by spaces in order after the command ("/command args1 args2 args3 ..."). These are strings containing any non-space characters
function example_func(actor, args1, args2)
    -- your code here
end

mods.on_all_mods_loaded(function() 
    -- find chatconsole script
    for k, v in pairs(mods) do if type(v) == "table" and v.chatconsole then ChatConsole = v end end 
    -- add the function you want to add
    for k, v in pairs(mods) do
        if type(v) == "table" and v.examplemod then 
            -- name in the function array, reference, usage text, command ("/example")
            -- optional fields go at the end after mandatory fields (you can avoid doing this if you know what you're doing)
            -- you can overwrite default commands by using the same name (here examplemod_examplefunc)
            ChatConsole.add_function(examplemod_examplefunc, v.example_func, "<y>/example <example mandatory field> [example optional field]", "example")
        end 
    end
end)

-- to add in main

-- function add_function(ref, func, use, help)
--     functions[ref] = func
--     match_strings[ref] = {
--         usage = use,
--         cmd_name = help
--     }
-- end
