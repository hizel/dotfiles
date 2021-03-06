---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { open = io.open }
local setmetatable = setmetatable
local string = { match = string.match }
-- }}}


-- Cpuinf: provides speed and cache information for all available CPUs/cores
module("vicious.cpuinf")


-- {{{ CPU Information widget type
local function worker(format)
    -- Get cpuinfo
    local f = io.open("/proc/cpuinfo")
    local cpu_id   = nil
    local cpu_info = {}

    for line in f:lines() do
        if string.match(line, "^processor.*") then
            cpu_id = string.match(line, "([%d]+)")
        elseif string.match(line, "^cpu MHz.*") then
            local cpu_speed = string.match(line, "([%d]+)%.")
            cpu_info["{cpu"..cpu_id.." mhz}"] = cpu_speed
            cpu_info["{cpu"..cpu_id.." ghz}"] = tonumber(cpu_speed) / 1000
        elseif string.match(line, "^cache size.*") then
            local cpu_cache = string.match(line, "([%d]+)[%s]KB")
            cpu_info["{cpu"..cpu_id.." kb}"] = cpu_cache
            cpu_info["{cpu"..cpu_id.." mb}"] = tonumber(cpu_cache) / 1024
        end
    end
    f:close()

    return cpu_info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
