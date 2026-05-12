from __future__ import annotations

import json
import math
from dataclasses import dataclass
from typing import Any, Literal, Optional, TYPE_CHECKING

import numpy as np

if TYPE_CHECKING:  # pragma: no cover
    from craftium.craftium_env import CraftiumEnv


Button = Literal["left", "right"]
Direction = Literal["forward", "backward", "left", "right"]

CREATIVE_ITEMS = {
    # --- nc_terrain: Terrain & World ---
    "stone": "nc_terrain:stone",
    "dirt": "nc_terrain:dirt",
    "cobblestone": "nc_terrain:cobble",
    "cobble": "nc_terrain:cobble",
    "sand": "nc_terrain:sand",
    "gravel": "nc_terrain:gravel",
    "grass": "nc_terrain:grass",
    "water": "nc_terrain:water_source",
    "lava": "nc_terrain:lava_source",
    "hard_stone_1": "nc_terrain:hard_stone_1",
    "hard_stone_2": "nc_terrain:hard_stone_2",
    "hard_stone_3": "nc_terrain:hard_stone_3",
    "cloudstone": "nc_terrain:cloudstone",
    "sandstone": "nc_terrain:sandstone",
    "pumwater": "nc_terrain:pumwater",

    # --- nc_tree: Trees & Wood ---
    "log": "nc_tree:log",
    "tree_trunk": "nc_tree:tree",
    "stump": "nc_tree:root",
    "stick": "nc_tree:stick",
    "eggcorn": "nc_tree:eggcorn",
    "humus": "nc_tree:humus",
    "peat": "nc_tree:peat",
    "sapling": "nc_tree:eggcorn",

    # --- nc_flora: Plants & Flora ---
    "leaves": "nc_tree:leaves",
    "apple": "nc_flora:apple",
    "flower": "nc_flora:flower",
    "flower_red": "nc_flora:flower_red",
    "flower_blue": "nc_flora:flower_blue",
    "flower_yellow": "nc_flora:flower_yellow",
    "flower_white": "nc_flora:flower_white",
    "rushes": "nc_flora:rush",
    "rush_dry": "nc_flora:rush_dry",
    "sedge": "nc_flora:sedge",
    "thatch": "nc_flora:thatch",
    "wicker": "nc_flora:wicker",

    # --- nc_woodwork: Woodwork & Tools ---
    "wood": "nc_woodwork:plank",
    "plank": "nc_woodwork:plank",
    "staff": "nc_woodwork:staff",
    "wooden_mallet": "nc_woodwork:tool_mallet",
    "wooden_spade": "nc_woodwork:tool_spade",
    "wooden_hatchet": "nc_woodwork:tool_hatchet",
    "wooden_pick": "nc_woodwork:tool_pick",
    "wood_adze": "nc_woodwork:adze",
    "wood_rake": "nc_woodwork:rake",
    "ladder": "nc_woodwork:ladder",
    "wood_shelf": "nc_woodwork:shelf",
    "sign": "nc_woodwork:sign",

    # --- nc_stonework: Stonework ---
    "brick": "nc_stonework:bricks_stone",
    "bricks_stone": "nc_stonework:bricks_stone",
    "bricks_stone_bonded": "nc_stonework:bricks_stone_bonded",
    "stone_chip": "nc_stonework:chip",
    "stone_adze": "nc_stonework:adze",
    "stone_mallet": "nc_stonework:tool_mallet",
    "stone_spade": "nc_stonework:tool_spade",
    "stone_hatchet": "nc_stonework:tool_hatchet",
    "stone_pick": "nc_stonework:tool_pick",

    # --- nc_lode: Metals & Ores ---
    "coal": "nc_lode:coal",
    "iron": "nc_lode:iron_raw",
    "gold": "nc_lode:gold_raw",
    "diamond": "nc_lode:diamond",
    "lode_stone": "nc_lode:stone",
    "lode_ore": "nc_lode:ore",
    "lode_cobble": "nc_lode:cobble",
    "lode_prill": "nc_lode:prill",
    "lode_block": "nc_lode:block",
    "lode_block_hot": "nc_lode:block_hot",
    "lode_block_annealed": "nc_lode:block_annealed",
    "lode_block_tempered": "nc_lode:block_tempered",
    "lode_bar": "nc_lode:bar",
    "lode_bar_hot": "nc_lode:bar_hot",
    "lode_bar_annealed": "nc_lode:bar_annealed",
    "lode_bar_tempered": "nc_lode:bar_tempered",
    "lode_rod": "nc_lode:rod",
    "lode_rod_hot": "nc_lode:rod_hot",
    "lode_rod_annealed": "nc_lode:rod_annealed",
    "lode_rod_tempered": "nc_lode:rod_tempered",
    "anvil": "nc_lode:anvil",
    "lode_form": "nc_lode:form",
    "lode_shelf": "nc_lode:shelf",
    "lode_ladder": "nc_lode:ladder",
    "lode_frame": "nc_lode:frame",
    "lode_tongs": "nc_lode:tongs",
    "lode_adze": "nc_lode:adze",
    "lode_rake": "nc_lode:rake",
    "lode_toolhead_mallet": "nc_lode:toolhead_mallet",
    "lode_toolhead_spade": "nc_lode:toolhead_spade",
    "lode_toolhead_hatchet": "nc_lode:toolhead_hatchet",
    "lode_toolhead_pick": "nc_lode:toolhead_pick",
    "lode_mallet": "nc_lode:tool_mallet",
    "lode_spade": "nc_lode:tool_spade",
    "lode_hatchet": "nc_lode:tool_hatchet",
    "lode_pick": "nc_lode:tool_pick",

    # --- nc_torch: Light ---
    "torch": "nc_torch:torch",
    "torch_lit": "nc_torch:torch_lit",

    # --- nc_optics: Glass & Optics ---
    "glass": "nc_optics:glass",
    "glass_crude": "nc_optics:glass_crude",
    "lens": "nc_optics:lens",
    "prism": "nc_optics:prism",

    # --- nc_fire: Fire & Fuel ---
    "ash": "nc_fire:lump_ash",
    "coal_lump": "nc_fire:lump_coal",
    "ember": "nc_fire:ember",

    # --- nc_sponge: Sponge ---
    "sponge": "nc_sponge:sponge",
    "sponge_living": "nc_sponge:sponge_living",
    "sponge_wet": "nc_sponge:sponge_wet",

    # --- nc_items: General Items ---
    "stack": "nc_items:stack",
    "book": "nc_items:book",
    "paper": "nc_items:paper",

    # --- nc_concrete: Concrete ---
    "concrete": "nc_concrete:concrete",

    # --- nc_lantern: Lantern ---
    "lantern": "nc_lantern:lantern",

    # --- nc_lux: Lux Crystal ---
    "lux_crystal": "nc_lux:crystal",

    # --- nc_tote: Tote (Portable Storage) ---
    "tote": "nc_tote:tote",
}


def get_creative_item_name(description: str) -> Optional[str]:
    """
    Get item name from a description like 'stone', 'dirt', 'diamond sword'.
    Returns the canonical item name (e.g., 'nc_terrain:stone') or None if not found.
    """
    desc_lower = description.lower().strip()
    if desc_lower in CREATIVE_ITEMS:
        return CREATIVE_ITEMS[desc_lower]
    for key, item_name in CREATIVE_ITEMS.items():
        if key in desc_lower or desc_lower in key:
            return item_name
    return None


@dataclass
class StepResult:
    observation: Any
    reward: float
    terminated: bool
    truncated: bool
    info: dict[str, Any]


class NodeCoreLLMApi:
    """
    High-level, LLM-friendly API built on top of NodeCore's low-level (keyboard + mouse) action space.

    Important constraint:
    - NodeCore's default external control channel is *input simulation* (keys/mouse), not direct node/meta APIs.
      So operations like crafting or machine interaction must be performed via UI interaction
      (open formspec, move mouse, click), and reliability depends on the game's UI/layout and camera state.
    """

    def __init__(self, env: "CraftiumEnv"):
        self.env = env
        self.last_obs: Any | None = None
        self.last_info: dict[str, Any] | None = None

    # -----------------------------
    # Core stepping helpers
    # -----------------------------
    def reset(self, **kwargs) -> tuple[Any, dict[str, Any]]:
        obs, info = self.env.reset(**kwargs)
        self.last_obs = obs
        self.last_info = info
        return obs, info

    def step(self, action: dict[str, Any]) -> StepResult:
        obs, reward, terminated, truncated, info = self.env.step(action)
        self.last_obs = obs
        self.last_info = info
        return StepResult(obs, float(reward), bool(terminated), bool(truncated), info)

    def wait(self, steps: int = 1) -> StepResult:
        """Advance time without input (NOP)."""
        res: StepResult | None = None
        for _ in range(max(1, int(steps))):
            res = self.step({})
            if res.terminated or res.truncated:
                break
        assert res is not None
        return res

    def key(self, name: str, pressed: bool = True, *, steps: int = 1) -> StepResult:
        """Press/hold a single discrete action key for N steps."""
        action: dict[str, Any] = {name: 1 if pressed else 0, "mouse": np.array([0.0, 0.0], dtype=np.float32)}
        res: StepResult | None = None
        for _ in range(max(1, int(steps))):
            res = self.step(action)
            if res.terminated or res.truncated:
                break
        assert res is not None
        return res

    def mouse(self, dx: float, dy: float, *, steps: int = 1) -> StepResult:
        """
        Move the mouse by normalized deltas in [-1, 1].

        In NodeCore, the normalized deltas are scaled internally to roughly half the screen size.
        """
        dx = float(np.clip(dx, -1.0, 1.0))
        dy = float(np.clip(dy, -1.0, 1.0))
        action = {"mouse": np.array([dx, dy], dtype=np.float32)}
        res: StepResult | None = None
        for _ in range(max(1, int(steps))):
            res = self.step(action)
            if res.terminated or res.truncated:
                break
        assert res is not None
        return res

    # -----------------------------
    # Common "Minecraft-like" ops
    # -----------------------------
    def move(self, direction: Direction, *, steps: int = 5) -> StepResult:
        """Move in the specified direction for N steps."""
        return self.key(direction, True, steps=steps)

    def jump(self, *, steps: int = 1) -> StepResult:
        return self.key("jump", True, steps=steps)

    def sneak(self, *, steps: int = 1) -> StepResult:
        return self.key("sneak", True, steps=steps)

    def dig(self, *, steps: int = 1) -> StepResult:
        """Left-click (dig / attack / UI click)."""
        return self.key("dig", True, steps=steps)

    def place_or_use(self, *, steps: int = 1) -> StepResult:
        """Right-click (place / use / UI click)."""
        return self.key("place", True, steps=steps)

    def drop(self, *, steps: int = 1) -> StepResult:
        return self.key("drop", True, steps=steps)

    def open_inventory(self, *, steps: int = 1) -> StepResult:
        return self.key("inventory", True, steps=steps)

    def select_hotbar_slot(self, slot: int, *, steps: int = 1) -> StepResult:
        """
        Select hotbar slot 1-9.
        """
        if slot < 1 or slot > 9:
            raise ValueError("slot must be in [1, 9]")
        return self.key(f"slot_{slot}", True, steps=steps)

    # -----------------------------
    # UI helpers (for crafting & machine interaction)
    # -----------------------------
    def ui_click(self, button: Button = "left", *, steps: int = 1) -> StepResult:
        """
        Click in the UI at the current cursor position.

        Note:
        - There is no absolute cursor positioning in the exposed action space; use `mouse(dx, dy, ...)`
          to move relative before clicking.
        """
        if button == "left":
            return self.dig(steps=steps)
        if button == "right":
            return self.place_or_use(steps=steps)
        raise ValueError("button must be 'left' or 'right'")

    def ui_drag(
        self,
        dx: float,
        dy: float,
        *,
        button: Button = "left",
        hold_steps: int = 1,
        move_steps: int = 1,
        release_steps: int = 1,
    ) -> StepResult:
        """
        Best-effort UI drag: click-hold, move, release.
        """
        # press+hold
        if button == "left":
            res = self.dig(steps=max(1, int(hold_steps)))
        else:
            res = self.place_or_use(steps=max(1, int(hold_steps)))
        if res.terminated or res.truncated:
            return res

        # move while holding (NodeCore doesn't expose "button held", so we approximate by alternating)
        res = self.mouse(dx, dy, steps=max(1, int(move_steps)))
        if res.terminated or res.truncated:
            return res

        # release = NOP steps
        return self.wait(steps=max(1, int(release_steps)))

    def ui_pick_and_place(
        self,
        dx: float,
        dy: float,
        *,
        button: Button = "left",
        pickup_steps: int = 1,
        move_steps: int = 1,
        place_steps: int = 1,
        settle_steps: int = 1,
    ) -> StepResult:
        """
        UI helper for inventory/formspec interaction:
        pick item at current cursor, move relatively, then place item.

        This is useful for NodeCore formspec operations such as putting a stack
        into a machine slot from inventory.
        """
        res = self.ui_click(button=button, steps=max(1, int(pickup_steps)))
        if res.terminated or res.truncated:
            return res

        res = self.mouse(dx, dy, steps=max(1, int(move_steps)))
        if res.terminated or res.truncated:
            return res

        res = self.ui_click(button=button, steps=max(1, int(place_steps)))
        if res.terminated or res.truncated:
            return res

        return self.wait(steps=max(1, int(settle_steps)))

    def inventory_to_hotbar(
        self,
        inventory_dx: float,
        inventory_dy: float,
        hotbar_dx: float,
        hotbar_dy: float,
        *,
        steps: int = 1
    ) -> StepResult:
        """
        Move an item from inventory to hotbar.

        Args:
            inventory_dx: Mouse delta to move from center to inventory item
            inventory_dy: Mouse delta to move from center to inventory item
            hotbar_dx: Mouse delta to move from inventory item to hotbar slot
            hotbar_dy: Mouse delta to move from inventory item to hotbar slot
            steps: Number of steps for each action
        """
        # Open inventory
        res = self.open_inventory(steps=steps)
        if res.terminated or res.truncated:
            return res

        # Wait for inventory to open
        res = self.wait(steps=steps * 2)
        if res.terminated or res.truncated:
            return res

        # Move to inventory item
        res = self.mouse(inventory_dx, inventory_dy, steps=steps)
        if res.terminated or res.truncated:
            return res

        # Click to pick up item
        res = self.dig(steps=steps)
        if res.terminated or res.truncated:
            return res

        # Move to hotbar slot
        res = self.mouse(hotbar_dx, hotbar_dy, steps=steps)
        if res.terminated or res.truncated:
            return res

        # Click to place item
        res = self.dig(steps=steps)
        if res.terminated or res.truncated:
            return res

        # Close inventory
        res = self.open_inventory(steps=steps)
        if res.terminated or res.truncated:
            return res

        return self.wait(steps=steps)

    def give_item(self, item_name: str, count: int = 1, hotbar_slot: int = 1) -> StepResult:
        """
        Give an item to the player by name and place it in the hotbar.

        Args:
            item_name: The name of the item to give (e.g., "nc_terrain:dirt")
            count: The number of items to give
            hotbar_slot: The hotbar slot to place the item (1-9)
        """
        # Call the give_item method on the environment
        self.env.give_item(item_name, count, hotbar_slot)

        # Wait a bit for the item to be given
        res = self.wait(steps=2)
        if res.terminated or res.truncated:
            return res

        # Select the hotbar slot
        if hotbar_slot >= 1 and hotbar_slot <= 9:
            res = self.select_hotbar_slot(hotbar_slot)
            if res.terminated or res.truncated:
                return res

        return self.wait(steps=2)

    def pick_creative(self, item_name: str, count: int = 1, hotbar_slot: int = 1, *, steps: int = 5) -> StepResult:
        """
        Pick an item from creative inventory and place it in the hotbar.

        Args:
            item_name: The name of the item to pick (e.g., "nc_terrain:stone")
            count: The number of items to pick
            hotbar_slot: The hotbar slot to place the item (1-9)
            steps: Number of wait steps
        """
        self.env.pick_creative(item_name, count, hotbar_slot)
        return self.wait(steps=steps)

    def node_give(self, pos: tuple, item_name: str, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Give items directly to a node's inventory (without opening GUI).

        This is useful for:
        - Adding items to storage nodes (chests, mass storage, etc.)
        - Filling up storage without GUI interaction
        - Simulating placing items into containers

        Args:
            pos: Tuple (x, y, z) - the position of the node
            item_name: The name of the item to add (e.g., "nc_terrain:stone")
            count: The number of items to add
            steps: Number of wait steps

        Returns:
            StepResult indicating success or failure

        Example:
            # Give 64 stone to a chest at position (0, 5, 0)
            api.node_give((0, 5, 0), "nc_terrain:stone", 64)

            # Give 10 dirt to a mass storage at player's feet
            api.node_give((player_x, player_y-1, player_z), "nc_terrain:dirt", 10)
        """
        success = self.env.node_give(pos, item_name, count)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to give item to node. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def open_formspec(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Open a node's formspec (GUI) for viewing inventory.

        Use this after node_give to view the contents of a storage node.

        Args:
            pos: Tuple (x, y, z) - the position of the node
            steps: Number of wait steps

        Returns:
            StepResult indicating success or failure

        Example:
            # Open a mass storage GUI at position (0, 5, 0)
            api.open_formspec((0, 5, 0))
        """
        success = self.env.open_formspec(pos)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to open formspec. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def node_give_filter(self, pos: tuple, item_name: str, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Give items directly to filter inventory of a Mass Storage.

        This is useful for setting up filter items without needing to manually
        interact with the GUI.

        Args:
            pos: Tuple (x, y, z) - the position of the Mass Storage
            item_name: The name of the item to add (e.g., "nc_terrain:stone")
            count: The number of filter slots to fill with this item type
            steps: Number of wait steps

        Returns:
            StepResult indicating success or failure

        Example:
            # Add stone to the first 3 filter slots
            api.node_give_filter((0, 5, 0), "nc_terrain:stone", 3)
        """
        success = self.env.node_give_filter(pos, item_name, count)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to give item to filter. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def get_node_info(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Get information about a node's inventory.

        Args:
            pos: Tuple (x, y, z) - the position of the node
            steps: Number of wait steps

        Returns:
            StepResult with node inventory info

        Example:
            # Get info about a mass storage at player's feet
            api.get_node_info((player_x, player_y-1, player_z))
        """
        success = self.env.get_node_info(pos)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to get node info. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def get_pointed_node(self, *, steps: int = 5) -> StepResult:
        """
        Get the node the player's crosshair is currently pointing at.

        Uses raycast from player's eye position to detect the pointed node.

        Returns:
            StepResult with info containing {"pointed": {x, y, z, name}} or {"pointed": null}

        Example:
            result = api.get_pointed_node()
            if result.info.get("pointed"):
                pos = result.info["pointed"]
                print(f"Looking at {pos['name']} at ({pos['x']}, {pos['y']}, {pos['z']})")
        """
        self.env.get_pointed_node()
        return self.wait(steps=steps)

    def find_chest(self, radius: int = 3, *, steps: int = 5) -> StepResult:
        """
        Find the nearest chest near the player.

        This uses /find_chest command to scan nearby blocks for chests.
        The position will be logged and can be used with open_formspec.

        Args:
            radius: Scan radius (default 3, max 10)
            steps: Number of wait steps

        Returns:
            StepResult with chest position info

        Example:
            # Find nearby chest
            result = api.find_chest()
            if "chest_pos" in result.info:
                chest_pos = result.info["chest_pos"]
                api.open_formspec(chest_pos)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.send_chat_message(f"/find_chest {radius}")
        return self.wait(steps=steps)

    def pick_item(self, description: str, count: int = 1, hotbar_slot: int = 1) -> StepResult:
        """
        Pick an item from creative inventory using a description (e.g., 'stone', 'dirt').
        This is an LLM-friendly wrapper around pick_creative.

        Args:
            description: Human-readable item description (e.g., 'stone', 'diamond')
            count: The number of items to pick
            hotbar_slot: The hotbar slot to place the item (1-9)

        Returns:
            StepResult with error info if item not found
        """
        item_name = get_creative_item_name(description)
        if item_name is None:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": f"Item not found: {description}. Available items: {list(CREATIVE_ITEMS.keys())}"},
            )
        return self.pick_creative(item_name, count, hotbar_slot)

    def move_to_wield(self, slot: int, *, steps: int = 1) -> StepResult:
        """
        Move an item from inventory slot to the wield slot (current hotbar slot).

        Args:
            slot: The inventory slot to move from (1-25)
            steps: Number of steps to wait after moving
        """
        self.env.move_to_wield(slot)
        return self.wait(steps=max(1, int(steps)))

    def place_at(self, x: float, y: float, z: float, *, steps: int = 1) -> StepResult:
        """
        Place the currently wielded item at the specified position.

        Args:
            x: X coordinate of the position
            y: Y coordinate of the position
            z: Z coordinate of the position
            steps: Number of steps to wait after placing
        """
        self.env.place_at({"x": x, "y": y, "z": z})
        return self.wait(steps=max(1, int(steps)))

    def node_place(self, pos: tuple, node_name: str, *, steps: int = 5) -> StepResult:
        """
        Directly place a node at the specified position (no player item needed).

        This is useful for replaying player actions where the exact placement
        position is known but the player may not be in the right position.

        Args:
            pos: Tuple (x, y, z) - the position to place the node
            node_name: The name of the node to place (e.g., "nc_terrain:stone", "nc_items:stack")
            steps: Number of steps to wait after placing

        Returns:
            StepResult indicating success or failure

        Example:
            # Place a stone block at position (0, 5, 0)
            api.node_place((0, 5, 0), "nc_terrain:stone")

            # Place a storage node at position (-242, 3, 287)
            api.node_place((-242, 3, 287), "nc_items:stack")
        """
        success = self.env.node_place(pos, node_name)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to place node. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def chest_give(self, pos: tuple, item_name: str, count: int = 1, slot: int = None, *, steps: int = 5) -> StepResult:
        """
        Give items directly to a chest inventory (no need to hold item).

        This is useful for placing items into chests without the player needing
        to have the item in their hand.

        Args:
            pos: Tuple (x, y, z) - the position of the chest
            item_name: The item name to give (e.g., "nc_terrain:stone")
            count: The number of items to give (default 1)
            slot: Optional slot index (1-based) to put item in. If not specified,
                  item goes to first available slot via add_item.
            steps: Number of steps to wait after giving

        Returns:
            StepResult indicating success or failure

        Example:
            # Give 64 stone to chest at position (0, 3, 0)
            api.chest_give((0, 3, 0), "nc_terrain:stone", 64)

            # Give 64 stone to chest slot 2
            api.chest_give((0, 3, 0), "nc_terrain:stone", 64, slot=2)
        """
        if slot is not None:
            self.env.chest_give_to_slot(pos[0], pos[1], pos[2], item_name, count, slot)
        else:
            self.env.chest_give(pos, item_name, count)
        return self.wait(steps=steps)

    def container_give(self, pos: tuple, item_name: str, count: int = 1, listname: str = "main", slot: int = None, *, steps: int = 5) -> StepResult:
        """
        Give items to any container with inventory (no chest name restriction).

        This works with Luanti default chest, NodeCore storage nodes,
        and any other node with an inventory.

        Args:
            pos: Tuple (x, y, z) - the position of the container
            item_name: The item name to give (e.g., "nc_terrain:stone")
            count: The number of items to give (default 1)
            listname: Inventory list name (e.g., "main", "storage", "filter"). Default: "main"
            slot: Optional slot index (1-based). If not specified, auto-finds empty slot.
            steps: Number of steps to wait after giving

        Returns:
            StepResult indicating success or failure

        Example:
            # Give 64 stone to chest at position (0, 3, 0) - auto slot
            api.container_give((0, 3, 0), "nc_terrain:stone", 64)

            # Give 64 stone to storage list slot 2
            api.container_give((0, 5, 0), "nc_terrain:stone", 64, "storage", 2)

            # Give 10 stone to filter list slot 1
            api.container_give((0, 5, 0), "nc_terrain:stone", 10, "filter", 1)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.container_give(pos, item_name, count, listname, slot)
        return self.wait(steps=steps)

    def container_set_slot(self, pos: tuple, listname: str, index: int, item_name: str, count: int, *, steps: int = 5) -> StepResult:
        """
        Set a specific container slot to an item (overwrites existing item).

        This works with any node that has an inventory.

        Args:
            pos: Tuple (x, y, z) - the position of the container
            listname: Inventory list name (e.g., "main", "storage", "filter")
            index: Slot index (1-based)
            item_name: The item name (e.g., "nc_terrain:stone")
            count: The number of items
            steps: Number of steps to wait after setting

        Returns:
            StepResult indicating success or failure

        Example:
            # Set storage main slot 1 to 64 stone
            api.container_set_slot((0, 5, 0), "main", 1, "nc_terrain:stone", 64)

            # Set filter slot 1 to 5 stone
            api.container_set_slot((0, 5, 0), "filter", 1, "nc_terrain:stone", 5)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.container_set_slot(pos, listname, index, item_name, count)
        return self.wait(steps=steps)

    def container_get_info(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Get container inventory info and print to terminal.

        This prints the container's inventory lists and their contents
        in a parseable format to stdout/stderr.

        Args:
            pos: Tuple (x, y, z) - the position of the container
            steps: Number of steps to wait after command

        Returns:
            StepResult

        Example:
            # Get storage inventory info
            result = api.container_get_info((0, 5, 0))
        """
        self.env.container_get_info(pos)
        return self.wait(steps=steps)

    def container_list_names(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Get container's supported inventory list names.

        This queries the container to find out what inventory lists it supports,
        useful for storage nodes which have filter, storage, main lists.

        Args:
            pos: Tuple (x, y, z) - the position of the container
            steps: Number of steps to wait after command

        Returns:
            StepResult

        Example:
            # Get storage's list names
            result = api.container_list_names((0, 5, 0))
            # Then use read_container_result() to get the actual list info
        """
        self.env.container_list_names(pos)
        return self.wait(steps=steps)

    def scan_network(self, radius: int = 5, *, steps: int = 5) -> StepResult:
        """
        Scan for network nodes around the player.

        This scans an area around the player and returns information about all
        machines and cables found within the radius.

        Args:
            radius: Scan radius in blocks (1-50), default 5
            steps: Number of steps to wait after command

        Returns:
            StepResult

        The result is written to a file that can be read with read_container_result().
        Format: NETWORK_SCAN|radius=5|center=0,5,0|count=3|type:x,y,z;type:x,y,z;...

        Example:
            # Scan 10 blocks around the player
            api.scan_network(10)
            result = api.read_container_result()
        """
        self.env.mt_chann.scan_network(radius)
        return self.wait(steps=steps)

    def parse_network_scan(self, result: tuple) -> dict:
        """
        Parse the result of a network scan into structured data.

        Args:
            result: Tuple from read_container_result() after scan_network()

        Returns:
            dict with keys: radius, center, count, nodes (list of dicts with type, pos)

        Example:
            api.scan_network(5)
            result = api.read_container_result()
            data = api.parse_network_scan(result)
            print(f"Found {data['count']} nodes")
            for node in data['nodes']:
                print(f"  {node['type']} at {node['pos']}")
        """
        if not result or len(result) < 3:
            return None

        result_type, pos_str, data = result
        if result_type != "NETWORK_SCAN":
            return None

        info = {}
        nodes = []

        # Parse key=value pairs from data
        for part in data.split("|"):
            if "=" in part:
                key, value = part.split("=", 1)
                info[key] = value

        # Parse nodes
        if "nodes" in info:
            for node_str in info["nodes"].split(";"):
                if not node_str:
                    continue
                parts = node_str.split(":")
                if len(parts) >= 2:
                    node_type = parts[0]
                    pos_parts = parts[1].split(",")
                    if len(pos_parts) == 3:
                        nodes.append({
                            "type": node_type,
                            "pos": (int(pos_parts[0]), int(pos_parts[1]), int(pos_parts[2]))
                        })

        return {
            "radius": int(info.get("radius", 0)),
            "center": info.get("center", ""),
            "count": int(info.get("count", 0)),
            "nodes": nodes
        }

    def read_container_result(self) -> tuple:
        """
        Read the result of the last container operation.

        This reads the result file written by the Lua mod after
        container_give or container_get_info commands.

        Returns:
            tuple: (result_type, pos_str, data) e.g. ("INFO", "-4,6,-12", "nc_items:stack main:nc_terrain:stone:10:s1")
            or None if no result available

        Example:
            result = api.read_container_result()
            if result:
                print(f"Type: {result[0]}, Pos: {result[1]}, Data: {result[2]}")
        """
        return self.env.read_container_result()

    def insert_to_storage(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Insert the currently held item into a storage node.

        This function requires the player to be holding an item. The item will be
        transferred from the player's hand to the storage node at the specified position.

        Args:
            pos: Tuple (x, y, z) - the position of the storage node
            steps: Number of steps to wait after inserting

        Returns:
            StepResult indicating success or failure

        Example:
            # First get an item to the player's hand
            api.pick_creative("nc_terrain:stone", count=64, hotbar_slot=1)

            # Place a storage node
            api.node_place((0, 5, 0), "nc_items:stack")

            # Insert the held item into the storage
            api.insert_to_storage((0, 5, 0))
        """
        success = self.env.insert_to_storage(pos)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to insert to storage. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def insert_to_filter(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Insert the currently held item into the filter slot of a Mass Storage.

        This function requires the player to be holding an item. The item will be
        transferred from the player's hand to the filter slot at the specified position.

        Args:
            pos: Tuple (x, y, z) - the position of the storage node
            steps: Number of steps to wait after inserting

        Returns:
            StepResult indicating success or failure

        Example:
            # First get an item to the player's hand
            api.pick_creative("nc_terrain:stone", count=64, hotbar_slot=1)

            # Insert the held item into the filter slot
            api.insert_to_filter((0, 5, 0))
        """
        success = self.env.insert_to_filter(pos)
        if not success:
            return StepResult(
                observation=self.last_obs,
                reward=-1.0,
                terminated=False,
                truncated=False,
                info={"error": "Failed to insert to filter. MT channel may not be open."},
            )
        return self.wait(steps=steps)

    def move_to_node(self, from_list: str, from_index: int, pos: tuple, to_list: str, to_index: int, count: int, *, steps: int = 5) -> StepResult:
        """
        Move item from player inventory to node inventory (IMoveAction simulation).

        This simulates the action of dragging items from the player's inventory
        to a container node in the game, WITHOUT using GUI interactions.
        It directly sends the move command to the server.

        This is useful for:
        - Moving items from hotbar to storage containers
        - Transferring items between inventories
        - Automating item management tasks

        Args:
            from_list: Source inventory list name (e.g., "main", "wield")
            from_index: Source slot index (1-based)
            pos: Tuple (x, y, z) - the position of the target node
            to_list: Destination inventory list name in the node (e.g., "main", "storage", "input")
            to_index: Destination slot index in the node (1-based)
            count: Number of items to move
            steps: Number of steps to wait after moving

        Returns:
            StepResult indicating success or failure

        Example:
            # Move 64 stones from hotbar slot 1 to storage input slot
            api.move_to_node("main", 1, (-250, 4, 288), "main", 1, 64)

            # Move items from player inventory to chest
            api.move_to_node("main", 2, (0, 5, 0), "main", 1, 32)

        Note:
            - The player does NOT need to be looking at or interacting with the node
            - This bypasses the GUI entirely
            - The node must exist at the specified position
        """
        self.env.move_to_node(from_list, from_index, pos, to_list, to_index, count)
        return self.wait(steps=steps)

    def punch_node(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Punch a node to trigger on_punch callback.

        For storage nodes, this will auto-insert the player's wielded item into storage.
        This is useful when you want to insert items without opening the GUI.

        Args:
            pos: Tuple (x, y, z) - the position of the node to punch
            steps: Number of steps to wait after punching

        Returns:
            StepResult indicating success or failure

        Example:
            # Get stone to hand first
            api.pick_creative("nc_terrain:stone", count=64, hotbar_slot=1)
            api.select_hotbar_slot(1)

            # Place storage node
            api.node_place((0, 5, 0), "nc_items:stack")

            # Punch the storage to auto-insert stone
            api.punch_node((0, 5, 0))

        Note:
            - The player must be holding an item to insert
            - The player does NOT need to be looking at the node
            - This triggers auto-insert mechanism
        """
        self.env.punch_node(pos)
        return self.wait(steps=steps)

    def close_formspec(self, *, steps: int = 5) -> StepResult:
        """
        Close the current formspec (GUI).

        This is used to close storage panel before reopening.
        After closing, you can right-click the node again to reopen the panel.

        Args:
            steps: Number of steps to wait after closing

        Returns:
            StepResult

        Example:
            # Close the current storage panel
            api.close_formspec()
        """
        self.env.close_formspec()
        return self.wait(steps=steps)

    def container_put(self, pos: tuple, listname: str, index: int, item_name: str, count: int, *, steps: int = 5) -> StepResult:
        """
        Put item directly into container slot (bypasses GUI).

        This is a low-level inventory operation that directly modifies the container's
        inventory without requiring the player to open the GUI. This is useful for:
        - Replaying container_put events from recording data
        - Automating item management without GUI interaction
        - Direct inventory manipulation for testing

        Args:
            pos: Tuple (x, y, z) - the position of the container node
            listname: Inventory list name (e.g., "main", "storage", "filter", "input")
            index: Slot index (1-based)
            item_name: Item name to put (e.g., "nc_terrain:stone")
            count: Number of items to put
            steps: Number of steps to wait after operation

        Returns:
            StepResult indicating success or failure

        Example:
            # Put 64 stone into storage main slot 1
            api.container_put((0, 5, 0), "main", 1, "nc_terrain:stone", 64)

            # Put items into filter slot
            api.container_put((-250, 4, 288), "filter", 1, "nc_terrain:stone", 5)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.container_put(pos, listname, index, item_name, count)
        return self.wait(steps=steps)

    def container_take(self, pos: tuple, listname: str, index: int, count: int = 99, *, steps: int = 5) -> StepResult:
        """
        Take item directly from container slot (bypasses GUI).

        This is a low-level inventory operation that directly reads and modifies
        the container's inventory without requiring the player to open the GUI.

        Args:
            pos: Tuple (x, y, z) - the position of the container node
            listname: Inventory list name (e.g., "main", "storage")
            index: Slot index (1-based)
            count: Number of items to take (default: 99 = all)
            steps: Number of steps to wait after operation

        Returns:
            StepResult indicating success or failure

        Example:
            # Take up to 64 items from storage slot 1
            api.container_take((0, 5, 0), "main", 1, 64)

            # Take all items from storage slot
            api.container_take((-250, 4, 288), "storage", 1)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.container_take(pos, listname, index, count)
        return self.wait(steps=steps)

    def container_move(self, pos: tuple, from_list: str, from_index: int, to_list: str, to_index: int, count: int, *, steps: int = 5) -> StepResult:
        """
        Move item within container (bypasses GUI).

        This is a low-level inventory operation that directly moves items between
        slots within a container without requiring the player to open the GUI.

        Args:
            pos: Tuple (x, y, z) - the position of the container node
            from_list: Source inventory list name
            from_index: Source slot index (1-based)
            to_list: Destination inventory list name
            to_index: Destination slot index (1-based)
            count: Number of items to move
            steps: Number of steps to wait after operation

        Returns:
            StepResult indicating success or failure

        Example:
            # Move 64 items from main slot 1 to storage slot 1
            api.container_move((0, 5, 0), "main", 1, "storage", 1, 64)

            # Move items within the same list
            api.container_move((-250, 4, 288), "storage", 1, "storage", 2, 32)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.container_move(pos, from_list, from_index, to_list, to_index, count)
        return self.wait(steps=steps)

    def node_info_log(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Print node inventory info to server log.

        This is useful for debugging - the inventory will be printed to stderr/stdout.

        Args:
            pos: Tuple (x, y, z) - the position of the node
            steps: Number of steps to wait after command

        Returns:
            StepResult

        Example:
            # Print storage inventory to log
            api.node_info_log((2, 6, -12))
        """
        self.env.node_info_log(pos)
        return self.wait(steps=steps)

    def get_node_inv(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Get node inventory as parseable string.

        Args:
            pos: Tuple (x, y, z) - the position of the node
            steps: Number of steps to wait after command

        Returns:
            StepResult

        Example:
            # Get storage inventory
            api.get_node_inv((2, 6, -12))
        """
        self.env.get_node_inv(pos)
        return self.wait(steps=steps)

    def get_hud_info(self, *, steps: int = 1) -> StepResult:
        """
        Get HUD information from the game, including hotbar items and player status.

        Args:
            steps: Number of steps to wait after getting HUD info
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.get_hud_info()
        return self.wait(steps=max(1, int(steps)))

    def print_hud_info(self) -> dict:
        """
        Get and print game HUD information to terminal.

        Print content includes:
        - Player position (x, y, z)
        - View angle (yaw, pitch)

        Returns:
            Dictionary containing HUD information
        """
        info = self.last_info if self.last_info else {}

        pos = info.get("player_pos", (0, 0, 0))
        yaw = info.get("player_yaw", 0)
        pitch = info.get("player_pitch", 0)

        print("\n" + "=" * 50)
        print("  [Game HUD Info]")
        print("=" * 50)
        if isinstance(pos, (list, tuple)) and len(pos) >= 3:
            print("  Position: ({:.2f}, {:.2f}, {:.2f})".format(pos[0], pos[1], pos[2]))
        else:
            print("  Position:", pos)
        print("  View: yaw={:.4f}, pitch={:.4f}".format(yaw, pitch))
        print("=" * 50)

        return info

    # -----------------------------
    # Player Data Replay Methods (based on player_data.jsonl)
    # -----------------------------

    def get_look(self) -> tuple[float, float]:
        """
        Get current view angle (yaw, pitch).

        Returns:
            (yaw, pitch) tuple in radians
        """
        if self.last_info is None:
            return 0.0, 0.0
        yaw = float(self.last_info.get("player_yaw", 0.0))
        pitch = float(self.last_info.get("player_pitch", 0.0))
        return yaw, pitch

    def get_player_position(self) -> dict:
        """
        Get current player position.

        Returns:
            Dictionary containing x, y, z
        """
        if self.last_info is None:
            return {"x": 0.0, "y": 0.0, "z": 0.0}
        pos = self.last_info.get("player_pos", [0.0, 0.0, 0.0])
        if isinstance(pos, (list, np.ndarray)):
            return {
                "x": float(pos[0]),
                "y": float(pos[1]),
                "z": float(pos[2]),
            }
        return {
            "x": float(pos.get("x", 0.0)),
            "y": float(pos.get("y", 0.0)),
            "z": float(pos.get("z", 0.0)),
        }

    def look_to_mouse(self, target_yaw: float, target_pitch: float, *, sensitivity: float = 1.0) -> list[StepResult]:
        """
        Convert target view (yaw, pitch) to mouse movement instruction sequence.

        Args:
            target_yaw: Target yaw angle (radians), 0 = South, clockwise positive
            target_pitch: Target pitch angle (radians), 0 = horizontal, positive=look down
            sensitivity: Mouse sensitivity coefficient, default 1.0

        Returns:
            List of mouse movement StepResults
        """
        results = []
        if self.last_info is None:
            return results

        current_look = self.last_info.get("player_look", {})
        current_yaw = current_look.get("yaw", 0.0)
        current_pitch = current_look.get("pitch", 0.0)

        yaw_diff = target_yaw - current_yaw
        pitch_diff = target_pitch - current_pitch

        while yaw_diff > math.pi:
            yaw_diff -= 2 * math.pi
        while yaw_diff < -math.pi:
            yaw_diff += 2 * math.pi

        max_dx, max_dy = 0.3 * sensitivity, 0.3 * sensitivity

        yaw_steps = math.ceil(abs(yaw_diff) / max_dx) if yaw_diff != 0 else 0
        pitch_steps = math.ceil(abs(pitch_diff) / max_dy) if pitch_diff != 0 else 0
        max_steps = max(yaw_steps, pitch_steps, 1)

        for _ in range(max_steps):
            dx = (yaw_diff / max_steps) if max_steps > 0 else 0
            dy = (pitch_diff / max_steps) if max_steps > 0 else 0
            dx = max(-0.3, min(0.3, dx / sensitivity))
            dy = max(-0.3, min(0.3, dy / sensitivity))
            results.append(self.mouse(dx, dy, steps=1))

        return results

    def position_to_movement(self, from_pos: dict, to_pos: dict) -> list[tuple[str, int]]:
        """
        Calculate movement direction and steps from position change.

        Args:
            from_pos: Start position {"x": float, "y": float, "z": float}
            to_pos: Target position {"x": float, "y": float, "z": float}

        Returns:
            List of movement instructions [(direction, steps), ...]
        """
        dx = round(to_pos["x"] - from_pos["x"])
        dy = round(to_pos["y"] - from_pos["y"])
        dz = round(to_pos["z"] - from_pos["z"])

        movements = []

        horizontal_dist = math.sqrt(dx * dx + dz * dz)

        if horizontal_dist >= 1:
            yaw_from = math.atan2(dx, dz)
            yaw_to = math.atan2(dz, dx) if dx != 0 or dz != 0 else 0
            move_yaw = math.atan2(dz, -dx) if dx != 0 or dz != 0 else 0

            if abs(dx) >= abs(dz):
                if dx > 0:
                    movements.append(("forward", abs(dx)))
                else:
                    movements.append(("backward", abs(dx)))
            else:
                if dz > 0:
                    movements.append(("left", abs(dz)))
                else:
                    movements.append(("right", abs(dz)))

        if dy > 0:
            movements.append(("jump", 1))
        elif dy < 0:
            movements.append(("sneak", 1))

        return movements

    def replay_player_action(self, player_data: dict) -> StepResult:
        """
        Replay a single action from player data record.

        Args:
            player_data: Player data dictionary containing:
                - action_type: Action type (IDLE, PLACE, DIG, USE_ITEM, CHAT, etc.)
                - player_position: Position info
                - player_look: View angle info
                - held_item: Held item
                - hotbar: Hotbar item list
                - node_name, position: PLACE/DIG events have this
                - message: CHAT events have this

        Returns:
            Last StepResult
        """
        action_type = player_data.get("action_type", "IDLE")
        result = self.wait(steps=1)

        if action_type == "IDLE":
            pass

        elif action_type == "PLACE":
            node_name = player_data.get("node_name", "")
            pos = player_data.get("position", {})
            held_item = player_data.get("held_item", "")
            result = self.replay_hotbar_item(held_item)
            result = self.wait(steps=2)

        elif action_type == "DIG":
            result = self.dig(steps=3)
            result = self.wait(steps=2)

        elif action_type == "USE_ITEM":
            result = self.place_or_use(steps=3)
            result = self.wait(steps=2)

        elif action_type == "CHAT":
            message = player_data.get("message", "")
            result = self.chat(message)

        elif action_type == "JOIN":
            result = self.wait(steps=5)

        elif action_type == "LEAVE":
            pass

        return result

    def replay_player_data(self, data_path: str, *, start_elapsed: float = 0, end_elapsed: float = None) -> list[StepResult]:
        """
        Replay player data from JSONL file.

        Args:
            data_path: player_data.jsonl file path
            start_elapsed: Start time (seconds)
            end_elapsed: End time (seconds), None means replay all

        Returns:
            List of all StepResults
        """
        results = []
        last_pos = None
        last_look = None
        last_hotbar = None

        with open(data_path, 'r') as f:
            for line in f:
                try:
                    data = json.loads(line.strip())
                except json:
                    continue

                elapsed = data.get("elapsed", 0)
                if elapsed < start_elapsed:
                    continue
                if end_elapsed is not None and elapsed > end_elapsed:
                    break

                player_pos = data.get("player_position", {})
                player_look = data.get("player_look", {})
                hotbar = data.get("hotbar", [])

                if last_pos is not None and last_look is not None:
                    pos_diff = abs(player_pos.get("x", 0) - last_pos.get("x", 0)) + \
                               abs(player_pos.get("y", 0) - last_pos.get("y", 0)) + \
                               abs(player_pos.get("z", 0) - last_pos.get("z", 0))
                    if pos_diff > 0.5:
                        movements = self.position_to_movement(last_pos, player_pos)
                        for direction, steps in movements:
                            if direction == "jump":
                                results.append(self.jump(steps=steps))
                            elif direction == "sneak":
                                results.append(self.sneak(steps=steps))
                            else:
                                results.append(self.move(direction, steps=steps))

                    yaw_diff = abs(player_look.get("yaw", 0) - last_look.get("yaw", 0))
                    pitch_diff = abs(player_look.get("pitch", 0) - last_look.get("pitch", 0))
                    if yaw_diff > 0.01 or pitch_diff > 0.01:
                        self.look_to_mouse(
                            player_look.get("yaw", 0),
                            player_look.get("pitch", 0)
                        )

                if last_hotbar is not None and hotbar != last_hotbar:
                    for i, item in enumerate(hotbar):
                        if i < len(last_hotbar) and item != last_hotbar[i] and item:
                            results.append(self.select_hotbar_slot(i + 1))

                result = self.replay_player_action(data)
                results.append(result)

                last_pos = player_pos
                last_look = player_look
                last_hotbar = hotbar

        return results

    def replay_hotbar_item(self, item_name: str) -> StepResult:
        """
        Select hotbar slot based on item name.

        Args:
            item_name: Item name (e.g., "nc_terrain:stone")

        Returns:
            StepResult
        """
        if not item_name:
            return self.wait(steps=1)

        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.pick_creative(item_name, 1, 1)
            return self.wait(steps=3)

        return self.wait(steps=1)

    def chat(self, message: str, *, steps: int = 1) -> StepResult:
        """
        Send chat message.

        Args:
            message: Message to send
            steps: Wait steps

        Returns:
            StepResult
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.chat(message)
        return self.wait(steps=max(1, int(steps)))

    def set_look(self, yaw: float, pitch: float, *, steps: int = 1) -> StepResult:
        """
        Directly set player view angle (without mouse movement).

        Uses Minetest Lua API player:set_look_horizontal() and player:set_look_vertical().

        Args:
            yaw: Yaw angle (radians), 0 = South, clockwise positive
            pitch: Pitch angle (radians), 0 = horizontal, positive = look down
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Look west, slightly up
            api.set_look(math.pi / 2, -0.3)

            # Look straight down
            api.set_look(0, math.pi / 2)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.set_look(yaw, pitch)
        return self.wait(steps=max(1, int(steps)))

    def look_at(self, x: float, y: float, z: float, *, dy_deg: float = 0, dx_deg: float = 0, steps: int = 1) -> StepResult:
        """
        Look at specified world coordinate position (auto-calculates yaw/pitch).

        Args:
            x, y, z: World coordinates of target position
            dy_deg: Vertical offset angle (positive=down, negative=up), default 0
            dx_deg: Horizontal offset angle (positive=right, negative=left), default 0
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Look at coordinate (10, 5, -20)
            api.look_at(10, 5, -20)

            # Look at coordinate, offset down 5 degrees, right 5 degrees
            api.look_at(10, 5, -20, dy_deg=5, dx_deg=5)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.look_at(x, y, z, dy_deg=dy_deg, dx_deg=dx_deg)
        return self.wait(steps=max(1, int(steps)))

    def teleport(self, x: float, y: float, z: float, *, steps: int = 1) -> StepResult:
        """
        Instantly move player to specified position.

        Args:
            x, y, z: Target position coordinates
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Teleport to (0, 10, 0)
            api.teleport(0, 10, 0)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.teleport(x, y, z)
        return self.wait(steps=max(1, int(steps)))

    # ==============================
    # Inventory Low-Level Operations (2026-04-17)
    # ==============================

    def inv_set(self, listname: str, index: int, item_name: str, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Directly set inventory slot to specified item (bypasses GUI).

        Args:
            listname: Inventory list name (e.g., "main", "wield")
            index: Slot index (1-based)
            item_name: Item name (e.g., "nc_terrain:stone")
            count: Item count
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Set hotbar slot 1 to 64 stone
            api.inv_set("main", 1, "nc_terrain:stone", 64)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.inv_set(listname, index, item_name, count)
        return self.wait(steps=max(1, int(steps)))

    def inv_remove(self, listname: str, index: int, count: int = 64, *, steps: int = 5) -> StepResult:
        """
        Remove items from inventory slot.

        Args:
            listname: Inventory list name (e.g., "main")
            index: Slot index (1-based)
            count: Number of items to remove
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Remove 10 items from hotbar slot 1
            api.inv_remove("main", 1, 10)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.inv_remove(listname, index, count)
        return self.wait(steps=max(1, int(steps)))

    def inv_take(self, listname: str, index: int, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Take items from inventory slot (will return item info).

        Args:
            listname: Inventory list name (e.g., "main")
            index: Slot index (1-based)
            count: Number of items to take
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Take 5 items from hotbar slot 1
            api.inv_take("main", 1, 5)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.inv_take(listname, index, count)
        return self.wait(steps=max(1, int(steps)))

    def inv_move(self, from_list: str, from_index: int, to_list: str, to_index: int, count: int, *, steps: int = 5) -> StepResult:
        """
        Move items within inventory.

        Args:
            from_list: Source inventory list name
            from_index: Source slot index (1-based)
            to_list: Target inventory list name
            to_index: Target slot index (1-based)
            count: Number of items to move
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Move 10 items from hotbar slot 1 to slot 5
            api.inv_move("main", 1, "main", 5, 10)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.inv_move(from_list, from_index, to_list, to_index, count)
        return self.wait(steps=max(1, int(steps)))

    def inv_info(self, *, steps: int = 5) -> StepResult:
        """
        Get player inventory info (hotbar and wield item).

        Returns:
            StepResult

        Example:
            api.inv_info()
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.inv_info()
        return self.wait(steps=max(1, int(steps)))

    # ==============================
    # Movement & Camera Helpers (2026-04-17)
    # ==============================

    def turn_to(self, target_yaw: float, *, steps: int = 1) -> StepResult:
        """
        Turn player facing to absolute yaw angle.

        Args:
            target_yaw: Target yaw angle (radians), 0 = South, clockwise positive
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Turn to west
            api.turn_to(math.pi / 2)
        """
        current_yaw, _ = self.get_look()
        yaw_diff = target_yaw - current_yaw

        # Normalize to [-pi, pi]
        while yaw_diff > math.pi:
            yaw_diff -= 2 * math.pi
        while yaw_diff < -math.pi:
            yaw_diff += 2 * math.pi

        max_dx = 0.3
        n_steps = max(1, int(abs(yaw_diff) / max_dx))

        for _ in range(n_steps):
            dx = (yaw_diff / n_steps) if n_steps > 0 else 0
            dx = max(-0.3, min(0.3, dx))
            self.mouse(dx, 0.0, steps=1)

        return self.wait(steps=max(1, int(steps)))

    def turn_pitch(self, target_pitch: float, *, steps: int = 1) -> StepResult:
        """
        Adjust player pitch to absolute value.

        Args:
            target_pitch: Target pitch angle (radians), 0 = horizontal, positive = look down
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Look down 30 degrees
            api.turn_pitch(math.radians(30))
        """
        _, current_pitch = self.get_look()
        pitch_diff = target_pitch - current_pitch

        while pitch_diff > math.pi:
            pitch_diff -= 2 * math.pi
        while pitch_diff < -math.pi:
            pitch_diff += 2 * math.pi

        max_dy = 0.3
        n_steps = max(1, int(abs(pitch_diff) / max_dy))

        for _ in range(n_steps):
            dy = (pitch_diff / n_steps) if n_steps > 0 else 0
            dy = max(-0.3, min(0.3, dy))
            self.mouse(0.0, dy, steps=1)

        return self.wait(steps=max(1, int(steps)))

    def face_direction(self, yaw: float, pitch: float, *, steps: int = 1) -> StepResult:
        """
        Set both player yaw and pitch at once (combined helper).

        Args:
            yaw: Target yaw angle (radians)
            pitch: Target pitch angle (radians)
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.face_direction(math.pi / 4, math.radians(-15))
        """
        self.turn_to(yaw, steps=steps)
        return self.turn_pitch(pitch, steps=steps)

    def walk_forward(self, distance: int = 1, *, steps: int = 10) -> StepResult:
        """
        Walk forward specified number of blocks.

        Args:
            distance: Number of blocks to walk
            steps: Wait steps per block

        Returns:
            StepResult

        Example:
            # Walk forward 3 blocks
            api.walk_forward(3)
        """
        return self.move("forward", steps=distance * steps)

    def walk_to(self, x: float, y: float, z: float, *, steps: int = 5) -> StepResult:
        """
        Walk to specified world coordinate position (auto-calculates direction and distance).

        Args:
            x, y, z: Target position coordinates
            steps: Wait steps per step

        Returns:
            StepResult

        Example:
            # Walk to coordinate (10, 5, -20)
            api.walk_to(10, 5, -20)
        """
        current_pos = self.get_player_position()

        dx = round(x - current_pos["x"])
        dy = round(y - current_pos["y"])
        dz = round(z - current_pos["z"])

        horizontal_dist = math.sqrt(dx * dx + dz * dz)

        if horizontal_dist >= 1:
            if abs(dx) >= abs(dz):
                if dx > 0:
                    self.move("forward", steps=abs(dx) * steps)
                else:
                    self.move("backward", steps=abs(dx) * steps)
            else:
                if dz > 0:
                    self.move("left", steps=abs(dz) * steps)
                else:
                    self.move("right", steps=abs(dz) * steps)

        if dy > 0:
            self.jump(steps=steps)
        elif dy < 0:
            self.sneak(steps=steps)

        return self.wait(steps=steps)

    # ==============================
    # Combat & Interaction (2026-04-17)
    # ==============================

    def attack_entity(self, *, steps: int = 5) -> StepResult:
        """
        Left-click attack entity (similar to dig, but semantics for attacking mobs).

        Returns:
            StepResult

        Example:
            api.attack_entity()
        """
        return self.dig(steps=steps)

    def use_item(self, *, steps: int = 5) -> StepResult:
        """
        Right-click use item (same as place_or_use).

        Returns:
            StepResult

        Example:
            api.use_item()
        """
        return self.place_or_use(steps=steps)

    def sprint(self, *, steps: int = 1) -> StepResult:
        """
        Hold sprint key.

        Args:
            steps: Duration steps

        Returns:
            StepResult

        Example:
            api.sprint(steps=30)
        """
        return self.key("aux1", True, steps=steps)

    def drop_item(self, slot: int = None, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Drop items from inventory.

        Args:
            slot: Optional, specify hotbar slot (1-9). If not specified, drops current held item.
            count: Number of items to drop
            steps: Wait steps

        Returns:
            StepResult

        Example:
            # Drop items from hotbar slot 1
            api.drop_item(slot=1, count=10)
        """
        if slot is not None and 1 <= slot <= 9:
            self.select_hotbar_slot(slot, steps=1)
            self.wait(steps=2)
        return self.drop(steps=steps)

    def drop_all(self, *, steps: int = 10) -> StepResult:
        """
        Drop all items from current hand (sneak + drop).

        Args:
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.drop_all()
        """
        self.sneak(steps=1)
        return self.drop(steps=steps)

    # ==============================
    # NodeCore UI Operations (2026-04-18)
    # ==============================

    def nodecore_open_formspec(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Open a NodeCore machine's formspec at the given position.

        Args:
            pos: Tuple (x, y, z) - the position of the NodeCore node
            steps: Number of steps to wait after opening

        Returns:
            StepResult

        Example:
            # Open storage GUI at position (0, 5, 0)
            api.nodecore_open_formspec((0, 5, 0))
        """
        return self.open_formspec(pos, steps=steps)

    def nodecore_close_formspec(self, *, steps: int = 3) -> StepResult:
        """
        Close the currently open NodeCore formspec.

        Args:
            steps: Number of steps to wait after closing

        Returns:
            StepResult

        Example:
            api.nodecore_close_formspec()
        """
        return self.close_formspec(steps=steps)

    # ---- Mass Storage Commands (command-based, no mouse UI) ----

    def mass_storage_set_reserve(self, pos: tuple, slot: int, amount: int, *, steps: int = 5) -> StepResult:
        """
        Set reserve amount for a Mass Storage slot.

        Args:
            pos: Tuple (x, y, z) - Mass Storage position
            slot: Storage slot index (1-8)
            amount: Reserve amount (0 = no reserve)

        Returns:
            StepResult

        Example:
            api.mass_storage_set_reserve((0, 5, 0), 1, 64)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.mass_storage_set_reserve(pos, slot, amount)
        return self.wait(steps=steps)

    def mass_storage_set_front_image(self, pos: tuple, slot: int, *, steps: int = 5) -> StepResult:
        """
        Set which storage slot is displayed as the Mass Storage front image.

        Args:
            pos: Tuple (x, y, z) - Mass Storage position
            slot: Image slot index (1-8), or 0 to disable

        Returns:
            StepResult

        Example:
            api.mass_storage_set_front_image((0, 5, 0), 3)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.mass_storage_set_image_slot(pos, slot)
        return self.wait(steps=steps)

    def mass_storage_insert_item(self, pos: tuple, item: str, count: int = 64, *, steps: int = 5) -> StepResult:
        """
        Insert an item into Mass Storage via the main input slot.

        Args:
            pos: Tuple (x, y, z) - Mass Storage position
            item: Item name (e.g., "nc_terrain:stone")
            count: Number of items to insert

        Returns:
            StepResult

        Example:
            api.mass_storage_insert_item((0, 5, 0), "nc_terrain:stone", 64)
        """
        return self.container_put(pos, "main", 1, item, count, steps=steps)

    def mass_storage_toggle_pull(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Toggle pull-from-network setting in Mass Storage.

        Args:
            pos: Tuple (x, y, z) - Mass Storage position

        Returns:
            StepResult

        Example:
            api.mass_storage_toggle_pull((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_toggle_machine(pos)
        return self.wait(steps=steps)

    # ---- Access Point Commands ----

    def access_point_insert_item(self, pos: tuple, item: str, count: int = 64, *, steps: int = 5) -> StepResult:
        """
        Insert an item into the NodeCore network via Access Point.

        Args:
            pos: Tuple (x, y, z) - Access Point position
            item: Item name (e.g., "nc_terrain:stone")
            count: Number of items to insert

        Returns:
            StepResult

        Example:
            api.access_point_insert_item((0, 5, 0), "nc_terrain:stone", 64)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_insert_to_network(pos, item, count)
        return self.wait(steps=steps)

    # ---- Requester Commands ----

    def requester_set_filter(self, pos: tuple, slot: int, item: str, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Set a request slot in the Requester.

        Args:
            pos: Tuple (x, y, z) - Requester position
            slot: Request slot index (1-4)
            item: Item name to request (e.g., "nc_terrain:stone")
            count: Number of items to request

        Returns:
            StepResult

        Example:
            api.requester_set_filter((0, 5, 0), 1, "nc_terrain:stone", 64)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_set_filter(pos, slot, item, count)
        return self.wait(steps=steps)

    def requester_set_infinite(self, pos: tuple, slot: int, enabled: bool = True, *, steps: int = 5) -> StepResult:
        """
        Set infinite mode for a Requester slot.

        Args:
            pos: Tuple (x, y, z) - Requester position
            slot: Request slot index (1-4)
            enabled: True for infinite mode, False for normal

        Returns:
            StepResult

        Example:
            api.requester_set_infinite((0, 5, 0), 1, True)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_requester_set_infinite(pos, slot, enabled)
        return self.wait(steps=steps)

    def requester_set_target(self, pos: tuple, list_name: str, *, steps: int = 5) -> StepResult:
        """
        Set the target inventory for a Requester.

        Args:
            pos: Tuple (x, y, z) - Requester position
            list_name: Target list name (e.g., "main", "wield")

        Returns:
            StepResult

        Example:
            api.requester_set_target((0, 5, 0), "main")
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_requester_set_target(pos, list_name)
        return self.wait(steps=steps)

    def requester_toggle(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Toggle the Requester on/off.

        Args:
            pos: Tuple (x, y, z) - Requester position

        Returns:
            StepResult

        Example:
            api.requester_toggle((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_toggle_machine(pos)
        return self.wait(steps=steps)

    # ---- Supplier Commands ----

    def supplier_toggle(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Toggle the Supplier on/off.

        Args:
            pos: Tuple (x, y, z) - Supplier position

        Returns:
            StepResult

        Example:
            api.supplier_toggle((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_toggle_machine(pos)
        return self.wait(steps=steps)

    # ---- Injector Commands ----

    def injector_set_filter(self, pos: tuple, slot: int, item: str, count: int = 1, *, steps: int = 5) -> StepResult:
        """
        Set a filter slot in the Injector.

        Args:
            pos: Tuple (x, y, z) - Injector position
            slot: Filter slot index (1-8)
            item: Item name to filter (e.g., "nc_terrain:stone")
            count: Number of items

        Returns:
            StepResult

        Example:
            api.injector_set_filter((0, 5, 0), 1, "nc_terrain:stone", 1)
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_set_filter(pos, slot, item, count)
        return self.wait(steps=steps)

    def injector_toggle(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Toggle the Injector on/off.

        Args:
            pos: Tuple (x, y, z) - Injector position

        Returns:
            StepResult

        Example:
            api.injector_toggle((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_toggle_machine(pos)
        return self.wait(steps=steps)

    def injector_set_put_into(self, pos: tuple, target_type: int, enabled: bool = True, *, steps: int = 5) -> StepResult:
        """
        Set whether the Injector puts items into a target machine type.

        Args:
            pos: Tuple (x, y, z) - Injector position
            target_type: 1=Requesters, 2=Mass/Item Storage, 3=Supply Chests, 4=Trashcans
            enabled: True to put into this type, False to skip

        Returns:
            StepResult

        Example:
            api.injector_set_put_into((0, 5, 0), 1, True)   # put into Requesters
            api.injector_set_put_into((0, 5, 0), 4, False)  # skip Trashcans
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_injector_set_put_into(pos, target_type, enabled)
        return self.wait(steps=steps)

    # ---- Trashcan Commands ----

    def trashcan_set_filter(self, pos: tuple, slot: int, item: str, *, steps: int = 5) -> StepResult:
        """
        Set a filter slot in the Trashcan.

        Args:
            pos: Tuple (x, y, z) - Trashcan position
            slot: Filter slot index (1-8)
            item: Item name to filter (e.g., "nc_terrain:stone")

        Returns:
            StepResult

        Example:
            api.trashcan_set_filter((0, 5, 0), 1, "nc_terrain:stone")
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_set_filter(pos, slot, item, 1)
        return self.wait(steps=steps)

    # ---- Vaccuum Chest Commands ----

    def vaccuum_chest_toggle(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Toggle the Vaccuum Chest on/off.

        Args:
            pos: Tuple (x, y, z) - Vaccuum Chest position

        Returns:
            StepResult

        Example:
            api.vaccuum_chest_toggle((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_toggle_machine(pos)
        return self.wait(steps=steps)

    # ---- Generic Machine Commands ----

    def nodecore_machine_info(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Get detailed info about a NodeCore machine.

        Args:
            pos: Tuple (x, y, z) - Machine position

        Returns:
            StepResult

        Example:
            api.nodecore_machine_info((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.nodecore_machine_info(pos)
        return self.wait(steps=steps)

    # ---- Batch Command ----

    def batch(self, *commands, steps: int = 10) -> StepResult:
        """
        Execute multiple commands at once via /batch command.

        This is useful for setting up test scenarios with multiple commands
        that need to run together.

        Args:
            *commands: Variable number of command strings (without leading /)
                      Commands are separated by semicolons.
            steps: Number of steps to wait after batch execution

        Returns:
            StepResult

        Example:
            # Batch teleport and get items
            api.batch(
                "teleport 0 5 0",
                "pick_creative nc_terrain:stone 64 1",
                "pick_creative nc_items:stack 1 2"
            )
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.batch(*commands)
        return self.wait(steps=steps)

    # ==============================
    # Environment Sensing (2026-05-02)
    # ==============================

    def get_node_at(self, pos: tuple, *, steps: int = 1) -> StepResult:
        """
        Get the node name at a specific position.

        Args:
            pos: Tuple (x, y, z) - the position to query
            steps: Wait steps

        Returns:
            StepResult with node name in info["node_name"]

        Example:
            result = api.get_node_at((0, 5, 0))
            print(result.info.get("node_name"))
        """
        node_name = None
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            node_name = self.env.mt_chann.get_node_at(pos)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"node_name": node_name, "pos": pos},
        )

    def get_node_name(self, pos: tuple) -> str | None:
        """
        Synchronous helper: get node name at position (no step).

        Args:
            pos: Tuple (x, y, z)

        Returns:
            Node name string or None
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            return self.env.mt_chann.get_node_at(pos)
        return None

    def find_nodes_near(self, radius: int = 5, node_name: str = None, *, steps: int = 5) -> StepResult:
        """
        Find nodes of a specific type near the player.

        Args:
            radius: Search radius in blocks
            node_name: Node name to search for (e.g., "nc_terrain:stone"). If None, returns all nodes.
            steps: Wait steps

        Returns:
            StepResult with list of positions in info["positions"]

        Example:
            # Find all stone nodes within 10 blocks
            result = api.find_nodes_near(10, "nc_terrain:stone")
            positions = result.info.get("positions", [])
        """
        positions = []
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            positions = self.env.mt_chann.find_nodes_near(radius, node_name)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"positions": positions or [], "radius": radius, "node_name": node_name},
        )

    def get_ground_level(self, x: float = None, z: float = None, *, steps: int = 1) -> StepResult:
        """
        Find the ground (solid block) Y-level at given X,Z coordinates.

        Args:
            x: X coordinate (default: player current X)
            z: Z coordinate (default: player current Z)
            steps: Wait steps

        Returns:
            StepResult with ground Y in info["ground_y"]

        Example:
            result = api.get_ground_level(10, -20)
            print(f"Ground is at Y={result.info['ground_y']}")
        """
        pos = self.get_player_position()
        x = x if x is not None else pos["x"]
        z = z if z is not None else pos["z"]
        ground_y = None
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            ground_y = self.env.mt_chann.get_ground_level(x, z)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"ground_y": ground_y, "x": x, "z": z},
        )

    def detect_surroundings(self, radius: int = 3, *, steps: int = 5) -> StepResult:
        """
        Scan surroundings and return a summary of nearby nodes.

        Args:
            radius: Scan radius in blocks (1-10)
            steps: Wait steps

        Returns:
            StepResult with info containing:
                - "nodes": dict of {node_name: count}
                - "player_pos": current player position
                - "ground_y": ground level at player position

        Example:
            result = api.detect_surroundings(5)
            nodes = result.info["nodes"]
            for name, count in sorted(nodes.items(), key=lambda x: -x[1])[:5]:
                print(f"  {name}: {count}")
        """
        nodes = {}
        player_pos = self.get_player_position()
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            nodes = self.env.mt_chann.detect_surroundings(radius)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={
                "nodes": nodes or {},
                "player_pos": player_pos,
                "radius": radius,
            },
        )

    def get_pointed_node(self, *, steps: int = 5) -> StepResult:
        """
        Get information about the node the player is currently pointing at.

        Args:
            steps: Wait steps

        Returns:
            StepResult with info containing:
                - "node_name": name of the pointed node
                - "pos": position of the pointed node
                - "under_pos": position under the cursor
                - "above_pos": position above the cursor

        Example:
            result = api.get_pointed_node()
            print(f"Pointing at: {result.info['node_name']} at {result.info['pos']}")
        """
        info = {"node_name": None, "pos": None, "under_pos": None, "above_pos": None}
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            pointed = self.env.mt_chann.get_pointed_node()
            if pointed:
                info = pointed
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info=info,
        )

    # ==============================
    # NodeCore Crafting Helpers (2026-05-02)
    # ==============================

    def pummel(self, pos: tuple, *, steps: int = 10) -> StepResult:
        """
        Pummel a node with the currently held tool (NodeCore crafting mechanic).

        In NodeCore, many crafting recipes are performed by "pummeling" a node
        with a tool. This repeatedly left-clicks the node to trigger crafting.

        Args:
            pos: Tuple (x, y, z) - the position of the node to pummel
            steps: Number of pummel steps (each step is a dig action)

        Returns:
            StepResult

        Example:
            # Pummel a stone to create chips (requires wooden mallet)
            api.pick_creative("nc_woodwork:tool_mallet", count=1, hotbar_slot=1)
            api.pummel((0, 5, 0), steps=15)

            # Pummel a plank to carve a tool head
            api.pick_creative("nc_woodwork:tool_hatchet", count=1, hotbar_slot=1)
            api.pummel((0, 5, 0), steps=10)
        """
        # First look at the node
        self.look_at(pos[0], pos[1], pos[2], steps=2)
        # Then repeatedly dig (pummel)
        for _ in range(steps):
            res = self.dig(steps=1)
            if res.terminated or res.truncated:
                return res
            self.wait(steps=1)
        return self.wait(steps=2)

    def stack_apply(self, pos: tuple, item_name: str = None, *, steps: int = 5) -> StepResult:
        """
        Apply the currently held item (or specified item) to a node by right-clicking.

        In NodeCore, "stack apply" is a crafting mechanic where you apply an item
        to a node (e.g., applying a stone chip to a wooden tool to upgrade it).

        Args:
            pos: Tuple (x, y, z) - the position of the node
            item_name: Optional item to equip before applying. If None, uses current held item.
            steps: Wait steps after applying

        Returns:
            StepResult

        Example:
            # Apply stone chip to wooden mallet to upgrade to stone mallet
            api.pick_creative("nc_stonework:chip", count=1, hotbar_slot=1)
            api.stack_apply((0, 5, 0), "nc_stonework:chip")
        """
        if item_name:
            self.pick_creative(item_name, count=1, hotbar_slot=1)
            self.wait(steps=2)
        self.look_at(pos[0], pos[1], pos[2], steps=2)
        return self.place_or_use(steps=steps)

    def cook_node(self, pos: tuple, *, steps: int = 30) -> StepResult:
        """
        Wait for a node to cook/completion (NodeCore cooking mechanic).

        In NodeCore, cooking happens via ABM when a node is near fire/flame.
        This method waits and periodically checks if the node has changed.

        Args:
            pos: Tuple (x, y, z) - the position of the cooking node
            steps: Max wait steps (default 30 = ~3 seconds)

        Returns:
            StepResult with info["cooked_to"] = new node name or None

        Example:
            # Place wet sponge near fire and wait for it to cook/dry
            api.cook_node((0, 5, 0), steps=60)
        """
        initial_node = self.get_node_name(pos)
        for _ in range(steps):
            current_node = self.get_node_name(pos)
            if current_node != initial_node:
                return StepResult(
                    observation=self.last_obs,
                    reward=1.0,
                    terminated=False,
                    truncated=False,
                    info={"cooked_to": current_node, "from": initial_node, "pos": pos},
                )
            res = self.wait(steps=1)
            if res.terminated or res.truncated:
                return res
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"cooked_to": None, "from": initial_node, "pos": pos, "timeout": True},
        )

    # ==============================
    # Advanced Inventory Management (2026-05-02)
    # ==============================

    def get_hotbar_items(self) -> list[dict]:
        """
        Get the current hotbar items as a list of dicts.

        Returns:
            List of dicts with keys: "slot" (1-9), "name", "count"

        Example:
            items = api.get_hotbar_items()
            for item in items:
                print(f"Slot {item['slot']}: {item['name']} x{item['count']}")
        """
        info = self.last_info if self.last_info else {}
        hotbar = info.get("hotbar", [])
        result = []
        for i, item in enumerate(hotbar, start=1):
            if item and item.get("name"):
                result.append({
                    "slot": i,
                    "name": item.get("name", ""),
                    "count": item.get("count", 1),
                })
            else:
                result.append({"slot": i, "name": "", "count": 0})
        return result

    def find_item_in_inventory(self, item_name: str) -> dict | None:
        """
        Find the first occurrence of an item in the player's hotbar.

        Args:
            item_name: Item name to search for (e.g., "nc_terrain:stone")

        Returns:
            Dict with "slot" and "count" or None if not found

        Example:
            found = api.find_item_in_inventory("nc_terrain:stone")
            if found:
                print(f"Found in slot {found['slot']} x{found['count']}")
        """
        hotbar = self.get_hotbar_items()
        for item in hotbar:
            if item["name"] == item_name:
                return {"slot": item["slot"], "count": item["count"]}
        return None

    def has_item(self, item_name: str, min_count: int = 1) -> bool:
        """
        Check if the player has at least min_count of an item in their hotbar.

        Args:
            item_name: Item name to check
            min_count: Minimum required count (default 1)

        Returns:
            True if player has enough, False otherwise

        Example:
            if api.has_item("nc_terrain:stone", 64):
                print("Player has enough stone")
        """
        total = 0
        hotbar = self.get_hotbar_items()
        for item in hotbar:
            if item["name"] == item_name:
                total += item["count"]
                if total >= min_count:
                    return True
        return False

    def clear_hotbar(self, *, steps: int = 5) -> StepResult:
        """
        Drop all items from the hotbar.

        Args:
            steps: Wait steps after clearing

        Returns:
            StepResult
        """
        for slot in range(1, 10):
            self.select_hotbar_slot(slot, steps=1)
            self.drop_all(steps=2)
        return self.wait(steps=steps)

    def equip_item(self, item_name: str, *, steps: int = 5) -> StepResult:
        """
        Equip a specific item by name, using creative inventory if needed.

        This is a convenience method that:
        1. Checks if the item is already in the hotbar
        2. If found, selects that slot
        3. If not found, uses pick_creative to get it in slot 1

        Args:
            item_name: Item name to equip
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.equip_item("nc_woodwork:tool_pick")
            api.equip_item("nc_stonework:chip")
        """
        found = self.find_item_in_inventory(item_name)
        if found:
            return self.select_hotbar_slot(found["slot"], steps=steps)
        return self.pick_creative(item_name, count=1, hotbar_slot=1, steps=steps)

    # ==============================
    # Advanced Building (2026-05-02)
    # ==============================

    def place_node_looking_at(self, node_name: str = None, *, steps: int = 5) -> StepResult:
        """
        Place the currently held (or specified) node at where the player is looking.

        Args:
            node_name: Optional node name to equip before placing
            steps: Wait steps after placing

        Returns:
            StepResult

        Example:
            api.place_node_looking_at("nc_terrain:stone")
        """
        if node_name:
            self.equip_item(node_name, steps=3)
        return self.place_or_use(steps=steps)

    def dig_node_at(self, pos: tuple, *, steps: int = 10) -> StepResult:
        """
        Dig a node at a specific position by looking at it and digging.

        Args:
            pos: Tuple (x, y, z) - the position to dig
            steps: Number of dig steps

        Returns:
            StepResult

        Example:
            api.dig_node_at((0, 5, 0))
        """
        self.look_at(pos[0], pos[1], pos[2], steps=2)
        for _ in range(steps):
            res = self.dig(steps=1)
            if res.terminated or res.truncated:
                return res
            # Check if node was removed
            current = self.get_node_name(pos)
            if current in ("air", "nc_terrain:air"):
                return StepResult(
                    observation=self.last_obs,
                    reward=1.0,
                    terminated=False,
                    truncated=False,
                    info={"dug": pos, "node": current},
                )
            self.wait(steps=1)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"dug": None, "pos": pos},
        )

    def place_block(self, x: float, y: float, z: float, node_name: str = None, *, steps: int = 5) -> StepResult:
        """
        Place a block at a specific world coordinate.

        This method will:
        1. Look at the target position
        2. Place the node (using currently held item or specified item)

        Args:
            x, y, z: Target coordinates
            node_name: Optional item name to equip
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.place_block(0, 5, 0, "nc_terrain:stone")
        """
        if node_name:
            self.equip_item(node_name, steps=2)
        self.look_at(x, y, z, steps=2)
        return self.place_or_use(steps=steps)

    def build_column(self, pos: tuple, height: int, node_name: str, *, steps: int = 5) -> list[StepResult]:
        """
        Build a vertical column of blocks.

        Args:
            pos: Tuple (x, y, z) - base position
            height: Number of blocks to stack upward
            node_name: Block type to use
            steps: Wait steps per block

        Returns:
            List of StepResults

        Example:
            api.build_column((0, 5, 0), 3, "nc_terrain:stone")
        """
        results = []
        x, y, z = pos
        self.equip_item(node_name, steps=2)
        for i in range(height):
            target_y = y + i
            # Stand next to the target position
            self.teleport(x, target_y - 1, z, steps=1)
            # Place block above
            self.place_block(x, target_y, z, steps=steps)
            results.append(self.wait(steps=steps))
        return results

    def build_floor(self, pos: tuple, width: int, depth: int, node_name: str, *, steps: int = 3) -> list[StepResult]:
        """
        Build a horizontal floor/platform.

        Args:
            pos: Tuple (x, y, z) - corner position
            width: Width in blocks (X direction)
            depth: Depth in blocks (Z direction)
            node_name: Block type to use
            steps: Wait steps per block

        Returns:
            List of StepResults

        Example:
            api.build_floor((0, 5, 0), 3, 3, "nc_woodwork:plank")
        """
        results = []
        x, y, z = pos
        self.equip_item(node_name, steps=2)
        for dx in range(width):
            for dz in range(depth):
                target_pos = (x + dx, y, z + dz)
                self.place_block(target_pos[0], target_pos[1], target_pos[2], steps=steps)
                results.append(self.wait(steps=steps))
        return results

    def build_wall(self, pos: tuple, height: int, length: int, node_name: str, direction: str = "x", *, steps: int = 3) -> list[StepResult]:
        """
        Build a wall.

        Args:
            pos: Tuple (x, y, z) - base corner position
            height: Wall height in blocks
            length: Wall length in blocks
            node_name: Block type to use
            direction: "x" or "z" - direction to build along
            steps: Wait steps per block

        Returns:
            List of StepResults

        Example:
            api.build_wall((0, 5, 0), 2, 3, "nc_terrain:stone", direction="x")
        """
        results = []
        x, y, z = pos
        self.equip_item(node_name, steps=2)
        for dy in range(height):
            for dl in range(length):
                target_x = x + (dl if direction == "x" else 0)
                target_z = z + (dl if direction == "z" else 0)
                target_y = y + dy
                self.place_block(target_x, target_y, target_z, steps=steps)
                results.append(self.wait(steps=steps))
        return results

    # ==============================
    # Utility Helpers (2026-05-02)
    # ==============================

    def get_game_time(self) -> dict:
        """
        Get current game time information.

        Returns:
            Dict with keys:
                - "time_of_day": float 0.0-1.0 (0=dawn, 0.5=noon, 1=dusk)
                - "day_count": integer day count
                - "is_daytime": bool

        Example:
            time = api.get_game_time()
            print(f"Time of day: {time['time_of_day']:.2f}, Day: {time['day_count']}")
        """
        info = self.last_info if self.last_info else {}
        tod = info.get("time_of_day", 0.5)
        day_count = info.get("day_count", 0)
        return {
            "time_of_day": tod,
            "day_count": day_count,
            "is_daytime": 0.2 < tod < 0.8,
        }

    def is_daytime(self) -> bool:
        """
        Check if it's currently daytime in the game.

        Returns:
            True if daytime, False if night

        Example:
            if api.is_daytime():
                print("It's daytime!")
        """
        return self.get_game_time()["is_daytime"]

    def screenshot(self, filename: str = None, *, steps: int = 1) -> StepResult:
        """
        Take a screenshot of the current game view.

        Args:
            filename: Optional filename to save. If None, auto-generated.
            steps: Wait steps

        Returns:
            StepResult with info["screenshot_path"] if available

        Example:
            api.screenshot("my_build.png")
        """
        path = None
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            path = self.env.mt_chann.screenshot(filename)
        return StepResult(
            observation=self.last_obs,
            reward=0.0,
            terminated=False,
            truncated=False,
            info={"screenshot_path": path},
        )

    def get_health(self) -> dict:
        """
        Get player health and breath information.

        Returns:
            Dict with keys: "hp", "breath", "max_hp"

        Example:
            health = api.get_health()
            print(f"HP: {health['hp']}/{health['max_hp']}")
        """
        info = self.last_info if self.last_info else {}
        return {
            "hp": info.get("hp", 20),
            "breath": info.get("breath", 11),
            "max_hp": info.get("max_hp", 20),
        }

    def is_alive(self) -> bool:
        """
        Check if the player is alive (HP > 0).

        Returns:
            True if alive, False if dead
        """
        return self.get_health()["hp"] > 0

    def print_status(self) -> None:
        """
        Print a human-readable summary of player status.

        This is useful for debugging and understanding the current game state.
        """
        pos = self.get_player_position()
        look = self.get_look()
        health = self.get_health()
        hotbar = self.get_hotbar_items()
        time = self.get_game_time()

        print("\n" + "=" * 60)
        print("  [Player Status]")
        print("=" * 60)
        print(f"  Position: ({pos['x']:.2f}, {pos['y']:.2f}, {pos['z']:.2f})")
        print(f"  Look: yaw={look[0]:.4f} ({math.degrees(look[0]):.1f} deg), pitch={look[1]:.4f}")
        print(f"  Health: {health['hp']}/{health['max_hp']}, Breath: {health['breath']}")
        print(f"  Time: {time['time_of_day']:.2f} ({'Day' if time['is_daytime'] else 'Night'})")
        print("  Hotbar:")
        for item in hotbar:
            if item["name"]:
                print(f"    Slot {item['slot']}: {item['name']} x{item['count']}")
        print("=" * 60)

    def set_time_of_day(self, time_of_day: float, *, steps: int = 1) -> StepResult:
        """
        Set the time of day (0.0 = dawn, 0.5 = noon, 1.0 = dusk).

        Args:
            time_of_day: Time value 0.0-1.0
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.set_time_of_day(0.5)  # Set to noon
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.set_time_of_day(time_of_day)
        return self.wait(steps=steps)

    def spawn_entity(self, entity_name: str, pos: tuple = None, *, steps: int = 5) -> StepResult:
        """
        Spawn an entity at a position.

        Args:
            entity_name: Entity name (e.g., "nc_mobs:animal")
            pos: Tuple (x, y, z) or None for player position
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.spawn_entity("nc_mobs:animal", (0, 5, 0))
        """
        if pos is None:
            pos = self.get_player_position()
            pos = (pos["x"], pos["y"], pos["z"])
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.spawn_entity(entity_name, pos)
        return self.wait(steps=steps)

    def clear_area(self, pos: tuple, radius: int = 2, *, steps: int = 5) -> list[StepResult]:
        """
        Clear all non-air nodes in an area around a position.

        Args:
            pos: Center position (x, y, z)
            radius: Radius to clear
            steps: Wait steps per node

        Returns:
            List of StepResults

        Example:
            api.clear_area((0, 5, 0), radius=2)
        """
        results = []
        x, y, z = pos
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            nodes = self.env.mt_chann.get_nodes_in_area(
                (x - radius, y - radius, z - radius),
                (x + radius, y + radius, z + radius)
            )
            for node_pos in nodes:
                node_name = self.get_node_name(node_pos)
                if node_name and node_name not in ("air", "nc_terrain:air", "ignore"):
                    self.dig_node_at(node_pos, steps=steps)
                    results.append(self.wait(steps=steps))
        return results

    def fill_area(self, pos1: tuple, pos2: tuple, node_name: str, *, steps: int = 2) -> list[StepResult]:
        """
        Fill a rectangular area with a specific node type.

        Args:
            pos1: First corner (x, y, z)
            pos2: Second corner (x, y, z)
            node_name: Node name to fill with
            steps: Wait steps per block

        Returns:
            List of StepResults

        Example:
            api.fill_area((0, 5, 0), (2, 7, 2), "nc_terrain:stone")
        """
        results = []
        self.equip_item(node_name, steps=2)
        x1, y1, z1 = pos1
        x2, y2, z2 = pos2
        for x in range(min(x1, x2), max(x1, x2) + 1):
            for y in range(min(y1, y2), max(y1, y2) + 1):
                for z in range(min(z1, z2), max(z1, z2) + 1):
                    self.place_block(x, y, z, steps=steps)
                    results.append(self.wait(steps=steps))
        return results

    def remove_node(self, pos: tuple, *, steps: int = 5) -> StepResult:
        """
        Remove (set to air) a node at a specific position via MT channel.

        This directly removes the node without requiring the player to dig it.

        Args:
            pos: Tuple (x, y, z)
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.remove_node((0, 5, 0))
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.remove_node(pos)
        return self.wait(steps=steps)

    def swap_node(self, pos: tuple, node_name: str, *, steps: int = 5) -> StepResult:
        """
        Swap a node at a position to a different type via MT channel.

        This directly changes the node without requiring the player to interact.

        Args:
            pos: Tuple (x, y, z)
            node_name: New node name
            steps: Wait steps

        Returns:
            StepResult

        Example:
            api.swap_node((0, 5, 0), "nc_terrain:stone")
        """
        if hasattr(self.env, 'mt_chann') and self.env.mt_chann.is_open():
            self.env.mt_chann.swap_node(pos, node_name)
        return self.wait(steps=steps)


def openai_tool_schemas() -> list[dict[str, Any]]:
    """
    Tool schemas for LLM function-calling (OpenAI-compatible JSON schema style).
    These describe *capabilities*; you still need to bind them to a NodeCoreLLMApi instance.
    """
    # Keep schemas minimal and model-friendly.
    return [
        {
            "type": "function",
            "function": {
                "name": "move",
                "description": "Move the player in a cardinal direction for a number of steps.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "direction": {"type": "string", "enum": ["forward", "backward", "left", "right"]},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 5},
                    },
                    "required": ["direction"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mouse",
                "description": "Move mouse by normalized deltas in [-1,1].",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "dx": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "dy": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                    },
                    "required": ["dx", "dy"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "dig",
                "description": "Left-click (dig / attack / UI click) for some steps.",
                "parameters": {
                    "type": "object",
                    "properties": {"steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1}},
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "place_or_use",
                "description": "Right-click (place / use / UI click) for some steps.",
                "parameters": {
                    "type": "object",
                    "properties": {"steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1}},
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "open_inventory",
                "description": "Toggle the inventory UI.",
                "parameters": {
                    "type": "object",
                    "properties": {"steps": {"type": "integer", "minimum": 1, "maximum": 10, "default": 1}},
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "select_hotbar_slot",
                "description": "Select hotbar slot 1-9.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "slot": {"type": "integer", "minimum": 1, "maximum": 9},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 10, "default": 1},
                    },
                    "required": ["slot"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "ui_click",
                "description": "Click in UI at current cursor position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "button": {"type": "string", "enum": ["left", "right"], "default": "left"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 10, "default": 1},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "ui_drag",
                "description": "Drag in UI from current cursor by relative mouse movement.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "dx": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "dy": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "button": {"type": "string", "enum": ["left", "right"], "default": "left"},
                        "hold_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                        "move_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                        "release_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                    },
                    "required": ["dx", "dy"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "ui_pick_and_place",
                "description": "Pick item at current UI cursor, move relatively, and place item (for formspec slot operations).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "dx": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "dy": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "button": {"type": "string", "enum": ["left", "right"], "default": "left"},
                        "pickup_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                        "move_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                        "place_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                        "settle_steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                    },
                    "required": ["dx", "dy"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "wait",
                "description": "Advance time with no input.",
                "parameters": {
                    "type": "object",
                    "properties": {"steps": {"type": "integer", "minimum": 1, "maximum": 5000, "default": 1}},
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "inventory_to_hotbar",
                "description": "Move an item from inventory to hotbar.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "inventory_dx": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "inventory_dy": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "hotbar_dx": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "hotbar_dy": {"type": "number", "minimum": -1.0, "maximum": 1.0},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                    },
                    "required": ["inventory_dx", "inventory_dy", "hotbar_dx", "hotbar_dy"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "give_item",
                "description": "Give an item to the player by name and place it in the hotbar.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "item_name": {"type": "string", "description": "The name of the item to give (e.g., 'nc_terrain:dirt')"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "hotbar_slot": {"type": "integer", "minimum": 1, "maximum": 9, "default": 1},
                    },
                    "required": ["item_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "pick_creative",
                "description": "Pick an item from creative inventory and place it in the hotbar.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "item_name": {"type": "string", "description": "The name of the item to pick (e.g., 'nc_terrain:stone')"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "hotbar_slot": {"type": "integer", "minimum": 1, "maximum": 9, "default": 1},
                    },
                    "required": ["item_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "pick_item",
                "description": "Pick an item from creative inventory using a description like 'stone', 'dirt', 'diamond'. LLM-friendly version.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "description": {"type": "string", "description": "Human-readable item description (e.g., 'stone', 'dirt', 'diamond sword')"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "hotbar_slot": {"type": "integer", "minimum": 1, "maximum": 9, "default": 1},
                    },
                    "required": ["description"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "move_to_wield",
                "description": "Move an item from inventory slot to the wield slot (current hotbar slot).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "slot": {"type": "integer", "minimum": 1, "maximum": 25},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 10, "default": 1},
                    },
                    "required": ["slot"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "place_at",
                "description": "Place the currently wielded item at the specified position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "x": {"type": "number"},
                        "y": {"type": "number"},
                        "z": {"type": "number"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 10, "default": 1},
                    },
                    "required": ["x", "y", "z"],
                },
},
        },
        # ---- 2026-04-17: new schemas ----
        {
            "type": "function",
            "function": {
                "name": "inv_set",
                "description": "Set an inventory slot to a specific item (bypasses GUI).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "listname": {"type": "string", "description": "Inventory list name (e.g., 'main', 'wield')"},
                        "index": {"type": "integer", "minimum": 1, "description": "Slot index (1-based)"},
                        "item_name": {"type": "string", "description": "Item name (e.g., 'nc_terrain:stone')"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["listname", "index", "item_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "inv_remove",
                "description": "Remove items from an inventory slot.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "listname": {"type": "string"},
                        "index": {"type": "integer", "minimum": 1},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 64},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["listname", "index"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "inv_take",
                "description": "Take items from an inventory slot (returns item info).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "listname": {"type": "string"},
                        "index": {"type": "integer", "minimum": 1},
                        "count": {"type": "integer", "minimum": 1, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["listname", "index"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "inv_move",
                "description": "Move items between inventory slots.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "from_list": {"type": "string"},
                        "from_index": {"type": "integer", "minimum": 1},
                        "to_list": {"type": "string"},
                        "to_index": {"type": "integer", "minimum": 1},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["from_list", "from_index", "to_list", "to_index", "count"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "inv_info",
                "description": "Get player inventory info (hotbar and wield item).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "turn_to",
                "description": "Turn player to an absolute yaw angle (radians).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "target_yaw": {"type": "number", "description": "Target yaw in radians (0=South, clockwise positive)"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                    "required": ["target_yaw"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "turn_pitch",
                "description": "Adjust player pitch to an absolute value (radians).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "target_pitch": {"type": "number", "description": "Target pitch in radians (0=horizontal, positive=look down)"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                    "required": ["target_pitch"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "face_direction",
                "description": "Set both player yaw and pitch to look in a direction.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "yaw": {"type": "number"},
                        "pitch": {"type": "number"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                    "required": ["yaw", "pitch"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "walk_forward",
                "description": "Walk forward a specific number of blocks.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "distance": {"type": "integer", "minimum": 1, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 10},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "walk_to",
                "description": "Walk to a world coordinate position (auto-calculates direction).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "x": {"type": "number"},
                        "y": {"type": "number"},
                        "z": {"type": "number"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 5},
                    },
                    "required": ["x", "y", "z"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "attack_entity",
                "description": "Left-click to attack an entity (same as dig).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "use_item",
                "description": "Right-click to use an item (same as place_or_use).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "sprint",
                "description": "Hold the sprint key for N steps.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 1},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "drop_item",
                "description": "Drop items from a hotbar slot (or current hand if no slot specified).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "slot": {"type": "integer", "minimum": 1, "maximum": 9},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "drop_all",
                "description": "Drop all items from current hand (sneak + drop).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 10},
                    },
                },
            },
        },
        # ---- 2026-04-18: NodeCore UI schemas ----
        {
            "type": "function",
            "function": {
                "name": "nodecore_open_formspec",
                "description": "Open a NodeCore machine's formspec at the given position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "nodecore_close_formspec",
                "description": "Close the currently open NodeCore formspec.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 3},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_open",
                "description": "Open Mass Storage GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_set_filter",
                "description": "Set a filter slot in Mass Storage.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Filter slot index (1-8)", "minimum": 1, "maximum": 8},
                        "item": {"type": "string", "description": "Item name to set as filter"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 8, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_set_reserve",
                "description": "Set reserve amount for a Mass Storage slot via UI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Storage slot index (1-8)", "minimum": 1, "maximum": 8},
                        "amount": {"type": "integer", "description": "Reserve amount", "minimum": 0},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot", "amount"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_toggle_pull",
                "description": "Toggle pull-from-network setting in Mass Storage.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_insert_item",
                "description": "Insert an item into Mass Storage via the main input slot.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "item": {"type": "string", "description": "Item name"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 64},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "mass_storage_set_front_image",
                "description": "Set which storage slot is displayed as the Mass Storage front image.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Storage slot index (1-8), or 0 to disable", "minimum": 0, "maximum": 8},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_open",
                "description": "Open Access Point GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_search",
                "description": "Search the Access Point network inventory.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "query": {"type": "string", "description": "Search text (e.g., 'stone', 'group:wood')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "query"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_set_filter",
                "description": "Set the filter type in Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "filter_type": {"type": "string", "enum": ["all", "nodes", "items", "tools", "lights"]},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "filter_type"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_set_sort",
                "description": "Set the sort method in Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "sort_type": {"type": "string", "enum": ["name", "mod", "count", "wear"]},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "sort_type"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_pagination",
                "description": "Navigate pages in Access Point inventory.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "action": {"type": "string", "enum": ["first", "prev", "next", "last"]},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "action"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_toggle_metadata",
                "description": "Toggle metadata usage in Access Point (for tool differentiation).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_insert_item",
                "description": "Insert an item into the network via Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "item": {"type": "string", "description": "Item name to insert"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 64},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_withdraw_item",
                "description": "Withdraw an item from the network via Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Fake inventory slot index (1-48)", "minimum": 1, "maximum": 48},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 64},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_next_liquid",
                "description": "Navigate to next liquid in Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "access_point_prev_liquid",
                "description": "Navigate to previous liquid in Access Point.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "requester_open",
                "description": "Open Requester GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "requester_set_filter",
                "description": "Set a request slot in the Requester.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Filter slot index (1-4)", "minimum": 1, "maximum": 4},
                        "item": {"type": "string", "description": "Item name to request"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "requester_set_infinite",
                "description": "Set infinite mode for a Requester slot.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Filter slot index (1-4)", "minimum": 1, "maximum": 4},
                        "enabled": {"type": "boolean", "default": True},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "requester_set_target",
                "description": "Set the target inventory for a Requester.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "list_name": {"type": "string", "description": "Target list name (e.g., 'main')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "list_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "requester_toggle",
                "description": "Toggle the Requester on/off.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "supplier_open",
                "description": "Open Supplier GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "supplier_toggle",
                "description": "Toggle the Supplier on/off.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "injector_open",
                "description": "Open Injector GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "injector_set_filter",
                "description": "Set a filter slot in the Injector.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Filter slot index (1-8)", "minimum": 1, "maximum": 8},
                        "item": {"type": "string", "description": "Item name to filter"},
                        "count": {"type": "integer", "minimum": 1, "maximum": 64, "default": 1},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "injector_set_source",
                "description": "Set the source inventory for the Injector.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "list_name": {"type": "string", "description": "Source list name (e.g., 'main')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "list_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "injector_set_targets",
                "description": "Set insertion targets for the Injector.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "requesters": {"type": "boolean", "default": True},
                        "mass_storage": {"type": "boolean", "default": True},
                        "suppliers": {"type": "boolean", "default": True},
                        "trashcans": {"type": "boolean", "default": True},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "injector_toggle",
                "description": "Toggle the Injector on/off.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "controller_open",
                "description": "Open Controller GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "controller_set_name",
                "description": "Set the network name via Controller.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "name": {"type": "string", "description": "Network name to set"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "trashcan_open",
                "description": "Open Trashcan GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "trashcan_set_filter",
                "description": "Set a filter slot in the Trashcan.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "slot": {"type": "integer", "description": "Filter slot index (1-8)", "minimum": 1, "maximum": 8},
                        "item": {"type": "string", "description": "Item name to filter (will be trashed)"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "slot", "item"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "item_storage_open",
                "description": "Open Item Storage GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "item_storage_sort",
                "description": "Sort the Item Storage inventory.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "method": {"type": "string", "description": "Sort method (e.g., 'name', 'count')", "default": "name"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "vaccuum_chest_open",
                "description": "Open Vaccuum Chest GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "vaccuum_chest_toggle",
                "description": "Toggle the Vaccuum Chest on/off.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "receiver_open",
                "description": "Open Wireless Receiver GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "receiver_set_network",
                "description": "Select a network for the Wireless Receiver.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "network_name": {"type": "string", "description": "Name of the network to connect to"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "network_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "receiver_connect",
                "description": "Connect the Wireless Receiver to the selected network.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "synchronizer_open",
                "description": "Open Synchronizer GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "synchronizer_set_crystal",
                "description": "Set crystal frequency in the Synchronizer.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "crystal": {"type": "integer", "description": "Crystal index (1 or 2)", "minimum": 1, "maximum": 2},
                        "frequency": {"type": "integer", "description": "Frequency value to set", "minimum": 0},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "crystal", "frequency"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "synchronizer_apply",
                "description": "Apply the Synchronizer upgrade.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "autocrafter_open",
                "description": "Open Autocrafter GUI.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "autocrafter_set_recipe",
                "description": "Set the recipe in the Autocrafter.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "recipe": {"type": "string", "description": "Recipe item name (e.g., 'nc_woodwork:pick_stone')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "recipe"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "autocrafter_start",
                "description": "Start the Autocrafter.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        # ---- 2026-05-02: Environment Sensing schemas ----
        {
            "type": "function",
            "function": {
                "name": "get_node_at",
                "description": "Get the node name at a specific position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "find_nodes_near",
                "description": "Find nodes of a specific type near the player.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "radius": {"type": "integer", "minimum": 1, "maximum": 50, "default": 5},
                        "node_name": {"type": "string", "description": "Node name to search for (e.g., 'nc_terrain:stone')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["radius"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "get_ground_level",
                "description": "Find the ground Y-level at given X,Z coordinates.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "x": {"type": "number"},
                        "z": {"type": "number"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "detect_surroundings",
                "description": "Scan surroundings and return a summary of nearby nodes.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "radius": {"type": "integer", "minimum": 1, "maximum": 20, "default": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "get_pointed_node",
                "description": "Get information about the node the player is currently pointing at.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        # ---- 2026-05-02: NodeCore Crafting schemas ----
        {
            "type": "function",
            "function": {
                "name": "pummel",
                "description": "Pummel a node with the currently held tool (NodeCore crafting mechanic).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 10},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "stack_apply",
                "description": "Apply the currently held item to a node (NodeCore stack-apply crafting).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "item_name": {"type": "string", "description": "Optional item to equip before applying"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "cook_node",
                "description": "Wait for a node to cook/complete (NodeCore cooking mechanic).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 200, "default": 30},
                    },
                    "required": ["pos"],
                },
            },
        },
        # ---- 2026-05-02: Advanced Inventory schemas ----
        {
            "type": "function",
            "function": {
                "name": "clear_hotbar",
                "description": "Drop all items from the hotbar.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "equip_item",
                "description": "Equip a specific item by name, using creative inventory if needed.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "item_name": {"type": "string", "description": "Item name to equip (e.g., 'nc_woodwork:tool_pick')"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["item_name"],
                },
            },
        },
        # ---- 2026-05-02: Advanced Building schemas ----
        {
            "type": "function",
            "function": {
                "name": "place_node_looking_at",
                "description": "Place the currently held (or specified) node at where the player is looking.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "node_name": {"type": "string", "description": "Node name to place"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "place_block",
                "description": "Place a block at a specific world coordinate.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "x": {"type": "number"},
                        "y": {"type": "number"},
                        "z": {"type": "number"},
                        "node_name": {"type": "string", "description": "Node name to place"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["x", "y", "z"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "build_column",
                "description": "Build a vertical column of blocks.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Base position (x, y, z)", "minItems": 3, "maxItems": 3},
                        "height": {"type": "integer", "minimum": 1, "maximum": 50, "default": 1},
                        "node_name": {"type": "string", "description": "Block type to use"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "height", "node_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "build_floor",
                "description": "Build a horizontal floor/platform.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Corner position (x, y, z)", "minItems": 3, "maxItems": 3},
                        "width": {"type": "integer", "minimum": 1, "maximum": 50, "default": 3},
                        "depth": {"type": "integer", "minimum": 1, "maximum": 50, "default": 3},
                        "node_name": {"type": "string", "description": "Block type to use"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 3},
                    },
                    "required": ["pos", "width", "depth", "node_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "build_wall",
                "description": "Build a wall.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Base corner position (x, y, z)", "minItems": 3, "maxItems": 3},
                        "height": {"type": "integer", "minimum": 1, "maximum": 50, "default": 2},
                        "length": {"type": "integer", "minimum": 1, "maximum": 50, "default": 3},
                        "node_name": {"type": "string", "description": "Block type to use"},
                        "direction": {"type": "string", "enum": ["x", "z"], "default": "x"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 3},
                    },
                    "required": ["pos", "height", "length", "node_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "dig_node_at",
                "description": "Dig a node at a specific position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 10},
                    },
                    "required": ["pos"],
                },
            },
        },
        # ---- 2026-05-02: Utility schemas ----
        {
            "type": "function",
            "function": {
                "name": "set_time_of_day",
                "description": "Set the time of day (0.0 = dawn, 0.5 = noon, 1.0 = dusk).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "time_of_day": {"type": "number", "minimum": 0.0, "maximum": 1.0, "description": "Time value 0.0-1.0"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 1},
                    },
                    "required": ["time_of_day"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "remove_node",
                "description": "Remove (set to air) a node at a specific position via MT channel.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "swap_node",
                "description": "Swap a node at a position to a different type via MT channel.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Position tuple (x, y, z)", "minItems": 3, "maxItems": 3},
                        "node_name": {"type": "string", "description": "New node name"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos", "node_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "fill_area",
                "description": "Fill a rectangular area with a specific node type.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos1": {"type": "array", "items": {"type": "number"}, "description": "First corner (x, y, z)", "minItems": 3, "maxItems": 3},
                        "pos2": {"type": "array", "items": {"type": "number"}, "description": "Second corner (x, y, z)", "minItems": 3, "maxItems": 3},
                        "node_name": {"type": "string", "description": "Node name to fill with"},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 2},
                    },
                    "required": ["pos1", "pos2", "node_name"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "clear_area",
                "description": "Clear all non-air nodes in an area around a position.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "pos": {"type": "array", "items": {"type": "number"}, "description": "Center position (x, y, z)", "minItems": 3, "maxItems": 3},
                        "radius": {"type": "integer", "minimum": 1, "maximum": 20, "default": 2},
                        "steps": {"type": "integer", "minimum": 1, "maximum": 100, "default": 5},
                    },
                    "required": ["pos"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "print_status",
                "description": "Print a human-readable summary of player status to the console.",
                "parameters": {
                    "type": "object",
                    "properties": {},
                },
            },
        },
    ]
