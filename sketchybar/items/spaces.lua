local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")
local spaces = {}

-- Function to split a string by a delimiter
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function addSpaceIndicator()
  local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
  })

  local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 0,
    icon = {
      padding_left = 8,
      padding_right = 9,
      color = colors.grey,
      string = icons.switch.on,
    },
    label = {
      width = 0,
      padding_left = 0,
      padding_right = 8,
      string = "Spaces",
      color = colors.bg1,
    },
    background = {
      color = colors.with_alpha(colors.grey, 0.0),
      border_color = colors.with_alpha(colors.bg1, 0.0),
    }
  })

  spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
      icon = currently_on and icons.switch.off or icons.switch.on
    })
  end)

  spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
      spaces_indicator:set({
        background = {
          color = { alpha = 1.0 },
          border_color = { alpha = 1.0 },
        },
        icon = { color = colors.bg1 },
        label = { width = "dynamic" }
      })
    end)
  end)

  spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
      spaces_indicator:set({
        background = {
          color = { alpha = 0.0 },
          border_color = { alpha = 0.0 },
        },
        icon = { color = colors.grey },
        label = { width = 0, }
      })
    end)
  end)

  spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
  end)
end

local function updateSpaceIcons(apps, space)
  local icon_line = ""
  local no_app = true
  for _, app in ipairs(apps) do
    no_app = false
    local lookup = app_icons[app]
    local icon = ((lookup == nil) and app_icons["default"] or lookup)
    icon_line = icon_line .. " " .. icon
  end

  if (no_app) then
    icon_line = " —"
  end

  print("Icon Line: " .. icon_line)
  space:set({ label = icon_line })
end

local function initSbar(app_ids)
  for _, i in ipairs(app_ids) do
    local space = sbar.add("item", "space." .. i, {
      -- id = i,
      icon = {
        font = { family = settings.font.numbers, size = 12.0 },
        string = i,
        highlight_color = colors.blue,
        color = colors.grey,
        width = 20,
      },
      label = {
        color = colors.white,
        highlight_color = colors.blue,
        font = "sketchybar-app-font:Regular:12.0",
        width = 55
      },
      padding_right = 1,
      padding_left = 5,
      background = {
        color = colors.transparent,
        border_width = 0,
        height = 50,
        border_color = colors.bg0,
      },
    })

    spaces[i] = space

    spaces[i]:subscribe("aerospace_workspace_change", function(env)
      local selected = env.FOCUSED_WORKSPACE == i
      print("Workspace Change: " ..
        env.FOCUSED_WORKSPACE .. " Current Space Id:" .. i .. " Selected: " .. tostring(selected))
      local background_color = selected and colors.highlight or colors.bg2

      spaces[i]:set({
        icon = { highlight = selected },
        label = { highlight = selected },

        background = { border_color = selected and colors.black or colors.bg2, color = selected and background_color or colors.transparent }
      })
      sbar.exec("/opt/homebrew/bin/aerospace list-windows --format '%{app-name}'  --workspace " .. i,
        function(result, exit_code)
          print("Workspace " .. i .. ": " .. result)
          local apps = split(result, "\n")
          updateSpaceIcons(apps, spaces[i])
        end)
    end)


    space:subscribe("mouse.clicked", function(env)
      if env.BUTTON == "other" then
        space:set({ popup = { drawing = "toggle" } })
      else
        local op = (env.BUTTON == "right") and "--destroy" or "--focus"
        sbar.exec("/opt/homebrew/bin/aerospace workspace " .. i)
      end
    end)




    -- space:subscribe("mouse.entered", function(env)
    --   sbar.animate("tanh", 30, function()
    --     space:set({
    --       background = {
    --         color = { alpha = 1.0 },
    --         border_color = { alpha = 1.0 },
    --       },
    --       icon = { color = colors.bg1 },
    --       label = { width = "dynamic" }
    --     })
    --   end)
    -- end)

    -- space:subscribe("mouse.exited", function(env)
    --   sbar.animate("tanh", 30, function()
    --     space:set({
    --       background = {
    --         color = { alpha = 0.0 },
    --         border_color = { alpha = 0.0 },
    --       },
    --       icon = { color = colors.grey },
    --       label = { width = 0, }
    --     })
    --   end)
    -- end)
  end

  addSpaceIndicator()
  -- Iterate over the workspace IDs
end

sbar.exec("/opt/homebrew/bin/aerospace list-workspaces --all", function(result, exit_code)
  local app_ids = split(result, "\n")
  initSbar(app_ids)
end)

sbar.exec("sleep 1 && echo 'Triggering aerospace_workspace_change'",
  function(result, exit_code)
    sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = "1" })
  end)
