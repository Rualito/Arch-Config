-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- Extra widgets

local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")


local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local brightnessarc_widget = require("awesome-wm-widgets.brightnessarc-widget.brightnessarc")

local volumebar_widget = require("awesome-wm-widgets.volumebar-widget.volumebar")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local run_shell = require("awesome-wm-widgets.run-shell.run-shell")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

local net_widgets = require("net_widgets")

package.path = package.path .. ';/usr/share/powerline/bindings/awesome/?.lua'
require('powerline')

-- Initial tag count
local tag_count = 4

--

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "emacs"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Custom commands
awful.spawn.with_shell("~/.config/awesome/autorun.sh")


--beautiful.init(gears.filesystem.get_configuration_dir() .. "/themes/default/theme.lua")
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")
beautiful.init(theme_path)


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- --awful.layout.suit.dwindle,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
			     { "open terminal", terminal },
			     { "screenshot", "deepin-screen-recorder" },
			     {"systemctl", {{"poweroff", "systemctl poweroff"},
			     {"suspend", "systemctl suspend"},
			     {"hibernate", "systemctl hibernate"}} },
                        }
		       })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("  %A %d %B  %H:%M ", 60, "Lisbon")

local cw = calendar_widget({theme = 'outrun', placement = 'top_right'})

mytextclock:connect_signal("button::press", 
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
end)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


--    Custom shapes for fancy figures
local custom_powerline0 = function(cr, width, height)
   gears.shape.transform(gears.shape.powerline) : rotate_at(width/2, height/2, math.pi) (cr, width, height)
end

local custom_rectangular_tag = function(cr, width, height)
   gears.shape.rectangular_tag (cr, width, height, -height/2)
end



-- Shapes, useful functions and visual widgets

local function apply_background(widget, id)
   if id == 0 then
      return { -- end of line thing
	 widget,
	 bg = "#48325b",
	 shape = custom_rectangular_tag,
	 widget = wibox.container.background
      }
   elseif id == 1 then
      return { -- powerline rotated
	 widget,
	 --bg = "#48325b",
	 bg = "#48325b",
	 shape = custom_powerline0,
	 widget = wibox.container.background
      }
   elseif id == 2 then
      return { -- hexagon
	 widget,
	 --bg = "#48325b",
	 bg = "#48325b",
	 shape = gears.shape.hexagon,
	 widget = wibox.container.background
      }
   else
      return widget
   end
   --return wibox.container.background(widget,  , gears.shape.)
end

local  semi_hexagon = function(cr, width, height)
    -- OMG, it works, dont touch it
    -- the parameters are such that the hexagon lines up on the right spot
    -- essentially, just a rotated hexagon, since the normal parameters don't work so well
    gears.shape.transform(gears.shape.hexagon) : translate(width,0) : rotate(math.pi/2) (cr,height,2*width)
    
end

local bottom_semi_hexagon = function(cr, width, height)

    gears.shape.transform(gears.shape.hexagon) : translate(0,0) : rotate(0) (cr, width, 2*height)
end

local bottom_semi_octogon = function(cr, width, height)
    gears.shape.transform(gears.shape.octogon) : translate(0,0*height/2) (cr, width, 2*height, 12/16*height)

end

local octo_fill = function(cr, width, height)
    
    -- gears.shape.transform(gears.shape.octogon): translate(0,50) (cr, width, height*1.1, width/3)
    gears.shape.rectangle(cr, width, height)
end

local bottom_parallelogram = function(cr, width, height)
    delta = height/math.tan(math.pi/3) -- parallelogram with angle the same as hexagon
    gears.shape.parallelogram(cr, width, height, width-delta)
end




awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    tags_table = {}
    for i = 1, tag_count do
        tags_table[i] = tostring(tag_count)
    end
    awful.tag(tags_table, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt({with_shell = true, prompt="run: " })

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        layout = {
            -- spacing = 25,
            -- inner_fill_strategy = 'justify',
            
            spacing = -1,
            spacing_widget = {
                shape  = gears.shape.rectangle,
                widget = wibox.widget.separator,
            },
            layout  = wibox.layout.flex.vertical,
            
        },

        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        style = {
            shape = gears.shape.rectangle
        },
        buttons = taglist_buttons,
        -- spacing_widget = {
        --     widget = wibox.widget.separator,
        --     shape ={ 
        --         widget = gears.shape.octogon,
        --         corner_radius = 5,
        --         width = 10,
        --         height = 10,
        --     },
        --     color = '#ffff00',
        --     valign = 'center',
        --     halign = 'center',
        --     widget = wibox.container.place,
        -- },
        widget_template = {
            {

                {
                    id = 'index_role',
                    align = 'center',
                    valign = 'center',
                    font = beautiful.taglist_font,
                    widget = wibox.widget.textbox
                },
                --dir = 'east',
                -- margins = 40,
                widget  = wibox.container.margin,
            
            },
            id = 'background_role',
            forced_width = dpi(15),
            widget = wibox.container.background,
            create_callback = function(self,c3, index, objects)
                self:get_children_by_id('index_role')[1].markup = '<b>'..index..'</b>'
                self:connect_signal('mouse::enter', function()
                    if self.bg ~=beautiful.tag_highlight then 
                        self.backup = self.bg
                        self.has_backup = true
                    end
                    self.bg = beautiful.tag_highlight
                end)
                self:connect_signal('mouse::leave', function()
                    if self.has_backup then self.bg = self.backup end
                end)
            end,
            update_callback = function(self, c3, index, objects)
                self:get_children_by_id('index_role')[1].margin = '<b>'..index..'</b>'
            end,
        }
    }


    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            layout = wibox.layout.flex.vertical,
        },
        style = {
            shape = semi_hexagon,
            
        },
        widget_template = {
            {
                {
                    {
                        {
                            
                            {
                                {
                                    { -- Client Icon widget
                                        id     = 'client_role',
                                        forced_height = beautiful.taglist_icon_size,
                                        widget = awful.widget.clienticon,
                                    },
                                    right = dpi(10),
                                    widget  = wibox.container.margin,
                                },
                                {  -- Client Text Widget
                                    id     = 'text_role',
                                    widget = wibox.widget.textbox,
                                },
                                layout = wibox.layout.align.horizontal,
                                expand = "inside",
                            },
                            widget = wibox.container.margin,
                            margins = dpi(5),
                        },
                        valign = 'center',
                        halign = 'center',
                        widget = wibox.container.place,
                    },
                    -- Rotating both the Icon and Text to the side
                    widget = wibox.container.rotate,
                    direction = 'east'
                },
                widget = wibox.container.margin,
                top = 20,
                bottom = 20,
            },
            -- forced_height = dpi(200),
            -- forced_width = 200,
            widget = wibox.container.background,
            id     = 'background_role',
            opacity = 0.75,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id('client_role')[1].client = c
            end,
        },
        
    }

    -- Create the wibox
    s.side_bar = awful.wibar({position = "left", screen = s,width=50,  bg=beautiful.bg_normal_transparent, type="desktop", stretch=false, height=dpi(1110)})
    
    s.side_bar:setup {
        
        -- layout = wibox.layout.flex.vertical,
        -- wibox.container.rotate( , "east"),
        layout = wibox.layout.fixed.horizontal,
        s.mytaglist,        
        -- {
        --     widget = wibox.widget.separator,
        -- },
        -- {
        --     widget = wibox.container.background,
        --     {
        --         layout = wibox.layout.fixed.vertical,
                
                
        --     },
        -- },
        -- wibox.widget.separator,
        -- wibox.widget.systray(),
        s.mytasklist,
        create_callback = function(self,c, index, objects)
            self:connect_signal('side_bar::invisible', function()
                self.visible = false
            end)

            self:connect_signal('side_bar::visible', function()
                self.visible = true
            end)
        end
        -- opacity = 0,
    }


    s.bottom_bar = awful.wibar({ position = "bottom", screen = s , height=beautiful.bottombar_height, stretch=false, width=1080, ontop = false, type='dock', shape_bounding = bottom_semi_hexagon, shape = bottom_semi_hexagon})
    
    cpu_w = cpu_widget(
        {
            width = 60,
            step_width = 2,
            step_spacing = 0,
            color = '#434c5e'
    });

    s.bottom_bar:setup {
        
        widget = wibox.container.background,
        {
            widget = wibox.container.margin,
            left = beautiful.bottombar_height,
            right = beautiful.bottombar_height,
            
            -- wibox.widget.textbox("hi there"),
            { 
                layout = wibox.layout.fixed.horizontal,
                spacing = -17,
                -- {
                --     markup = ,
                --     widget = wibox.widget.textbox,
                -- },
                { -- system status section
                    layout = wibox.layout.fixed.horizontal,
                    { -- ram pie chart
                        widget = wibox.container.background,
                        -- forced_width = 15,
                        ram_widget(),
                    },
                    { -- cpu graph 
                        widget = wibox.container.background,
                        forced_width = 70,
                        {
                            widget = wibox.container.margin,
                            left = 10,
                            right = 25,
                            top = 2,
                            bottom = 2,
                            {
                                layout = wibox.layout.flex.vertical,
                                spacing = -3,
                                -- spacing =1,
                                spacing_widget = {
                                    widget = wibox.widget.separator,
                                    span_ratio = 1,
                                    border_width = 0, 
                                    opacity = 0.7,
                                    color = beautiful.bottombar_bg_widget1,
                                },
                                {
                                    widget = wibox.container.constraint,
                                    -- fill_vertical = true,
                                    cpu_w,
                                },
                                {
                                    widget = wibox.container.mirror,
                                    reflection = {horizontal=false, vertical=true},
                                    cpu_w
                                    
                                },
                                
                            }
                            
                        }
                    },
                },
                { -- some device icons, like wifi, battery and others
                    layout = wibox.layout.fixed.horizontal,
                    {
                        widget = wibox.container.background,
                        shape = bottom_parallelogram,
                        shape_border_width = 0,
                        bg = beautiful.bottombar_bg_widget1,
                        {
                            widget = wibox.container.margin,
                            left = dpi(30),
                            right = dpi(30),
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = 10,
                                batteryarc_widget({
                                        show_current_level = true,
                                        arc_thickness = dpi(3),
                                        timeout = 60,
                                        display_notification = true,
                                        -- notification_position = 'bottom_right',
                                }),
                                {
                                    widget = wibox.container.margin,
                                    top = dpi(5),
                                    bottom = dpi(5),
                                    net_widgets.wireless({
                                            interface='wlan0', 
                                            onclick="wpa-cute"
                                    }),
                                },
                                {
                                    widget = wibox.container.margin,
                                    top = 4,
                                    bottom = 4,
                                    left = 0,
                                    right = 0,
                                    s.mylayoutbox,
                                },
                                
                                -- run_shell()
                                
                            }
                        }
                    },
                },
                { -- prompt box
                    widget = wibox.container.background,
                    forced_width = dpi(300),
                    shape = bottom_parallelogram,
                    shape_border_width = 0,
                    bg = beautiful.bottombar_bg_widget2,
                    {
                        widget = wibox.container.margin,
                        -- bg = beautiful.bottombar_bg_widget3,
                        left = 20,
                        -- top = 15,
                        -- bottom = 15,
                        right = 20,
                        {
                            widget = wibox.container.constraint,
                            -- bg = beautiful.bottombar_bg_widget3,
                            s.mypromptbox,
                        }
                    }
                },

                { -- volume and brightness
                    widget = wibox.container.background,
                    -- forced_width = dpi(200),
                    shape = bottom_parallelogram,
                    shape_border_width = 0,
                    bg = beautiful.bottombar_bg_widget1,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        separator = bottom_parallelogram,
                        {
                            widget = wibox.container.margin,
                            left = 30,
                            right = 10,
                            volumebar_widget({
                                main_color = beautiful.bottombar_bg_widget3,
                                mute_color = '#ff0000',
                                width = 150,
                                -- shape = 'hexagon',
                                real_shape = bottom_semi_octogon,
                                -- margins = 10,
                                top = dpi(15),
                                margins = 0
                            }),
                        },
                        {
                            widget = wibox.container.margin,
                            left = 10,
                            right = 25,
                            top = 5,
                            bottom = 5,
                            brightness_widget({
                                get_brightness_cmd = 'xbacklight -get',
                                inc_brightness_cmd = 'xbacklight -inc 5',
                                dec_brightness_cmd = 'xbacklight -dec 5',
                                -- arc_thickness = 3,
                                -- tooltip = true,
                                color = '/usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg'
                            })
                        }
                    }
                    
                },
                {
                    widget = wibox.container.margin,
                    left = 30,
                    right = 0,
                    top = 8,
                    bottom = 8,
                    mytextclock
                }
                


                -- run_shell,
                -- {
                --     widget = wibox.container.background,
                --     volumebar_widget(
                --     {
                --         main_color = '#6666ff',
                --         mute_color = '#ff0000',
                --         width = 80,
                --         shape = 'rounded_bar',
                --         margins = 8
                --     })
                -- },
            }
        },

    }

    -- Add widgets to the wibox
    -- s.bottom_bar:setup {
    --     -- On the bottom bar there will be only system widgets: cpu, ram, wifi, brightness, date, layout, etc...
    --     -- 
    --     -- shape = semi_hexagon,
        
            
    --     -- inner_fill_strategy = 'center',
    --     layout = wibox.layout.flex.horizontal,
    --     { -- main widgets
    --         layout = wibox.layout.flex.horizontal,
    --         mylauncher,
    --         -- s.mytaglist,
    --         s.mypromptbox,
    --     },
    --     -- wibox.container.margin(
    --     --         s.mytaglist, 10, 10
    --     --     ), -- Middle widget
    --     { -- Right widgets
    --         layout = wibox.layout.fixed.horizontal,
    --         apply_background(wibox.widget.systray(), 1),

    --         wibox.container.margin(spotify_widget({
    --             font = 'Hack 10',
    --             play_icon = '/usr/share/icons/Papirus-Light/24x24/categories/spotify.svg',
    --             pause_icon = '/usr/share/icons/Papirus-Dark/24x24/panel/spotify-indicator.svg',
    --             dim_when_paused = true,
    --             dim_opacity = 0.5,
    --             max_length = 25,
    --             show_tooltip = true,
    --             shape = gears.shape.rounded_rect
    --         }), 10,10),
                
    --         wibox.container.margin(volumebar_widget({
    --             main_color = '#6666ff',
    --             mute_color = '#ff0000',
    --             width = 80,
    --             shape = 'rounded_bar',
    --             margins = 8
    --         }), 5,5),
    --         --powerline_widget,
            
    --         cpu_widget({
    --             width = 70,
    --             step_width = 2,
    --             step_spacing = 0,
    --             color = '#434c5e'
    --         }),
    --         ram_widget(),
            
            
    --         apply_background(wibox.container.margin (wibox.widget {
    --                     battery_widget({
    --                         show_current_level = true,
    --                         display_notification = true
    --                     }),
    --                     wibox.container.margin(net_widgets.wireless({interface='wlan0', onclick="wpa-cute"}), 0,0 ),
    --                     brightness_widget({
    --                         get_brightness_cmd = 'xbacklight -get',
    --                         inc_brightness_cmd = 'xbacklight -inc 10',
    --                         dec_brightness_cmd = 'xbacklight -dec 10',
    --                         arc_thickness = 1
    --                     }),
    --                     layout = wibox.layout.fixed.horizontal
    --                         }, 15, 12
    --         ), 1),
    
    --         -- mykeyboardlayout,
    --         wibox.container.margin(s.mylayoutbox, 5,5),
            
    --         apply_background(wibox.container.margin(mytextclock, 12, 5), 0),
    --         --run_shell,

    --     },
            
	    
    --     -- create_callback = function(self, c, index, objects)
    --     --     self:connect_signal('bottom_bar::pop_out', function()
            
    --     --     end)
    --     --     self:connect_signal('bottom_bar::pop_in', function()
            
    --     --     end)

    --     -- end
    -- }

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

    -- Brightness shortcuts
   awful.key({}, "XF86MonBrightnessDown" , function() awful.spawn("xbacklight -dec 10") end,
      {description="Decrease Brightness", group="Custom: brightness"}),
   awful.key({}, "XF86MonBrightnessUp" , function() awful.spawn("xbacklight -inc 10") end,
      {description="Increase Brightness", group="Custom: brightness"}),

    -- Volume shortcuts
   awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("amixer -c 0 set 'Master' 5%-") end,
      {description="Lower Master Volume", group="Custom: volume"}),
   awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("amixer -c 0 set 'Master' 5%+") end,
      {description="Raise Master Volume", group="Custom: volume"}),

   -- Music player
   awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end,
      {description="Play/Pause Audio", group="Custom: music player"}),
   awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end,
      {description="Skip song", group="Custom"}),
   awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end,
      {description="Listen to previous song", group="Custom: music player"}),

    -- Misc
   awful.key({}, "Print", function() awful.spawn("deepin-screen-recorder") end,
      {description="Print Screen (deepin)", group="Custom"}),
   
    -- Adding and removing tags
    awful.key({modkey, "Control" }, "+", function()
        tag_count = tag_count + 1
        awful.tag.add(tostring(tag_count+1), {screen = awful.screen.focused(), layout = awful.layout.layouts[1]}):view_only()
    end, {description="Add new tag after current ", group="Custom: tag control"}),

    awful.key({modkey, "Control" }, "-", function()
        local t = awful.screen.focused().selected_tag
        if not t then return end
        t:delete()
    end, {description="Remove current tag and rename ", group="Custom: tag control"}),

   awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Up",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Down",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal, {opacity=0.9}) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
   awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}),
    -- awful.key({modkey}, "r", function () run_shell.launch() end,
   --{description = "run prompt", group = "launcher"}),

    
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		     -- shape_bounding = beautiful.client_shape,
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}



-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
			 
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
       -- Prevent clients from being unreachable after screen count changes.
       awful.placement.no_offscreen(c)
       
    end
    -- gears.surface.apply_shape_bounding(c, gears.shape.partially_rounded_rect, false, true, false, false, beautiful.border_radius)
    gears.surface.apply_shape_bounding(c, gears.shape.octogon, beautiful.border_radius)
    -- gears.surface.apply_shape_bounding(c, gears.shape.hexagon)
end)

client.connect_signal("property::size", function(c)
	-- aa
    gears.surface.apply_shape_bounding(c, gears.shape.octogon, beautiful.border_radius)
    -- gears.surface.apply_shape_bounding(c, gears.shape.hexagon)
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
			 c.border_color = beautiful.border_focus
			 c.opacity = 1.0
end)
client.connect_signal("unfocus", function(c)
			 c.border_color = beautiful.border_normal
			 c.opacity = 0.75
end)
-- }}}
