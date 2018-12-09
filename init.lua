--[[
	ticket Mod [ticket]
	===================
	v0.1 by unknown
	Copyright (C) 2017-2018 Alexander K.
	idea: maxx :)
	LGPLv2.1+
	See LICENSE.txt for more information
]]--



local mod_storage = minetest.get_mod_storage()

local function del_old_players()
	mod_storage:set_string("d","d")
	local num = 0
	local t = mod_storage:to_table()
	local newt ={fields = {}}
	for description,playerS in pairs(t.fields) do
		if minetest.player_exists(playerS) then
			newt.fields[description] = playerS
		else 
			num = num + 1
		end
	end
	mod_storage:from_table(newt)
	return num
end

minetest.register_chatcommand("ticket_remove_old_players", {
	description = "Delete tickets of old players",
	privs = {debug = true},
	func = function(_,_)
		local num = del_old_players()
		return true,"Successfully removed "..num.." player/s!"
	end,
})

del_old_players()

local function show_formspec(player)
	minetest.show_formspec(player:get_player_name(), "ticket:write_formspec",
                "size[4.5,2.5]" ..
                "field[1,1;3,1;description;Description;]" ..
                "button_exit[1.25,1.5;2,1;exit;Save]")
end

minetest.register_craftitem("ticket:unlabeled_ticket", {
	description = "ticket (rightclick!)",
	stack_max = 999,
	inventory_image = "ticket_unlabeled_ticket.png",
	groups = {},
	on_place = function(_, placer)
		show_formspec(placer)
	end,
	on_secondary_use = function(_, user)
		show_formspec(user)
	end,	
})

minetest.register_craftitem("ticket:ticket", {
	description = "You hacker you!",
	stack_max = 999,
	inventory_image = "ticket_ticket.png",
	groups = {not_in_creative_inventory = 1},
})


minetest.register_on_player_receive_fields(function(player,formname, fields)
	local playerS = player:get_player_name()
    if formname ~= "ticket:write_formspec" then return false end
	if not fields.description or fields.description == "" then 
		minetest.chat_send_player(playerS,"[ticket] Please enter description!")
		return false
	end
	if mod_storage:get_string("do_"..fields.description) ~= "" and
	   mod_storage:get_string("do_"..fields.description) ~= playerS then 
		minetest.chat_send_player(playerS,"[ticket] This description is already taken!")
		return false
	end
	mod_storage:set_string("do_"..fields.description, playerS)
	local itemstack = player:get_wielded_item()
	if not itemstack or itemstack:is_empty() then return false end
	itemstack:set_name("ticket:ticket")
	local meta = itemstack:get_meta()
	meta:set_string("description", fields.description)
	player:set_wielded_item(itemstack)
	minetest.chat_send_player(playerS,"[ticket] Successfully created ticket!")
    return true
end)

minetest.register_craft({
	output = "ticket:unlabeled_ticket 999",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:sign_wall_wood", "default:sign_wall_wood", "default:sign_wall_wood"},
		{"default:paper", "default:paper", "default:paper"}
	}
})
