-- TestMod
-- SmoothSpatula


log.info("Successfully loaded ".._ENV["!guid"]..".")

testmod = true
str = "tettetette"

--has access to passed args and normal parameters
function public_func(args1, args2)
    print(str)
    print("printed this "..args2.." from testmod" )
end

mods.on_all_mods_loaded(function() 
    --find chatconsole script
    for k, v in pairs(mods) do 
        if type(v) == "table" and v.chatconsole then 
            ChatConsole = v 
        end
    end 
    --add the function you want to add
    for k, v in pairs(mods) do
        if type(v) == "table" and v.testmod then 
            --name, reference, usage text, command ("/public")
            ChatConsole.add_function(public_func, v.public_func, "<y> lolxdtest", "public")
        end 
    end
end)

-- to add in main

-- function add_function(ref, func, use, help)
--     print("adding function")
--     functions[ref] = func
--     match_strings[ref] = {
--         usage = use,
--         help_str = help
--     }
-- end
