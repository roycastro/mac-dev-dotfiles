#!/usr/bin/env sh

echo "Running $(basename "$0")"
focused_app=$(yabai -m query --windows --window)
echo "$focused_app"
is_invis_teams_noti=$(echo "$focused_app" | jq '.title == "Microsoft Teams Notification"')

if $is_invis_teams_noti; then
  focused_display_id=$(echo "$focused_app" | jq '.display')
  # echo $(yabai -m query --spaces --display $focused_display_id)
  visible_space_id=$(yabai -m query --spaces --display $focused_display_id | jq 'map(select(."is-visible" == true))[0].index')
  available_windows=$(yabai -m query --windows --display $focused_display_id | jq --argjson space $visible_space_id 'map(select(.space == $space))')
  # echo "available_windows: $available_windows"
  recent_window_id=$(echo "$available_windows" | jq 'map(select(.title | contains("Microsoft Teams Notification") | not))[0].id')
  # echo "recent_window_id: $recent_window_id"
  yabai -m window --focus $recent_window_id
  echo "Defeated Teams!"
fi
