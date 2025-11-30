# Payload as Text - Wireshark Plugin

A lightweight Wireshark plugin that extracts and displays TCP/UDP payload data as readable text, making it easier to analyze application layer content in network captures.

## Features

- Extracts payload from both TCP and UDP packets
- Sanitizes data to printable ASCII (replaces non-printable characters with `.`)
- Truncates long payloads (>200 characters) for performance
- Adds `payloadtext.data` field for use as a Wireshark column
- Works as a postdissector on existing captures

## Installation

1. Copy `payload-as-text.lua` to your Wireshark plugins directory:
   - **Linux**: `~/.local/lib/wireshark/plugins/`
   - **Windows**: `%APPDATA%\Wireshark\plugins\`
   - **macOS**: `~/Library/Application Support/Wireshark/plugins/`

2. Restart Wireshark or reload plugins via `Analyze → Reload Lua Plugins`

## Usage

### Using as a Column
1. Right-click any column header in the packet list
2. Select "Column Preferences"
3. Click "+" to add a new column
4. Set **Title** to "Payload Text" and **Type** to "Custom"
5. Enter `payloadtext.data` in the **Fields** field

### Viewing in Packet Details
The plugin automatically adds a "Payload Text" section to the packet details tree for any packet containing TCP or UDP payload data.

## Example Output

```
Payload Text
    Payload Text: GET /api/users HTTP/1.1
Host: example.com
User-Agent: curl/7.68.0
Accept: application/json
...
```

## How It Works

The plugin:
- Registers as a postdissector to process all packets after protocol parsing
- Extracts TCP/UDP payload using Wireshark's field system
- Sanitizes binary data to readable ASCII format
- Truncates long payloads for performance
- Adds the cleaned text to the protocol tree

## Limitations

- Only shows printable ASCII characters (non-printable chars become `.`)
- Truncates payloads longer than 200 characters
- Requires payload data to be available (unencrypted, not compressed)

## Technical Details

- **Protocol**: `payloadtext`
- **Field**: `payloadtext.data`
- **Dependencies**: Wireshark with Lua support
- **Performance**: Minimal impact due to early return when no payload exists