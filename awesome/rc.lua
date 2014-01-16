-- {{{ Header
--
-- Set locale
os.setlocale("ru_RU.utf8")
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")
--
-- }}}


-- {{{ Variable definitions
--
-- Load theme

beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")
-- Apps
terminal = "sakura"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "/usr/bin/firefox"
fileManager = "pcmanfm"

-- Volume
cardid = 0
channel = "PCM"

-- Modkey
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.

layouts = {
    awful.layout.suit.tile,            -- 1
    awful.layout.suit.tile.left,       -- 2
    awful.layout.suit.tile.bottom,     -- 3
    awful.layout.suit.tile.top,        -- 4
    awful.layout.suit.fair,            -- 5
    awful.layout.suit.fair.horizontal, -- 6
    awful.layout.suit.max,             -- 7
    awful.layout.suit.magnifier,       -- 8
    awful.layout.suit.floating         -- 9
}
use_titlebar = false
-- }}}


-- {{{ Tags
tags = {}
tags.settings = {
    { name = "www",  layout = layouts[7] },
    { name = "im",   layout = layouts[5] },
    { name = "dc",   layout = layouts[5] },
    { name = "fm",   layout = layouts[7] },
    { name = "mus",  layout = layouts[7] },
    { name = "tor",  layout = layouts[7] },
    { name = "misc", layout = layouts[2], mwfact = 0.15 },
    { name = "term", layout = layouts[3] },
    { name = "term", layout = layouts[3] },
}

for s = 1, screen.count() do
    tags[s] = {}
    for i, v in ipairs(tags.settings) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",   v.hide)
    end
    tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separators
spacer         = widget({ type = "textbox", name = "spacer" })
separator      = widget({ type = "textbox", name = "separator" })
spacer.text    = " "
separator.text = "|"
-- }}}

-- {{{ CPU usage and temperature
-- Widget icon
cpuicon        = widget({ type = "imagebox", name = "cpuicon" })
cpuicon.image  = image(beautiful.widget_cpu)
-- Initialize widgets
thermalwidget  = widget({ type = "textbox", name = "thermalwidget" })
cpuwidget      = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
-- Graph properties
cpuwidget:set_width(50)
--cpuwidget:set_scale(false)
cpuwidget:set_max_value(100)
cpuwidget:set_background_color(beautiful.fg_off_widget)
cpuwidget:set_border_color(beautiful.border_widget)
cpuwidget:set_color(beautiful.fg_end_widget)
cpuwidget:set_gradient_angle(0)
cpuwidget:set_gradient_colors({
    beautiful.fg_end_widget,
    beautiful.fg_center_widget,
    beautiful.fg_widget })
-- Register widgets
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
-- }}}

-- {{{ Memory usage
-- Widget icon
memicon       = widget({ type = "imagebox", name = "memicon" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
memwidget     = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- Pogressbar properties
memwidget:set_width(8)
memwidget:set_height(12)
memwidget:set_vertical(true)
memwidget:set_background_color(beautiful.fg_off_widget)
memwidget:set_border_color(nil)
memwidget:set_color(beautiful.fg_widget)
memwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[memwidget.widget] = { top = 2, bottom = 2 }
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ Network usage
-- Widget icons
neticon         = widget({ type = "imagebox", name = "neticon" })
neticonup       = widget({ type = "imagebox", name = "neticonup" })
neticon.image   = image(beautiful.widget_net)
neticonup.image = image(beautiful.widget_netup)
-- Initialize widgets
netwidget       = widget({ type = "textbox", name = "netwidget" })
-- Register ethernet widget
vicious.enable_caching(vicious.widgets.net)
vicious.register(netwidget, vicious.widgets.net,
  '<span color="'.. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 3)
-- }}}

-- {{{ Volume level
-- Widget icon
volicon       = widget({ type = "imagebox", name = "volicon" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volwidget     = widget({ type = "textbox", name = "volwidget" })
volbarwidget  = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- Progressbar properties
volbarwidget:set_width(8)
volbarwidget:set_height(12)
volbarwidget:set_vertical(true)
volbarwidget:set_background_color(beautiful.fg_off_widget)
volbarwidget:set_border_color(nil)
volbarwidget:set_color(beautiful.fg_widget)
volbarwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[volbarwidget.widget] = { top = 2, bottom = 2 }
-- Register widgets
vicious.enable_caching(vicious.widgets.volume)
vicious.register(volwidget, vicious.widgets.volume, "$1%", 1, "PCM")
vicious.register(volbarwidget, vicious.widgets.volume, "$1", 1, "PCM")
-- Register buttons
volbarwidget.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -name mixer -e alsamixer", false) end),
    awful.button({ }, 2, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset PCM 2dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset PCM 2dB-", false) end)
))
volwidget:buttons( volbarwidget.widget:buttons() )
-- }}}

-- {{{ Date and time
-- Widget icon
dateicon       = widget({ type = "imagebox", name = "dateicon" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget     = widget({ type = "textbox", name = "datewidget" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%a, %b %e, %X ", 1)
-- Register buttons
datewidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("/home/lord/.config/awesome/pylendar.py", false) end)))
-- }}}


-- {{{ HDD Temp
-- Widget icon
tempicon        = widget({ type = "imagebox", name = "tempicon" })
tempicon.image  = image(beautiful.widget_temp)
-- Initialize widgets
hddtempwidget     = widget({ type = "textbox", name = "hddtempwidget" })
hddtempwidget1     = widget({ type = "textbox", name = "hddtempwidget1" })
-- Register widgets
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "HDD: ${/dev/sda}C", 19)
-- }}}

-- {{{ Power
-- Initialize widgets
powericon     = widget({ type = "imagebox", name = "powericon" })
powericon.image = image(beautiful.widget_power)
powericon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("xmessage 'Are you sure?' -button poweroff:'sudo halt',reboot:'sudo reboot',cancel:cancel -default cancel -center", false) end)
))
-- }}}

-- {{{Systray
systray = widget({ type = "systray", align = "right" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox = {}
statusbar = {}
promptbox = {}
layoutbox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
tasklist = {}
tasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))


for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    layoutbox[s].fg = beautiful.fg_focus
    layoutbox[s].bg = beautiful.bg_normal
                             
    -- Create a taglist widget
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)

    -- Create a tasklist widget
    -- Mod: Only display currently focused client in tasklist
    tasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, tasklist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({
        position = "top", height = 14, screen = s,
        fg = beautiful.fg_normal, bg = beautiful.bg_normal
    })
    -- Add widgets to the wibox - order matters
    wibox[s].widgets = { 
        {
            taglist[s],
            layoutbox[s],
            promptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        datewidget, separator, spacer,
        s == 1 and systray or nil, spacer, separator, spacer,
        volbarwidget.widget, spacer, volwidget, spacer, volicon, spacer, separator, spacer,
        memwidget.widget, spacer, memicon, spacer, separator, spacer,
        cpuwidget.widget, cpuicon, spacer, separator, 
        spacer, neticonup, netwidget, neticon,
        layout = awful.widget.layout.horizontal.rightleft
        }

end

-- }}}
--
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ modkey }, "t",
        function ()
            awful.util.spawn("urxvtc -name rtorrent -e screen -t rtorrent rtorrent -o http_capath=/etc/ssl/certs", false)
        end),
    awful.key({ modkey }, "p",
        function ()
            awful.util.spawn("urxvtc -name music -e ncmpcpp", false)
        end),
     awful.key({ modkey }, "m",
        function ()
            awful.util.spawn("urxvtc -name mcabber -e mcabber", false)
        end),
    awful.key({ }, "Print",
        function ()
            awful.util.spawn("scrot -m -e 'mv $f ~/Pictures/Screenshots/'", false)
        end),
    awful.key({ modkey }, "z",
        function ()
            awful.util.spawn("ncmpcpp stop", false)
        end),
    awful.key({ modkey }, "x",
        function ()
            awful.util.spawn("ncmpcpp pause", false)
        end),
    awful.key({ modkey }, "c",
        function ()
            awful.util.spawn("ncmpcpp play", false)
        end),
    awful.key({ modkey }, "v",
        function ()
            awful.util.spawn("ncmpcpp next", false)
        end),
    awful.key({ modkey }, "b",
        function ()
            awful.util.spawn("ncmpcpp prev", false)
        end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end)
)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey }, "t", awful.client.togglemarked),
    awful.key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "SMPlayer" },
      properties = { floating = true } },
    { rule = { class = "Xmessage" },
      properties = { floating = true } },
    { rule = { instance = "vlc" },
      properties = { floating = true } },
    { rule = { class = "Wine" },
      properties = { floating = true } },
    -- Tag 1: www

    -- Tag 2: im
    { rule = { class = "mcabber" },
      properties = { tag = tags[1][5],  ontop = true } }

}
-- }}}


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- {{{ Autorun
autorun = true
autorunApps =
{
--"pcmanfm",
-- "mpd",
"/usr/bin/wmname LG3D",
"setxkbmap -option \"grp:caps_toggle\""
}
if autorun then
   for app = 1, #autorunApps do
          awful.util.spawn(autorunApps[app])
                --os.execute(autorunApps[app])
   end
end 
-- }}}
