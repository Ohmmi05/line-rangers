-- 🚀 Start Script
gg.setVisible(false)

-- 🎯 Shortcuts
local toast, alert, prompt = gg.toast, gg.alert, gg.prompt

-- 📦 Hack Definitions
local function addr(offset)
    return BaseAddress + offset
end

local Hack = {
    { name = "ตีแรง", offset = 0x82cbac, type = gg.TYPE_FLOAT },
    { name = "ตีไว", offset = 0x4eaa20, type = gg.TYPE_FLOAT },
    { name = "ปล่อยตัวไว", offset = 0x4e5ffc, type = gg.TYPE_FLOAT },
    { name = "ฆ่าศัตรู", offset = 0x5b0fd0, value = 10000, type = gg.TYPE_FLOAT },
    { name = "ศัตรูไม่ออก", offset = {0x551614, 0x5524b0, 0x557924}, value = 0, type = gg.TYPE_FLOAT },
    { name = "บอสกิลด์ยืนนิ่ง", offset = 0x587240, value = -100, type = gg.TYPE_FLOAT },
    { name = "กันรายงาน PVP", offset = 0x540800, value = 1.40129846e-40, type = gg.TYPE_FLOAT },
    { name = "ความเร็วเกม", offset = 0xd22654, type = gg.TYPE_FLOAT },
}

-- 🧠 Memory Helpers
local function write(address, type, value)
    gg.setValues({{ address = address, flags = type, value = value }})
end

local function read(address, type)
    return gg.getValues({{ address = address, flags = type }})[1].value
end

local function GetLibBase(libName)
    for _, range in pairs(gg.getRangesList(libName)) do
        if range.state == "Xa" then
            return range.start
        end
    end
end

-- 🔧 Apply Hack
local function ApplyHack(h)
    local addrs = type(h.offset) == "table" and h.offset or {h.offset}
    for _, offset in ipairs(addrs) do
        local address = addr(offset)
        if h.value then
            write(address, h.type, h.value)
            toast("✅ ดำเนินการ: " .. h.name)
        else
            local current = read(address, h.type)
            local input = prompt({"⚙️ ปรับค่า: " .. h.name}, {tostring(current)}, {"number"})
            if input and tonumber(input[1]) then
                write(address, h.type, tonumber(input[1]))
                toast("✅ ตั้งค่าใหม่: " .. h.name)
            else
                toast("⚠️ ยกเลิกการเปลี่ยนแปลง")
            end
        end
    end
end

-- 📋 Main Menu
local function ShowMenu()
    local options = {}
    for i, h in ipairs(Hack) do
        table.insert(options, "➤ " .. h.name)
    end
    table.insert(options, "🚫 ออกจากสคริปต์")

    local choice = gg.choice(options, nil, "👑 ผู้พัฒนา: Ohmmi\n\n✅ LINE Rangers Script v11.0.3\n\nเลือกสิ่งที่คุณต้องการทำ")
    
    if choice == nil then
        return
    elseif choice == #options then
        toast("👋 เจอกันรอบหน้า!")
        gg.setVisible(true)
        gg.sleep(1000)
        os.exit()
    elseif Hack[choice] then
        ApplyHack(Hack[choice])
    end
end

-- ⚙️ Setup & Version Check
BaseAddress = GetLibBase("libgame.so")
if not BaseAddress then
    alert("❌ Error", "ไม่พบ libgame.so\nโปรดเข้าเกมก่อนเปิดสคริปต์")
    os.exit()
end

local gameVersion = gg.getTargetInfo().versionName
if gameVersion ~= "11.0.3" then
    alert("⚠️ แจ้งเตือน", string.format(
        "เกมเวอร์ชัน: %s\n\nเวอร์ชันที่รองรับ: 11.0.3\nกรุณาอัปเดตสคริปต์หากใช้เวอร์ชันอื่น", 
        gameVersion
    ))
end

-- 🔄 Main Loop
while true do
    ShowMenu()
    while not gg.isVisible() do
        gg.sleep(200)
    end
    gg.setVisible(false)
end

-- 🎉 End of Script
print("✨ ขอบคุณที่ใช้สคริปต์ | by Ohmmi ✨")
