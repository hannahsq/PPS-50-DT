; f9dasm: M6800/1/2/3/8/9 / H6309 Binary/OS9/FLEX9 Disassembler V1.83
; Loaded binary file gpib_controller.bin
; Loaded binary file gpib_controller.bin

;****************************************************
;* Used Labels                                      *
;****************************************************

gpib_addr EQU     $0000
M0001   EQU     $0001
M0002   EQU     $0002
M0003   EQU     $0003
M0004   EQU     $0004
M0005   EQU     $0005
M0006   EQU     $0006
M0007   EQU     $0007
M0008   EQU     $0008
M0009   EQU     $0009
M000A   EQU     $000A
M000B   EQU     $000B
M000D   EQU     $000D
M000F   EQU     $000F
M0010   EQU     $0010
M0012   EQU     $0012
M0014   EQU     $0014
M0021   EQU     $0021
uart_tx_cmd EQU     $0022
uart_tx_data_hi EQU     $0023
uart_tx_data_lo EQU     $0024
link_state_flags EQU     $0025
spoll_status EQU     $0026
conv_workspace EQU     $0027
M0028   EQU     $0028
M0029   EQU     $0029
M002A   EQU     $002A
M002B   EQU     $002B
M002C   EQU     $002C
M002D   EQU     $002D
conv_accum_hi EQU     $0033
conv_accum_lo EQU     $0034
conv_digit_count EQU     $0035
conv_temp_hi EQU     $0036
conv_temp_lo EQU     $0037
conv_int_digit_count EQU     $0038
gpib_rx_char_count EQU     $0039
gpib_rx_buf_ptr_hi EQU     $003A
M003C   EQU     $003C
gpib_rx_error_flag EQU     $003D
uart_retry_count EQU     $003E
uart_rx_resp EQU     $003F
uart_rx_data_hi EQU     $0040
uart_rx_data_lo EQU     $0041
gpib_csr_snapshot EQU     $0042
dac_value_hi EQU     $0043
dac_value_lo EQU     $0044
device_status_confirmed EQU     $0045
device_status_pending EQU     $0046
error_code_hi EQU     $0047
error_code_lo EQU     $0048
gpib_eoi_flag EQU     $0049
current_gpib_cmd EQU     $004A
srq_pending EQU     $004B
gpib_line_complete EQU     $004C
gpib_tx_ptr_hi EQU     $004D
gpib_tx_last_byte EQU     $004F
STACK_TOP EQU     $007F
ACIA_CSR EQU     $00C0
ACIA_DR EQU     $00C1
STR_UNKNOWN_CMD EQU     $3F3F
STR_ER  EQU     $4552
STR_F_CR EQU     $460D
STR_FF  EQU     $4646
STR_OF  EQU     $4F46
STR_OK  EQU     $4F4B
STR_ON  EQU     $4F4E
STR_OP  EQU     $4F50
STR_R_SPACE EQU     $5220
STR_T_SPACE EQU     $5420
STR_TO  EQU     $544F
MC68488_ISR EQU     $8000
MC68488_CSR EQU     $8001
MC68488_ADSR EQU     $8002
MC68488_ACR EQU     $8003
MC68488_ADR EQU     $8004
MC68488_SPR EQU     $8005
MC68488_DR EQU     $8007

;****************************************************
;* Program Code / Data Areas                        *
;****************************************************

        ORG     $E000

; Set stack pointer to top of RAM
hdlr_RST LDS     #STACK_TOP               ;E000: 8E 00 7F       '...'
        LDAA    #$03                     ;E003: 86 03          '..'
; ACIA Master Reset (write 0x03 to CSR)
        STAA    ACIA_CSR                 ;E005: 97 C0          '..'
        LDAB    #$11                     ;E007: C6 11          '..'
; Configure ACIA: /16 clock, 8N2, RTS asserted, no interrupts
        STAB    ACIA_CSR                 ;E009: D7 C0          '..'
; Disable interrupts during init
        SEI                              ;E00B: 0F             '.'
; Clear all RAM ($0001-$007F)
        LDX     #STACK_TOP               ;E00C: CE 00 7F       '...'
        CLRA                             ;E00F: 4F             'O'
ZE010   STAA    ,X                       ;E010: A7 00          '..'
        DEX                              ;E012: 09             '.'
        BNE     ZE010                    ;E013: 26 FB          '&.'
; Reset MC68488 GPIA (set bit 7 of ACR)
        LDAA    #$80                     ;E015: 86 80          '..'
        STAA    MC68488_ACR              ;E017: B7 80 03       '...'
; Read GPIB address from DIP switch (ADR register)
        LDAA    MC68488_ADR              ;E01A: B6 80 04       '...'
; Mask to 5-bit address (bits 4:0)
        ANDA    #$1F                     ;E01D: 84 1F          '..'
; Store GPIB address in RAM
        STAA    gpib_addr                ;E01F: 97 00          '..'
; OR with $60 to disable talk/listen during setup
        ORAA    #$60                     ;E021: 8A 60          '.`'
; Write address to MC68488 ADR (talk+listen disabled)
        STAA    MC68488_ADR              ;E023: B7 80 04       '...'
; Clear Auxiliary Command Register
        CLR     MC68488_ACR              ;E026: 7F 80 03       '...'
; Clear Interrupt Status Register
        CLR     MC68488_ISR              ;E029: 7F 80 00       '...'
; Set MSA (Mode Select Auxiliary) bit
        LDAA    #$04                     ;E02C: 86 04          '..'
        STAA    MC68488_ACR              ;E02E: B7 80 03       '...'
; Clear ACR again (complete mode select sequence)
        CLR     MC68488_ACR              ;E031: 7F 80 03       '...'
; Clear Address Status/Mode Register
        CLR     MC68488_ADSR             ;E034: 7F 80 02       '...'
; Init GPIB RX buffer pointer to start (M0x01)
        LDX     #M0001                   ;E037: CE 00 01       '...'
        STX     gpib_rx_buf_ptr_hi       ;E03A: DF 3A          '.:'
; Init GPIB TX output pointer to start (M0x01)
        STX     gpib_tx_ptr_hi           ;E03C: DF 4D          '.M'
; Clear last-byte-sent register
        CLR     >gpib_tx_last_byte       ;E03E: 7F 00 4F       '..O'
; Re-read stored address
        LDAA    gpib_addr                ;E041: 96 00          '..'
; Write address with talk+listen enabled
        STAA    MC68488_ADR              ;E043: B7 80 04       '...'
; Load "OK" via immediate
        LDX     #STR_OK                  ;E046: CE 4F 4B       '.OK'
; Init error status to "OK"
        STX     error_code_hi            ;E049: DF 47          '.G'
; === MAIN LOOP START ===
; Check for status changes from primary controller
main_loop JSR     check_status_change      ;E04B: BD E6 FA       '...'
; Poll UART for incoming data from primary controller
        JSR     uart_poll_rx             ;E04E: BD E6 A0       '...'
; Check if link state needs synchronisation
        JSR     sync_link_state          ;E051: BD E7 6F       '..o'
; Clear CSR snapshot
        CLR     >gpib_csr_snapshot       ;E054: 7F 00 42       '..B'
; Read MC68488 Interrupt Status Register
        LDAA    MC68488_ISR              ;E057: B6 80 00       '...'
; Read MC68488 Command Status Register
        LDAB    MC68488_CSR              ;E05A: F6 80 01       '...'
; Store CSR in snapshot variable
        STAB    gpib_csr_snapshot        ;E05D: D7 42          '.B'
; Transfer ISR to condition codes via TAP:
; N=ISR.7 (SPC/RLC/DCAS), Z=ISR==0, V=ISR.6 (CO/ERR)
; C=ISR.0 (BI - Byte In)
        TAP                              ;E05F: 06             '.'
; Branch if no GPIB interrupts pending (Z=1)
        BEQ     poll_gpib_commands       ;E060: 27 03          ''.'
; GPIB interrupt active: enter receive handler
        JMP     gpib_receive_handler     ;E062: 7E E0 B1       '~..'

; Secondary check: test CSR bits directly
poll_gpib_commands LDAA    gpib_csr_snapshot        ;E065: 96 42          '.B'
; Test CSR bits 7 (SPC) and 0 (LPAS/TPAS)
        BITA    #$81                     ;E067: 85 81          '..'
; Branch if no command status bits set
        BEQ     poll_gpib_status_bits    ;E069: 27 08          ''.'
; Acknowledge command: write 0x10 to ACR (valid cmd)
        LDAA    #$10                     ;E06B: 86 10          '..'
        STAA    MC68488_ACR              ;E06D: B7 80 03       '...'
        JMP     gpib_receive_handler     ;E070: 7E E0 B1       '~..'

; Transfer CSR to condition codes via TAP
poll_gpib_status_bits TAP                              ;E073: 06             '.'
; Branch if N=1 (CSR.7: Remote/Local change)
        BMI     ZE086                    ;E074: 2B 10          '+.'
; Branch if V=1 (CSR.6: Device Clear Active State)
        BVS     ZE09A                    ;E076: 29 22          ')"'
; Mask off device-clear-pending flag
        LDAA    #$EF                     ;E078: 86 EF          '..'
        JSR     clear_link_state_bits    ;E07A: BD E7 AD       '...'
; Re-read CSR for additional checks
        LDAA    MC68488_CSR              ;E07D: B6 80 01       '...'
        TAP                              ;E080: 06             '.'
; Loop back if no further status
        BEQ     poll_gpib_commands       ;E081: 27 E2          ''.'
        JMP     gpib_receive_handler     ;E083: 7E E0 B1       '~..'

; Handle Remote/Local state change
ZE086   LDAA    gpib_csr_snapshot        ;E086: 96 42          '.B'
; Process serial poll state from CSR
        JSR     handle_serial_poll       ;E088: BD E7 3D       '..='
; Check if output pending
        LDAA    gpib_line_complete       ;E08B: 96 4C          '.L'
        BEQ     ZE092                    ;E08D: 27 03          ''.'
        JSR     dispatch_gpib_command    ;E08F: BD E1 DB       '...'
; Clear DCAS bit from CSR snapshot
ZE092   LDAA    gpib_csr_snapshot        ;E092: 96 42          '.B'
        ANDA    #$F7                     ;E094: 84 F7          '..'
        STAA    gpib_csr_snapshot        ;E096: 97 42          '.B'
; Return to main loop polling
        BRA     poll_gpib_commands       ;E098: 20 CB          ' .'

; Device clear received on GPIB bus
ZE09A   LDAA    #$10                     ;E09A: 86 10          '..'
; Acknowledge via ACR
        STAA    MC68488_ACR              ;E09C: B7 80 03       '...'
; Set device-clear-pending flag in link_state_flags
        LDAA    #$10                     ;E09F: 86 10          '..'
        JSR     set_link_state_bits      ;E0A1: BD E7 B1       '...'
; Notify primary controller (send 'V' status)
        LDAA    #$56                     ;E0A4: 86 56          '.V'
        JSR     send_status_to_primary   ;E0A6: BD E7 92       '...'
; Clear device-clear-pending flag
        LDAA    #$EF                     ;E0A9: 86 EF          '..'
        JSR     clear_link_state_bits    ;E0AB: BD E7 AD       '...'
; Return to main loop
        JMP     main_loop                ;E0AE: 7E E0 4B       '~.K'

; === GPIB DATA RECEIVE HANDLER ===
; Clear char count, error flag, reset buffer pointer
gpib_receive_handler CLRA                             ;E0B1: 4F             'O'
        STAA    gpib_rx_char_count       ;E0B2: 97 39          '.9'
        STAA    gpib_rx_error_flag       ;E0B4: 97 3D          '.='
        LDX     #M0001                   ;E0B6: CE 00 01       '...'
        STX     gpib_rx_buf_ptr_hi       ;E0B9: DF 3A          '.:'
; Poll loop: service housekeeping while waiting for data
ZE0BB   JSR     check_status_change      ;E0BB: BD E6 FA       '...'
        LDAA    MC68488_CSR              ;E0BE: B6 80 01       '...'
        JSR     handle_serial_poll       ;E0C1: BD E7 3D       '..='
        JSR     uart_poll_rx             ;E0C4: BD E6 A0       '...'
        JSR     sync_link_state          ;E0C7: BD E7 6F       '..o'
        JSR     update_spoll_and_talker  ;E0CA: BD E1 AF       '...'
; Read MC68488 ADSR to check talk/listen addressing
        LDAA    MC68488_ADSR             ;E0CD: B6 80 02       '...'
; Compare against 0x84 (addressed to listen)
        CMPA    #$84                     ;E0D0: 81 84          '..'
; Branch if addressed to listen (continue receiving)
        BEQ     ZE0DF                    ;E0D2: 27 0B          ''.'
; Not addressed: clear addressed flag
        LDAA    #$FD                     ;E0D4: 86 FD          '..'
        JSR     clear_link_state_bits    ;E0D6: BD E7 AD       '...'
; Check talker state
        JSR     check_talker_state       ;E0D9: BD E3 94       '...'
; Jump to post-receive processing
        JMP     ZE18D                    ;E0DC: 7E E1 8D       '~..'

; NOPs (alignment padding)
ZE0DF   NOP                              ;E0DF: 01             '.'
        NOP                              ;E0E0: 01             '.'
        NOP                              ;E0E1: 01             '.'
; Set addressed-to-talk flag in link_state_flags
        LDAA    #$02                     ;E0E2: 86 02          '..'
        JSR     set_link_state_bits      ;E0E4: BD E7 B1       '...'
; Load buffer write pointer
        LDX     gpib_rx_buf_ptr_hi       ;E0E7: DE 3A          '.:'
; Read ISR
        LDAA    MC68488_ISR              ;E0E9: B6 80 00       '...'
; Transfer to condition codes (C=Byte-In, V=End)
        TAP                              ;E0EC: 06             '.'
; Branch if no byte waiting (C=0)
        BCC     ZE0BB                    ;E0ED: 24 CC          '$.'
; Re-read ISR for EOI check
        LDAA    MC68488_ISR              ;E0EF: B6 80 00       '...'
; Transfer to condition codes
        TAP                              ;E0F2: 06             '.'
; Branch if V=1 (EOI asserted: end of message)
        BVS     gpib_handle_eoi          ;E0F3: 29 08          ').'
; Normal byte: read from data register
        LDAB    MC68488_DR               ;E0F5: F6 80 07       '...'
; Handle CR/LF line ending within message
        JSR     ZE1BD                    ;E0F8: BD E1 BD       '...'
; Jump to character validation
        BRA     gpib_validate_char       ;E0FB: 20 21          ' !'

; EOI received: mark end of GPIB message
gpib_handle_eoi LDAA    #$7F                     ;E0FD: 86 7F          '..'
; Store 0x7F sentinel after current position
        STAA    $01,X                    ;E0FF: A7 01          '..'
; Set EOI flag
        STAA    gpib_eoi_flag            ;E101: 97 49          '.I'
; Set line-complete flag
        STAA    gpib_line_complete       ;E103: 97 4C          '.L'
; Read final data byte
        LDAB    MC68488_DR               ;E105: F6 80 07       '...'
; Check if it's CR
        CMPB    #$0D                     ;E108: C1 0D          '..'
; Branch if CR (store as-is)
        BEQ     gpib_store_char_no_inc   ;E10A: 27 06          ''.'
; Check if LF
        CMPB    #$0A                     ;E10C: C1 0A          '..'
; Branch if LF
        BEQ     gpib_store_char_no_inc   ;E10E: 27 02          ''.'
        BRA     gpib_store_char          ;E110: 20 01          ' .'

; Store char directly (no buffer advance)
gpib_store_char_no_inc TAB                              ;E112: 16             '.'
; Store char at current buffer position
gpib_store_char STAB    ,X                       ;E113: E7 00          '..'
; Drain remaining GPIB input bytes after EOI
gpib_drain_input LDAB    MC68488_DR               ;E115: F6 80 07       '...'
        LDAA    MC68488_ISR              ;E118: B6 80 00       '...'
        TAP                              ;E11B: 06             '.'
        BCS     gpib_drain_input         ;E11C: 25 F7          '%.'
; === CHARACTER VALIDATION ===
; Set rejection table size (10 entries)
gpib_validate_char LDAA    #$0A                     ;E11E: 86 0A          '..'
; Point to rejected characters table
        LDX     #REJECTED_CHARS          ;E120: CE E1 62       '..b'
; Compare received byte against rejection entry
ZE123   CMPB    ,X                       ;E123: E1 00          '..'
; If match, discard char and continue receiving
        BEQ     ZE0BB                    ;E125: 27 94          ''.'
; Advance to next rejection table entry
        INX                              ;E127: 08             '.'
        DECA                             ;E128: 4A             'J'
        BNE     ZE123                    ;E129: 26 F8          '&.'
; Reload buffer pointer
        LDX     gpib_rx_buf_ptr_hi       ;E12B: DE 3A          '.:'
; Check for CR terminator (0x0D)
        CMPB    #$0D                     ;E12D: C1 0D          '..'
        BEQ     gpib_accept_char         ;E12F: 27 3B          '';'
; Check for LF terminator (0x0A)
        CMPB    #$0A                     ;E131: C1 0A          '..'
        BEQ     gpib_accept_char         ;E133: 27 37          ''7'
; Check for '.' (decimal point, accepted)
        CMPB    #$2E                     ;E135: C1 2E          '..'
        BEQ     gpib_accept_char         ;E137: 27 33          ''3'
; Check for control chars (< 0x20)
        CMPB    #$1F                     ;E139: C1 1F          '..'
        BHI     ZE140                    ;E13B: 22 03          '".'
; Control char: discard and continue
        JMP     ZE0BB                    ;E13D: 7E E0 BB       '~..'

; Check for digits: 0x30-0x39 ('0'-'9')
ZE140   CMPB    #$2F                     ;E140: C1 2F          './'
        BLS     gpib_reject_char         ;E142: 23 18          '#.'
        CMPB    #$39                     ;E144: C1 39          '.9'
        BLS     gpib_accept_char         ;E146: 23 24          '#$'
; Check for uppercase: 0x41-0x5A ('A'-'Z')
        CMPB    #$40                     ;E148: C1 40          '.@'
        BHI     ZE14E                    ;E14A: 22 02          '".'
        BRA     gpib_reject_char         ;E14C: 20 0E          ' .'

ZE14E   CMPB    #$5A                     ;E14E: C1 5A          '.Z'
        BLS     gpib_accept_char         ;E150: 23 1A          '#.'
; Check for lowercase: 0x61-0x7B ('a'-'z')
        CMPB    #$60                     ;E152: C1 60          '.`'
        BHI     ZE158                    ;E154: 22 02          '".'
        BRA     gpib_reject_char         ;E156: 20 04          ' .'

ZE158   CMPB    #$7B                     ;E158: C1 7B          '.{'
        BLS     gpib_accept_char         ;E15A: 23 10          '#.'
; Character rejected: set error flag to 0xFF
gpib_reject_char LDAA    #$FF                     ;E15C: 86 FF          '..'
        STAA    gpib_rx_error_flag       ;E15E: 97 3D          '.='
        BRA     gpib_accept_char         ;E160: 20 0A          ' .'

REJECTED_CHARS FCC     " '+,-/:;`\"             ;E162: 20 27 2B 2C 2D 2F 3A 3B 60 5C ' '+,-/:;`\' Rejected chars: space ' + , - / : ; ` 

; === ACCEPTED CHARACTER / LINE COMPLETE ===
; Check if EOI was received
gpib_accept_char LDAA    gpib_eoi_flag            ;E16C: 96 49          '.I'
        BEQ     ZE179                    ;E16E: 27 09          ''.'
; Clear EOI flag
        CLR     >gpib_eoi_flag           ;E170: 7F 00 49       '..I'
; EOI with valid data: dispatch command
        JSR     dispatch_gpib_command    ;E173: BD E1 DB       '...'
; Return to main loop
        JMP     main_loop                ;E176: 7E E0 4B       '~.K'

; Increment character count
ZE179   INC     >gpib_rx_char_count      ;E179: 7C 00 39       '|.9'
        LDAA    gpib_rx_char_count       ;E17C: 96 39          '.9'
; Check against max command length (50 chars)
        CMPA    #$32                     ;E17E: 81 32          '.2'
        BLS     ZE185                    ;E180: 23 03          '#.'
; Overflow: set error status
        JMP     set_overflow_error       ;E182: 7E E3 88       '~..'

; Store character in buffer
ZE185   STAB    ,X                       ;E185: E7 00          '..'
; Advance buffer pointer
        INX                              ;E187: 08             '.'
        STX     gpib_rx_buf_ptr_hi       ;E188: DF 3A          '.:'
; Continue receiving
        JMP     ZE0BB                    ;E18A: 7E E0 BB       '~..'

; Check CSR for DCAS (Device Clear Active State)
ZE18D   LDAA    gpib_csr_snapshot        ;E18D: 96 42          '.B'
        ROLA                             ;E18F: 49             'I'
        ROLA                             ;E190: 49             'I'
; Branch if not DCAS (handle normally)
        BPL     hdlr_device_clear        ;E191: 2A 13          '*.'
; Load link state flags
        LDAA    link_state_flags         ;E193: 96 25          '.%'
        TAP                              ;E195: 06             '.'
; Branch if no active flags
        BEQ     ZE1A2                    ;E196: 27 0A          ''.'
; Set device-clear-pending bit
        LDAA    #$04                     ;E198: 86 04          '..'
        JSR     set_link_state_bits      ;E19A: BD E7 B1       '...'
; Notify primary controller ('U' = status update)
        LDAA    #$55                     ;E19D: 86 55          '.U'
        JSR     send_status_to_primary   ;E19F: BD E7 92       '...'
; Update serial poll status and check talker
ZE1A2   BSR     update_spoll_and_talker  ;E1A2: 8D 0B          '..'
        BRA     ZE1BA                    ;E1A4: 20 14          ' .'

; === DEVICE CLEAR HANDLER ===
; Clear device-clear-pending bit in link_state_flags
hdlr_device_clear LDAA    #$FB                     ;E1A6: 86 FB          '..'
        JSR     clear_link_state_bits    ;E1A8: BD E7 AD       '...'
; Update serial poll status
        BSR     update_spoll_and_talker  ;E1AB: 8D 02          '..'
        BRA     ZE1BA                    ;E1AD: 20 0B          ' .'

; === UPDATE SPOLL AND CHECK TALKER ===
; Load serial poll status byte
update_spoll_and_talker LDAA    spoll_status             ;E1AF: 96 26          '.&'
; Branch if zero (no status to report)
        BEQ     ZE1B6                    ;E1B1: 27 03          ''.'
; Update MC68488 SPR and handle SRQ
        JSR     ZE2EC                    ;E1B3: BD E2 EC       '...'
ZE1B6   JSR     check_talker_state       ;E1B6: BD E3 94       '...'
        RTS                              ;E1B9: 39             '9'

;-------------------------------------------------------------------------------

ZE1BA   JMP     main_loop                ;E1BA: 7E E0 4B       '~.K'

ZE1BD   CMPB    #$0D                     ;E1BD: C1 0D          '..'
        BNE     ZE1C3                    ;E1BF: 26 02          '&.'
        BRA     ZE1C7                    ;E1C1: 20 04          ' .'

ZE1C3   CMPB    #$0A                     ;E1C3: C1 0A          '..'
        BNE     ZE1DA                    ;E1C5: 26 13          '&.'
ZE1C7   LDAB    MC68488_DR               ;E1C7: F6 80 07       '...'
        LDAA    MC68488_ISR              ;E1CA: B6 80 00       '...'
        TAP                              ;E1CD: 06             '.'
        BCS     ZE1C7                    ;E1CE: 25 F7          '%.'
        LDAA    #$7F                     ;E1D0: 86 7F          '..'
        STAA    gpib_eoi_flag            ;E1D2: 97 49          '.I'
        STAA    $01,X                    ;E1D4: A7 01          '..'
        LDAA    #$FF                     ;E1D6: 86 FF          '..'
        STAA    gpib_line_complete       ;E1D8: 97 4C          '.L'
ZE1DA   RTS                              ;E1DA: 39             '9'

;-------------------------------------------------------------------------------

; === COMMAND DISPATCH (called after complete line received) ===
; Check if primary link is active (bit 3)
dispatch_gpib_command LDAA    link_state_flags         ;E1DB: 96 25          '.%'
        ANDA    #$08                     ;E1DD: 84 08          '..'
; Branch if link not active (ignore command)
        BEQ     ZE1FF                    ;E1DF: 27 1E          ''.'
; Clear line-complete flag
        CLR     >gpib_line_complete      ;E1E1: 7F 00 4C       '..L'
; Reset buffer pointer to start
        LDX     #M0001                   ;E1E4: CE 00 01       '...'
        STX     gpib_rx_buf_ptr_hi       ;E1E7: DF 3A          '.:'
; Skip leading null bytes in buffer
ZE1E9   LDX     gpib_rx_buf_ptr_hi       ;E1E9: DE 3A          '.:'
        LDAA    ,X                       ;E1EB: A6 00          '..'
        BNE     ZE1F4                    ;E1ED: 26 05          '&.'
        INX                              ;E1EF: 08             '.'
        STX     gpib_rx_buf_ptr_hi       ;E1F0: DF 3A          '.:'
        BRA     ZE1E9                    ;E1F2: 20 F5          ' .'

; Check for non-printable chars (< 0x30)
ZE1F4   CMPA    #$2F                     ;E1F4: 81 2F          './'
        BLS     ZE23A                    ;E1F6: 23 42          '#B'
; Check for end sentinel (0x7F)
        CMPA    #$7F                     ;E1F8: 81 7F          '..'
        BNE     classify_command_char    ;E1FA: 26 04          '&.'
; End of buffer: clear and return
        JSR     clear_gpib_tx_buffer     ;E1FC: BD E3 6E       '..n'
ZE1FF   RTS                              ;E1FF: 39             '9'

;-------------------------------------------------------------------------------

; === CLASSIFY FIRST CHARACTER OF COMMAND ===
; Store command character in current_gpib_cmd
classify_command_char STAA    current_gpib_cmd         ;E200: 97 4A          '.J'
; Compare against '@' (0x40)
        CMPA    #$40                     ;E202: 81 40          '.@'
; Branch if > '@' (alphabetic command)
        BHI     ZE20B                    ;E204: 22 05          '".'
; Non-alpha first char: syntax error
        JSR     set_syntax_error         ;E206: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E209: 20 F4          ' .'

; Compare against 'H' (0x48)
ZE20B   CMPA    #$48                     ;E20B: 81 48          '.H'
; Branch if <= 'H': set command (A-H) with numeric arg
        BLS     ZE21E                    ;E20D: 23 0F          '#.'
; Store command for UART transmission
        STAA    uart_tx_cmd              ;E20F: 97 22          '."'
; Check for 'q' (0x71): query command
        CMPA    #$71                     ;E211: 81 71          '.q'
; Return without sending (query handled separately)
        BEQ     ZE1FF                    ;E213: 27 EA          ''.'
; Check for 'r' (0x72): read status command
        CMPA    #$72                     ;E215: 81 72          '.r'
; Return without sending (status handled separately)
        BEQ     ZE1FF                    ;E217: 27 E6          ''.'
; Other cmd > 'H': advance past command char
        INX                              ;E219: 08             '.'
        STX     gpib_rx_buf_ptr_hi       ;E21A: DF 3A          '.:'
; Continue to UART send
        BRA     ZE22D                    ;E21C: 20 0F          ' .'

; === SET COMMAND (A-H): parse numeric argument ===
; Store command letter in UART TX buffer byte 0
ZE21E   STAA    uart_tx_cmd              ;E21E: 97 22          '."'
; Advance past command letter
        INX                              ;E220: 08             '.'
; Parse decimal digits into binary value
        JSR     parse_numeric_argument   ;E221: BD E2 4B       '..K'
; Check for parse error
        LDAA    gpib_rx_error_flag       ;E224: 96 3D          '.='
; Branch if OK
        BEQ     ZE22D                    ;E226: 27 05          ''.'
; Parse error: set syntax error
        JSR     set_syntax_error         ;E228: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E22B: 20 D2          ' .'

; Send command to primary via UART
ZE22D   JSR     uart_send_command        ;E22D: BD E5 FB       '...'
; Check UART response for errors
        JSR     check_uart_error_response ;E230: BD E7 32       '..2'
; Validate and store DAC values from response
        JSR     validate_primary_response ;E233: BD E7 98       '...'
        LDX     gpib_rx_buf_ptr_hi       ;E236: DE 3A          '.:'
        BRA     ZE23D                    ;E238: 20 03          ' .'

; Skip non-command characters in buffer
ZE23A   LDX     gpib_rx_buf_ptr_hi       ;E23A: DE 3A          '.:'
        INX                              ;E23C: 08             '.'
; Check if buffer pointer reached UART TX area (overflow)
ZE23D   CPX     #uart_tx_cmd             ;E23D: 8C 00 22       '.."'
        BNE     ZE247                    ;E240: 26 05          '&.'
; Buffer overrun: syntax error
        JSR     set_syntax_error         ;E242: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E245: 20 B8          ' .'

; Store updated pointer, continue parsing buffer
ZE247   STX     gpib_rx_buf_ptr_hi       ;E247: DF 3A          '.:'
        BRA     ZE1E9                    ;E249: 20 9E          ' .'

; === PARSE NUMERIC ARGUMENT ===
; Save buffer pointer (X clobbered by conversion)
parse_numeric_argument STX     gpib_rx_buf_ptr_hi       ;E24B: DF 3A          '.:'
; Point to conversion workspace
        LDX     #conv_workspace          ;E24D: CE 00 27       '..''
; Clear workspace
        CLRA                             ;E250: 4F             'O'
; Clear M0x27 through M0x33
clear_conv_workspace STAA    ,X                       ;E251: A7 00          '..'
        INX                              ;E253: 08             '.'
        CPX     #conv_accum_hi           ;E254: 8C 00 33       '..3'
        BNE     clear_conv_workspace     ;E257: 26 F8          '&.'
; Init accumulator pointer to M0x2D
        LDX     #M002D                   ;E259: CE 00 2D       '..-'
        STX     conv_accum_hi            ;E25C: DF 33          '.3'
; === DIGIT EXTRACTION LOOP ===
; Restore buffer pointer
ZE25E   LDX     gpib_rx_buf_ptr_hi       ;E25E: DE 3A          '.:'
; Load current character
        LDAA    ,X                       ;E260: A6 00          '..'
; Check if > '9' (end of numeric string)
        CMPA    #$39                     ;E262: 81 39          '.9'
; Branch if non-digit: done extracting
        BHI     ZE272                    ;E264: 22 0C          '".'
; Advance buffer pointer
        INX                              ;E266: 08             '.'
        STX     gpib_rx_buf_ptr_hi       ;E267: DF 3A          '.:'
; Load accumulator write pointer
        LDX     conv_accum_hi            ;E269: DE 33          '.3'
; Store digit in accumulator
        STAA    ,X                       ;E26B: A7 00          '..'
; Advance accumulator pointer
        INX                              ;E26D: 08             '.'
        STX     conv_accum_hi            ;E26E: DF 33          '.3'
; Continue with next character
        BRA     ZE25E                    ;E270: 20 EC          ' .'

; Count integer digits (before decimal point)
ZE272   CLR     >conv_int_digit_count    ;E272: 7F 00 38       '..8'
        LDX     #M002D                   ;E275: CE 00 2D       '..-'
; Scan extracted digits
ZE278   LDAA    ,X                       ;E278: A6 00          '..'
        BEQ     ZE28C                    ;E27A: 27 10          ''.'
; Check for '.' (decimal point)
        CMPA    #$2E                     ;E27C: 81 2E          '..'
        BEQ     ZE28C                    ;E27E: 27 0C          ''.'
; Count digits before decimal
        INC     >conv_int_digit_count    ;E280: 7C 00 38       '|.8'
        INX                              ;E283: 08             '.'
        CPX     #conv_accum_lo           ;E284: 8C 00 34       '..4'
        BNE     ZE278                    ;E287: 26 EF          '&.'
        DEC     >gpib_rx_error_flag      ;E289: 7A 00 3D       'z.='
ZE28C   STX     conv_accum_hi            ;E28C: DF 33          '.3'
; Calculate expected digit count from command type
; Subtract command char from 'H' to determine format
        LDAA    #$48                     ;E28E: 86 48          '.H'
        SUBA    uart_tx_cmd              ;E290: 90 22          '."'
; Branch if result negative (cmd > 'H')
        BMI     ZE2C5                    ;E292: 2B 31          '+1'
; Commands A-D: voltage/current with 3-digit integer
        CMPA    #$03                     ;E294: 81 03          '..'
        BHI     ZE29A                    ;E296: 22 02          '".'
        ADDA    #$04                     ;E298: 8B 04          '..'
; Commands E-H: limits with 5-digit format
ZE29A   CMPA    #$05                     ;E29A: 81 05          '..'
        BLS     ZE2B2                    ;E29C: 23 14          '#.'
        LDAA    conv_int_digit_count     ;E29E: 96 38          '.8'
        CMPA    #$02                     ;E2A0: 81 02          '..'
        BHI     ZE2D6                    ;E2A2: 22 32          '"2'
        LDX     conv_accum_hi            ;E2A4: DE 33          '.3'
        LDAA    $01,X                    ;E2A6: A6 01          '..'
        STAA    ,X                       ;E2A8: A7 00          '..'
        LDAA    $02,X                    ;E2AA: A6 02          '..'
        STAA    $01,X                    ;E2AC: A7 01          '..'
        LDAB    #$04                     ;E2AE: C6 04          '..'
        BRA     ZE2C0                    ;E2B0: 20 0E          ' .'

ZE2B2   LDAA    conv_int_digit_count     ;E2B2: 96 38          '.8'
        CMPA    #$04                     ;E2B4: 81 04          '..'
        BHI     ZE2D6                    ;E2B6: 22 1E          '".'
        LDX     conv_accum_hi            ;E2B8: DE 33          '.3'
        LDAA    $01,X                    ;E2BA: A6 01          '..'
        STAA    ,X                       ;E2BC: A7 00          '..'
        LDAB    #$02                     ;E2BE: C6 02          '..'
ZE2C0   ADDB    conv_int_digit_count     ;E2C0: DB 38          '.8'
        JSR     shift_buffer_left        ;E2C2: BD E3 59       '..Y'
ZE2C5   LDX     #conv_workspace          ;E2C5: CE 00 27       '..''
ZE2C8   LDAA    ,X                       ;E2C8: A6 00          '..'
        BEQ     ZE2D9                    ;E2CA: 27 0D          ''.'
        CMPA    #$2F                     ;E2CC: 81 2F          './'
        BHI     ZE2D2                    ;E2CE: 22 02          '".'
        BRA     ZE2D6                    ;E2D0: 20 04          ' .'

ZE2D2   CMPA    #$39                     ;E2D2: 81 39          '.9'
        BLS     ZE2D9                    ;E2D4: 23 03          '#.'
ZE2D6   STAA    gpib_rx_error_flag       ;E2D6: 97 3D          '.='
        RTS                              ;E2D8: 39             '9'

;-------------------------------------------------------------------------------

ZE2D9   INX                              ;E2D9: 08             '.'
        CPX     #conv_accum_lo           ;E2DA: 8C 00 34       '..4'
        BNE     ZE2C8                    ;E2DD: 26 E9          '&.'
        LDX     #conv_workspace          ;E2DF: CE 00 27       '..''
        JSR     decimal_to_binary        ;E2E2: BD E3 11       '...'
        LDX     conv_accum_hi            ;E2E5: DE 33          '.3'
        STX     uart_tx_data_hi          ;E2E7: DF 23          '.#'
        LDX     gpib_rx_buf_ptr_hi       ;E2E9: DE 3A          '.:'
        RTS                              ;E2EB: 39             '9'

;-------------------------------------------------------------------------------

ZE2EC   LDAA    link_state_flags         ;E2EC: 96 25          '.%'
        BITA    #$08                     ;E2EE: 85 08          '..'
        BEQ     ZE2FC                    ;E2F0: 27 0A          ''.'
        LDAA    MC68488_SPR              ;E2F2: B6 80 05       '...'
        BNE     ZE2FC                    ;E2F5: 26 05          '&.'
        LDAA    spoll_status             ;E2F7: 96 26          '.&'
        STAA    MC68488_SPR              ;E2F9: B7 80 05       '...'
ZE2FC   LDAA    MC68488_SPR              ;E2FC: B6 80 05       '...'
        BITA    #$40                     ;E2FF: 85 40          '.@'
        BNE     ZE310                    ;E301: 26 0D          '&.'
        LDAA    MC68488_CSR              ;E303: B6 80 01       '...'
        BITA    #$04                     ;E306: 85 04          '..'
        BNE     ZE310                    ;E308: 26 06          '&.'
        CLR     >spoll_status            ;E30A: 7F 00 26       '..&'
        CLR     MC68488_SPR              ;E30D: 7F 80 05       '...'
ZE310   RTS                              ;E310: 39             '9'

;-------------------------------------------------------------------------------

; === BINARY TO DECIMAL (16-bit to 5 ASCII digits) ===
; Max 4 powers of ten (10000, 1000, 100, 10)
decimal_to_binary LDAA    #$04                     ;E311: 86 04          '..'
        STAA    conv_digit_count         ;E313: 97 35          '.5'
; Clear result accumulator
        CLRA                             ;E315: 4F             'O'
        STAA    conv_accum_hi            ;E316: 97 33          '.3'
        STAA    conv_accum_lo            ;E318: 97 34          '.4'
        BRA     ZE33F                    ;E31A: 20 23          ' #'

; Multiply step: shift and add
ZE31C   LDAB    #$20                     ;E31C: C6 20          '. '
        LDAA    conv_accum_hi            ;E31E: 96 33          '.3'
        STAA    M002C                    ;E320: 97 2C          '.,'
        LDAA    conv_accum_lo            ;E322: 96 34          '.4'
        STAA    M002D                    ;E324: 97 2D          '.-'
; Shift accumulator left
ZE326   ASL     >conv_accum_lo           ;E326: 78 00 34       'x.4'
        ROL     >conv_accum_hi           ;E329: 79 00 33       'y.3'
        ASLB                             ;E32C: 58             'X'
        BEQ     ZE33F                    ;E32D: 27 10          ''.'
        BPL     ZE326                    ;E32F: 2A F5          '*.'
        LDAA    conv_accum_lo            ;E331: 96 34          '.4'
        ADDA    M002D                    ;E333: 9B 2D          '.-'
        STAA    conv_accum_lo            ;E335: 97 34          '.4'
        LDAA    conv_accum_hi            ;E337: 96 33          '.3'
        ADCA    M002C                    ;E339: 99 2C          '.,'
        STAA    conv_accum_hi            ;E33B: 97 33          '.3'
        BRA     ZE326                    ;E33D: 20 E7          ' .'

; Add digit value to accumulator
ZE33F   LDAA    ,X                       ;E33F: A6 00          '..'
        ANDA    #$0F                     ;E341: 84 0F          '..'
        ADDA    conv_accum_lo            ;E343: 9B 34          '.4'
        STAA    conv_accum_lo            ;E345: 97 34          '.4'
        LDAA    conv_accum_hi            ;E347: 96 33          '.3'
        ADCA    #$00                     ;E349: 89 00          '..'
        STAA    conv_accum_hi            ;E34B: 97 33          '.3'
        BCC     ZE352                    ;E34D: 24 03          '$.'
        INC     >conv_accum_hi           ;E34F: 7C 00 33       '|.3'
; Advance to next digit, decrement counter
ZE352   INX                              ;E352: 08             '.'
        DEC     >conv_digit_count        ;E353: 7A 00 35       'z.5'
        BNE     ZE31C                    ;E356: 26 C4          '&.'
        RTS                              ;E358: 39             '9'

;-------------------------------------------------------------------------------

; === SHIFT BUFFER LEFT (removes leading chars) ===
; Count = 12 bytes to shift
shift_buffer_left LDAA    #$0C                     ;E359: 86 0C          '..'
        STAA    conv_digit_count         ;E35B: 97 35          '.5'
        LDX     #conv_workspace          ;E35D: CE 00 27       '..''
; Copy byte from offset+1 to offset
ZE360   LDAA    $01,X                    ;E360: A6 01          '..'
        STAA    ,X                       ;E362: A7 00          '..'
        INX                              ;E364: 08             '.'
; Decrement shift counter
        DEC     >conv_digit_count        ;E365: 7A 00 35       'z.5'
        BNE     ZE360                    ;E368: 26 F6          '&.'
; Decrement outer loop counter (ACCB)
        DECB                             ;E36A: 5A             'Z'
        BNE     shift_buffer_left        ;E36B: 26 EC          '&.'
        RTS                              ;E36D: 39             '9'

;-------------------------------------------------------------------------------

; === CLEAR GPIB TX BUFFER ===
; Fill M0x01-M0x20 with 0x7F (empty sentinel)
clear_gpib_tx_buffer LDX     #M0001                   ;E36E: CE 00 01       '...'
; Also serves as IRQ handler entry (NOP + fill)
hdlr_IRQ LDAA    #$7F                     ;E371: 86 7F          '..'
ZE373   STAA    ,X                       ;E373: A7 00          '..'
        INX                              ;E375: 08             '.'
        CPX     #M0021                   ;E376: 8C 00 21       '..!'
        BNE     ZE373                    ;E379: 26 F8          '&.'
        RTS                              ;E37B: 39             '9'

;-------------------------------------------------------------------------------

; === SET SYNTAX ERROR ===
; Store 'M' (0x4D) as serial poll status
set_syntax_error LDAA    #$4D                     ;E37C: 86 4D          '.M'
        STAA    spoll_status             ;E37E: 97 26          '.&'
; Store in error code
        STAA    error_code_hi            ;E380: 97 47          '.G'
; Clear transmit buffer
        BSR     clear_gpib_tx_buffer     ;E382: 8D EA          '..'
; Clear EOI flag
        CLR     >gpib_eoi_flag           ;E384: 7F 00 49       '..I'
        RTS                              ;E387: 39             '9'

;-------------------------------------------------------------------------------

; === SET OVERFLOW ERROR ===
; Store 'O' (0x4F) as serial poll status
set_overflow_error LDAA    #$4F                     ;E388: 86 4F          '.O'
        STAA    error_code_hi            ;E38A: 97 47          '.G'
; Store in error code
        STAA    spoll_status             ;E38C: 97 26          '.&'
; Clear EOI flag
        CLR     >gpib_eoi_flag           ;E38E: 7F 00 49       '..I'
; Jump to spoll/talker update
        JMP     ZE1A2                    ;E391: 7E E1 A2       '~..'

; === CHECK TALKER STATE ===
; Test bit 3 of link_state_flags (link active)
check_talker_state LDAA    link_state_flags         ;E394: 96 25          '.%'
        ANDA    #$08                     ;E396: 84 08          '..'
; Branch if link active (proceed to talker check)
        BNE     enter_talker_mode        ;E398: 26 03          '&.'
; Link not active: return immediately
        JMP     return_ok                ;E39A: 7E E5 9A       '~..'

; === ENTER TALKER MODE ===
; Read MC68488 ADSR
enter_talker_mode LDAA    MC68488_ADSR             ;E39D: B6 80 02       '...'
; Test bit 3 (TPAS: Talker Primary Address State)
        ANDA    #$08                     ;E3A0: 84 08          '..'
; Branch if addressed as talker
        BNE     handle_talker_addressed  ;E3A2: 26 10          '&.'
; Not talker: clear talker-active bit
        LDAA    #$FE                     ;E3A4: 86 FE          '..'
        JSR     clear_link_state_bits    ;E3A6: BD E7 AD       '...'
; Reset TX pointer to buffer start
        LDX     #M0001                   ;E3A9: CE 00 01       '...'
        STX     gpib_tx_ptr_hi           ;E3AC: DF 4D          '.M'
        CLR     >gpib_tx_last_byte       ;E3AE: 7F 00 4F       '..O'
; Return
        JMP     return_ok                ;E3B1: 7E E5 9A       '~..'

; === HANDLE TALKER ADDRESSED ===
; Set talker-active bit in link_state_flags
handle_talker_addressed LDAA    #$01                     ;E3B4: 86 01          '..'
        JSR     set_link_state_bits      ;E3B6: BD E7 B1       '...'
; Load current command character
        LDAA    current_gpib_cmd         ;E3B9: 96 4A          '.J'
; Branch if command is set (not zero)
        BNE     handle_special_cmd_range ;E3BB: 26 02          '&.'
        BRA     ZE3C7                    ;E3BD: 20 08          ' .'

; Check if command is in special range (0x61-0x72)
handle_special_cmd_range CMPA    #$60                     ;E3BF: 81 60          '.`'
; Branch if <= 0x60
        BLS     ZE3C7                    ;E3C1: 23 04          '#.'
; Check against 'r' (0x72)
        CMPA    #$72                     ;E3C3: 81 72          '.r'
; Branch if <= 'r': handle query/status response
        BLS     handle_cmd_read_status   ;E3C5: 23 19          '#.'
; === RESPOND WITH UNKNOWN COMMAND ERROR ===
; Check for null command
ZE3C7   CMPA    #$00                     ;E3C7: 81 00          '..'
        BNE     ZE3CE                    ;E3C9: 26 03          '&.'
        JMP     return_ok                ;E3CB: 7E E5 9A       '~..'

; Store command char in TX buffer position 1
ZE3CE   STAA    M0001                    ;E3CE: 97 01          '..'
; Store space (0x20) at position 2
        LDAA    #$20                     ;E3D0: 86 20          '. '
        STAA    M0002                    ;E3D2: 97 02          '..'
; Store "??" at positions 3-4
        LDX     #STR_UNKNOWN_CMD         ;E3D4: CE 3F 3F       '.??'
        STX     M0003                    ;E3D7: DF 03          '..'
; Store CR (0x0D) at position 5
        LDAA    #$0D                     ;E3D9: 86 0D          '..'
        STAA    M0005                    ;E3DB: 97 05          '..'
; Jump to transmit
        JMP     begin_gpib_transmit      ;E3DD: 7E E5 51       '~.Q'

; === HANDLE 'r' COMMAND (read error status) ===
handle_cmd_read_status LDAA    current_gpib_cmd         ;E3E0: 96 4A          '.J'
; Compare against 'r'
        CMPA    #$72                     ;E3E2: 81 72          '.r'
; Branch if not 'r': handle set-command response
        BNE     handle_cmd_query_or_other ;E3E4: 26 20          '& '
; Build response: "ER R" + status
; Store "ER" in positions 1-2
        LDX     #STR_ER                  ;E3E6: CE 45 52       '.ER'
        STX     M0001                    ;E3E9: DF 01          '..'
; Store "R " (R space) in positions 3-4
        LDX     #STR_R_SPACE             ;E3EB: CE 52 20       '.R '
        STX     M0003                    ;E3EE: DF 03          '..'
; Load current error code (M0x47:M0x48)
        LDX     error_code_hi            ;E3F0: DE 47          '.G'
; Compare against "OK"
        CPX     #STR_OK                  ;E3F2: 8C 4F 4B       '.OK'
; Branch if status is OK
        BEQ     ZE3FD                    ;E3F5: 27 06          ''.'
; Error state: append '!' after error char
        LDAB    #$21                     ;E3F7: C6 21          '.!'
        STAB    error_code_lo            ;E3F9: D7 48          '.H'
        LDX     error_code_hi            ;E3FB: DE 47          '.G'
; Store error code at positions 5-6
ZE3FD   STX     M0005                    ;E3FD: DF 05          '..'
; Store CR terminator at position 7
        LDAB    #$0D                     ;E3FF: C6 0D          '..'
        STAB    M0007                    ;E401: D7 07          '..'
; Jump to transmit
        JMP     begin_gpib_transmit      ;E403: 7E E5 51       '~.Q'

; === HANDLE 'q' COMMAND (query full status) ===
; Compare against 'q'
handle_cmd_query_or_other CMPA    #$71                     ;E406: 81 71          '.q'
; Branch if 'q'
        BEQ     handle_cmd_query         ;E408: 27 03          ''.'
; Not 'q': handle as set-command response
        JMP     build_setcmd_response    ;E40A: 7E E4 9A       '~..'

; === WAIT FOR STATUS SYNC before responding ===
; Compare confirmed vs pending status
handle_cmd_query LDAA    device_status_pending    ;E40D: 96 46          '.F'
        LDAB    device_status_confirmed  ;E40F: D6 45          '.E'
; Compare: are they equal?
        CBA                              ;E411: 11             '.'
; Branch if synced: build response
        BEQ     build_query_response     ;E412: 27 05          ''.'
; Not synced: poll UART and retry
        JSR     uart_poll_rx             ;E414: BD E6 A0       '...'
        BRA     handle_cmd_query         ;E417: 20 F4          ' .'

; === BUILD QUERY RESPONSE STRING ===
; Mask channel A status bits (low 3 bits)
build_query_response ANDA    #$05                     ;E419: 84 05          '..'
; Point to STATUS_STRING_TABLE
        LDX     #STATUS_STRING_TABLE     ;E41B: CE E7 B6       '...'
; Find Channel A mode string (CV/CC/IL/VL)
        JSR     find_table_entry_by_key  ;E41E: BD E7 63       '..c'
; Copy 4-char string to TX buffer positions 1-4
        LDAA    $01,X                    ;E421: A6 01          '..'
        STAA    M0001                    ;E423: 97 01          '..'
        LDAA    $02,X                    ;E425: A6 02          '..'
        STAA    M0002                    ;E427: 97 02          '..'
        LDAA    $03,X                    ;E429: A6 03          '..'
        STAA    M0003                    ;E42B: 97 03          '..'
        LDAA    $04,X                    ;E42D: A6 04          '..'
        STAA    M0004                    ;E42F: 97 04          '..'
; Store '/' separator at position 5
        LDAA    #$2F                     ;E431: 86 2F          './'
        STAA    M0005                    ;E433: 97 05          '..'
; Load status for channel B selection
        LDAA    device_status_confirmed  ;E435: 96 45          '.E'
; Mask channel B status bits
        ANDA    #$0A                     ;E437: 84 0A          '..'
; Find Channel B mode string
        JSR     find_next_table_entry    ;E439: BD E7 5E       '..^'
; Copy 4-char string to positions 6-9
        LDAA    $01,X                    ;E43C: A6 01          '..'
        STAA    M0006                    ;E43E: 97 06          '..'
        LDAA    $02,X                    ;E440: A6 02          '..'
        STAA    M0007                    ;E442: 97 07          '..'
        LDAA    $03,X                    ;E444: A6 03          '..'
        STAA    M0008                    ;E446: 97 08          '..'
        LDAA    $04,X                    ;E448: A6 04          '..'
        STAA    M0009                    ;E44A: 97 09          '..'
; Store '/' separator at position 10
        LDAA    #$2F                     ;E44C: 86 2F          './'
        STAA    M000A                    ;E44E: 97 0A          '..'
; Test bit 7 of device_status (tracking flag)
        LDAA    device_status_confirmed  ;E450: 96 45          '.E'
; Branch if tracking enabled
        BMI     ZE464                    ;E452: 2B 10          '+.'
; Tracking off: store "TOFF" at positions 11-14
        LDX     #STR_TO                  ;E454: CE 54 4F       '.TO'
        STX     M000B                    ;E457: DF 0B          '..'
        LDX     #STR_FF                  ;E459: CE 46 46       '.FF'
        STX     M000D                    ;E45C: DF 0D          '..'
; Store '/' separator at position 15
        LDAA    #$2F                     ;E45E: 86 2F          './'
        STAA    M000F                    ;E460: 97 0F          '..'
; Branch to output state
        BRA     ZE472                    ;E462: 20 0E          ' .'

; Tracking on: store "T ON" at positions 11-14
ZE464   LDX     #STR_T_SPACE             ;E464: CE 54 20       '.T '
        STX     M000B                    ;E467: DF 0B          '..'
        LDX     #STR_ON                  ;E469: CE 4F 4E       '.ON'
        STX     M000D                    ;E46C: DF 0D          '..'
; Store '/' separator at position 15
        LDAA    #$2F                     ;E46E: 86 2F          './'
        STAA    M000F                    ;E470: 97 0F          '..'
; Test bit 6 of device_status (output flag)
ZE472   LDAA    device_status_confirmed  ;E472: 96 45          '.E'
; Mask bit 6
        ANDA    #$40                     ;E474: 84 40          '.@'
; Branch if output enabled
        BNE     ZE489                    ;E476: 26 11          '&.'
; Output off: store "OPOFF" + CR at positions 16-21
        LDX     #STR_OP                  ;E478: CE 4F 50       '.OP'
        STX     M0010                    ;E47B: DF 10          '..'
        LDX     #STR_OF                  ;E47D: CE 4F 46       '.OF'
        STX     M0012                    ;E480: DF 12          '..'
        LDX     #STR_F_CR                ;E482: CE 46 0D       '.F.'
        STX     M0014                    ;E485: DF 14          '..'
; Branch to transmit
        BRA     ZE497                    ;E487: 20 0E          ' .'

; Output on: store "OPON" + CR at positions 16-20
ZE489   LDX     #STR_OP                  ;E489: CE 4F 50       '.OP'
        STX     M0010                    ;E48C: DF 10          '..'
        LDX     #STR_ON                  ;E48E: CE 4F 4E       '.ON'
        STX     M0012                    ;E491: DF 12          '..'
        LDAA    #$0D                     ;E493: 86 0D          '..'
        STAA    M0014                    ;E495: 97 14          '..'
; Jump to transmit
ZE497   JMP     begin_gpib_transmit      ;E497: 7E E5 51       '~.Q'

; === BUILD SET-COMMAND RESPONSE ===
; Load DAC value echo from primary (2 bytes)
build_setcmd_response LDAA    dac_value_hi             ;E49A: 96 43          '.C'
; Mask bit 6 of high byte
        ANDA    #$BF                     ;E49C: 84 BF          '..'
        STAA    conv_temp_hi             ;E49E: 97 36          '.6'
        LDAB    dac_value_lo             ;E4A0: D6 44          '.D'
        STAB    conv_temp_lo             ;E4A2: D7 37          '.7'
; Convert binary DAC value to decimal ASCII
        JSR     binary_to_decimal        ;E4A4: BD E5 9B       '...'
; Load command character
        LDAA    current_gpib_cmd         ;E4A7: 96 4A          '.J'
; Point to command-response lookup table
        LDX     #CMD_RESPONSE_TABLE      ;E4A9: CE E4 BB       '...'
; === LOOKUP LOOP: find 3-letter response code ===
; Compare command char against table entry
setcmd_lookup_loop CMPA    ,X                       ;E4AC: A1 00          '..'
; Branch if match found
        BEQ     ZE4EF                    ;E4AE: 27 3F          ''?'
; Advance 4 bytes to next table entry
        INX                              ;E4B0: 08             '.'
        INX                              ;E4B1: 08             '.'
        INX                              ;E4B2: 08             '.'
        INX                              ;E4B3: 08             '.'
; Check for end of table
        CPX     #CMD_RESPONSE_TABLE_END  ;E4B4: 8C E4 EB       '...'
; Loop if not at end
        BNE     setcmd_lookup_loop       ;E4B7: 26 F3          '&.'
; No match: fall through (uses last entry "  ??")
        BRA     ZE4EF                    ;E4B9: 20 34          ' 4'

CMD_RESPONSE_TABLE FCC     "aVSAbVSBcISAdISBiVOAj"  ;E4BB: 61 56 53 41 62 56 53 42 63 49 53 41 64 49 53 42 69 56 4F 41 6A 'aVSAbVSBcISAdISBiVOAj' Command lookup table (4 bytes each): cmd_char, response[3]
                                         ; a=VSA b=VSB c=ISA d=ISB i=VOA j=VOB k=IOA l=IOB e=VLA f=VLB g=ILA h=ILB
        FCC     "VOBkIOAlIOBeVLAfVLBgI"  ;E4D0: 56 4F 42 6B 49 4F 41 6C 49 4F 42 65 56 4C 41 66 56 4C 42 67 49 'VOBkIOAlIOBeVLAfVLBgI'
        FCC     "LAhILB"                 ;E4E5: 4C 41 68 49 4C 42 'LAhILB'
CMD_RESPONSE_TABLE_END FCC     "  ??"                   ;E4EB: 20 20 3F 3F    '  ??'
; Copy 3-letter response code to TX buffer
ZE4EF   LDAA    $01,X                    ;E4EF: A6 01          '..'
; Check if response byte is space (default entry)
        CMPA    #$20                     ;E4F1: 81 20          '. '
; If space: use original command char instead
        BNE     ZE4F7                    ;E4F3: 26 02          '&.'
        LDAA    current_gpib_cmd         ;E4F5: 96 4A          '.J'
; Store response string in TX positions 1-3
ZE4F7   STAA    M0001                    ;E4F7: 97 01          '..'
        LDAA    $02,X                    ;E4F9: A6 02          '..'
        STAA    M0002                    ;E4FB: 97 02          '..'
        LDAA    $03,X                    ;E4FD: A6 03          '..'
        STAA    M0003                    ;E4FF: 97 03          '..'
; Store space separator at position 4
        LDAA    #$20                     ;E501: 86 20          '. '
        STAA    M0004                    ;E503: 97 04          '..'
; Reload command character
        LDAA    current_gpib_cmd         ;E505: 96 4A          '.J'
; Subtract 'a' to get channel/function index
        SUBA    #$61                     ;E507: 80 61          '.a'
; === CALCULATE CHANNEL OFFSET (a-d=0-3, e-h=0-3, i-l=0-3) ===
; Compare against 3
calc_channel_offset CMPA    #$03                     ;E509: 81 03          '..'
; Branch if > 3 (commands e-l)
        BHI     ZE50F                    ;E50B: 22 02          '".'
; Branch to format with decimal point
        BRA     ZE513                    ;E50D: 20 04          ' .'

; Subtract 4 for second group, loop
ZE50F   SUBA    #$04                     ;E50F: 80 04          '..'
        BRA     calc_channel_offset      ;E511: 20 F6          ' .'

; Compare offset: 0-1=voltage/current, 2-3=limits
ZE513   CMPA    #$01                     ;E513: 81 01          '..'
; Branch if > 1: limit commands (no decimal in value)
        BHI     ZE52F                    ;E515: 22 18          '".'
; Format value with decimal point insertion
        LDX     M0007                    ;E517: DE 07          '..'
        STX     M0008                    ;E519: DF 08          '..'
; Store '.' at appropriate position
        LDAA    #$2E                     ;E51B: 86 2E          '..'
        STAA    M0007                    ;E51D: 97 07          '..'
        LDAA    M0005                    ;E51F: 96 05          '..'
; Suppress leading zero
        CMPA    #$30                     ;E521: 81 30          '.0'
        BNE     ZE54D                    ;E523: 26 28          '&('
        LDAA    #$20                     ;E525: 86 20          '. '
        STAA    M0005                    ;E527: 97 05          '..'
; Store CR terminator
        LDAA    #$0D                     ;E529: 86 0D          '..'
        STAA    M000A                    ;E52B: 97 0A          '..'
        BRA     begin_gpib_transmit      ;E52D: 20 22          ' "'

; Limit format: space-pad instead of decimal
ZE52F   LDAA    #$20                     ;E52F: 86 20          '. '
        STAA    M0009                    ;E531: 97 09          '..'
        LDAA    M0005                    ;E533: 96 05          '..'
        CMPA    #$30                     ;E535: 81 30          '.0'
        BNE     ZE54D                    ;E537: 26 14          '&.'
        LDAB    #$20                     ;E539: C6 20          '. '
        STAB    M0005                    ;E53B: D7 05          '..'
        LDAA    M0006                    ;E53D: 96 06          '..'
        CMPA    #$30                     ;E53F: 81 30          '.0'
        BNE     ZE54D                    ;E541: 26 0A          '&.'
        STAB    M0006                    ;E543: D7 06          '..'
        LDAA    M0007                    ;E545: 96 07          '..'
        CMPA    #$30                     ;E547: 81 30          '.0'
        BNE     ZE54D                    ;E549: 26 02          '&.'
        STAB    M0007                    ;E54B: D7 07          '..'
; Store CR at position 10
ZE54D   LDAA    #$0D                     ;E54D: 86 0D          '..'
        STAA    M000A                    ;E54F: 97 0A          '..'
; === BEGIN GPIB TRANSMIT ===
; Load last-byte-sent register
begin_gpib_transmit LDAB    gpib_tx_last_byte        ;E551: D6 4F          '.O'
; Load TX output pointer
        LDX     gpib_tx_ptr_hi           ;E553: DE 4D          '.M'
; === GPIB TRANSMIT LOOP ===
; Read MC68488 ISR
gpib_transmit_loop LDAA    MC68488_ISR              ;E555: B6 80 00       '...'
; Rotate: bit 2 -> N flag (BO: Byte Out ready)
        ROLA                             ;E558: 49             'I'
; Branch if not ready (also checks for SPC/DCAS/etc)
        BPL     return_ok                ;E559: 2A 3F          '*?'
; Load current byte from TX buffer
        LDAA    ,X                       ;E55B: A6 00          '..'
; Check if last byte was CR (end of response)
        CMPB    #$0D                     ;E55D: C1 0D          '..'
; Branch if end of string
        BEQ     ZE56C                    ;E55F: 27 0B          ''.'
; Write byte to MC68488 data register
        STAA    MC68488_DR               ;E561: B7 80 07       '...'
; Save as last-byte-sent
        TAB                              ;E564: 16             '.'
        STAB    gpib_tx_last_byte        ;E565: D7 4F          '.O'
; Advance TX pointer
        INX                              ;E567: 08             '.'
        STX     gpib_tx_ptr_hi           ;E568: DF 4D          '.M'
; Loop to send next byte
        BRA     gpib_transmit_loop       ;E56A: 20 E9          ' .'

; === END OF GPIB RESPONSE ===
; Set GPIB EOI + Force End (0x22 to ACR)
ZE56C   LDAB    #$22                     ;E56C: C6 22          '."'
        STAB    MC68488_ACR              ;E56E: F7 80 03       '...'
; Send LF (0x0A) as final byte with EOI
        LDAA    #$0A                     ;E571: 86 0A          '..'
        STAA    MC68488_DR               ;E573: B7 80 07       '...'
; Read CSR
        LDAA    MC68488_CSR              ;E576: B6 80 01       '...'
; Check if still remote-enabled
        ROLA                             ;E579: 49             'I'
; Branch if remote (done)
        BPL     return_ok                ;E57A: 2A 1E          '*.'
; Reset GPIA (returned to local)
        LDAA    #$10                     ;E57C: 86 10          '..'
        STAA    MC68488_ACR              ;E57E: B7 80 03       '...'
; Reset TX pointer to buffer start
        LDX     #M0001                   ;E581: CE 00 01       '...'
        STX     gpib_tx_ptr_hi           ;E584: DF 4D          '.M'
; Clear last-byte-sent
        CLR     >gpib_tx_last_byte       ;E586: 7F 00 4F       '..O'
; Clear transmit buffer
        JSR     clear_gpib_tx_buffer     ;E589: BD E3 6E       '..n'
; Check if this was a read-status command
        LDAA    current_gpib_cmd         ;E58C: 96 4A          '.J'
; Compare against 'r'
        CMPA    #$72                     ;E58E: 81 72          '.r'
; Branch if not 'r'
        BNE     ZE597                    ;E590: 26 05          '&.'
; Reset error status to "OK" after successful read
        LDX     #STR_OK                  ;E592: CE 4F 4B       '.OK'
        STX     error_code_hi            ;E595: DF 47          '.G'
; Clear current command
ZE597   CLR     >current_gpib_cmd        ;E597: 7F 00 4A       '..J'
return_ok RTS                              ;E59A: 39             '9'
; === BINARY TO DECIMAL CONVERSION ===
; Clear conversion workspace
binary_to_decimal LDX     #gpib_addr               ;E59B: CE 00 00       '...'
        STX     conv_workspace           ;E59E: DF 27          '.''
        STX     M0029                    ;E5A0: DF 29          '.)'
        CLRA                             ;E5A2: 4F             'O'
        STAA    M002B                    ;E5A3: 97 2B          '.+'
        LDX     #conv_workspace          ;E5A5: CE 00 27       '..''
; Set digit count to 4
        LDAA    #$04                     ;E5A8: 86 04          '..'
        STAA    M002C                    ;E5AA: 97 2C          '.,'
; Load 16-bit value to convert
        LDAA    conv_temp_hi             ;E5AC: 96 36          '.6'
        LDAB    conv_temp_lo             ;E5AE: D6 37          '.7'
; Save workspace pointer
        STX     conv_temp_hi             ;E5B0: DF 36          '.6'
; Point to powers-of-ten table
        LDX     #POWERS_OF_TEN           ;E5B2: CE E5 F3       '...'
; === DIVISION LOOP: repeated subtraction ===
; Subtract current power of ten
ZE5B5   SUBB    $01,X                    ;E5B5: E0 01          '..'
        SBCA    ,X                       ;E5B7: A2 00          '..'
; Branch if result positive (digit found)
        BPL     ZE5CB                    ;E5B9: 2A 10          '*.'
; Add back (went too far)
        ADDB    $01,X                    ;E5BB: EB 01          '..'
        ADCA    ,X                       ;E5BD: A9 00          '..'
; Advance to next power of ten
        INX                              ;E5BF: 08             '.'
        INX                              ;E5C0: 08             '.'
; Increment digit counter for current position
        INC     >conv_temp_lo            ;E5C1: 7C 00 37       '|.7'
        DEC     >M002C                   ;E5C4: 7A 00 2C       'z.,'
; Branch if more digits to extract
        BNE     ZE5B5                    ;E5C7: 26 EC          '&.'
        BRA     ZE5D5                    ;E5C9: 20 0A          ' .'

; Digit found: increment count at workspace position
ZE5CB   STX     M002D                    ;E5CB: DF 2D          '.-'
        LDX     conv_temp_hi             ;E5CD: DE 36          '.6'
        INC     ,X                       ;E5CF: 6C 00          'l.'
        LDX     M002D                    ;E5D1: DE 2D          '.-'
        BRA     ZE5B5                    ;E5D3: 20 E0          ' .'

; Store remainder
ZE5D5   LDX     conv_temp_hi             ;E5D5: DE 36          '.6'
        STAB    ,X                       ;E5D7: E7 00          '..'
; Convert BCD digits to ASCII ('0'-'9')
        LDX     #conv_workspace          ;E5D9: CE 00 27       '..''
ZE5DC   LDAA    ,X                       ;E5DC: A6 00          '..'
        ANDA    #$0F                     ;E5DE: 84 0F          '..'
; OR with 0x30 to make ASCII
        ORAA    #$30                     ;E5E0: 8A 30          '.0'
        STAA    ,X                       ;E5E2: A7 00          '..'
        INX                              ;E5E4: 08             '.'
        CPX     #M002C                   ;E5E5: 8C 00 2C       '..,'
        BNE     ZE5DC                    ;E5E8: 26 F2          '&.'
; Store decimal digits in TX buffer positions 5-8
        LDX     M0028                    ;E5EA: DE 28          '.('
        STX     M0005                    ;E5EC: DF 05          '..'
        LDX     M002A                    ;E5EE: DE 2A          '.*'
        STX     M0007                    ;E5F0: DF 07          '..'
        RTS                              ;E5F2: 39             '9'

;-------------------------------------------------------------------------------

POWERS_OF_TEN FCC     "'"                      ;E5F3: 27             '''     Powers of ten: $2710(10000) $03E8(1000) $0064(100) $000A(10)
        FCB     $10,$03,$E8,$00          ;E5F4: 10 03 E8 00    '....'
        FCC     "d"                      ;E5F8: 64             'd'
        FCB     $00,$0A                  ;E5F9: 00 0A          '..'
; === SEND COMMAND TO PRIMARY CONTROLLER ===
; Set retry count to 5
uart_send_command LDAA    #$05                     ;E5FB: 86 05          '..'
        STAA    uart_retry_count         ;E5FD: 97 3E          '.>'
; Send link_state_flags as handshake byte
ZE5FF   LDAB    link_state_flags         ;E5FF: D6 25          '.%'
; Transmit via UART
        JSR     uart_put_byte            ;E601: BD E6 52       '..R'
; === WAIT FOR ACKNOWLEDGMENT ===
; Receive byte from primary
ZE604   JSR     uart_get_byte            ;E604: BD E6 68       '..h'
; Branch if timeout
        BNE     ZE61C                    ;E607: 26 13          '&.'
; Transfer to ACCA
        TBA                              ;E609: 17             '.'
; Mask framing bits (0x30)
        ANDA    #$30                     ;E60A: 84 30          '.0'
; Branch if framing bits present (not yet acknowledged)
        BNE     ZE604                    ;E60C: 26 F6          '&.'
; Store received status in link state
        STAB    M003C                    ;E60E: D7 3C          '.<'
; Send 3-byte command (uart_tx_cmd + data)
        JSR     uart_send_3_bytes        ;E610: BD E6 83       '...'
; Branch if send failed
        BNE     ZE61C                    ;E613: 26 07          '&.'
; Receive 3-byte response
        JSR     uart_recv_3_bytes        ;E615: BD E6 35       '..5'
; Branch if receive failed
        BNE     ZE61C                    ;E618: 26 02          '&.'
; Success: process response
        BRA     ZE624                    ;E61A: 20 08          ' .'

; === UART COMMS ERROR ===
; Set error code to 'K' (comms error)
ZE61C   LDAA    #$4B                     ;E61C: 86 4B          '.K'
        STAA    error_code_hi            ;E61E: 97 47          '.G'
; Set serial poll status to 'K'
        STAA    spoll_status             ;E620: 97 26          '.&'
        BRA     ZE631                    ;E622: 20 0D          ' .'

; === VERIFY RESPONSE ===
; Load response byte 0
ZE624   LDAA    uart_rx_resp             ;E624: 96 3F          '.?'
; Mask bit 7 (error flag)
        ANDA    #$7F                     ;E626: 84 7F          '..'
; Compare against sent command
        CMPA    uart_tx_cmd              ;E628: 91 22          '."'
; Branch if match (command acknowledged)
        BEQ     ZE631                    ;E62A: 27 05          ''.'
; Mismatch: decrement retry counter
        DEC     >uart_retry_count        ;E62C: 7A 00 3E       'z.>'
; Branch if retries remaining
        BNE     ZE5FF                    ;E62F: 26 CE          '&.'
ZE631   CLR     >uart_retry_count        ;E631: 7F 00 3E       '..>'
        RTS                              ;E634: 39             '9'

;-------------------------------------------------------------------------------

; === UART RECEIVE 3 BYTES ===
; Receive byte 0 (command echo / status)
uart_recv_3_bytes JSR     uart_get_byte            ;E635: BD E6 68       '..h'
        BNE     uart_recv_timeout        ;E638: 26 14          '&.'
; Store in uart_rx_resp
        STAB    uart_rx_resp             ;E63A: D7 3F          '.?'
; Receive byte 1 (data high)
        JSR     uart_get_byte            ;E63C: BD E6 68       '..h'
        BNE     uart_recv_timeout        ;E63F: 26 0D          '&.'
; Store in uart_rx_data_hi
        STAB    uart_rx_data_hi          ;E641: D7 40          '.@'
; Receive byte 2 (data low)
        JSR     uart_get_byte            ;E643: BD E6 68       '..h'
        BNE     uart_recv_timeout        ;E646: 26 06          '&.'
; Store in uart_rx_data_lo
        STAB    uart_rx_data_lo          ;E648: D7 41          '.A'
; Clear error flag (success)
        CLRA                             ;E64A: 4F             'O'
        JMP     uart_recv_done           ;E64B: 7E E6 50       '~.P'

; Timeout: set error flag 0xFF
uart_recv_timeout LDAA    #$FF                     ;E64E: 86 FF          '..'
uart_recv_done TSTA                             ;E650: 4D             'M'
        RTS                              ;E651: 39             '9'

;-------------------------------------------------------------------------------

; === UART PUT BYTE (ACCB -> ACIA) ===
; Init timeout counter to 0xFFFF
uart_put_byte LDX     #MFFFF                   ;E652: CE FF FF       '...'
; Poll ACIA status: check TDRE (bit 1)
ZE655   LDAA    ACIA_CSR                 ;E655: 96 C0          '..'
        ANDA    #$02                     ;E657: 84 02          '..'
; Branch if transmit register empty
        BNE     ZE663                    ;E659: 26 08          '&.'
; Decrement timeout counter
        DEX                              ;E65B: 09             '.'
        BNE     ZE655                    ;E65C: 26 F7          '&.'
; Timeout: return with error (0xFF)
        LDAA    #$FF                     ;E65E: 86 FF          '..'
        JMP     ZE666                    ;E660: 7E E6 66       '~.f'

; Write byte to ACIA data register
ZE663   STAB    ACIA_DR                  ;E663: D7 C1          '..'
; Clear error flag (success)
        CLRA                             ;E665: 4F             'O'
ZE666   TSTA                             ;E666: 4D             'M'
; Return: Z=1 if success, Z=0 if error
        RTS                              ;E667: 39             '9'

;-------------------------------------------------------------------------------

; === UART GET BYTE (ACIA -> ACCB) ===
; Init timeout counter to 0xFFFF
uart_get_byte LDX     #MFFFF                   ;E668: CE FF FF       '...'
; Poll ACIA status: check RDRF (bit 0)
ZE66B   LDAA    ACIA_CSR                 ;E66B: 96 C0          '..'
        TAB                              ;E66D: 16             '.'
        ANDA    #$01                     ;E66E: 84 01          '..'
; Branch if receive register full
        BNE     ZE67A                    ;E670: 26 08          '&.'
        DEX                              ;E672: 09             '.'
        BNE     ZE66B                    ;E673: 26 F6          '&.'
; Timeout: return with error
ZE675   LDAA    #$FF                     ;E675: 86 FF          '..'
        JMP     ZE67F                    ;E677: 7E E6 7F       '~..'

; Check for framing/overrun errors (bits 6:4)
ZE67A   ANDB    #$70                     ;E67A: C4 70          '.p'
; Error detected: return with error
        BNE     ZE675                    ;E67C: 26 F7          '&.'
; Clear error flag (success)
        CLRA                             ;E67E: 4F             'O'
; Read byte from ACIA data register
ZE67F   LDAB    ACIA_DR                  ;E67F: D6 C1          '..'
        TSTA                             ;E681: 4D             'M'
        RTS                              ;E682: 39             '9'

;-------------------------------------------------------------------------------

; === UART SEND 3 BYTES ===
; Send uart_tx_cmd
uart_send_3_bytes LDAB    uart_tx_cmd              ;E683: D6 22          '."'
        JSR     uart_put_byte            ;E685: BD E6 52       '..R'
; Branch if error
        BNE     uart_send_timeout        ;E688: 26 12          '&.'
; Send uart_tx_data_hi
        LDAB    uart_tx_data_hi          ;E68A: D6 23          '.#'
        JSR     uart_put_byte            ;E68C: BD E6 52       '..R'
; Branch if error
        BNE     uart_send_timeout        ;E68F: 26 0B          '&.'
; Send uart_tx_data_lo
        LDAB    uart_tx_data_lo          ;E691: D6 24          '.$'
        JSR     uart_put_byte            ;E693: BD E6 52       '..R'
; Branch if error
        BNE     uart_send_timeout        ;E696: 26 04          '&.'
; Clear error flag (success)
        CLRA                             ;E698: 4F             'O'
        JMP     uart_send_done           ;E699: 7E E6 9E       '~..'

; Timeout: set error flag 0xFF
uart_send_timeout LDAA    #$FF                     ;E69C: 86 FF          '..'
uart_send_done TSTA                             ;E69E: 4D             'M'
        RTS                              ;E69F: 39             '9'

;-------------------------------------------------------------------------------

; === POLL UART FOR INCOMING DATA FROM PRIMARY ===
; Read ACIA status register
uart_poll_rx LDAA    ACIA_CSR                 ;E6A0: 96 C0          '..'
; Transfer to condition codes (C=RDRF)
        TAP                              ;E6A2: 06             '.'
; Branch if receive data register full
        BCS     ZE6AA                    ;E6A3: 25 05          '%.'
; No data: clear MC68488 ACR and return
        CLR     MC68488_ACR              ;E6A5: 7F 80 03       '...'
        BRA     uart_rx_return           ;E6A8: 20 3F          ' ?'

; Read received byte
ZE6AA   LDAA    ACIA_DR                  ;E6AA: 96 C1          '..'
; Transfer to ACCB (preserve original)
        TAB                              ;E6AC: 16             '.'
; Mask framing/type bits (0x30)
        ANDA    #$30                     ;E6AD: 84 30          '.0'
; Branch if no framing bits (raw data, ignore)
        BEQ     uart_rx_return           ;E6AF: 27 38          ''8'
; Check for 0x20 (status update frame)
        CMPA    #$20                     ;E6B1: 81 20          '. '
; Branch to handle status update
        BEQ     uart_rx_update_status    ;E6B3: 27 35          ''5'
; Check for 0x30 (link state frame)
        CMPA    #$30                     ;E6B5: 81 30          '.0'
; Branch to handle link state update
        BEQ     uart_rx_update_link_state ;E6B7: 27 3B          '';'
; Other frame type: extract payload
        TBA                              ;E6B9: 17             '.'
; Clear framing bits to get status code
        ANDA    #$CF                     ;E6BA: 84 CF          '..'
; Check if status code has bit 7 set (0x8x = mode change)
        CMPA    #$80                     ;E6BC: 81 80          '..'
; Branch if not a mode change
        BNE     uart_rx_handle_error_code ;E6BE: 26 17          '&.'
; Mode change: check link state
        LDAA    link_state_flags         ;E6C0: 96 25          '.%'
; Compare against 0x0C (both directions active)
        CMPA    #$0C                     ;E6C2: 81 0C          '..'
; Branch if fully active (ignore duplicate)
        BEQ     uart_rx_return           ;E6C4: 27 23          ''#'
; Notify primary: send 'T' (talker notification)
        LDAA    #$54                     ;E6C6: 86 54          '.T'
        JSR     send_status_to_primary   ;E6C8: BD E7 92       '...'
; Clear link-active bit in link_state_flags
        LDAA    #$F7                     ;E6CB: 86 F7          '..'
        JSR     clear_link_state_bits    ;E6CD: BD E7 AD       '...'
; Set MSA bit in MC68488 ACR
        LDAA    #$04                     ;E6D0: 86 04          '..'
        STAA    MC68488_ACR              ;E6D2: B7 80 03       '...'
; Return
        BRA     uart_rx_return           ;E6D5: 20 12          ' .'

; === HANDLE ERROR STATUS CODE ===
; Check for 'I' (0x49, internal error)
uart_rx_handle_error_code CMPA    #$49                     ;E6D7: 81 49          '.I'
; Branch if not 'I'
        BNE     uart_rx_handle_nmi_error ;E6D9: 26 06          '&.'
; Store 'I' as error code and spoll status
        STAA    error_code_hi            ;E6DB: 97 47          '.G'
        STAA    spoll_status             ;E6DD: 97 26          '.&'
; Return
        BRA     uart_rx_return           ;E6DF: 20 08          ' .'

; Check for 'J' (0x4A, NMI error)
uart_rx_handle_nmi_error CMPA    #$4A                     ;E6E1: 81 4A          '.J'
; Branch if not 'J': ignore other codes
        BNE     uart_rx_return           ;E6E3: 26 04          '&.'
; Store 'J' as error code and spoll status
        STAA    error_code_hi            ;E6E5: 97 47          '.G'
        STAA    spoll_status             ;E6E7: 97 26          '.&'
uart_rx_return RTS                              ;E6E9: 39             '9'
; === HANDLE STATUS UPDATE (0x20 frame) ===
; Copy pending status to confirmed
uart_rx_update_status LDAA    device_status_pending    ;E6EA: 96 46          '.F'
        STAA    device_status_confirmed  ;E6EC: 97 45          '.E'
; Clear framing bits from received byte
        ANDB    #$CF                     ;E6EE: C4 CF          '..'
; Store as new pending device status
        STAB    device_status_pending    ;E6F0: D7 46          '.F'
; Return
        BRA     uart_rx_return           ;E6F2: 20 F5          ' .'

; === HANDLE LINK STATE UPDATE (0x30 frame) ===
; Clear framing bits
uart_rx_update_link_state ANDB    #$CF                     ;E6F4: C4 CF          '..'
; Store as link state status
        STAB    M003C                    ;E6F6: D7 3C          '.<'
; Return
        BRA     uart_rx_return           ;E6F8: 20 EF          ' .'

; === CHECK FOR STATUS CHANGE (called from main loop) ===
; Load confirmed device status
check_status_change LDAA    device_status_confirmed  ;E6FA: 96 45          '.E'
; Load pending device status
        LDAB    device_status_pending    ;E6FC: D6 46          '.F'
; Compare: has status changed?
        CBA                              ;E6FE: 11             '.'
; Branch if different (still waiting for sync)
        BNE     ZE71E                    ;E6FF: 26 1D          '&.'
; Mask lower nibble (channel mode bits)
        ANDA    #$0F                     ;E701: 84 0F          '..'
; Branch if zero (no active mode to report)
        BEQ     ZE71E                    ;E703: 27 19          ''.'
; Point to STATUS_ERROR_TABLE
        LDX     #STATUS_ERROR_TABLE      ;E705: CE E7 22       '.."'
; Search for matching status entry
status_table_search_loop INX                              ;E708: 08             '.'
        DECA                             ;E709: 4A             'J'
        BNE     status_table_search_loop ;E70A: 26 FC          '&.'
; Load table entry
        LDAA    ,X                       ;E70C: A6 00          '..'
; Branch if null (end of table)
        BEQ     ZE71E                    ;E70E: 27 0E          ''.'
; Store as error code
        STAA    error_code_hi            ;E710: 97 47          '.G'
; Load SRQ pending flag
        LDAB    srq_pending              ;E712: D6 4B          '.K'
; Branch if SRQ already pending
        BNE     check_status_return      ;E714: 26 0B          '&.'
; Store as spoll status
        STAA    spoll_status             ;E716: 97 26          '.&'
; Set SRQ pending flag to 0x55
        LDAA    #$55                     ;E718: 86 55          '.U'
        STAA    srq_pending              ;E71A: 97 4B          '.K'
        BRA     check_status_return      ;E71C: 20 03          ' .'

; Clear SRQ pending flag
ZE71E   CLR     >srq_pending             ;E71E: 7F 00 4B       '..K'
check_status_return RTS                              ;E721: 39             '9'
STATUS_ERROR_TABLE FCB     $00                      ;E722: 00             '.'     Status error table: maps lower nibble of device status
                                         ; to error code characters. Index 0-3=null, 4-15=ACACBBDDEGFH
        FCB     $00                      ;E723: 00             '.'
        FCB     $00                      ;E724: 00             '.'
        FCB     $00                      ;E725: 00             '.'
        FCC     "ACACBBDDEGFH"           ;E726: 41 43 41 43 42 42 44 44 45 47 46 48 'ACACBBDDEGFH'
; === CHECK UART ERROR IN RESPONSE ===
; Load response byte 0
check_uart_error_response LDAA    uart_rx_resp             ;E732: 96 3F          '.?'
; Test bit 7 (error flag from primary)
        BPL     ZE73C                    ;E734: 2A 06          '*.'
; Branch if no error
        ANDA    #$7F                     ;E736: 84 7F          '..'
; Error: mask to get error code
        STAA    error_code_hi            ;E738: 97 47          '.G'
; Store as error code and spoll status
        STAA    spoll_status             ;E73A: 97 26          '.&'
ZE73C   RTS                              ;E73C: 39             '9'

;-------------------------------------------------------------------------------

; === HANDLE SERIAL POLL STATE ===
; Store CSR in snapshot
handle_serial_poll STAA    gpib_csr_snapshot        ;E73D: 97 42          '.B'
; Transfer to condition codes
        TAP                              ;E73F: 06             '.'
; Branch if bit 7 clear (SPC not active)
        BPL     ZE75D                    ;E740: 2A 1B          '*.'
; Rotate to check next bit
        ROLA                             ;E742: 49             'I'
; Branch if talk-addressed during poll
        BMI     ZE754                    ;E743: 2B 0F          '+.'
; Not talk-addressed: clear link-active bit
        LDAA    #$F7                     ;E745: 86 F7          '..'
        JSR     clear_link_state_bits    ;E747: BD E7 AD       '...'
; Notify primary: send 'T' (entering talker mode)
        LDAA    #$54                     ;E74A: 86 54          '.T'
ZE74C   JSR     send_status_to_primary   ;E74C: BD E7 92       '...'
; Clear SRQ pending flag
        CLR     >srq_pending             ;E74F: 7F 00 4B       '..K'
        BRA     ZE75D                    ;E752: 20 09          ' .'

; Talk-addressed: set link-active bit
ZE754   LDAA    #$08                     ;E754: 86 08          '..'
        JSR     set_link_state_bits      ;E756: BD E7 B1       '...'
; Notify primary: send 'S' (serial poll response)
        LDAA    #$53                     ;E759: 86 53          '.S'
        BRA     ZE74C                    ;E75B: 20 EF          ' .'

ZE75D   RTS                              ;E75D: 39             '9'

;-------------------------------------------------------------------------------

; === FIND NEXT TABLE ENTRY (advance 5 bytes) ===
find_next_table_entry INX                              ;E75E: 08             '.'
        INX                              ;E75F: 08             '.'
        INX                              ;E760: 08             '.'
        INX                              ;E761: 08             '.'
        INX                              ;E762: 08             '.'
; === FIND TABLE ENTRY BY KEY (search for ACCA in 5-byte table) ===
; Compare ACCA against first byte of entry
find_table_entry_by_key CMPA    ,X                       ;E763: A1 00          '..'
; Branch if match
        BEQ     ZE76E                    ;E765: 27 07          ''.'
; Advance 5 bytes to next entry
        INX                              ;E767: 08             '.'
        INX                              ;E768: 08             '.'
        INX                              ;E769: 08             '.'
        INX                              ;E76A: 08             '.'
        INX                              ;E76B: 08             '.'
; Loop (no bounds check - table must contain match)
        BRA     find_table_entry_by_key  ;E76C: 20 F5          ' .'

ZE76E   RTS                              ;E76E: 39             '9'

;-------------------------------------------------------------------------------

; === SYNC LINK STATE WITH PRIMARY ===
; Load SRQ pending flag
sync_link_state LDAA    srq_pending              ;E76F: 96 4B          '.K'
; Return if SRQ pending (don't sync during poll)
        BNE     sync_return              ;E771: 26 1E          '&.'
; Load link_state_flags
        LDAA    link_state_flags         ;E773: 96 25          '.%'
; Mask bit 3 (link active)
        ANDA    #$08                     ;E775: 84 08          '..'
; Load link state from UART
        LDAB    M003C                    ;E777: D6 3C          '.<'
; Mask bit 0, shift to bit 3 position
        ANDB    #$01                     ;E779: C4 01          '..'
        ASLB                             ;E77B: 58             'X'
        ASLB                             ;E77C: 58             'X'
        ASLB                             ;E77D: 58             'X'
; Compare local vs remote link state
        CBA                              ;E77E: 11             '.'
; Branch if already synced
        BEQ     sync_return              ;E77F: 27 10          ''.'
; Check if local says active
        CMPA    #$08                     ;E781: 81 08          '..'
; Branch if local says inactive
        BNE     notify_primary_stop      ;E783: 26 07          '&.'
; Local active, remote inactive: send 'S' to primary
        LDAA    #$53                     ;E785: 86 53          '.S'
        JSR     send_status_to_primary   ;E787: BD E7 92       '...'
        BRA     sync_return              ;E78A: 20 05          ' .'

; Local inactive, remote active: send 'T' to primary
notify_primary_stop LDAA    #$54                     ;E78C: 86 54          '.T'
        JSR     send_status_to_primary   ;E78E: BD E7 92       '...'
sync_return RTS                              ;E791: 39             '9'
; === SEND STATUS BYTE TO PRIMARY ===
; Store status char in uart_tx_cmd
send_status_to_primary STAA    uart_tx_cmd              ;E792: 97 22          '."'
; Send command via UART
        JSR     uart_send_command        ;E794: BD E5 FB       '...'
        RTS                              ;E797: 39             '9'

;-------------------------------------------------------------------------------

; === VALIDATE PRIMARY RESPONSE ===
; Load response byte 0
validate_primary_response LDAA    uart_rx_resp             ;E798: 96 3F          '.?'
; Mask bit 7
        ANDA    #$7F                     ;E79A: 84 7F          '..'
; Compare against '_' (0x5F)
        CMPA    #$5F                     ;E79C: 81 5F          '._'
; Branch if less (not a valid command echo)
        BLS     validate_return          ;E79E: 23 0C          '#.'
; Compare against 'p' (0x70)
        CMPA    #$70                     ;E7A0: 81 70          '.p'
; Branch if greater (not valid)
        BHI     validate_return          ;E7A2: 22 08          '".'
; Valid echo: store response data as DAC values
        LDAA    uart_rx_data_hi          ;E7A4: 96 40          '.@'
        LDAB    uart_rx_data_lo          ;E7A6: D6 41          '.A'
; Store in dac_value_hi and dac_value_lo
        STAA    dac_value_hi             ;E7A8: 97 43          '.C'
        STAB    dac_value_lo             ;E7AA: D7 44          '.D'
validate_return RTS                              ;E7AC: 39             '9'
; === CLEAR BITS IN link_state_flags ===
; AND ACCA with link_state_flags (ACCA = mask)
clear_link_state_bits ANDA    link_state_flags         ;E7AD: 94 25          '.%'
; Branch to store
        BRA     ZE7B3                    ;E7AF: 20 02          ' .'

; === SET BITS IN link_state_flags ===
; OR ACCA with link_state_flags (ACCA = bits to set)
set_link_state_bits ORAA    link_state_flags         ;E7B1: 9A 25          '.%'
; Store result
ZE7B3   STAA    link_state_flags         ;E7B3: 97 25          '.%'
        RTS                              ;E7B5: 39             '9'

;-------------------------------------------------------------------------------

STATUS_STRING_TABLE FCB     $00                      ;E7B6: 00             '.'     Status string table (5 bytes each: status_key, 4-char string)
SSTR_A_CV FCC     "A CV"                   ;E7B7: 41 20 43 56    'A CV'  Key $00: "A CV" - Channel A Constant Voltage
        FCB     $01                      ;E7BB: 01             '.'
SSTR_A_CC FCC     "A CC"                   ;E7BC: 41 20 43 43    'A CC'  Key $01: "A CC" - Channel A Constant Current
        FCB     $04                      ;E7C0: 04             '.'
SSTR_A_IL FCC     "A IL"                   ;E7C1: 41 20 49 4C    'A IL'  Key $04: "A IL" - Channel A Current Limit
        FCB     $05                      ;E7C5: 05             '.'
SSTR_A_VL FCC     "A VL"                   ;E7C6: 41 20 56 4C    'A VL'  Key $05: "A VL" - Channel A Voltage Limit
        FCB     $00                      ;E7CA: 00             '.'
SSTR_B_CV FCC     "B CV"                   ;E7CB: 42 20 43 56    'B CV'  Key $00: "B CV" - Channel B Constant Voltage
        FCB     $02                      ;E7CF: 02             '.'
SSTR_B_CC FCC     "B CC"                   ;E7D0: 42 20 43 43    'B CC'  Key $02: "B CC" - Channel B Constant Current
        FCB     $08                      ;E7D4: 08             '.'
SSTR_B_IL FCC     "B IL"                   ;E7D5: 42 20 49 4C    'B IL'  Key $08: "B IL" - Channel B Current Limit
        FCB     $0A                      ;E7D9: 0A             '.'
SSTR_B_VL FCC     "B VL"                   ;E7DA: 42 20 56 4C    'B VL'  Key $0A: "B VL" - Channel B Voltage Limit
; === NMI HANDLER (hardware fault) ===
; Set status to 'J' (0x4A, NMI/hardware error)
hdlr_NMI LDAA    #$4A                     ;E7DE: 86 4A          '.J'
; Write to MC68488 Serial Poll Register (assert SRQ)
        STAA    MC68488_SPR              ;E7E0: B7 80 05       '...'
; Store as spoll status
        STAA    spoll_status             ;E7E3: 97 26          '.&'
; Store as error code
        STAA    error_code_hi            ;E7E5: 97 47          '.G'
; Return from interrupt
        RTI                              ;E7E7: 3B             ';'

;-------------------------------------------------------------------------------


        ORG     $FFF8 

svec_IRQ FDB     hdlr_IRQ                 ;FFF8: E3 70          '.p'
svec_SWI FDB     hdlr_RST                 ;FFFA: E0 00          '..'
svec_NMI FDB     hdlr_NMI                 ;FFFC: E7 DE          '..'

svec_RST FDB     hdlr_RST                 ;FFFE: E0 00          '..'

        END
