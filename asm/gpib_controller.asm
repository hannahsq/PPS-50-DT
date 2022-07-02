; f9dasm: M6800/1/2/3/8/9 / H6309 Binary/OS9/FLEX9 Disassembler V1.80
; Loaded binary file gpib_controller.bin
; Loaded binary file gpib_controller.bin

; stores 0x4A in M0x26 and M0x47

;****************************************************
;* Used Labels                                      *
;****************************************************

GPIB_Addr EQU     $0000
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
uart_tx_buf_0 EQU     $0022
uart_tx_buf_1 EQU     $0023
uart_tx_buf_2 EQU     $0024
unknown_status_0 EQU     $0025
possible_gpib_status EQU     $0026
M0027   EQU     $0027
M0028   EQU     $0028
M0029   EQU     $0029
M002A   EQU     $002A
M002B   EQU     $002B
M002C   EQU     $002C
M002D   EQU     $002D
M0033   EQU     $0033
M0034   EQU     $0034
M0035   EQU     $0035
M0036   EQU     $0036
M0037   EQU     $0037
M0038   EQU     $0038
M0039   EQU     $0039
M003A   EQU     $003A
unknown_status_1 EQU     $003C
M003D   EQU     $003D
unkown_uart_reg_0 EQU     $003E
uart_rx_buf_0 EQU     $003F
uart_rx_buf_1 EQU     $0040
uart_rx_buf_2 EQU     $0041
gpia_csr_copy EQU     $0042
uart_msg_1 EQU     $0043
uart_msg_2 EQU     $0044
M0045   EQU     $0045
M0046   EQU     $0046
M0047   EQU     $0047
M0048   EQU     $0048
M0049   EQU     $0049
test_ram_addr_4 EQU     $004A
unknown_status_2 EQU     $004B
M004C   EQU     $004C
M004D   EQU     $004D
test_ram_addr_5 EQU     $004F
STACK_TOP EQU     $007F
IC11_CSR EQU     $00C0
IC11_RTDR EQU     $00C1
STR_1   EQU     $3F3F
STR_2   EQU     $4552
STR_3   EQU     $460D
STR_4   EQU     $4646
STR_5   EQU     $4F46
STR_6   EQU     $4F4B
STR_7   EQU     $4F4E
STR_8   EQU     $4F50
STR_9   EQU     $5220
STR_A   EQU     $5420
STR_B   EQU     $544F
IC5_INTR EQU     $8000
IC5_CSR EQU     $8001
IC5_ADSMR EQU     $8002
IC5_ACR EQU     $8003
IC5_ADRR EQU     $8004
IC5_SPR EQU     $8005
IC5_DR  EQU     $8007

;****************************************************
;* Program Code / Data Areas                        *
;****************************************************

        ORG     $E000

hdlr_RST LDS     #STACK_TOP               ;E000: 8E 00 7F       '...'
        LDAA    #$03                     ;E003: 86 03          '..'
; Initiate ACIA(UART) Master Reset
        STAA    IC11_CSR                 ;E005: 97 C0          '..'
        LDAB    #$11                     ;E007: C6 11          '..'
; Set ACIA clock divider to 16
; Set ACIA format to 8 data bits, 2 stop bits, no parity bits
; Set ACIA Request To Send, disable Tx data register empty interrupt 
        STAB    IC11_CSR                 ;E009: D7 C0          '..'
        SEI                              ;E00B: 0F             '.'
        LDX     #STACK_TOP               ;E00C: CE 00 7F       '...'
        CLRA                             ;E00F: 4F             'O'
ZE010   STAA    ,X                       ;E010: A7 00          '..'
        DEX                              ;E012: 09             '.'
        BNE     ZE010                    ;E013: 26 FB          '&.'
        LDAA    #$80                     ;E015: 86 80          '..'
; Reset GPIA
        STAA    IC5_ACR                  ;E017: B7 80 03       '...'
; Read GPIB Address DIP switch
        LDAA    IC5_ADRR                 ;E01A: B6 80 04       '...'
; Discard user-defined bits UD3:UD1
        ANDA    #$1F                     ;E01D: 84 1F          '..'
        STAA    GPIB_Addr                ;E01F: 97 00          '..'
        ORAA    #$60                     ;E021: 8A 60          '.`'
; Set GPIB Address and disable talker and listener functionality
        STAA    IC5_ADRR                 ;E023: B7 80 04       '...'
; Clear Auxiliary Command Register
        CLR     IC5_ACR                  ;E026: 7F 80 03       '...'
; Clear Interrupt Mask Register
        CLR     IC5_INTR                 ;E029: 7F 80 00       '...'
        LDAA    #$04                     ;E02C: 86 04          '..'
; Set MSA bit of Aux Cmd Register
        STAA    IC5_ACR                  ;E02E: B7 80 03       '...'
; Clear Aux Cmd Reg again
        CLR     IC5_ACR                  ;E031: 7F 80 03       '...'
; Clear Address Mode Register
        CLR     IC5_ADSMR                ;E034: 7F 80 02       '...'
; Store 0001 in M0x3A:0x3B
        LDX     #M0001                   ;E037: CE 00 01       '...'
        STX     M003A                    ;E03A: DF 3A          '.:'
; Store 0001 in M0x4D:0x4E
        STX     M004D                    ;E03C: DF 4D          '.M'
; Clear M0x4F
        CLR     >test_ram_addr_5         ;E03E: 7F 00 4F       '..O'
        LDAA    GPIB_Addr                ;E041: 96 00          '..'
; Enable talker and Listerner functionality
        STAA    IC5_ADRR                 ;E043: B7 80 04       '...'
        LDX     #STR_6                   ;E046: CE 4F 4B       '.OK'
; Store "OK" in 0x47:0x48
        STX     M0047                    ;E049: DF 47          '.G'
main_loop_entry JSR     get_M0x45&0xfth_char_of_STR_ARR_2 ;E04B: BD E6 FA       '...'
        JSR     important_looking_uart_func_0 ;E04E: BD E6 A0       '...'
        JSR     test_unk_status_reg_1_0  ;E051: BD E7 6F       '..o'
        CLR     >gpia_csr_copy           ;E054: 7F 00 42       '..B'
        LDAA    IC5_INTR                 ;E057: B6 80 00       '...'
        LDAB    IC5_CSR                  ;E05A: F6 80 01       '...'
        STAB    gpia_csr_copy            ;E05D: D7 42          '.B'
        TAP                              ;E05F: 06             '.'
; Br if GPIB CMD IRQ set
        BEQ     some_str_func_A          ;E060: 27 03          ''.'
        JMP     some_str_func_9          ;E062: 7E E0 B1       '~..'

some_str_func_A LDAA    gpia_csr_copy            ;E065: 96 42          '.B'
        BITA    #$81                     ;E067: 85 81          '..'
; Br if defined GPIB CMD
        BEQ     some_str_func_B          ;E069: 27 08          ''.'
        LDAA    #$10                     ;E06B: 86 10          '..'
        STAA    IC5_ACR                  ;E06D: B7 80 03       '...'
        JMP     some_str_func_9          ;E070: 7E E0 B1       '~..'

some_str_func_B TAP                              ;E073: 06             '.'
; Br if remote/local state changed
        BMI     ZE086                    ;E074: 2B 10          '+.'
; Br if device clear requested
        BVS     ZE09A                    ;E076: 29 22          ')"'
        LDAA    #$EF                     ;E078: 86 EF          '..'
        JSR     anda_unk_status_0        ;E07A: BD E7 AD       '...'
        LDAA    IC5_CSR                  ;E07D: B6 80 01       '...'
        TAP                              ;E080: 06             '.'
        BEQ     some_str_func_A          ;E081: 27 E2          ''.'
        JMP     some_str_func_9          ;E083: 7E E0 B1       '~..'

ZE086   LDAA    gpia_csr_copy            ;E086: 96 42          '.B'
        JSR     test_gpib_csr_0          ;E088: BD E7 3D       '..='
        LDAA    M004C                    ;E08B: 96 4C          '.L'
        BEQ     ZE092                    ;E08D: 27 03          ''.'
        JSR     ZE1DB                    ;E08F: BD E1 DB       '...'
ZE092   LDAA    gpia_csr_copy            ;E092: 96 42          '.B'
        ANDA    #$F7                     ;E094: 84 F7          '..'
        STAA    gpia_csr_copy            ;E096: 97 42          '.B'
        BRA     some_str_func_A          ;E098: 20 CB          ' .'

ZE09A   LDAA    #$10                     ;E09A: 86 10          '..'
        STAA    IC5_ACR                  ;E09C: B7 80 03       '...'
        LDAA    #$10                     ;E09F: 86 10          '..'
        JSR     oraa_unk_status_0        ;E0A1: BD E7 B1       '...'
        LDAA    #$56                     ;E0A4: 86 56          '.V'
        JSR     some_uart_func_2         ;E0A6: BD E7 92       '...'
        LDAA    #$EF                     ;E0A9: 86 EF          '..'
        JSR     anda_unk_status_0        ;E0AB: BD E7 AD       '...'
        JMP     main_loop_entry          ;E0AE: 7E E0 4B       '~.K'

some_str_func_9 CLRA                             ;E0B1: 4F             'O'
        STAA    M0039                    ;E0B2: 97 39          '.9'
        STAA    M003D                    ;E0B4: 97 3D          '.='
        LDX     #M0001                   ;E0B6: CE 00 01       '...'
        STX     M003A                    ;E0B9: DF 3A          '.:'
ZE0BB   JSR     get_M0x45&0xfth_char_of_STR_ARR_2 ;E0BB: BD E6 FA       '...'
        LDAA    IC5_CSR                  ;E0BE: B6 80 01       '...'
        JSR     test_gpib_csr_0          ;E0C1: BD E7 3D       '..='
        JSR     important_looking_uart_func_0 ;E0C4: BD E6 A0       '...'
        JSR     test_unk_status_reg_1_0  ;E0C7: BD E7 6F       '..o'
        JSR     some_str_func_8          ;E0CA: BD E1 AF       '...'
        LDAA    IC5_ADSMR                ;E0CD: B6 80 02       '...'
        CMPA    #$84                     ;E0D0: 81 84          '..'
        BEQ     ZE0DF                    ;E0D2: 27 0B          ''.'
        LDAA    #$FD                     ;E0D4: 86 FD          '..'
        JSR     anda_unk_status_0        ;E0D6: BD E7 AD       '...'
        JSR     test_unknown_status_0    ;E0D9: BD E3 94       '...'
        JMP     ZE18D                    ;E0DC: 7E E1 8D       '~..'

ZE0DF   NOP                              ;E0DF: 01             '.'
        NOP                              ;E0E0: 01             '.'
        NOP                              ;E0E1: 01             '.'
        LDAA    #$02                     ;E0E2: 86 02          '..'
        JSR     oraa_unk_status_0        ;E0E4: BD E7 B1       '...'
        LDX     M003A                    ;E0E7: DE 3A          '.:'
        LDAA    IC5_INTR                 ;E0E9: B6 80 00       '...'
        TAP                              ;E0EC: 06             '.'
; Br if GPIB byte input interrupt set
        BCC     ZE0BB                    ;E0ED: 24 CC          '$.'
        LDAA    IC5_INTR                 ;E0EF: B6 80 00       '...'
        TAP                              ;E0F2: 06             '.'
        BVS     get_gpib_newline         ;E0F3: 29 08          ').'
        LDAB    IC5_DR                   ;E0F5: F6 80 07       '...'
        JSR     ZE1BD                    ;E0F8: BD E1 BD       '...'
        BRA     validate_gpib_char_0     ;E0FB: 20 21          ' !'

get_gpib_newline LDAA    #$7F                     ;E0FD: 86 7F          '..'
        STAA    $01,X                    ;E0FF: A7 01          '..'
        STAA    M0049                    ;E101: 97 49          '.I'
        STAA    M004C                    ;E103: 97 4C          '.L'
        LDAB    IC5_DR                   ;E105: F6 80 07       '...'
        CMPB    #$0D                     ;E108: C1 0D          '..'
        BEQ     get_gpib_char_entry_0    ;E10A: 27 06          ''.'
        CMPB    #$0A                     ;E10C: C1 0A          '..'
        BEQ     get_gpib_char_entry_0    ;E10E: 27 02          ''.'
        BRA     get_gpib_char_entry_1    ;E110: 20 01          ' .'

get_gpib_char_entry_0 TAB                              ;E112: 16             '.'
get_gpib_char_entry_1 STAB    ,X                       ;E113: E7 00          '..'
get_gpib_char_entry_2 LDAB    IC5_DR                   ;E115: F6 80 07       '...'
        LDAA    IC5_INTR                 ;E118: B6 80 00       '...'
        TAP                              ;E11B: 06             '.'
; Br if GPIB input buffer full
        BCS     get_gpib_char_entry_2    ;E11C: 25 F7          '%.'
; Load loop counter
validate_gpib_char_0 LDAA    #$0A                     ;E11E: 86 0A          '..'
        LDX     #STR_ARR_0               ;E120: CE E1 62       '..b'
ZE123   CMPB    ,X                       ;E123: E1 00          '..'
; Br if char in STR_ARR_0
        BEQ     ZE0BB                    ;E125: 27 94          ''.'
        INX                              ;E127: 08             '.'
        DECA                             ;E128: 4A             'J'
        BNE     ZE123                    ;E129: 26 F8          '&.'
        LDX     M003A                    ;E12B: DE 3A          '.:'
; Br if carriage return char
        CMPB    #$0D                     ;E12D: C1 0D          '..'
        BEQ     valid_char_0             ;E12F: 27 3B          '';'
        CMPB    #$0A                     ;E131: C1 0A          '..'
; Br if line feed char
        BEQ     valid_char_0             ;E133: 27 37          ''7'
        CMPB    #$2E                     ;E135: C1 2E          '..'
; Br if full stop char
        BEQ     valid_char_0             ;E137: 27 33          ''3'
        CMPB    #$1F                     ;E139: C1 1F          '..'
; Br if char is printable
        BHI     ZE140                    ;E13B: 22 03          '".'
        JMP     ZE0BB                    ;E13D: 7E E0 BB       '~..'

ZE140   CMPB    #$2F                     ;E140: C1 2F          './'
        BLS     invalid_char_0           ;E142: 23 18          '#.'
        CMPB    #$39                     ;E144: C1 39          '.9'
; Br if char is a number
        BLS     valid_char_0             ;E146: 23 24          '#$'
        CMPB    #$40                     ;E148: C1 40          '.@'
        BHI     ZE14E                    ;E14A: 22 02          '".'
        BRA     invalid_char_0           ;E14C: 20 0E          ' .'

ZE14E   CMPB    #$5A                     ;E14E: C1 5A          '.Z'
; Br if char is capital letter
        BLS     valid_char_0             ;E150: 23 1A          '#.'
        CMPB    #$60                     ;E152: C1 60          '.`'
        BHI     ZE158                    ;E154: 22 02          '".'
        BRA     invalid_char_0           ;E156: 20 04          ' .'

ZE158   CMPB    #$7B                     ;E158: C1 7B          '.{'
; Br if char is lower case letter
        BLS     valid_char_0             ;E15A: 23 10          '#.'
; Char is not alphanumeric or in '.\r\n'
invalid_char_0 LDAA    #$FF                     ;E15C: 86 FF          '..'
        STAA    M003D                    ;E15E: 97 3D          '.='
        BRA     valid_char_0             ;E160: 20 0A          ' .'

STR_ARR_0 FCC     " '+,-/:;`\"             ;E162: 20 27 2B 2C 2D 2F 3A 3B 60 5C ' '+,-/:;`\' "
valid_char_0 LDAA    M0049                    ;E16C: 96 49          '.I'
        BEQ     ZE179                    ;E16E: 27 09          ''.'
        CLR     >M0049                   ;E170: 7F 00 49       '..I'
        JSR     ZE1DB                    ;E173: BD E1 DB       '...'
        JMP     main_loop_entry          ;E176: 7E E0 4B       '~.K'

ZE179   INC     >M0039                   ;E179: 7C 00 39       '|.9'
        LDAA    M0039                    ;E17C: 96 39          '.9'
        CMPA    #$32                     ;E17E: 81 32          '.2'
        BLS     ZE185                    ;E180: 23 03          '#.'
        JMP     ZE388                    ;E182: 7E E3 88       '~..'

ZE185   STAB    ,X                       ;E185: E7 00          '..'
        INX                              ;E187: 08             '.'
        STX     M003A                    ;E188: DF 3A          '.:'
        JMP     ZE0BB                    ;E18A: 7E E0 BB       '~..'

ZE18D   LDAA    gpia_csr_copy            ;E18D: 96 42          '.B'
        ROLA                             ;E18F: 49             'I'
        ROLA                             ;E190: 49             'I'
; Br if Device Clear Active State
        BPL     hdlr_DCAS                ;E191: 2A 13          '*.'
        LDAA    unknown_status_0         ;E193: 96 25          '.%'
        TAP                              ;E195: 06             '.'
        BEQ     ZE1A2                    ;E196: 27 0A          ''.'
        LDAA    #$04                     ;E198: 86 04          '..'
        JSR     oraa_unk_status_0        ;E19A: BD E7 B1       '...'
        LDAA    #$55                     ;E19D: 86 55          '.U'
        JSR     some_uart_func_2         ;E19F: BD E7 92       '...'
ZE1A2   BSR     some_str_func_8          ;E1A2: 8D 0B          '..'
        BRA     ZE1BA                    ;E1A4: 20 14          ' .'

hdlr_DCAS LDAA    #$FB                     ;E1A6: 86 FB          '..'
        JSR     anda_unk_status_0        ;E1A8: BD E7 AD       '...'
        BSR     some_str_func_8          ;E1AB: 8D 02          '..'
        BRA     ZE1BA                    ;E1AD: 20 0B          ' .'

some_str_func_8 LDAA    possible_gpib_status     ;E1AF: 96 26          '.&'
        BEQ     ZE1B6                    ;E1B1: 27 03          ''.'
        JSR     ZE2EC                    ;E1B3: BD E2 EC       '...'
ZE1B6   JSR     test_unknown_status_0    ;E1B6: BD E3 94       '...'
        RTS                              ;E1B9: 39             '9'

;-------------------------------------------------------------------------------

ZE1BA   JMP     main_loop_entry          ;E1BA: 7E E0 4B       '~.K'

ZE1BD   CMPB    #$0D                     ;E1BD: C1 0D          '..'
        BNE     ZE1C3                    ;E1BF: 26 02          '&.'
        BRA     ZE1C7                    ;E1C1: 20 04          ' .'

ZE1C3   CMPB    #$0A                     ;E1C3: C1 0A          '..'
        BNE     ZE1DA                    ;E1C5: 26 13          '&.'
ZE1C7   LDAB    IC5_DR                   ;E1C7: F6 80 07       '...'
        LDAA    IC5_INTR                 ;E1CA: B6 80 00       '...'
        TAP                              ;E1CD: 06             '.'
        BCS     ZE1C7                    ;E1CE: 25 F7          '%.'
        LDAA    #$7F                     ;E1D0: 86 7F          '..'
        STAA    M0049                    ;E1D2: 97 49          '.I'
        STAA    $01,X                    ;E1D4: A7 01          '..'
        LDAA    #$FF                     ;E1D6: 86 FF          '..'
        STAA    M004C                    ;E1D8: 97 4C          '.L'
ZE1DA   RTS                              ;E1DA: 39             '9'

;-------------------------------------------------------------------------------

ZE1DB   LDAA    unknown_status_0         ;E1DB: 96 25          '.%'
        ANDA    #$08                     ;E1DD: 84 08          '..'
        BEQ     ZE1FF                    ;E1DF: 27 1E          ''.'
        CLR     >M004C                   ;E1E1: 7F 00 4C       '..L'
        LDX     #M0001                   ;E1E4: CE 00 01       '...'
        STX     M003A                    ;E1E7: DF 3A          '.:'
ZE1E9   LDX     M003A                    ;E1E9: DE 3A          '.:'
        LDAA    ,X                       ;E1EB: A6 00          '..'
        BNE     ZE1F4                    ;E1ED: 26 05          '&.'
        INX                              ;E1EF: 08             '.'
        STX     M003A                    ;E1F0: DF 3A          '.:'
        BRA     ZE1E9                    ;E1F2: 20 F5          ' .'

ZE1F4   CMPA    #$2F                     ;E1F4: 81 2F          './'
        BLS     ZE23A                    ;E1F6: 23 42          '#B'
        CMPA    #$7F                     ;E1F8: 81 7F          '..'
        BNE     ZE200                    ;E1FA: 26 04          '&.'
        JSR     fill_mem_w_0x7f          ;E1FC: BD E3 6E       '..n'
ZE1FF   RTS                              ;E1FF: 39             '9'

;-------------------------------------------------------------------------------

ZE200   STAA    test_ram_addr_4          ;E200: 97 4A          '.J'
        CMPA    #$40                     ;E202: 81 40          '.@'
; Br if M0x4A greater than 0x40
        BHI     ZE20B                    ;E204: 22 05          '".'
        JSR     ZE37C                    ;E206: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E209: 20 F4          ' .'

ZE20B   CMPA    #$48                     ;E20B: 81 48          '.H'
; Br if M0x4A less than 0x48
        BLS     ZE21E                    ;E20D: 23 0F          '#.'
        STAA    uart_tx_buf_0            ;E20F: 97 22          '."'
        CMPA    #$71                     ;E211: 81 71          '.q'
        BEQ     ZE1FF                    ;E213: 27 EA          ''.'
        CMPA    #$72                     ;E215: 81 72          '.r'
        BEQ     ZE1FF                    ;E217: 27 E6          ''.'
        INX                              ;E219: 08             '.'
        STX     M003A                    ;E21A: DF 3A          '.:'
        BRA     ZE22D                    ;E21C: 20 0F          ' .'

ZE21E   STAA    uart_tx_buf_0            ;E21E: 97 22          '."'
        INX                              ;E220: 08             '.'
        JSR     ZE24B                    ;E221: BD E2 4B       '..K'
        LDAA    M003D                    ;E224: 96 3D          '.='
        BEQ     ZE22D                    ;E226: 27 05          ''.'
        JSR     ZE37C                    ;E228: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E22B: 20 D2          ' .'

ZE22D   JSR     some_uart_func_0         ;E22D: BD E5 FB       '...'
        JSR     ZE732                    ;E230: BD E7 32       '..2'
        JSR     validate_uart_msg_0      ;E233: BD E7 98       '...'
        LDX     M003A                    ;E236: DE 3A          '.:'
        BRA     ZE23D                    ;E238: 20 03          ' .'

ZE23A   LDX     M003A                    ;E23A: DE 3A          '.:'
        INX                              ;E23C: 08             '.'
ZE23D   CPX     #uart_tx_buf_0           ;E23D: 8C 00 22       '.."'
        BNE     ZE247                    ;E240: 26 05          '&.'
        JSR     ZE37C                    ;E242: BD E3 7C       '..|'
        BRA     ZE1FF                    ;E245: 20 B8          ' .'

ZE247   STX     M003A                    ;E247: DF 3A          '.:'
        BRA     ZE1E9                    ;E249: 20 9E          ' .'

; TODO
; seems to copy bytes of memory from 
; preserve clobbered X register in M0x3A:0x3B
ZE24B   STX     M003A                    ;E24B: DF 3A          '.:'
        LDX     #M0027                   ;E24D: CE 00 27       '..''
        CLRA                             ;E250: 4F             'O'
; clear M0x27 to M0x33
clr_mem_loop_0 STAA    ,X                       ;E251: A7 00          '..'
        INX                              ;E253: 08             '.'
        CPX     #M0033                   ;E254: 8C 00 33       '..3'
        BNE     clr_mem_loop_0           ;E257: 26 F8          '&.'
        LDX     #M002D                   ;E259: CE 00 2D       '..-'
; store 0x002D in M0x33:0x34
        STX     M0033                    ;E25C: DF 33          '.3'
; not sure when this loop terminates 
; restore X register from M0x3A:0x3B
ZE25E   LDX     M003A                    ;E25E: DE 3A          '.:'
        LDAA    ,X                       ;E260: A6 00          '..'
        CMPA    #$39                     ;E262: 81 39          '.9'
; Br if *X greater than 0x39
        BHI     ZE272                    ;E264: 22 0C          '".'
        INX                              ;E266: 08             '.'
; Increment X and store in M0x3A
        STX     M003A                    ;E267: DF 3A          '.:'
; Load X register from M0x33
        LDX     M0033                    ;E269: DE 33          '.3'
; Store ACCA in *X
        STAA    ,X                       ;E26B: A7 00          '..'
        INX                              ;E26D: 08             '.'
; Increment X and store in M0x33:M0x34
        STX     M0033                    ;E26E: DF 33          '.3'
        BRA     ZE25E                    ;E270: 20 EC          ' .'

ZE272   CLR     >M0038                   ;E272: 7F 00 38       '..8'
        LDX     #M002D                   ;E275: CE 00 2D       '..-'
ZE278   LDAA    ,X                       ;E278: A6 00          '..'
        BEQ     ZE28C                    ;E27A: 27 10          ''.'
        CMPA    #$2E                     ;E27C: 81 2E          '..'
        BEQ     ZE28C                    ;E27E: 27 0C          ''.'
        INC     >M0038                   ;E280: 7C 00 38       '|.8'
        INX                              ;E283: 08             '.'
        CPX     #M0034                   ;E284: 8C 00 34       '..4'
        BNE     ZE278                    ;E287: 26 EF          '&.'
        DEC     >M003D                   ;E289: 7A 00 3D       'z.='
ZE28C   STX     M0033                    ;E28C: DF 33          '.3'
        LDAA    #$48                     ;E28E: 86 48          '.H'
        SUBA    uart_tx_buf_0            ;E290: 90 22          '."'
; Br if local GBIB status bits zero
        BMI     ZE2C5                    ;E292: 2B 31          '+1'
        CMPA    #$03                     ;E294: 81 03          '..'
        BHI     ZE29A                    ;E296: 22 02          '".'
        ADDA    #$04                     ;E298: 8B 04          '..'
ZE29A   CMPA    #$05                     ;E29A: 81 05          '..'
        BLS     ZE2B2                    ;E29C: 23 14          '#.'
        LDAA    M0038                    ;E29E: 96 38          '.8'
        CMPA    #$02                     ;E2A0: 81 02          '..'
        BHI     ZE2D6                    ;E2A2: 22 32          '"2'
        LDX     M0033                    ;E2A4: DE 33          '.3'
        LDAA    $01,X                    ;E2A6: A6 01          '..'
        STAA    ,X                       ;E2A8: A7 00          '..'
        LDAA    $02,X                    ;E2AA: A6 02          '..'
        STAA    $01,X                    ;E2AC: A7 01          '..'
        LDAB    #$04                     ;E2AE: C6 04          '..'
        BRA     ZE2C0                    ;E2B0: 20 0E          ' .'

ZE2B2   LDAA    M0038                    ;E2B2: 96 38          '.8'
        CMPA    #$04                     ;E2B4: 81 04          '..'
        BHI     ZE2D6                    ;E2B6: 22 1E          '".'
        LDX     M0033                    ;E2B8: DE 33          '.3'
        LDAA    $01,X                    ;E2BA: A6 01          '..'
        STAA    ,X                       ;E2BC: A7 00          '..'
        LDAB    #$02                     ;E2BE: C6 02          '..'
ZE2C0   ADDB    M0038                    ;E2C0: DB 38          '.8'
        JSR     ZE359                    ;E2C2: BD E3 59       '..Y'
ZE2C5   LDX     #M0027                   ;E2C5: CE 00 27       '..''
ZE2C8   LDAA    ,X                       ;E2C8: A6 00          '..'
        BEQ     ZE2D9                    ;E2CA: 27 0D          ''.'
        CMPA    #$2F                     ;E2CC: 81 2F          './'
        BHI     ZE2D2                    ;E2CE: 22 02          '".'
        BRA     ZE2D6                    ;E2D0: 20 04          ' .'

ZE2D2   CMPA    #$39                     ;E2D2: 81 39          '.9'
        BLS     ZE2D9                    ;E2D4: 23 03          '#.'
ZE2D6   STAA    M003D                    ;E2D6: 97 3D          '.='
        RTS                              ;E2D8: 39             '9'

;-------------------------------------------------------------------------------

ZE2D9   INX                              ;E2D9: 08             '.'
        CPX     #M0034                   ;E2DA: 8C 00 34       '..4'
        BNE     ZE2C8                    ;E2DD: 26 E9          '&.'
        LDX     #M0027                   ;E2DF: CE 00 27       '..''
        JSR     ZE311                    ;E2E2: BD E3 11       '...'
        LDX     M0033                    ;E2E5: DE 33          '.3'
        STX     uart_tx_buf_1            ;E2E7: DF 23          '.#'
        LDX     M003A                    ;E2E9: DE 3A          '.:'
        RTS                              ;E2EB: 39             '9'

;-------------------------------------------------------------------------------

ZE2EC   LDAA    unknown_status_0         ;E2EC: 96 25          '.%'
        BITA    #$08                     ;E2EE: 85 08          '..'
        BEQ     ZE2FC                    ;E2F0: 27 0A          ''.'
        LDAA    IC5_SPR                  ;E2F2: B6 80 05       '...'
; Br if no GPIB service request pending or status bits non-zero
        BNE     ZE2FC                    ;E2F5: 26 05          '&.'
        LDAA    possible_gpib_status     ;E2F7: 96 26          '.&'
        STAA    IC5_SPR                  ;E2F9: B7 80 05       '...'
ZE2FC   LDAA    IC5_SPR                  ;E2FC: B6 80 05       '...'
        BITA    #$40                     ;E2FF: 85 40          '.@'
; Br is no GBIB service request
        BNE     ZE310                    ;E301: 26 0D          '&.'
        LDAA    IC5_CSR                  ;E303: B6 80 01       '...'
        BITA    #$04                     ;E306: 85 04          '..'
; Br if GPIB remote disabled
        BNE     ZE310                    ;E308: 26 06          '&.'
; Clear local and IC5 status bits
        CLR     >possible_gpib_status    ;E30A: 7F 00 26       '..&'
        CLR     IC5_SPR                  ;E30D: 7F 80 05       '...'
ZE310   RTS                              ;E310: 39             '9'

;-------------------------------------------------------------------------------

ZE311   LDAA    #$04                     ;E311: 86 04          '..'
        STAA    M0035                    ;E313: 97 35          '.5'
        CLRA                             ;E315: 4F             'O'
        STAA    M0033                    ;E316: 97 33          '.3'
        STAA    M0034                    ;E318: 97 34          '.4'
        BRA     ZE33F                    ;E31A: 20 23          ' #'

ZE31C   LDAB    #$20                     ;E31C: C6 20          '. '
        LDAA    M0033                    ;E31E: 96 33          '.3'
        STAA    M002C                    ;E320: 97 2C          '.,'
        LDAA    M0034                    ;E322: 96 34          '.4'
        STAA    M002D                    ;E324: 97 2D          '.-'
ZE326   ASL     >M0034                   ;E326: 78 00 34       'x.4'
        ROL     >M0033                   ;E329: 79 00 33       'y.3'
        ASLB                             ;E32C: 58             'X'
        BEQ     ZE33F                    ;E32D: 27 10          ''.'
        BPL     ZE326                    ;E32F: 2A F5          '*.'
        LDAA    M0034                    ;E331: 96 34          '.4'
        ADDA    M002D                    ;E333: 9B 2D          '.-'
        STAA    M0034                    ;E335: 97 34          '.4'
        LDAA    M0033                    ;E337: 96 33          '.3'
        ADCA    M002C                    ;E339: 99 2C          '.,'
        STAA    M0033                    ;E33B: 97 33          '.3'
        BRA     ZE326                    ;E33D: 20 E7          ' .'

ZE33F   LDAA    ,X                       ;E33F: A6 00          '..'
        ANDA    #$0F                     ;E341: 84 0F          '..'
        ADDA    M0034                    ;E343: 9B 34          '.4'
        STAA    M0034                    ;E345: 97 34          '.4'
        LDAA    M0033                    ;E347: 96 33          '.3'
        ADCA    #$00                     ;E349: 89 00          '..'
        STAA    M0033                    ;E34B: 97 33          '.3'
        BCC     ZE352                    ;E34D: 24 03          '$.'
        INC     >M0033                   ;E34F: 7C 00 33       '|.3'
ZE352   INX                              ;E352: 08             '.'
        DEC     >M0035                   ;E353: 7A 00 35       'z.5'
        BNE     ZE31C                    ;E356: 26 C4          '&.'
        RTS                              ;E358: 39             '9'

;-------------------------------------------------------------------------------

ZE359   LDAA    #$0C                     ;E359: 86 0C          '..'
        STAA    M0035                    ;E35B: 97 35          '.5'
        LDX     #M0027                   ;E35D: CE 00 27       '..''
ZE360   LDAA    $01,X                    ;E360: A6 01          '..'
        STAA    ,X                       ;E362: A7 00          '..'
        INX                              ;E364: 08             '.'
        DEC     >M0035                   ;E365: 7A 00 35       'z.5'
        BNE     ZE360                    ;E368: 26 F6          '&.'
        DECB                             ;E36A: 5A             'Z'
        BNE     ZE359                    ;E36B: 26 EC          '&.'
        RTS                              ;E36D: 39             '9'

;-------------------------------------------------------------------------------

; Fills M0x01:M0x20 with 0x7F
fill_mem_w_0x7f LDX     #M0001                   ;E36E: CE 00 01       '...'
hdlr_IRQ_UART LDAA    #$7F                     ;E371: 86 7F          '..'
ZE373   STAA    ,X                       ;E373: A7 00          '..'
        INX                              ;E375: 08             '.'
        CPX     #M0021                   ;E376: 8C 00 21       '..!'
        BNE     ZE373                    ;E379: 26 F8          '&.'
        RTS                              ;E37B: 39             '9'

;-------------------------------------------------------------------------------

ZE37C   LDAA    #$4D                     ;E37C: 86 4D          '.M'
        STAA    possible_gpib_status     ;E37E: 97 26          '.&'
        STAA    M0047                    ;E380: 97 47          '.G'
        BSR     fill_mem_w_0x7f          ;E382: 8D EA          '..'
        CLR     >M0049                   ;E384: 7F 00 49       '..I'
        RTS                              ;E387: 39             '9'

;-------------------------------------------------------------------------------

ZE388   LDAA    #$4F                     ;E388: 86 4F          '.O'
        STAA    M0047                    ;E38A: 97 47          '.G'
        STAA    possible_gpib_status     ;E38C: 97 26          '.&'
        CLR     >M0049                   ;E38E: 7F 00 49       '..I'
        JMP     ZE1A2                    ;E391: 7E E1 A2       '~..'

test_unknown_status_0 LDAA    unknown_status_0         ;E394: 96 25          '.%'
        ANDA    #$08                     ;E396: 84 08          '..'
        BNE     some_str_func_6          ;E398: 26 03          '&.'
; Return early if unknown_status_0 == 0x00
        JMP     return_1                 ;E39A: 7E E5 9A       '~..'

some_str_func_6 LDAA    IC5_ADSMR                ;E39D: B6 80 02       '...'
        ANDA    #$08                     ;E3A0: 84 08          '..'
        BNE     some_str_func_5          ;E3A2: 26 10          '&.'
        LDAA    #$FE                     ;E3A4: 86 FE          '..'
        JSR     anda_unk_status_0        ;E3A6: BD E7 AD       '...'
        LDX     #M0001                   ;E3A9: CE 00 01       '...'
        STX     M004D                    ;E3AC: DF 4D          '.M'
        CLR     >test_ram_addr_5         ;E3AE: 7F 00 4F       '..O'
        JMP     return_1                 ;E3B1: 7E E5 9A       '~..'

some_str_func_5 LDAA    #$01                     ;E3B4: 86 01          '..'
        JSR     oraa_unk_status_0        ;E3B6: BD E7 B1       '...'
        LDAA    test_ram_addr_4          ;E3B9: 96 4A          '.J'
        BNE     some_str_func_C          ;E3BB: 26 02          '&.'
        BRA     ZE3C7                    ;E3BD: 20 08          ' .'

some_str_func_C CMPA    #$60                     ;E3BF: 81 60          '.`'
        BLS     ZE3C7                    ;E3C1: 23 04          '#.'
        CMPA    #$72                     ;E3C3: 81 72          '.r'
        BLS     some_str_func_4          ;E3C5: 23 19          '#.'
ZE3C7   CMPA    #$00                     ;E3C7: 81 00          '..'
        BNE     ZE3CE                    ;E3C9: 26 03          '&.'
        JMP     return_1                 ;E3CB: 7E E5 9A       '~..'

ZE3CE   STAA    M0001                    ;E3CE: 97 01          '..'
        LDAA    #$20                     ;E3D0: 86 20          '. '
        STAA    M0002                    ;E3D2: 97 02          '..'
        LDX     #STR_1                   ;E3D4: CE 3F 3F       '.??'
        STX     M0003                    ;E3D7: DF 03          '..'
        LDAA    #$0D                     ;E3D9: 86 0D          '..'
        STAA    M0005                    ;E3DB: 97 05          '..'
        JMP     ZE551                    ;E3DD: 7E E5 51       '~.Q'

some_str_func_4 LDAA    test_ram_addr_4          ;E3E0: 96 4A          '.J'
        CMPA    #$72                     ;E3E2: 81 72          '.r'
; Br if M0x4A not 0x72
        BNE     some_str_func_3          ;E3E4: 26 20          '& '
        LDX     #STR_2                   ;E3E6: CE 45 52       '.ER'
        STX     M0001                    ;E3E9: DF 01          '..'
        LDX     #STR_9                   ;E3EB: CE 52 20       '.R '
        STX     M0003                    ;E3EE: DF 03          '..'
        LDX     M0047                    ;E3F0: DE 47          '.G'
        CPX     #STR_6                   ;E3F2: 8C 4F 4B       '.OK'
; Br if M0x47:M0x48 == "OK"
        BEQ     ZE3FD                    ;E3F5: 27 06          ''.'
        LDAB    #$21                     ;E3F7: C6 21          '.!'
        STAB    M0048                    ;E3F9: D7 48          '.H'
        LDX     M0047                    ;E3FB: DE 47          '.G'
ZE3FD   STX     M0005                    ;E3FD: DF 05          '..'
        LDAB    #$0D                     ;E3FF: C6 0D          '..'
        STAB    M0007                    ;E401: D7 07          '..'
        JMP     ZE551                    ;E403: 7E E5 51       '~.Q'

some_str_func_3 CMPA    #$71                     ;E406: 81 71          '.q'
        BEQ     some_str_func_2          ;E408: 27 03          ''.'
        JMP     cmd_str_func_1           ;E40A: 7E E4 9A       '~..'

some_str_func_2 LDAA    M0046                    ;E40D: 96 46          '.F'
        LDAB    M0045                    ;E40F: D6 45          '.E'
        CBA                              ;E411: 11             '.'
        BEQ     some_str_func_1          ;E412: 27 05          ''.'
        JSR     important_looking_uart_func_0 ;E414: BD E6 A0       '...'
        BRA     some_str_func_2          ;E417: 20 F4          ' .'

some_str_func_1 ANDA    #$05                     ;E419: 84 05          '..'
        LDX     #STR_ARR_3               ;E41B: CE E7 B6       '...'
        JSR     ZE763                    ;E41E: BD E7 63       '..c'
        LDAA    $01,X                    ;E421: A6 01          '..'
        STAA    M0001                    ;E423: 97 01          '..'
        LDAA    $02,X                    ;E425: A6 02          '..'
        STAA    M0002                    ;E427: 97 02          '..'
        LDAA    $03,X                    ;E429: A6 03          '..'
        STAA    M0003                    ;E42B: 97 03          '..'
        LDAA    $04,X                    ;E42D: A6 04          '..'
        STAA    M0004                    ;E42F: 97 04          '..'
        LDAA    #$2F                     ;E431: 86 2F          './'
        STAA    M0005                    ;E433: 97 05          '..'
        LDAA    M0045                    ;E435: 96 45          '.E'
        ANDA    #$0A                     ;E437: 84 0A          '..'
        JSR     get_next_str_ptr         ;E439: BD E7 5E       '..^'
        LDAA    $01,X                    ;E43C: A6 01          '..'
        STAA    M0006                    ;E43E: 97 06          '..'
        LDAA    $02,X                    ;E440: A6 02          '..'
        STAA    M0007                    ;E442: 97 07          '..'
        LDAA    $03,X                    ;E444: A6 03          '..'
        STAA    M0008                    ;E446: 97 08          '..'
        LDAA    $04,X                    ;E448: A6 04          '..'
        STAA    M0009                    ;E44A: 97 09          '..'
        LDAA    #$2F                     ;E44C: 86 2F          './'
        STAA    M000A                    ;E44E: 97 0A          '..'
        LDAA    M0045                    ;E450: 96 45          '.E'
        BMI     ZE464                    ;E452: 2B 10          '+.'
        LDX     #STR_B                   ;E454: CE 54 4F       '.TO'
        STX     M000B                    ;E457: DF 0B          '..'
        LDX     #STR_4                   ;E459: CE 46 46       '.FF'
        STX     M000D                    ;E45C: DF 0D          '..'
        LDAA    #$2F                     ;E45E: 86 2F          './'
        STAA    M000F                    ;E460: 97 0F          '..'
        BRA     ZE472                    ;E462: 20 0E          ' .'

ZE464   LDX     #STR_A                   ;E464: CE 54 20       '.T '
        STX     M000B                    ;E467: DF 0B          '..'
        LDX     #STR_7                   ;E469: CE 4F 4E       '.ON'
        STX     M000D                    ;E46C: DF 0D          '..'
        LDAA    #$2F                     ;E46E: 86 2F          './'
        STAA    M000F                    ;E470: 97 0F          '..'
ZE472   LDAA    M0045                    ;E472: 96 45          '.E'
        ANDA    #$40                     ;E474: 84 40          '.@'
        BNE     ZE489                    ;E476: 26 11          '&.'
        LDX     #STR_8                   ;E478: CE 4F 50       '.OP'
        STX     M0010                    ;E47B: DF 10          '..'
        LDX     #STR_5                   ;E47D: CE 4F 46       '.OF'
        STX     M0012                    ;E480: DF 12          '..'
        LDX     #STR_3                   ;E482: CE 46 0D       '.F.'
        STX     M0014                    ;E485: DF 14          '..'
        BRA     ZE497                    ;E487: 20 0E          ' .'

ZE489   LDX     #STR_8                   ;E489: CE 4F 50       '.OP'
        STX     M0010                    ;E48C: DF 10          '..'
        LDX     #STR_7                   ;E48E: CE 4F 4E       '.ON'
        STX     M0012                    ;E491: DF 12          '..'
        LDAA    #$0D                     ;E493: 86 0D          '..'
        STAA    M0014                    ;E495: 97 14          '..'
ZE497   JMP     ZE551                    ;E497: 7E E5 51       '~.Q'

cmd_str_func_1 LDAA    uart_msg_1               ;E49A: 96 43          '.C'
        ANDA    #$BF                     ;E49C: 84 BF          '..'
        STAA    M0036                    ;E49E: 97 36          '.6'
        LDAB    uart_msg_2               ;E4A0: D6 44          '.D'
        STAB    M0037                    ;E4A2: D7 37          '.7'
        JSR     ZE59B                    ;E4A4: BD E5 9B       '...'
        LDAA    test_ram_addr_4          ;E4A7: 96 4A          '.J'
        LDX     #UART_STR_ARR_0          ;E4A9: CE E4 BB       '...'
cmd_str_func_1_loop CMPA    ,X                       ;E4AC: A1 00          '..'
        BEQ     ZE4EF                    ;E4AE: 27 3F          ''?'
        INX                              ;E4B0: 08             '.'
        INX                              ;E4B1: 08             '.'
        INX                              ;E4B2: 08             '.'
        INX                              ;E4B3: 08             '.'
        CPX     #UART_STR_ARR_0_END      ;E4B4: 8C E4 EB       '...'
        BNE     cmd_str_func_1_loop      ;E4B7: 26 F3          '&.'
        BRA     ZE4EF                    ;E4B9: 20 34          ' 4'

UART_STR_ARR_0 FCC     "aVSAbVSBcISAdISBiVOAj"  ;E4BB: 61 56 53 41 62 56 53 42 63 49 53 41 64 49 53 42 69 56 4F 41 6A 'aVSAbVSBcISAdISBiVOAj'
        FCC     "VOBkIOAlIOBeVLAfVLBgI"  ;E4D0: 56 4F 42 6B 49 4F 41 6C 49 4F 42 65 56 4C 41 66 56 4C 42 67 49 'VOBkIOAlIOBeVLAfVLBgI'
        FCC     "LAhILB"                 ;E4E5: 4C 41 68 49 4C 42 'LAhILB'
UART_STR_ARR_0_END FCC     "  ??"                   ;E4EB: 20 20 3F 3F    '  ??'
ZE4EF   LDAA    $01,X                    ;E4EF: A6 01          '..'
        CMPA    #$20                     ;E4F1: 81 20          '. '
; Br if ACCA = '%20'
        BNE     ZE4F7                    ;E4F3: 26 02          '&.'
        LDAA    test_ram_addr_4          ;E4F5: 96 4A          '.J'
; store command or error in buffer
ZE4F7   STAA    M0001                    ;E4F7: 97 01          '..'
        LDAA    $02,X                    ;E4F9: A6 02          '..'
        STAA    M0002                    ;E4FB: 97 02          '..'
        LDAA    $03,X                    ;E4FD: A6 03          '..'
        STAA    M0003                    ;E4FF: 97 03          '..'
        LDAA    #$20                     ;E501: 86 20          '. '
        STAA    M0004                    ;E503: 97 04          '..'
        LDAA    test_ram_addr_4          ;E505: 96 4A          '.J'
        SUBA    #$61                     ;E507: 80 61          '.a'
match_loop_1 CMPA    #$03                     ;E509: 81 03          '..'
; Br if no match
        BHI     ZE50F                    ;E50B: 22 02          '".'
        BRA     ZE513                    ;E50D: 20 04          ' .'

ZE50F   SUBA    #$04                     ;E50F: 80 04          '..'
        BRA     match_loop_1             ;E511: 20 F6          ' .'

ZE513   CMPA    #$01                     ;E513: 81 01          '..'
; Br if greater than 1
        BHI     ZE52F                    ;E515: 22 18          '".'
        LDX     M0007                    ;E517: DE 07          '..'
        STX     M0008                    ;E519: DF 08          '..'
        LDAA    #$2E                     ;E51B: 86 2E          '..'
        STAA    M0007                    ;E51D: 97 07          '..'
        LDAA    M0005                    ;E51F: 96 05          '..'
        CMPA    #$30                     ;E521: 81 30          '.0'
        BNE     ZE54D                    ;E523: 26 28          '&('
        LDAA    #$20                     ;E525: 86 20          '. '
        STAA    M0005                    ;E527: 97 05          '..'
        LDAA    #$0D                     ;E529: 86 0D          '..'
        STAA    M000A                    ;E52B: 97 0A          '..'
        BRA     ZE551                    ;E52D: 20 22          ' "'

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
ZE54D   LDAA    #$0D                     ;E54D: 86 0D          '..'
        STAA    M000A                    ;E54F: 97 0A          '..'
ZE551   LDAB    test_ram_addr_5          ;E551: D6 4F          '.O'
        LDX     M004D                    ;E553: DE 4D          '.M'
ZE555   LDAA    IC5_INTR                 ;E555: B6 80 00       '...'
        ROLA                             ;E558: 49             'I'
; Br if IC5_INTR bit 2 set i.e. GPIB SPAS or RLC or DCAS or UUCG or UACG occurred
        BPL     return_1                 ;E559: 2A 3F          '*?'
        LDAA    ,X                       ;E55B: A6 00          '..'
        CMPB    #$0D                     ;E55D: C1 0D          '..'
; Br if end of string
        BEQ     ZE56C                    ;E55F: 27 0B          ''.'
        STAA    IC5_DR                   ;E561: B7 80 07       '...'
        TAB                              ;E564: 16             '.'
        STAB    test_ram_addr_5          ;E565: D7 4F          '.O'
        INX                              ;E567: 08             '.'
        STX     M004D                    ;E568: DF 4D          '.M'
        BRA     ZE555                    ;E56A: 20 E9          ' .'

ZE56C   LDAB    #$22                     ;E56C: C6 22          '."'
; Set GPIB Force end or identify, data accept disable
        STAB    IC5_ACR                  ;E56E: F7 80 03       '...'
        LDAA    #$0A                     ;E571: 86 0A          '..'
; Send /cr 
        STAA    IC5_DR                   ;E573: B7 80 07       '...'
        LDAA    IC5_CSR                  ;E576: B6 80 01       '...'
        ROLA                             ;E579: 49             'I'
; Br if Serial Poll Active State set
        BPL     return_1                 ;E57A: 2A 1E          '*.'
        LDAA    #$10                     ;E57C: 86 10          '..'
; Set GPIB Release Data Accept Handshake
        STAA    IC5_ACR                  ;E57E: B7 80 03       '...'
        LDX     #M0001                   ;E581: CE 00 01       '...'
        STX     M004D                    ;E584: DF 4D          '.M'
        CLR     >test_ram_addr_5         ;E586: 7F 00 4F       '..O'
        JSR     fill_mem_w_0x7f          ;E589: BD E3 6E       '..n'
        LDAA    test_ram_addr_4          ;E58C: 96 4A          '.J'
        CMPA    #$72                     ;E58E: 81 72          '.r'
; Br if M0x4A not 0x72
        BNE     ZE597                    ;E590: 26 05          '&.'
        LDX     #STR_6                   ;E592: CE 4F 4B       '.OK'
        STX     M0047                    ;E595: DF 47          '.G'
ZE597   CLR     >test_ram_addr_4         ;E597: 7F 00 4A       '..J'
return_1 RTS                              ;E59A: 39             '9'
ZE59B   LDX     #GPIB_Addr               ;E59B: CE 00 00       '...'
        STX     M0027                    ;E59E: DF 27          '.''
        STX     M0029                    ;E5A0: DF 29          '.)'
        CLRA                             ;E5A2: 4F             'O'
        STAA    M002B                    ;E5A3: 97 2B          '.+'
        LDX     #M0027                   ;E5A5: CE 00 27       '..''
        LDAA    #$04                     ;E5A8: 86 04          '..'
        STAA    M002C                    ;E5AA: 97 2C          '.,'
        LDAA    M0036                    ;E5AC: 96 36          '.6'
        LDAB    M0037                    ;E5AE: D6 37          '.7'
        STX     M0036                    ;E5B0: DF 36          '.6'
        LDX     #CONST_2                 ;E5B2: CE E5 F3       '...'
ZE5B5   SUBB    $01,X                    ;E5B5: E0 01          '..'
        SBCA    ,X                       ;E5B7: A2 00          '..'
        BPL     ZE5CB                    ;E5B9: 2A 10          '*.'
        ADDB    $01,X                    ;E5BB: EB 01          '..'
        ADCA    ,X                       ;E5BD: A9 00          '..'
        INX                              ;E5BF: 08             '.'
        INX                              ;E5C0: 08             '.'
        INC     >M0037                   ;E5C1: 7C 00 37       '|.7'
        DEC     >M002C                   ;E5C4: 7A 00 2C       'z.,'
        BNE     ZE5B5                    ;E5C7: 26 EC          '&.'
        BRA     ZE5D5                    ;E5C9: 20 0A          ' .'

ZE5CB   STX     M002D                    ;E5CB: DF 2D          '.-'
        LDX     M0036                    ;E5CD: DE 36          '.6'
        INC     ,X                       ;E5CF: 6C 00          'l.'
        LDX     M002D                    ;E5D1: DE 2D          '.-'
        BRA     ZE5B5                    ;E5D3: 20 E0          ' .'

ZE5D5   LDX     M0036                    ;E5D5: DE 36          '.6'
        STAB    ,X                       ;E5D7: E7 00          '..'
        LDX     #M0027                   ;E5D9: CE 00 27       '..''
ZE5DC   LDAA    ,X                       ;E5DC: A6 00          '..'
        ANDA    #$0F                     ;E5DE: 84 0F          '..'
        ORAA    #$30                     ;E5E0: 8A 30          '.0'
        STAA    ,X                       ;E5E2: A7 00          '..'
        INX                              ;E5E4: 08             '.'
        CPX     #M002C                   ;E5E5: 8C 00 2C       '..,'
        BNE     ZE5DC                    ;E5E8: 26 F2          '&.'
        LDX     M0028                    ;E5EA: DE 28          '.('
        STX     M0005                    ;E5EC: DF 05          '..'
        LDX     M002A                    ;E5EE: DE 2A          '.*'
        STX     M0007                    ;E5F0: DF 07          '..'
        RTS                              ;E5F2: 39             '9'

;-------------------------------------------------------------------------------

CONST_2 FCC     "'"                      ;E5F3: 27             '''
        FCB     $10,$03,$E8,$00          ;E5F4: 10 03 E8 00    '....'
        FCC     "d"                      ;E5F8: 64             'd'
        FCB     $00,$0A                  ;E5F9: 00 0A          '..'
some_uart_func_0 LDAA    #$05                     ;E5FB: 86 05          '..'
        STAA    unkown_uart_reg_0        ;E5FD: 97 3E          '.>'
ZE5FF   LDAB    unknown_status_0         ;E5FF: D6 25          '.%'
        JSR     uart_put_char            ;E601: BD E6 52       '..R'
ZE604   JSR     uart_get_char            ;E604: BD E6 68       '..h'
        BNE     ZE61C                    ;E607: 26 13          '&.'
        TBA                              ;E609: 17             '.'
        ANDA    #$30                     ;E60A: 84 30          '.0'
        BNE     ZE604                    ;E60C: 26 F6          '&.'
        STAB    unknown_status_1         ;E60E: D7 3C          '.<'
        JSR     uart_put_str             ;E610: BD E6 83       '...'
        BNE     ZE61C                    ;E613: 26 07          '&.'
        JSR     uart_get_str             ;E615: BD E6 35       '..5'
        BNE     ZE61C                    ;E618: 26 02          '&.'
        BRA     ZE624                    ;E61A: 20 08          ' .'

ZE61C   LDAA    #$4B                     ;E61C: 86 4B          '.K'
        STAA    M0047                    ;E61E: 97 47          '.G'
        STAA    possible_gpib_status     ;E620: 97 26          '.&'
        BRA     ZE631                    ;E622: 20 0D          ' .'

ZE624   LDAA    uart_rx_buf_0            ;E624: 96 3F          '.?'
        ANDA    #$7F                     ;E626: 84 7F          '..'
        CMPA    uart_tx_buf_0            ;E628: 91 22          '."'
        BEQ     ZE631                    ;E62A: 27 05          ''.'
        DEC     >unkown_uart_reg_0       ;E62C: 7A 00 3E       'z.>'
        BNE     ZE5FF                    ;E62F: 26 CE          '&.'
ZE631   CLR     >unkown_uart_reg_0       ;E631: 7F 00 3E       '..>'
        RTS                              ;E634: 39             '9'

;-------------------------------------------------------------------------------

uart_get_str JSR     uart_get_char            ;E635: BD E6 68       '..h'
        BNE     uart_get_str_timeout     ;E638: 26 14          '&.'
        STAB    uart_rx_buf_0            ;E63A: D7 3F          '.?'
        JSR     uart_get_char            ;E63C: BD E6 68       '..h'
        BNE     uart_get_str_timeout     ;E63F: 26 0D          '&.'
        STAB    uart_rx_buf_1            ;E641: D7 40          '.@'
        JSR     uart_get_char            ;E643: BD E6 68       '..h'
        BNE     uart_get_str_timeout     ;E646: 26 06          '&.'
        STAB    uart_rx_buf_2            ;E648: D7 41          '.A'
        CLRA                             ;E64A: 4F             'O'
        JMP     uart_get_str_end         ;E64B: 7E E6 50       '~.P'

uart_get_str_timeout LDAA    #$FF                     ;E64E: 86 FF          '..'
uart_get_str_end TSTA                             ;E650: 4D             'M'
        RTS                              ;E651: 39             '9'

;-------------------------------------------------------------------------------

; Send char in ACCB to UART via IC11
; Get char from UART and store in ACCA
uart_put_char LDX     #MFFFF                   ;E652: CE FF FF       '...'
; Poll until UART reports no parity error or timeout (0xFFFF loops)
ZE655   LDAA    IC11_CSR                 ;E655: 96 C0          '..'
        ANDA    #$02                     ;E657: 84 02          '..'
        BNE     ZE663                    ;E659: 26 08          '&.'
        DEX                              ;E65B: 09             '.'
        BNE     ZE655                    ;E65C: 26 F7          '&.'
; Timeout occurred
        LDAA    #$FF                     ;E65E: 86 FF          '..'
        JMP     ZE666                    ;E660: 7E E6 66       '~.f'

ZE663   STAB    IC11_RTDR                ;E663: D7 C1          '..'
        CLRA                             ;E665: 4F             'O'
ZE666   TSTA                             ;E666: 4D             'M'
; Return with zero flag set if ACCA=0
        RTS                              ;E667: 39             '9'

;-------------------------------------------------------------------------------

uart_get_char LDX     #MFFFF                   ;E668: CE FF FF       '...'
; Poll until UART reports no parity error or timeout (0xFFFF loops)
ZE66B   LDAA    IC11_CSR                 ;E66B: 96 C0          '..'
        TAB                              ;E66D: 16             '.'
        ANDA    #$01                     ;E66E: 84 01          '..'
        BNE     ZE67A                    ;E670: 26 08          '&.'
        DEX                              ;E672: 09             '.'
        BNE     ZE66B                    ;E673: 26 F6          '&.'
; Timeout occurred
ZE675   LDAA    #$FF                     ;E675: 86 FF          '..'
        JMP     ZE67F                    ;E677: 7E E6 7F       '~..'

ZE67A   ANDB    #$70                     ;E67A: C4 70          '.p'
        BNE     ZE675                    ;E67C: 26 F7          '&.'
        CLRA                             ;E67E: 4F             'O'
ZE67F   LDAB    IC11_RTDR                ;E67F: D6 C1          '..'
        TSTA                             ;E681: 4D             'M'
; Return with zero flag set if ACCA=0
        RTS                              ;E682: 39             '9'

;-------------------------------------------------------------------------------

uart_put_str LDAB    uart_tx_buf_0            ;E683: D6 22          '."'
        JSR     uart_put_char            ;E685: BD E6 52       '..R'
        BNE     uart_send_str_timeout    ;E688: 26 12          '&.'
        LDAB    uart_tx_buf_1            ;E68A: D6 23          '.#'
        JSR     uart_put_char            ;E68C: BD E6 52       '..R'
        BNE     uart_send_str_timeout    ;E68F: 26 0B          '&.'
        LDAB    uart_tx_buf_2            ;E691: D6 24          '.$'
        JSR     uart_put_char            ;E693: BD E6 52       '..R'
        BNE     uart_send_str_timeout    ;E696: 26 04          '&.'
        CLRA                             ;E698: 4F             'O'
; Return with status 0
        JMP     uart_send_str_end        ;E699: 7E E6 9E       '~..'

uart_send_str_timeout LDAA    #$FF                     ;E69C: 86 FF          '..'
uart_send_str_end TSTA                             ;E69E: 4D             'M'
; Return with zero flag set if ACCA=0
        RTS                              ;E69F: 39             '9'

;-------------------------------------------------------------------------------

important_looking_uart_func_0 LDAA    IC11_CSR                 ;E6A0: 96 C0          '..'
        TAP                              ;E6A2: 06             '.'
; Br if Receive Data Register full bit set
; Helps if the Rx clock is connected
        BCS     ZE6AA                    ;E6A3: 25 05          '%.'
; Clear GPIA Aux Cmd Reg if Receive Data register empty
        CLR     IC5_ACR                  ;E6A5: 7F 80 03       '...'
        BRA     return_3                 ;E6A8: 20 3F          ' ?'

ZE6AA   LDAA    IC11_RTDR                ;E6AA: 96 C1          '..'
        TAB                              ;E6AC: 16             '.'
        ANDA    #$30                     ;E6AD: 84 30          '.0'
        BEQ     return_3                 ;E6AF: 27 38          ''8'
        CMPA    #$20                     ;E6B1: 81 20          '. '
        BEQ     ZE6EA                    ;E6B3: 27 35          ''5'
        CMPA    #$30                     ;E6B5: 81 30          '.0'
        BEQ     ZE6F4                    ;E6B7: 27 3B          '';'
        TBA                              ;E6B9: 17             '.'
        ANDA    #$CF                     ;E6BA: 84 CF          '..'
        CMPA    #$80                     ;E6BC: 81 80          '..'
        BNE     ZE6D7                    ;E6BE: 26 17          '&.'
        LDAA    unknown_status_0         ;E6C0: 96 25          '.%'
        CMPA    #$0C                     ;E6C2: 81 0C          '..'
        BEQ     return_3                 ;E6C4: 27 23          ''#'
        LDAA    #$54                     ;E6C6: 86 54          '.T'
        JSR     some_uart_func_2         ;E6C8: BD E7 92       '...'
        LDAA    #$F7                     ;E6CB: 86 F7          '..'
        JSR     anda_unk_status_0        ;E6CD: BD E7 AD       '...'
        LDAA    #$04                     ;E6D0: 86 04          '..'
        STAA    IC5_ACR                  ;E6D2: B7 80 03       '...'
        BRA     return_3                 ;E6D5: 20 12          ' .'

ZE6D7   CMPA    #$49                     ;E6D7: 81 49          '.I'
        BNE     ZE6E1                    ;E6D9: 26 06          '&.'
        STAA    M0047                    ;E6DB: 97 47          '.G'
        STAA    possible_gpib_status     ;E6DD: 97 26          '.&'
        BRA     return_3                 ;E6DF: 20 08          ' .'

ZE6E1   CMPA    #$4A                     ;E6E1: 81 4A          '.J'
        BNE     return_3                 ;E6E3: 26 04          '&.'
        STAA    M0047                    ;E6E5: 97 47          '.G'
        STAA    possible_gpib_status     ;E6E7: 97 26          '.&'
return_3 RTS                              ;E6E9: 39             '9'
ZE6EA   LDAA    M0046                    ;E6EA: 96 46          '.F'
        STAA    M0045                    ;E6EC: 97 45          '.E'
        ANDB    #$CF                     ;E6EE: C4 CF          '..'
        STAB    M0046                    ;E6F0: D7 46          '.F'
        BRA     return_3                 ;E6F2: 20 F5          ' .'

ZE6F4   ANDB    #$CF                     ;E6F4: C4 CF          '..'
        STAB    unknown_status_1         ;E6F6: D7 3C          '.<'
        BRA     return_3                 ;E6F8: 20 EF          ' .'

get_M0x45&0xfth_char_of_STR_ARR_2 LDAA    M0045                    ;E6FA: 96 45          '.E'
        LDAB    M0046                    ;E6FC: D6 46          '.F'
        CBA                              ;E6FE: 11             '.'
; Br if M0x45 != M0x46
        BNE     ZE71E                    ;E6FF: 26 1D          '&.'
        ANDA    #$0F                     ;E701: 84 0F          '..'
; Br if lower nybble of M0x45 is zero 
        BEQ     ZE71E                    ;E703: 27 19          ''.'
        LDX     #STR_ARR_2               ;E705: CE E7 22       '.."'
str_arr_2_loop INX                              ;E708: 08             '.'
        DECA                             ;E709: 4A             'J'
        BNE     str_arr_2_loop           ;E70A: 26 FC          '&.'
        LDAA    ,X                       ;E70C: A6 00          '..'
; Return if *X == 0x00
        BEQ     ZE71E                    ;E70E: 27 0E          ''.'
        STAA    M0047                    ;E710: 97 47          '.G'
        LDAB    unknown_status_2         ;E712: D6 4B          '.K'
; Return if M0x4B == 0x00
        BNE     return_2                 ;E714: 26 0B          '&.'
        STAA    possible_gpib_status     ;E716: 97 26          '.&'
        LDAA    #$55                     ;E718: 86 55          '.U'
        STAA    unknown_status_2         ;E71A: 97 4B          '.K'
        BRA     return_2                 ;E71C: 20 03          ' .'

ZE71E   CLR     >unknown_status_2        ;E71E: 7F 00 4B       '..K'
return_2 RTS                              ;E721: 39             '9'
STR_ARR_2 FCB     $00                      ;E722: 00             '.'
        FCB     $00                      ;E723: 00             '.'
        FCB     $00                      ;E724: 00             '.'
        FCB     $00                      ;E725: 00             '.'
        FCC     "ACACBBDDEGFH"           ;E726: 41 43 41 43 42 42 44 44 45 47 46 48 'ACACBBDDEGFH'
ZE732   LDAA    uart_rx_buf_0            ;E732: 96 3F          '.?'
        BPL     ZE73C                    ;E734: 2A 06          '*.'
        ANDA    #$7F                     ;E736: 84 7F          '..'
        STAA    M0047                    ;E738: 97 47          '.G'
        STAA    possible_gpib_status     ;E73A: 97 26          '.&'
ZE73C   RTS                              ;E73C: 39             '9'

;-------------------------------------------------------------------------------

test_gpib_csr_0 STAA    gpia_csr_copy            ;E73D: 97 42          '.B'
        TAP                              ;E73F: 06             '.'
; Br if GPIB Serial Poll state inactive
        BPL     ZE75D                    ;E740: 2A 1B          '*.'
        ROLA                             ;E742: 49             'I'
        BMI     ZE754                    ;E743: 2B 0F          '+.'
        LDAA    #$F7                     ;E745: 86 F7          '..'
        JSR     anda_unk_status_0        ;E747: BD E7 AD       '...'
        LDAA    #$54                     ;E74A: 86 54          '.T'
ZE74C   JSR     some_uart_func_2         ;E74C: BD E7 92       '...'
        CLR     >unknown_status_2        ;E74F: 7F 00 4B       '..K'
        BRA     ZE75D                    ;E752: 20 09          ' .'

ZE754   LDAA    #$08                     ;E754: 86 08          '..'
        JSR     oraa_unk_status_0        ;E756: BD E7 B1       '...'
        LDAA    #$53                     ;E759: 86 53          '.S'
        BRA     ZE74C                    ;E75B: 20 EF          ' .'

ZE75D   RTS                              ;E75D: 39             '9'

;-------------------------------------------------------------------------------

get_next_str_ptr INX                              ;E75E: 08             '.'
        INX                              ;E75F: 08             '.'
        INX                              ;E760: 08             '.'
        INX                              ;E761: 08             '.'
        INX                              ;E762: 08             '.'
ZE763   CMPA    ,X                       ;E763: A1 00          '..'
        BEQ     ZE76E                    ;E765: 27 07          ''.'
        INX                              ;E767: 08             '.'
        INX                              ;E768: 08             '.'
        INX                              ;E769: 08             '.'
        INX                              ;E76A: 08             '.'
        INX                              ;E76B: 08             '.'
        BRA     ZE763                    ;E76C: 20 F5          ' .'

ZE76E   RTS                              ;E76E: 39             '9'

;-------------------------------------------------------------------------------

test_unk_status_reg_1_0 LDAA    unknown_status_2         ;E76F: 96 4B          '.K'
; Return if M0x4B not 0x00
        BNE     return_4                 ;E771: 26 1E          '&.'
        LDAA    unknown_status_0         ;E773: 96 25          '.%'
        ANDA    #$08                     ;E775: 84 08          '..'
        LDAB    unknown_status_1         ;E777: D6 3C          '.<'
        ANDB    #$01                     ;E779: C4 01          '..'
        ASLB                             ;E77B: 58             'X'
        ASLB                             ;E77C: 58             'X'
        ASLB                             ;E77D: 58             'X'
        CBA                              ;E77E: 11             '.'
        BEQ     return_4                 ;E77F: 27 10          ''.'
        CMPA    #$08                     ;E781: 81 08          '..'
        BNE     some_uart_func_1         ;E783: 26 07          '&.'
        LDAA    #$53                     ;E785: 86 53          '.S'
        JSR     some_uart_func_2         ;E787: BD E7 92       '...'
        BRA     return_4                 ;E78A: 20 05          ' .'

some_uart_func_1 LDAA    #$54                     ;E78C: 86 54          '.T'
        JSR     some_uart_func_2         ;E78E: BD E7 92       '...'
return_4 RTS                              ;E791: 39             '9'
some_uart_func_2 STAA    uart_tx_buf_0            ;E792: 97 22          '."'
        JSR     some_uart_func_0         ;E794: BD E5 FB       '...'
        RTS                              ;E797: 39             '9'

;-------------------------------------------------------------------------------

validate_uart_msg_0 LDAA    uart_rx_buf_0            ;E798: 96 3F          '.?'
        ANDA    #$7F                     ;E79A: 84 7F          '..'
        CMPA    #$5F                     ;E79C: 81 5F          '._'
; Br if char less than '_'
        BLS     return_5                 ;E79E: 23 0C          '#.'
        CMPA    #$70                     ;E7A0: 81 70          '.p'
; Br if char greater than 'p'
        BHI     return_5                 ;E7A2: 22 08          '".'
; Char is between '`' and 'o' inclusive
        LDAA    uart_rx_buf_1            ;E7A4: 96 40          '.@'
        LDAB    uart_rx_buf_2            ;E7A6: D6 41          '.A'
        STAA    uart_msg_1               ;E7A8: 97 43          '.C'
        STAB    uart_msg_2               ;E7AA: D7 44          '.D'
return_5 RTS                              ;E7AC: 39             '9'
anda_unk_status_0 ANDA    unknown_status_0         ;E7AD: 94 25          '.%'
        BRA     ZE7B3                    ;E7AF: 20 02          ' .'

oraa_unk_status_0 ORAA    unknown_status_0         ;E7B1: 9A 25          '.%'
ZE7B3   STAA    unknown_status_0         ;E7B3: 97 25          '.%'
        RTS                              ;E7B5: 39             '9'

;-------------------------------------------------------------------------------

STR_ARR_3 FCB     $00                      ;E7B6: 00             '.'
STR_10  FCC     "A CV"                   ;E7B7: 41 20 43 56    'A CV'
        NOP                              ;E7BB: 01             '.'
STR_11  FCC     "A CC"                   ;E7BC: 41 20 43 43    'A CC'
        FCB     $04                      ;E7C0: 04             '.'
STR_12  FCC     "A IL"                   ;E7C1: 41 20 49 4C    'A IL'
        FCB     $05                      ;E7C5: 05             '.'
STR_14  FCC     "A VL"                   ;E7C6: 41 20 56 4C    'A VL'
        FCB     $00                      ;E7CA: 00             '.'
STR_15  FCC     "B CV"                   ;E7CB: 42 20 43 56    'B CV'
        FCB     $02                      ;E7CF: 02             '.'
STR_16  FCC     "B CC"                   ;E7D0: 42 20 43 43    'B CC'
        INX                              ;E7D4: 08             '.'
STR_17  FCC     "B IL"                   ;E7D5: 42 20 49 4C    'B IL'
        CLV                              ;E7D9: 0A             '.'
STR_18  FCC     "B VL"                   ;E7DA: 42 20 56 4C    'B VL'
hdlr_NMI LDAA    #$4A                     ;E7DE: 86 4A          '.J'
        STAA    IC5_SPR                  ;E7E0: B7 80 05       '...'
        STAA    possible_gpib_status     ;E7E3: 97 26          '.&'
        STAA    M0047                    ;E7E5: 97 47          '.G'
        RTI                              ;E7E7: 3B             ';'

;-------------------------------------------------------------------------------


        ORG     $FFF8 

svec_IRQ FDB     hdlr_IRQ                 ;FFF8: E3 70          '.p'
svec_SWI FDB     hdlr_RST                 ;FFFA: E0 00          '..'
svec_NMI FDB     hdlr_NMI                 ;FFFC: E7 DE          '..'

svec_RST FDB     hdlr_RST                 ;FFFE: E0 00          '..'

        END
