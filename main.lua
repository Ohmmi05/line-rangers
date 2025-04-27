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
    [6] = { name = "บอสกิลด์ยืนนิ่ง", offset = 0x587240, value = -100, switch = false, type = gg.TYPE_FLOAT },
    [7] = { name = "กันรายงาน PVP", offset = 0x540800, value = 1.40129846e-40, switch = false, type = gg.TYPE_FLOAT },
    [8] = { name = "ความเร็วเกม", offset = 0xd22654, type = gg.TYPE_FLOAT },
}

-- 🧠 Memory Helpers
local function write(addr, type, val)
    gg.setValues({{address = addr, flags = type, value = val}})
end

local function read(addr, type)
    return gg.getValues({{address = addr, flags = type}})[1].value
end

local function GetLibBase(lib)
    for _, r in pairs(gg.getRangesList(lib)) do
        if r.state == "Xa" then return r.start end
    end
end

-- 📌 Setup
BaseAddress = GetLibBase("libgame.so")
if not BaseAddress then
    alert("Error", "ไม่พบ libgame.so\nโปรดเข้าเกมก่อนเปิดสคริปต์")
    os.exit()
end

if gg.getTargetInfo().versionName ~= "11.0.3" then
    alert("แจ้งเตือน", string.format(
        "เกมเวอร์ชัน: %s\n\nเวอร์ชันที่รองรับ: 11.0.3\nกรุณาอัปเดตสคริปต์หากใช้เวอร์ชันอื่น",
        gg.getTargetInfo().versionName
    ))
end

-- 💥 Cheat Function
local function ApplyHack(h, promptMode)
    local addrs = type(h.offset) == "table" and h.offset or {h.offset}

    if not h.base then h.base = {} end
    for i, o in ipairs(addrs) do
        h.base[i] = h.base[i] or addr(o)
    end

    if promptMode then
        local cur = read(h.base[1], h.type)
        local input = prompt({"⚙️ "..h.name}, {tostring(cur)}, {"number"})
        if input and tonumber(input[1]) then
            for _, a in ipairs(h.base) do
                write(a, h.type, tonumber(input[1]))
            end
            toast("⚙️ ปรับ "..h.name)
        end
    else
        h.switch = not h.switch
        if not h.off then h.off = read(h.base[1], h.type) end
        local val = h.switch and h.value or h.off
        for _, a in ipairs(h.base) do
            write(a, h.type, val)
        end
        toast((h.switch and "🟢 เปิดใช้งาน " or "🔴 ปิดการทำงาน ")..h.name)
    end
end

-- 🔥 ฟังก์ชันจัดชุดค่าอัตโนมัติ
function ApplyPreset(preset)
    for _, item in ipairs(preset) do
        local h = Hack[item.id]
        if h then
            local addrs = type(h.offset) == "table" and h.offset or {h.offset}
            if not h.base then h.base = {} end
            for i, o in ipairs(addrs) do
                h.base[i] = h.base[i] or addr(o)
            end
            for _, a in ipairs(h.base) do
                write(a, h.type, item.value)
            end
        end
    end
    toast("🟢 เปิดใช้งาน")
end

-- 📋 Manual Hack Menu (ให้ user ปรับเอง)
function ShowManualMenu()
    local menuItems = {}
    for i, h in ipairs(Hack) do
        table.insert(menuItems, "➤ "..h.name)
    end
    table.insert(menuItems, "↩ กลับไปเมนูหลัก")
    local choice = gg.choice(menuItems, nil, " โหมดปรับเอง")

    if not choice then return end
    if choice <= #Hack then
        ApplyHack(Hack[choice], true)
    else
        ShowMainMenu()
    end
end

-- 📋 Auto Hack Menu (แบบเซ็ตอัตโนมัติ)
function AutoHackMenu()
    local presetMenu = {
        "➤ สเตจหลัก",
        "➤ สเตจพิเศษ",
        "➤ สเตจจุติ",
        "➤ กิลด์เหรด",
        "➤ กิลด์วอร์",
        "➤ หอคอย",
        "➤ โหมด PVP",
        "↩ กลับไปเมนูหลัก"
    }
    local choice = gg.choice(presetMenu, nil, " โหมดอัติโนมัติ")

    if choice == 1 then
        ApplyPreset({
            {id = 2, value = 10},
            {id = 3, value = -3},
            {id = 5, value = 0},
            {id = 8, value = 0.5}
        })
    elseif choice == 2 then
        ApplyPreset({
            {id = 2, value = 10},
            {id = 3, value = -3},
            {id = 5, value = 0},
            {id = 8, value = 0.5}
        })
    elseif choice == 3 then
        ApplyPreset({
            {id = 1, value = 1000000},
            {id = 3, value = -3},
            {id = 7, value = 1.40129846e-40}
        })
    elseif choice == 4 then
        ApplyPreset({
            {id = 1, value = 200},
            {id = 3, value = -3},
            {id = 4, value = 10000},
            {id = 6, value = -100}
        })
    elseif choice == 5 then
        ApplyPreset({
            {id = 2, value = 10000},
            {id = 4, value = 10000}
        })
    elseif choice == 6 then
        ApplyPreset({
            {id = 2, value = 30},
            {id = 4, value = 10000},
            {id = 8, value = 0.5}
        })
    elseif choice == 7 then
        ApplyPreset({
            {id = 5, value = 0},
            {id = 7, value = 1.40129846e-40}
        })
    elseif choice == 8 then
        ShowMainMenu()
    end
end

-- 📋 Main Menu
function ShowMainMenu()
    local menuItems = {
        "➤ โหมดปรับเอง",
        "➤ โหมดอัตโนมัติ",
        "🚫 ออกจากสคริปต์"
    }
    local choice = gg.choice(menuItems, nil, "👑 ผู้พัฒนา: Ohmmi\n\nเลือกหมวดหมู่:")

    if choice == 1 then
        ShowManualMenu()
    elseif choice == 2 then
        AutoHackMenu()
    elseif choice == 3 then
        local exitMsgs = {
            "👋 เจอกันรอบหน้า!", "🛡️ พักก่อน นักรบ!", "🎮 เล่นให้สนุกนะ!",
            "😎 สคริปต์เทพไว้ใจได้ by Ohmmi!", "🚀 ออกแล้ว บินได้!"
        }
        toast(exitMsgs[math.random(#exitMsgs)])
        gg.setVisible(true)
        gg.sleep(1000)
        os.exit()
    end
end

-- 🔁 Main Loop
while true do
    ShowMainMenu()
    while not gg.isVisible() do
        gg.sleep(200)
    end
    gg.setVisible(false)
end

print("✨ ขอบคุณที่ใช้สคริปต์ | by Ohmmi ✨")
