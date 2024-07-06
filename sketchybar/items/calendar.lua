local settings = require("settings")
local colors = require("colors")

local date = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 7,
    font = {
      style = settings.font.style_map["Black"],
      size = 7.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 0,
    width = 60,
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 29,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.bg1,
    border_color = colors.black,
    border_width = 0
  },
  click_script = "open -a Calendar"
})

local time = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 4,
    font = {
      style = settings.font.style_map["Black"],
      size = 7.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 60,
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1
  },
  click_script = "open -a 'Clock'"
})

time:subscribe({ "forced", "routine", "system_woke" }, function(env)
  time:set({ label = os.date("%H:%M") })
end)

date:subscribe({ "forced", "routine", "system_woke" }, function(env)
  date:set({ label = os.date("%d %b") })
end)
