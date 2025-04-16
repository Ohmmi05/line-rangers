-- 🔥 LINE Rangers v11.0.3 Script by Ohmmi (Lite Edition + Floating GUI)
gg.setVisible(false)

-- 💡 Shortcut
local toast, alert, prompt = gg.toast, gg.alert, gg.prompt


-- 📌 Memory Helpers
local function write(addr, type, val) gg.setValues({{address = addr, flags = type, value = val}}) end
local function read(addr, type) return gg.getValues({{address = addr, flags = type}})[1].value end
local function GetLibBase(lib)
    for _, r in pairs(gg.getRangesList(lib)) do if r.state == "Xa" then return r.start end end
end

-- 📍 Setup
local BaseAddress = GetLibBase("libgame.so")
if not BaseAddress then alert("ไม่พบ libgame.so", "โปรดเข้าเกมก่อนเปิดสคริปต์") os.exit() end

if gg.getTargetInfo().versionName ~= "11.0.3" then
    alert("แจ้งเตือนเวอร์ชัน", "เกมเวอร์ชัน: "..gg.getTargetInfo().versionName..
          "\nสคริปต์รองรับเฉพาะเวอร์ชัน 11.0.3\nกรุณาอัปเดตหากเวอร์ชันไม่ตรง")
end

-- 🧠 Address Utils
local function addr(offset) return BaseAddress + offset end

-- ⚙️ Hack Definitions
local Hack = {
    [1] = { name = "ตีแรง",       offset = 0x82cbac,   type = gg.TYPE_FLOAT },
    [2] = { name = "ตีไว",        offset = 0x4eaa20,   type = gg.TYPE_FLOAT },
    [3] = { name = "ปล่อยตัวไว",  offset = 0x4e5ffc,   type = gg.TYPE_FLOAT },
    [4] = { name = "ฆ่าศัตรู",       offset = 0x5b0fd0,   value = 10000, switch = false, type = gg.TYPE_FLOAT },
    [5] = { name = "ศัตรูไม่ออก",     offset = {0x551614, 0x5524b0, 0x557924}, value = 0, switch = false, type = gg.TYPE_FLOAT },
    [6] = { name = "บอสกิลด์ยืนนิ่ง", offset = 0x587240,   value = -100, switch = false, type = gg.TYPE_FLOAT },
    [7] = { name = "กันรายงาน PVP",   offset = 0x540800,   value = 1.40129846e-40, switch = false, type = gg.TYPE_FLOAT },
    [8] = { name = "ความเร็วเกม", offset = 0xd22654,   type = gg.TYPE_FLOAT },

    modes = {
        ["สเตจหลัก"]   = { [1]=9999, [2]=-100, [3]=0 },
        ["สเตจพิเศษ"] = { [1]=8888, [2]=-90,  [3]=0 },
        ["สเตจจุติ"]   = { [1]=7777, [2]=-80,  [3]=0 },
        ["หอคอย"]     = { [1]=6666, [2]=-70,  [3]=0 },
        ["บอสกิลด์"]   = { [1]=5555, [2]=-60,  [3]=0 },
        ["PVP"]       = { [1]=0,    [2]=0,    [3]=1.40129846e-40 },
    }
}

-- ✅ Apply Hack
local function ApplyHack(h, askUser)
    local addrs = type(h.offset) == "table" and h.offset or {h.offset}
    h.base = h.base or {}
    for i, o in ipairs(addrs) do h.base[i] = h.base[i] or addr(o) end

    if askUser then
        local current = read(h.base[1], h.type)
        local input = prompt({"🔧 "..h.name}, {tostring(current)}, {"number"})
        if input and tonumber(input[1]) then
            for _, a in ipairs(h.base) do write(a, h.type, tonumber(input[1])) end
            toast("✅ "..h.name.." = "..input[1])
        end
    else
        h.switch = not h.switch
        h.off = h.off or read(h.base[1], h.type)
        local v = h.switch and h.value or h.off
        for _, a in ipairs(h.base) do write(a, h.type, v) end
        toast((h.switch and "🟢 เปิดใช้งาน " or "🔴 ปิดใช้งาน ")..h.name)
    end
end

-- 🎯 Auto Mode
local function ApplyAutoMode(modeName)
    local mode = Hack.modes[modeName]
    if not mode then toast("❌ ไม่พบโหมด: "..modeName) return end
    for i = 1, 3 do
        local h = Hack[i]
        if mode[i] then
            h.base = h.base or {}
            local addrs = type(h.offset) == "table" and h.offset or {h.offset}
            for j, o in ipairs(addrs) do h.base[j] = h.base[j] or addr(o) end
            for _, a in ipairs(h.base) do write(a, h.type, mode[i]) end
        end
    end
    toast("⚡ โหมดที่ใช้: "..modeName)
end

-- ♻️ Reset All Hacks
local function ResetAll()
    for _, h in pairs(Hack) do
        if h.switch and h.off then
            local base = type(h.base) == "table" and h.base or {h.base}
            for _, a in ipairs(base) do write(a, h.type, h.off) end
            h.switch = false
        end
    end
    toast("✅ รีเซ็ตทั้งหมดแล้ว")
end

-- 🪟 Floating GUI
local function FloatingGUI()
    while true do
        if gg.isVisible() then
            gg.setVisible(false)

            local main = gg.choice({
                "🎛️ ปรับค่าเอง",
                "⚡ โหมดอัตโนมัติ",
                "🔘 เปิด/ปิดฟังก์ชัน",
                "🔄 รีเซ็ตทั้งหมด",
                "🚫 ปิดเกม",
                "👋 ออกจากสคริปต์"
            }, nil, "👑 LINE Rangers Mod Menu\nby Ohmmi")

            if not main then return end

            if main == 1 then
                local options = {}
                for i = 1, 3 do table.insert(options, "[⚙️] "..Hack[i].name) end
                table.insert(options, "[⚙️] "..Hack[8].name)
                local selected = gg.multiChoice(options, nil, "🎛️ เลือกฟังก์ชันเพื่อปรับ")
                if selected then
                    for i = 1, #options do
                        if selected[i] and Hack[i] then
                            ApplyHack(Hack[i], true)
                        elseif selected[i] and i == 4 then
                            ApplyHack(Hack[8], true)
                        end
                    end
                end

            elseif main == 2 then
                local modeList = { "สเตจหลัก", "สเตจพิเศษ", "สเตจจุติ", "หอคอย", "บอสกิลด์", "PVP" }
                local picked = gg.choice(modeList, nil, "⚡ เลือกโหมด:")
                if picked then ApplyAutoMode(modeList[picked]) end

            elseif main == 3 then
                local toggles = {}
                for i = 4, 7 do
                    local status = Hack[i].switch and "🟢" or "🔴"
                    table.insert(toggles, "["..status.."] "..Hack[i].name)
                end
                local selected = gg.multiChoice(toggles, nil, "🔘 เปิด/ปิดฟังก์ชัน")
                if selected then
                    for i = 4, 7 do
                        if selected[i - 3] then
                            ApplyHack(Hack[i], false)
                        end
                    end
                end

            elseif main == 4 then
                ResetAll()
            elseif main == 5 then
                toast("🛑 ปิดเกม") gg.processKill() os.exit()
            elseif main == 6 then
                toast("👋 เจอกันรอบหน้า!") os.exit()
            end
        end
        gg.sleep(300)
    end
end

-- 🚀 Start GUI
FloatingGUI()
