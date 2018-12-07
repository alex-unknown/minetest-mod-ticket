--[[
	dice Mod [dice3]
	================
	v0.1 by unknown
	Copyright (C) 2017-2018 Alexander K.
	idea: maxx :)
	LGPLv2.1+
	See LICENSE.txt for more information
]]--



local function show_formspec(player)
	minetest.show_formspec(player:get_player_name(), "ticket:write_formspec",
                "size[4.5,3.5]" ..
                "field[1,1;3,1;description;Description;]" ..
				"field[1,2;3,1;id;ID (just enter anything);]" ..
                "button_exit[1.25,2.5;2,1;exit;Save]")
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
	if not fields.id or fields.id == "" or not fields.description or fields.description == "" then 
		minetest.chat_send_player(playerS,"[ticket] Please enter description and id!")
		return false
	end
	local itemstack = player:get_wielded_item()
	if not itemstack or itemstack:is_empty() then return false end
	itemstack:set_name("ticket:ticket")
	local meta = itemstack:get_meta()
	meta:set_string("", fields.id)
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
