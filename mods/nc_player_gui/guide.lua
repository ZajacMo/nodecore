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
			"- Aux+drop any item to drop everything.",
			"- Sneak+aux+drop an item to drop all matching items.",
			"- Items picked up try to fit into the current selected slot first.",
			"- Drop and pick up items to rearrange your inventory."
		}
	})

nodecore.register_inventory_tab({
		title = "Crafting",
		content = {
			"Player's Guide: Crafting",
			"",
			"- Crafting is done by building recipes in-world.",
			"- Order and specific face of placement may matter for crafting.",
			"- Larger recipes are usually more symmetrical.",
			"- For larger recipes, the center item is usually placed last.",
			"- Tools used as ingredients must be in very good condition."
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
		title = "Movement",
		content = {
			"Player's Guide: Movement and Navigation",
			"",
			"- To run faster, walk/swim forward or climb/swim upward continuously.",
			"- Hold/repeat right-click on walls/ceilings barehanded to climb.",
			"- Climbing spots also produce very faint light; raise display gamma to see.",
			"- Climbing spots may be climbed once black particles appear.",
			"- Learn to use the stars for long distance navigation.",
			"- Be wary of dark caves/chasms; you are responsible for getting yourself out.",
			"- If it takes more than 5 seconds to dig, you don't have the right tool.",
			"- Nodes dug without the right tool cannot be picked up, only displaced.",
			"- Displaced nodes can be climbed through like climbing spots."
		}
	})

nodecore.register_inventory_tab({
		title = "Tips",
		content = {
			"Player's Guide: Tips and Guidance",
			"",
			"- Do not use F5 debug info; it will mislead you!",
			"- Can't dig trees or grass? Search for sticks in the canopy.",
			"- Ores may be hidden, but revealed by subtle clues in terrain.",
			"- \"Furnaces\" are not a thing; discover smelting with open flames.",
			"- Trouble lighting a fire? Try using longer sticks, more tinder.",
			"- The game is challenging by design, sometimes frustrating. DON'T GIVE UP!",
			"- Hopelessly stuck? Try asking the community chatrooms (About tab)."
		}
	})
