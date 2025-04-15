-- LINE Rangers Script v11.0.3 by Ohmmi (Premium Edition)

gg.setVisible(false)

local toast, alert, prompt = gg.toast, gg.alert, gg.prompt

-- 🌐 Language Selection
local Lang = {}
local LangChoice = gg.choice({"🇹🇭 ไทย", "🇺🇸 English"}, nil, "🌐 Select Language / เลือกภาษา")
if not LangChoice then os.exit() end

Lang = LangChoice == 1 and {
    POWER = "ตีแรง", SPEED = "ตีไว", SPAWN = "ปล่อยตัวไว", INSTANT_KILL = "ฆ่าศัตรู",
    BLOCK_ENEMY = "ศัตรูไม่ออก", FREEZE_BOSS = "บอสกิลด์ยืนนิ่ง", ANTI_REPORT = "กันรายงาน PVP",
    GAME_SPEED = "ความเร็วเกม", RESET_ALL = "🔄 รีเซ็ตฟังก์ชันทั้งหมด", CLOSE_GAME = "🚫 ปิดเกม",
    EXIT_SCRIPT = "🚫 ออกจากสคริปต์", SCRIPT_BY = "👑 ผู้พัฒนา: Ohmmi",
    SCRIPT_NAME = "✅ LINE Rangers Script ", ALERT_VERSION = "แจ้งเตือน",
    UNSUPPORTED_VERSION = "เกมเวอร์ชัน: %s\n\nเวอร์ชันที่รองรับ: 11.0.3\nกรุณาอัปเดตสคริปต์หากใช้เวอร์ชันอื่น",
    NO_LIB = "ไม่พบ libgame.so\nโปรดเข้าเกมก่อนเปิดสคริปต์",
    EXIT_MSGS = {
        "👋 เจอกันรอบหน้า!", "🛡️ พักก่อน นักรบ!", "🎮 เล่นให้สนุกนะ!",
        "😎 สคริปต์เทพไว้ใจได้ by Ohmmi!", "🚀 ออกแล้ว บินได้!"
    }
} or {
    POWER = "Power Up", SPEED = "Attack Speed", SPAWN = "Reduce Ranger CD Time ", INSTANT_KILL = "Instant Kill",
    BLOCK_ENEMY = "Enemy Doesn't Appear", FREEZE_BOSS = "Freeze Guild Boss", ANTI_REPORT = "Anti-Report (PVP)",
    GAME_SPEED = "Game Speed", RESET_ALL = "🔄 Reset All Functions", CLOSE_GAME = "🚫 Close Game",
    EXIT_SCRIPT = "🚫 Exit Script", SCRIPT_BY = "👑 Developer: Ohmmi",
    SCRIPT_NAME = "✅ LINE Rangers Script ", ALERT_VERSION = "Warning",
    UNSUPPORTED_VERSION = "Game Version: %s\n\nSupported Version: 11.0.3\nPlease update the script if using another version.",
    NO_LIB = "libgame.so not found\nPlease enter game before running script.",
    EXIT_MSGS = {
        "👋 See you again!", "🛡️ Take a break, Ranger!", "🎮 Have fun playing!",
        "😎 God-tier script by Ohmmi!", "🚀 Exiting now!"
    }
}

-- 🔧 Hack Definitions
local function addr(offset) return BaseAddress + offset end
local Hack = {
    [1] = { name = Lang.POWER,       offset = 0x82cbac,   type = gg.TYPE_FLOAT },
    [2] = { name = Lang.SPEED,       offset = 0x4eaa20,   type = gg.TYPE_FLOAT },
    [3] = { name = Lang.SPAWN,       offset = 0x4e5ffc,   type = gg.TYPE_FLOAT },
    [4] = { name = Lang.INSTANT_KILL,offset = 0x5b0fd0,   value = 10000, switch = false, type = gg.TYPE_FLOAT },
    [5] = { name = Lang.BLOCK_ENEMY, offset = {0x551614, 0x5524b0, 0x557924}, value = 0, switch = false, type = gg.TYPE_FLOAT },
    [6] = { name = Lang.FREEZE_BOSS, offset = 0x587240,   value = -100, switch = false, type = gg.TYPE_FLOAT },
    [7] = { name = Lang.ANTI_REPORT, offset = 0x540800,   value = 1.40129846e-40, switch = false, type = gg.TYPE_FLOAT },
    [8] = { name = Lang.GAME_SPEED,  offset = 0xd22654,   type = gg.TYPE_FLOAT },
}

-- 🧠 Memory Helpers
local function write(addr, type, val) gg.setValues({{address = addr, flags = type, value = val}}) end
local function read(addr, type) return gg.getValues({{address = addr, flags = type}})[1].value end
local function GetLibBase(lib)
    for _, r in pairs(gg.getRangesList(lib)) do if r.state == "Xa" then return r.start end end
end

-- 📌 Setup
BaseAddress = GetLibBase("libgame.so")
if not BaseAddress then alert("Error", Lang.NO_LIB) os.exit() end
if gg.getTargetInfo().versionName ~= "11.0.3" then
    alert(Lang.ALERT_VERSION, string.format(Lang.UNSUPPORTED_VERSION, gg.getTargetInfo().versionName))
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
        local input = prompt({"🔧 "..h.name}, {tostring(cur)}, {"number"})
        if input and tonumber(input[1]) then
            for _, a in ipairs(h.base) do write(a, h.type, tonumber(input[1])) end
            toast("✅ "..h.name.." = "..input[1])
        end
    else
        h.switch = not h.switch
        if not h.off then h.off = read(h.base[1], h.type) end
        local val = h.switch and h.value or h.off
        for _, a in ipairs(h.base) do write(a, h.type, val) end
        toast((h.switch and "🟢 " or "🔴 ")..h.name.." = "..val)
    end
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
    toast("✅ "..Lang.RESET_ALL)
end

-- 📋 Menu
local function ShowMenu()
    local m = gg.multiChoice({
        string.format("[⚙️] %s", Hack[1].name),
        string.format("[⚙️] %s", Hack[2].name),
        string.format("[⚙️] %s", Hack[3].name),
        string.format("[%s] %s", Hack[4].switch and "🟢" or "🔴", Hack[4].name),
        string.format("[%s] %s", Hack[5].switch and "🟢" or "🔴", Hack[5].name),
        string.format("[%s] %s", Hack[6].switch and "🟢" or "🔴", Hack[6].name),
        string.format("[%s] %s", Hack[7].switch and "🟢" or "🔴", Hack[7].name),
        string.format("[⚙️] %s", Hack[8].name),
        Lang.RESET_ALL, Lang.CLOSE_GAME, Lang.EXIT_SCRIPT
    }, nil, Lang.SCRIPT_BY .. "\n" .. Lang.SCRIPT_NAME)

    if not m then return end
    for i = 1, 8 do if m[i] then ApplyHack(Hack[i], i ~= 4 and i ~= 5 and i ~= 6 and i ~= 7) end end
    if m[9] then ResetAll() end
    if m[10] then toast("🛑 "..Lang.CLOSE_GAME) gg.processKill() os.exit() end
    if m[11] then toast(Lang.EXIT_MSGS[math.random(#Lang.EXIT_MSGS)]) gg.setVisible(true) gg.sleep(1000) os.exit() end
end

-- 🔁 Main Loop
while true do
    ShowMenu()
    while not gg.isVisible() do gg.sleep(200) end
    gg.setVisible(false)
end

print("✨ Thank you for using the script! | by Ohmmi ✨")
