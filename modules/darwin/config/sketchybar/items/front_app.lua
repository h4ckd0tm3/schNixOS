local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = {
    drawing = false,
    color = colors.yellow,
    font = { style = settings.font.style_map["Bold"], size = 10.0 },
  },
  label = {
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)

-- yabai state of the focused window: float / zoom / stack, nothing for plain bsp.
-- skhdrc-common already fires `sketchybar --trigger window_focus` after toggles.
sbar.add("event", "window_focus")
front_app:subscribe({ "window_focus", "front_app_switched", "space_change" }, function()
  sbar.exec([[yabai -m query --windows --window 2>/dev/null | jq -r 'if .["is-floating"] then "float" elif (.["has-fullscreen-zoom"] or .["has-parent-zoom"]) then "zoom" elif .["stack-index"] > 0 then "stack" else "" end']], function(tag)
    tag = tag:gsub("%s+$", "")
    front_app:set({ icon = { drawing = tag ~= "", string = tag } })
  end)
end)

front_app:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
