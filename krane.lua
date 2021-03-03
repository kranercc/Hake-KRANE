local krane = {}


--table of sync functions
local sync_funcs = {};


--sync func generator
function new_sync_Task(function_f, delay, recurring_TRUE_FALSE, args)

    

    local object = {};
    --small time algo i know to make things basically run and not stop the thread
    object.stop_time = os.clock() + delay;
    object.current_time = 0;
    object.place_in_table = -1;


    --object has a function for it to be able to be called while in game loop
    function object:func()

        
        object.current_time = os.clock();
        

        --time algo in action
        if(object.current_time > object.stop_time ) then
            if recurring_TRUE_FALSE then
                object.stop_time = os.clock() + delay;
                
                if args ~= nil then
                    function_f(args);
                else
                    function_f();
                end
            else
                table.remove(sync_funcs, object.place_in_table);
                if args ~= nil then
                    function_f(args);
                else
                    function_f();
                end

            end
        end
        
    
        
    end
    
    table.insert (sync_funcs, object)

    return object;
end


function my_function(i_will_accept_table_of_inputs_which_i_will_break_down)
    
    --assign values on here, basically insted of having them as params you make them local here and extract from table
    local var1 = i_will_accept_table_of_inputs_which_i_will_break_down[1]
    local var2 = i_will_accept_table_of_inputs_which_i_will_break_down[2]
    local var3 = i_will_accept_table_of_inputs_which_i_will_break_down[3]
    local myhero = i_will_accept_table_of_inputs_which_i_will_break_down[4]
    Ability.CastNoTarget( NPC.GetAbility(myhero, "axe_berserkers_call"), false)


    Console.Print(var1 .. " " .. var2 .. " " .. var3)

end

myhero = Heroes.GetLocal()

test_var = "lmao"
test_var2 = "based on var"
test_var3 = 3


new_sync_Task(
    my_function,                       --function to call
    1,                               --delay
    true,                              --recurring
    {test_var, test_var2, test_var3, myhero}   --table of vars
    )

function krane.OnUpdate()
    
    --in the game loop
    for i,j in pairs(sync_funcs) do
        j.place_in_table = i; --get the place in table so it knows to remove itself
        j:func(); -- call the function you want basically

    end


end




return krane;