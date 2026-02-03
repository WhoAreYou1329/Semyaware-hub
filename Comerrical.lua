-- === CONFIGURATION ===
local script_id = getgenv().SCRIPT_ID
local script_name = getgenv().SCRIPT_NAME
local ADMIN_UUID = "1F6733A0-D7DA-11DD-99C4-D850E6B9C9EE"
local url = "https://semyaware.ru/virtualstorage/" .. script_id .. "/" .. script_name

-- === MD5 FUNC (Compact) ===
local function md5(s)
    local k = {0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,0x6b901122,0xfd987193,0xa679438e,0x49b40821,0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391}
    local bit = bit32 or require("bit")
    local band, bor, bnot, bxor, lshift, rshift = bit.band, bit.bor, bit.bnot, bit.bxor, bit.lshift, bit.rshift
    local function left_rotate(x, c) return bor(lshift(x, c), rshift(x, 32 - c)) end
    local h0, h1, h2, h3 = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
    local r = {7, 12, 17, 22,  5, 9, 14, 20,  4, 11, 16, 23,  6, 10, 15, 21}
    local msg = {}
    for i = 1, #s do table.insert(msg, string.byte(s, i)) end
    local len = #s * 8
    table.insert(msg, 0x80)
    while (#msg * 8 + 64) % 512 ~= 0 do table.insert(msg, 0) end
    table.insert(msg, band(len, 0xFF)); table.insert(msg, band(rshift(len, 8), 0xFF))
    table.insert(msg, band(rshift(len, 16), 0xFF)); table.insert(msg, band(rshift(len, 24), 0xFF))
    for i = 1, 4 do table.insert(msg, 0) end
    for i = 1, #msg, 64 do
        local w = {}
        for j = 0, 15 do w[j+1] = bor(msg[i+j*4], lshift(msg[i+j*4+1], 8), lshift(msg[i+j*4+2], 16), lshift(msg[i+j*4+3], 24)) end
        local a, b, c, d = h0, h1, h2, h3
        for j = 0, 63 do
            local f, g
            if j < 16 then f = bor(band(b, c), band(bnot(b), d)); g = j
            elseif j < 32 then f = bor(band(d, b), band(bnot(d), c)); g = (5 * j + 1) % 16
            elseif j < 48 then f = bxor(b, c, d); g = (3 * j + 5) % 16
            else f = bxor(c, bor(b, bnot(d))); g = (7 * j) % 16 end
            local temp = d; d = c; c = b; b = (b + left_rotate((a + f + k[j+1] + w[g+1]) % 4294967296, r[math.floor(j/16)*4 + (j%4) + 1])) % 4294967296; a = temp
        end
        h0 = (h0 + a) % 4294967296; h1 = (h1 + b) % 4294967296; h2 = (h2 + c) % 4294967296; h3 = (h3 + d) % 4294967296
    end
    local function tohex(n) local s = ""; for i = 0, 3 do s = s .. string.format("%02x", band(rshift(n, i*8), 0xFF)) end return s end
    return tohex(h0) .. tohex(h1) .. tohex(h2) .. tohex(h3)
end

-- === MAIN LOGIC ===
local timestamp = tostring(os.time())
local signature = md5(ADMIN_UUID .. script_name .. timestamp)

local req = (syn and syn.request) or (http and http.request) or http_request or request
if not req then return warn("HttpReq Missing") end

local response = req({
    Url = url, Method = "GET",
    -- ВАЖНО: Заголовки должны совпадать с вашим config.php
    Headers = { ["helloskid"] = timestamp, ["protectus"] = signature }
})

if response.StatusCode == 200 then
    -- === НОВАЯ БЫСТРАЯ РАСШИФРОВКА ===
    local function fast_decrypt(data)
        -- 1. Переворачиваем обратно
        local reversed = string.reverse(data)
        reversed = string.gsub(reversed, "%s+", "") -- Чистим мусор
        
        -- 2. Декодируем (сначала нативные методы)
        local success, result = pcall(function()
            if syn and syn.crypt then return syn.crypt.base64.decode(reversed) end
            if crypt and crypt.base64 then return crypt.base64.decode(reversed) end
            if bit and bit.base64_decode then return bit.base64_decode(reversed) end
            error("No native") 
        end)
        if success and result then return result end

        -- 3. Fallback (Lua Decoder)
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        reversed = string.gsub(reversed, '[^'..b..'=]', '')
        return (reversed:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end
    
    local code = fast_decrypt(response.Body)
    
    local f, err = loadstring(code)
    if f then 
        f() 
    else 
        warn("Compile Error:", err) 
    end
end
