-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_inventory_tab({
		title = "Inventory",
		content = {
			"Player's Guide: Inventory Management",
			"",
			"- There is NO inventory screen.",
			"- Drop items onto ground to create stack nodes. They do not decay.",
			"- Sneak+drop to count out single items from stack.",
			"- Items picked up try to fit into the current selected slot first.",
			"- Crafting is done by building recipes in-world.",
			"- Order and specific face of placement may matter for crafting.",
			"- Some recipes use a 3x3 \"grid\", laid out flat on the ground.",
			"- Larger recipes are usually more symmetrical."
		}
	})

nodecore.register_inventory_tab({
		title = "Pummel",
		content = {
			"Player's Guide: Pummeling Recipes",
			"",
			"- Some recipes require \"pummeling\" a node.",
			"- To pummel, punch a node repeatedly, WITHOUT digging.",
			"- You do not have to punch very fast (about 1 per second).",
			"- Recipes are time-based, punching faster does not speed up.",
			"- Wielded item, target face, and surrounding nodes may matter.",
			"- Stacks may be pummeled, exact item count may matter.",
			"- If a recipe exists, you will see a special particle effect."
		}
	})

nodecore.register_inventory_tab({
		title = "Tips",
		content = {
			"Player's Guide: Tips and Guidance",
			"",
			"- Do not use F5 debug info; it will mislead you!",
			"- Hold/repeat right-click on walls/ceilings barehanded to climb.",
			"- Can't dig trees or grass? Search for sticks in the canopy.",
			"- Ores may be hidden, but revealed by subtle clues in terrain.",
			"- \"Furnaces\" are not a thing; discover smelting with open flames.",
			"- Trouble lighting a fire? Try using longer sticks, more tinder.",
			"- If it takes more than 5 seconds to dig, you don't have the right tool.",
			"- The game is challenging by design, sometimes frustrating. DON'T GIVE UP!"
		}
	})
