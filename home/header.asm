; rst vectors (called through the rst instruction)

SECTION "rst0", ROM0[$0000]
	di
	jp Start

SECTION "rst8", ROM0[$0008]
FarCall::
	jp $2e94

SECTION "rst10", ROM0[$0010]
Bankswitch::
	ldh [hROMBank], a
	ld [$2000], a
	ret

SECTION "rst18", ROM0[$0018]
	rst $38

SECTION "rst20", ROM0[$0020]
	rst $38

SECTION "rst28", ROM0[$0028]
JumpTable::
    push de
    ld e, a
    ld d, $00
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
; SECTION "rst30", ROM0[$0030]
    ld l, a
    pop de
    jp hl

SECTION "rst38", ROM0[$0038]
    rst $38

; Game Boy hardware interrupts

SECTION "vblank", ROM0[$0040]
    jp $0150

SECTION "lcd", ROM0[$0048]
    jp $041b

SECTION "timer", ROM0[$0050]
    reti

SECTION "serial", ROM0[$0058]
    jp $06a9

SECTION "joypad", ROM0[$0060]
    jp $08de

SECTION "Header", ROM0[$0100]

Start::
; Nintendo requires all Game Boy ROMs to begin with a nop ($00) and a jp ($C3)
; to the starting address.
	nop
	jp _Start

; The Game Boy cartridge header data is patched over by rgbfix.
; This makes sure it doesn't get used for anything else.

	ds $0150 - @