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
        local input = prompt({"🔧 "..h.name}, {tostring(cur)}, {"number"})
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
    toast("✅ รีเซ็ตฟังก์ชันทั้งหมดแล้ว")
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
        "🔄 รีเซ็ตฟังก์ชันทั้งหมด", "🚫 ปิดเกม", "🚫 ออกจากสคริปต์"
    }, nil, "👑 ผู้พัฒนา: Ohmmi\n✅ LINE Rangers Script")

    if not m then return end
    for i = 1, 8 do if m[i] then ApplyHack(Hack[i], i ~= 4 and i ~= 5 and i ~= 6 and i ~= 7) end end
    if m[9] then ResetAll() end
    if m[10] then toast("🛑 ปิดเกมแล้ว") gg.processKill() os.exit() end
    if m[11] then
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
    ShowMenu()
    while not gg.isVisible() do gg.sleep(200) end
    gg.setVisible(false)
end

print("✨ ขอบคุณที่ใช้สคริปต์ | by Ohmmi ✨")
