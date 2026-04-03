# IEEE-488 (GPIB) Protocol Specification
## Reverse-Engineered from Firmware — Dual-Channel Power Supply

---

## 1. System Architecture

The instrument contains two 6802 processors connected via an optically-isolated UART link:

- **Primary Controller** — Manages the analog hardware: DACs, ADCs, analog switches,
  voltage/current regulation loops. Runs from 4K PROM.
- **GPIB Controller** — Handles all IEEE-488 bus communication. Contains an MC68488
  GPIA (General Purpose Interface Adapter) for GPIB bus management and an MC6850 ACIA
  for the inter-processor UART link.

The GPIB controller parses commands received over the IEEE-488 bus, translates them into
3-byte UART messages, sends them to the primary controller, receives 3-byte responses,
and formats the results back into GPIB response strings.

```
                 OPTOCOUPLERS
  IEEE-488       ┌──────────┐        ANALOG
  GPIB Bus ──── MC68488 ── ACIA ══════════ ACIA ── 6802 ──── DACs/ADCs
                 6802       │  UART LINK  │        Primary   Analog Switches
                 GPIB Ctrl  └──────────┘         Controller  Voltage/Current
```


## 2. GPIB Bus Configuration

- **Address**: Set by DIP switch (5-bit, bits 4:0 of MC68488 Address Register)
- **Capabilities**: Talk and Listen
- **Serial Poll**: Supported (status byte in MC68488 SPR, SRQ assertion)
- **Device Clear**: Supported (DCAS handling)
- **Termination**: Commands terminated by CR (0x0D), LF (0x0A), or EOI
- **Character set**: Alphanumeric (A-Z, a-z, 0-9), period (.), CR, LF only.
  Characters ` ' + , - / : ; \ ` and all control characters are rejected.
- **Max command length**: 50 characters


## 3. Command Reference

All commands are ASCII strings terminated by CR, LF, or EOI. Commands are
case-sensitive — set commands use lowercase letters.

### 3.1 Set Voltage

Set the output voltage for a channel.

| Command | Description |
|---------|-------------|
| `aXXXX` | Set Channel A voltage |
| `bXXXX` | Set Channel B voltage |

`XXXX` is a decimal number. The firmware parses up to 4 digits and converts to a 16-bit
binary value which is sent to the primary controller's DAC. The exact voltage scaling
depends on the DAC and analog circuitry (needs to be determined from the hardware).

The GPIB talk response includes a decimal point: `VSA XX.XX` or `VSB XX.XX`.

**Examples:**
```
a1250    → Set Channel A voltage to 12.50 (units TBD)
b0500    → Set Channel B voltage to 05.00
```

### 3.2 Set Current

Set the output current / current limit for a channel.

| Command | Description |
|---------|-------------|
| `cXXXX` | Set Channel A current |
| `dXXXX` | Set Channel B current |

Same numeric format as voltage commands. Response format: `ISA XX.XX` or `ISB XX.XX`.

### 3.3 Set Voltage Override

| Command | Description |
|---------|-------------|
| `iXXXX` | Set Channel A voltage override |
| `jXXXX` | Set Channel B voltage override |

Response format: `VOA XX.XX` or `VOB XX.XX`.

The exact meaning of "override" vs "set" needs confirmation from the analog hardware,
but likely sets the voltage directly bypassing any tracking or limit logic.

### 3.4 Set Current Override

| Command | Description |
|---------|-------------|
| `kXXXX` | Set Channel A current override |
| `lXXXX` | Set Channel B current override |

Response format: `IOA XX.XX` or `IOB XX.XX`.

### 3.5 Set Voltage Limit

| Command | Description |
|---------|-------------|
| `eXXXX` | Set Channel A voltage limit |
| `fXXXX` | Set Channel B voltage limit |

Response format: `VLA XXXXX` or `VLB XXXXX` (no decimal point — 5 digit integer).

### 3.6 Set Current Limit

| Command | Description |
|---------|-------------|
| `gXXXX` | Set Channel A current limit |
| `hXXXX` | Set Channel B current limit |

Response format: `ILA XXXXX` or `ILB XXXXX` (no decimal point — 5 digit integer).

### 3.7 Query Status

| Command | Description |
|---------|-------------|
| `q`     | Query full instrument status |

Returns a multi-field response string:

```
[ChA_mode]/[ChB_mode]/[tracking]/[output]<CR><LF+EOI>
```

**Channel mode fields** (4 characters each):

| String | Meaning |
|--------|---------|
| `A CV` | Channel A — Constant Voltage mode |
| `A CC` | Channel A — Constant Current mode |
| `A IL` | Channel A — Current Limit active |
| `A VL` | Channel A — Voltage Limit active |
| `B CV` | Channel B — Constant Voltage mode |
| `B CC` | Channel B — Constant Current mode |
| `B IL` | Channel B — Current Limit active |
| `B VL` | Channel B — Voltage Limit active |

**Tracking field** (4 characters):

| String | Meaning |
|--------|---------|
| `T ON` | Tracking mode enabled (channels linked) |
| `TOFF` | Tracking mode disabled |

**Output field** (4-5 characters):

| String | Meaning |
|--------|---------|
| `OPON`  | Output enabled |
| `OPOFF` | Output disabled |

**Example response:**
```
A CV/B CC/TOFF/OPON
```
This indicates Channel A is in constant voltage mode, Channel B is in constant current
mode, tracking is off, and the output is enabled.

### 3.8 Read Error Status

| Command | Description |
|---------|-------------|
| `r`     | Read error/status register |

Returns:
```
ER R [status]<CR><LF+EOI>
```

On success: `ER R OK`
On error: `ER R [code]!` where `[code]` is a single error character (see Section 5).

Reading the error status clears it back to "OK".

### 3.9 Unknown/Invalid Commands

If an unrecognised command character is received, the instrument responds with:

```
[cmd] ??<CR><LF+EOI>
```

Where `[cmd]` is the character that was sent.


## 4. Command-Response Lookup Table

The firmware contains an explicit mapping from command characters to 3-letter response
codes. This table is used when building GPIB talk responses after a set command:

| Command | Response Code | Full Meaning |
|---------|--------------|--------------|
| `a`     | `VSA`        | Voltage Set A |
| `b`     | `VSB`        | Voltage Set B |
| `c`     | `ISA`        | Current Set A |
| `d`     | `ISB`        | Current Set B |
| `e`     | `VLA`        | Voltage Limit A |
| `f`     | `VLB`        | Voltage Limit B |
| `g`     | `ILA`        | Current Limit A |
| `h`     | `ILB`        | Current Limit B |
| `i`     | `VOA`        | Voltage Override A |
| `j`     | `VOB`        | Voltage Override B |
| `k`     | `IOA`        | Current Override A |
| `l`     | `IOB`        | Current Override B |

Set commands (`a`-`d`, `i`-`l`) respond with a decimal-pointed value: `CODE XX.XX`
Limit commands (`e`-`h`) respond with an integer value: `CODE XXXXX`

Leading zeros are suppressed in responses.


## 5. Error / Status Codes

Single-character status codes used internally between the two processors and reported
via GPIB serial poll and the `r` (read status) command:

| Code | Hex  | Meaning |
|------|------|---------|
| `OK` | $4F4B | No error — normal operation |
| `I`  | $49   | Internal error (from primary controller) |
| `J`  | $4A   | NMI hardware fault (from GPIB controller NMI handler) |
| `K`  | $4B   | UART communication error (inter-processor link failure) |
| `M`  | $4D   | Syntax error (invalid character in command) |
| `N`  | $4E   | Value out of range (from primary controller) |
| `O`  | $4F   | Command overflow (exceeded 50-character limit) |

### Serial Poll Status Byte

The instrument supports IEEE-488 serial polling. The serial poll response byte (MC68488
SPR register) contains the same single-character error code. When an error occurs:

1. The error code is written to the MC68488 Serial Poll Register
2. This asserts SRQ on the GPIB bus
3. The controller can serial-poll to read the status byte
4. After the poll is serviced, the status is cleared

The SRQ/poll mechanism is also used for status change notifications (e.g., when a
channel transitions between CV/CC modes).


## 6. Inter-Processor UART Protocol

### 6.1 Physical Layer

- **Baud rate**: Determined by MC6850 ACIA configuration — clock divider set to /16
- **Format**: 8 data bits, 2 stop bits, no parity
- **Isolation**: Optocoupler-isolated
- **Flow control**: Software (polling with timeout)

### 6.2 Message Format

All exchanges are 3 bytes in each direction, preceded by a handshake byte:

```
GPIB Controller → Primary Controller:
  [handshake: link_state_flags byte]
  [wait for acknowledgment]
  [byte 0: command character]
  [byte 1: data high byte]
  [byte 2: data low byte]

Primary Controller → GPIB Controller:
  [acknowledgment byte]
  [byte 0: command echo | 0x80 on error]
  [byte 1: response data high]
  [byte 2: response data low]
```

### 6.3 Handshake Protocol

1. GPIB controller sends `link_state_flags` byte
2. Primary controller echoes back with framing bits (masked by 0x30)
3. GPIB controller waits for echo with framing bits cleared
4. 3-byte command is sent
5. 3-byte response is received
6. Response byte 0 is compared against sent command (with bit 7 masked)
7. If mismatch, retry up to 5 times

### 6.4 Framing Byte Types

The UART link uses bits 5:4 of each byte to distinguish frame types:

| Bits 5:4 | Value | Meaning |
|----------|-------|---------|
| `00`     | $00   | Handshake acknowledgment (no framing) |
| `01`     | $10   | Status frame (mode change notification) |
| `10`     | $20   | Device status update (channel modes, tracking, output) |
| `11`     | $30   | Link state update |

### 6.5 Asynchronous Status Updates

The primary controller can send unsolicited status updates to the GPIB controller
between command exchanges. These are received by the `uart_poll_rx` function in the
main loop:

- **Status update (0x20 frame)**: Carries the device status byte which encodes channel
  modes (CV/CC/IL/VL), tracking state, and output state.
- **Link state (0x30 frame)**: Carries link synchronisation state.
- **Error codes (0x10 frame with payload)**: Single-character error notifications
  ('I'=internal, 'J'=NMI, 'T'=talker, 'S'=serial poll).

### 6.6 Primary Controller Command Dispatch

The primary controller dispatches on the command byte (byte 0) minus 0x41 ('A') as an
index into a jump table. The command mapping is:

| Byte 0 Range | Jump Table Index | Function |
|-------------|------------------|----------|
| `A`-`H` ($41-$48) | 0-7 | Set voltage/current (value in bytes 1:2) |
| `I`-`L` ($49-$4C) | 8-11 | Set limits |
| `Q` ($51) | 16 | Enable tracking |
| `R` ($52) | 17 | Disable tracking |
| `S` ($53) | 18 | Serial poll acknowledgment |
| `T` ($54) | 19 | Talker state update |
| `U` ($55) | 20 | Status update request |
| `V` ($56) | 21 | Device clear notification |
| `Y` ($59) | 24 | Enable output |
| `Z` ($5A) | 25 | Disable output |
| `a`-`l` ($61-$6C) | 32-43 | Readback (returns current actual values) |
| `q` ($71) | 48 | Query state |
| `r` ($72) | 49 | Read status |


## 7. Numeric Value Format

### 7.1 Input Parsing

Numeric arguments are parsed as decimal ASCII digit strings (up to 4 digits). The
firmware converts using a repeated-subtraction division algorithm with a powers-of-ten
table:

```
Powers: 10000 ($2710), 1000 ($03E8), 100 ($0064), 10 ($000A)
```

The resulting 16-bit binary value is transmitted to the primary controller in bytes 1:2
of the UART message (big-endian).

### 7.2 Output Formatting

For GPIB talk responses, 16-bit binary values from the primary controller are converted
back to decimal ASCII using the same powers-of-ten table. The format depends on the
command type:

- **Voltage/Current set commands** (a-d, i-l): `XX.XX` with decimal point after digit 2
- **Limit commands** (e-h): `XXXXX` as a plain integer

Leading zeros are suppressed (replaced with spaces).


## 8. Implementation Notes for Building a GPIB Controller

### 8.1 Minimum Viable Controller

To control the instrument over GPIB, a controller needs to:

1. Address the instrument as a listener
2. Send a command string terminated by CR or LF (with or without EOI)
3. For queries, address the instrument as a talker and read until EOI

### 8.2 Example Session

```
Controller → Instrument (Listen):  "a1250\r"     Set Ch A voltage to 12.50
Controller → Instrument (Talk):    reads →        "VSA 12.50\n" (with EOI)
Controller → Instrument (Listen):  "c0300\r"     Set Ch A current to 03.00
Controller → Instrument (Talk):    reads →        "ISA  3.00\n" (with EOI)
Controller → Instrument (Listen):  "q\r"         Query status
Controller → Instrument (Talk):    reads →        "A CV/B CV/TOFF/OPON\n"
Controller → Instrument (Listen):  "r\r"         Read error status
Controller → Instrument (Talk):    reads →        "ER R OK\n"
```

### 8.3 Timing Considerations

- The GPIB controller polls (not interrupt-driven for GPIB), so it will respond at the
  main loop rate.
- UART exchanges with the primary controller include a 0xFFFF-iteration timeout loop
  and up to 5 retries.
- The `q` (query) command waits for status synchronisation between the two processors
  before responding, which may introduce additional latency.

### 8.4 Unresolved Items

- **DAC value scaling**: The exact relationship between the numeric command values and
  physical voltage/current depends on the DAC resolution and analog front-end scaling.
  This needs to be determined from the hardware (DAC IC, reference voltage, op-amp gain).
- **"Override" commands (i-l)**: The distinction between "set" (a-d) and "override"
  (i-l) commands is not fully clear from firmware alone. Likely bypasses tracking or
  limit enforcement.
- **Front panel interaction**: The primary controller also handles keyboard/display via
  PIAs (IC18, IC19, IC20). GPIB commands and front panel controls may interact — the
  firmware appears to manage this via the M0x53 state byte.
