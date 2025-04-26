-- LINE Rangers Script v11.0.3 by Ohmmi (No Lang / Toast No Value)

gg.setVisible(false)

local toast, alert, prompt = gg.toast, gg.alert, gg.prompt

-- 🔧 Hack Definitions
local function addr(offset) return BaseAddress + offset end
local Hack = {
    [1] = { name = "ตีแรง",       offset = 0x82cbac,   type = gg.TYPE_FLOAT },
    [2] = { name = "ตีไว",       offset = 0x4eaa20,   type = gg.TYPE_FLOAT },
    [3] = { name = "ปล่อยตัวไว", offset = 0x4e5ffc,   type = gg.TYPE_FLOAT },
    [4] = { name = "ฆ่าศัตรู",   offset = 0x5b0fd0,   value = 10000, switch = false, type = gg.TYPE_FLOAT },
    [5] = { name = "ศัตรูไม่ออก", offset = {0x551614, 0x5524b0, 0x557924}, value = 0, switch = false, type = gg.TYPE_FLOAT },
    [6] = { name = "บอสกิลด์ยืนนิ่ง", offset = 0x587240,   value = -100, switch = false, type = gg.TYPE_FLOAT },
    [7] = { name = "กันรายงาน PVP", offset = 0x540800,   value = 1.40129846e-40, switch = false, type = gg.TYPE_FLOAT },
    [8] = { name = "ความเร็วเกม", offset = 0xd22654,   type = gg.TYPE_FLOAT },
}

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
        local input = prompt({"⚙️ "..h.name}, {tostring(cur)}, {"number"})
        if input and tonumber(input[1]) then
            for _, a in ipairs(h.base) do write(a, h.type, tonumber(input[1])) end
            toast("✅ เปิดใช้งาน "..h.name)
        end
    else
        h.switch = not h.switch
        if not h.off then h.off = read(h.base[1], h.type) end
        local val = h.switch and h.value or h.off
        for _, a in ipairs(h.base) do write(a, h.type, val) end
        toast((h.switch and "🟢 เปิดใช้งาน " or "🔴 ปิดการทำงาน ")..h.name)
    end
end

-- 📋 Menu with Modern UI
local function ShowMenu()
    local menuOptions = {
        {name = Hack[1].name, icon = "⚙️", action = 1},
        {name = Hack[2].name, icon = "⚙️", action = 2},
        {name = Hack[3].name, icon = "⚙️", action = 3},
        {name = Hack[4].switch and "🟢 "..Hack[4].name or "🔴 "..Hack[4].name, icon = "", action = 4},
        {name = Hack[5].switch and "🟢 "..Hack[5].name or "🔴 "..Hack[5].name, icon = "", action = 5},
        {name = Hack[6].switch and "🟢 "..Hack[6].name or "🔴 "..Hack[6].name, icon = "", action = 6},
        {name = Hack[7].switch and "🟢 "..Hack[7].name or "🔴 "..Hack[7].name, icon = "", action = 7},
        {name = Hack[8].name, icon = "⚙️", action = 8},
        {name = "🚫 ออกจากสคริปต์", icon = "", action = 9}
    }

    local choice = gg.choice(
        -- Create a table of formatted choices with icons
        map(menuOptions, function(option)
            return option.icon .. " " .. option.name
        end),
        nil, "👑 ผู้พัฒนา: Ohmmi\n✅ LINE Rangers Script"
    )

    if not choice then return end
    -- Action based on choice
    for i, option in ipairs(menuOptions) do
        if choice == i then
            ApplyHack(Hack[option.action], i ~= 4 and i ~= 5 and i ~= 6 and i ~= 7)
        end
    end

    -- Exit option
    if choice == 9 then
        toast("👋 เจอกันรอบหน้า!")
        gg.setVisible(true)
        gg.sleep(1000)
        os.exit()
    end
end

-- 🔁 Main Loop
while true do
    ShowMenu()
    while not gg.isVisible() do gg.sleep(200) end
    gg.setVisible(false)
end


print("✨ ขอบคุณที่ใช้สคริปต์ | by Ohmmi ✨")
