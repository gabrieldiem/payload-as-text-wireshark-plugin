-- payload_text.lua
-- Extracts and displays only the inner TCP/UDP payload as readable text.
-- Adds a new field "payloadtext.data" usable as a Wireshark column.

local payload_proto = Proto("payloadtext", "Payload as Text")
local payload_text_field = ProtoField.string("payloadtext.data", "Payload Text")
payload_proto.fields = { payload_text_field }

-- These field handles will be created once and reused.
local tcp_payload_f = Field.new("tcp.payload")
local udp_payload_f = Field.new("udp.payload")

-- Helper: sanitize raw byte string into printable ASCII approximation
local function sanitize_data(raw)
    local clean = raw:gsub("[^%g%s]", ".")
    if #clean > 200 then          -- truncate long text for performance
        clean = clean:sub(1, 197) .. "..."
    end
    return clean
end

function payload_proto.dissector(tvb, pinfo, tree)
    -- try to get TCP payload first, then UDP
    local tcp_field = tcp_payload_f()     -- FFI object (can be nil)
    local udp_field = udp_payload_f()
    local payload_field = tcp_field or udp_field

    if not payload_field then
        return -- nothing to show
    end

    -- Convert to TvbRange that points exactly to payload
    local start = payload_field.offset
    local length = payload_field.len
    if not start or not length or length == 0 then
        return
    end

    local payload_buf = tvb(start, length)
    local raw_bytes = payload_buf:bytes():raw()
    local clean_data = sanitize_data(raw_bytes)

    local subtree = tree:add(payload_proto, payload_buf, "Payload Text")
    subtree:add(payload_text_field, clean_data)
end

register_postdissector(payload_proto)