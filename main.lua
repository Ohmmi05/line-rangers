-- LINE Rangers Script v11.0.3 by Ohmmi (Lite Edition)

gg.setVisible(false)

local toast, alert, prompt = gg.toast, gg.alert, gg.prompt

-- 🧠 Memory Helpers
local function write(addr, type, val) gg.setValues({{address = addr, flags = type, value = val}}) end
local function read(addr, type) return gg.getValues({{address = addr, flags = type}})[1].value end
local function GetLibBase(lib)
    for _, r in pairs(gg.getRangesList(lib)) do if r.state == "Xa" then return r.start end end
end

-- 📌 Setup
BaseAddress = GetLibBase("libgame.so")
if not BaseAddress then alert("Error", "ไม่พบ libgame.so\nโปรดเข้าเกมก่อนเปิดสคริปต์") os.exit() end
if gg.getTargetInfo().versionName ~= "11.0.3" then
    alert("แจ้งเตือน", string.format("เกมเวอร์ชัน: %s\n\nเวอร์ชันที่รองรับ: 11.0.3\nกรุณาอัปเดตสคริปต์หากใช้เวอร์ชันอื่น", gg.getTargetInfo().versionName))
end

-- 🔧 Hack Definitions
local function addr(offset) return BaseAddress + offset end
local Hack = {
    [1] = { name = "ตีแรง",       offset = 0x82cbac,   type = gg.TYPE_FLOAT },
    [2] = { name = "ตีไว",        offset = 0x4eaa20,   type = gg.TYPE_FLOAT },
    [3] = { name = "ปล่อยตัวไว",  offset = 0x4e5ffc,   type = gg.TYPE_FLOAT },
    [4] = { name = "ความเร็วเกม", offset = 0xd22654,   type = gg.TYPE_FLOAT },
    [5] = { name = "ฆ่าศัตรู",       offset = 0x5b0fd0,   value = 10000, switch = false, type = gg.TYPE_FLOAT },
    [6] = { name = "ศัตรูไม่ออก",     offset = {0x551614, 0x5524b0, 0x557924}, value = 0, switch = false, type = gg.TYPE_FLOAT },
    [7] = { name = "บอสกิลด์ยืนนิ่ง", offset = 0x587240,   value = -100, switch = false, type = gg.TYPE_FLOAT },
    [8] = { name = "กันรายงาน PVP",   offset = 0x540800,   value = 1.40129846e-40, switch = false, type = gg.TYPE_FLOAT },

    modes = {
        ["สเตจหลัก"]   = { [1]=9999, [2]=-100, [3]=0 },
        ["สเตจพิเศษ"] = { [1]=8888, [2]=-90,  [3]=0 },
        ["สเตจจุติ"]   = { [1]=7777, [2]=-80,  [3]=0 },
        ["หอคอย"]     = { [1]=6666, [2]=-70,  [3]=0 },
        ["บอสกิลด์"]   = { [1]=5555, [2]=-60,  [3]=0 },
        ["PVP"]       = { [1]=0,    [2]=0,    [3]=1.40129846e-40 },
    }
}

-- 💥 Cheat Function
local function ApplyHack(h, promptMode)
    local addrs = type(h.offset) == "table" and h.offset or {h.offset}
    local values = {}

    if not h.base then h.base = {} end
    for i, o in ipairs(addrs) do
        h.base[i] = h.base[i] or addr(o)
    end

    if promptMode then
        local cur = read(h.base[1], h.type)
        local input = prompt({"🔧 "..h.name}, {tostring(cur)}, {"number"})
        if input and tonumber(input[1]) then
            for _, a in ipairs(h.base) do write(a, h.type, tonumber(input[1])) end
            toast("✅ "..h.name)
        end
    else
        h.switch = not h.switch
        if not h.off then h.off = read(h.base[1], h.type) end
        local val = h.switch and h.value or h.off
        for _, a in ipairs(h.base) do write(a, h.type, val) end
        toast((h.switch and "🟢 " or "🔴 ")..h.name)
    end
end

-- 🎯 Auto Mode
local function ApplyAutoMode(modeName)
    local mode = Hack.modes[modeName]
    if not mode then toast("❌ ไม่พบโหมด: " .. modeName) return end
    for i = 1, 3 do
        local h = Hack[i]
        if mode[i] ~= nil then
            local addrs = type(h.offset) == "table" and h.offset or {h.offset}
            if not h.base then h.base = {} end
            for j, o in ipairs(addrs) do h.base[j] = h.base[j] or addr(o) end
            for _, a in ipairs(h.base) do write(a, h.type, mode[i]) end
        end
    end
    toast("⚡ ใช้งานโหมด: " .. modeName)
end

-- ♻️ Reset All
local function ResetAll()
    for _, h in pairs(Hack) do
        if h.switch and h.off then
            for _, a in ipairs(type(h.base) == "table" and h.base or {h.base}) do
                write(a, h.type, h.off)
            end
            h.switch = false
        end
    end
    toast("✅ รีเซ็ตฟังก์ชันทั้งหมด")
end

-- 📋 Menu
local function ShowMenu()
    local manualMenu = {
        "[⚙️] " .. Hack[1].name,
        "[⚙️] " .. Hack[2].name,
        "[⚙️] " .. Hack[3].name,
        "[⚙️] " .. Hack[4].name,
    }
    local toggleMenu = {
        "["..(Hack[5].switch and "🟢" or "🔴").."] "..Hack[5].name,
        "["..(Hack[6].switch and "🟢" or "🔴").."] "..Hack[6].name,
        "["..(Hack[7].switch and "🟢" or "🔴").."] "..Hack[7].name,
        "["..(Hack[8].switch and "🟢" or "🔴").."] "..Hack[8].name
    }
    local autoModes = { "สเตจหลัก", "สเตจพิเศษ", "สเตจจุติ", "หอคอย", "บอสกิลด์", "PVP" }

    local m = gg.choice({
        "🎛️ ปรับค่าเอง", "⚡ โหมดอัตโนมัติ", "🔘 เปิด/ปิดฟังก์ชัน", "🔄 รีเซ็ตทั้งหมด", "🚫 ปิดเกม", "👋 ออกจากสคริปต์"
    }, nil, "👑 LINE Rangers Mod by Ohmmi")

    if not m then return end

    if m == 1 then
        local choice = gg.multiChoice(manualMenu, nil, "🎛️ เลือกฟังก์ชันที่ต้องการปรับ")
        if choice then for i = 1, 4 do if choice[i] then ApplyHack(Hack[i], true) end end end
    elseif m == 2 then
        local mode = gg.choice(autoModes, nil, "⚡ เลือกโหมดที่ต้องการ")
        if mode then ApplyAutoMode(autoModes[mode]) end
    elseif m == 3 then
        local choice = gg.multiChoice(toggleMenu, nil, "🔘 เปิด/ปิดฟังก์ชัน")
        if choice then for i = 1, 4 do if choice[i] then ApplyHack(Hack[i + 4], false) end end end
    elseif m == 4 then
        ResetAll()
    elseif m == 5 then
        toast("🛑 ปิดเกม") gg.processKill() os.exit()
    elseif m == 6 then
        toast("👋 เจอกันรอบหน้า!") os.exit()
    end
end

-- 🔁 Main Loop
while true do
    ShowMenu()
    while not gg.isVisible() do gg.sleep(200) end
    gg.setVisible(false)
end
