Serial::
; The serial interrupt.

	push af
	push bc
	push de
	push hl

    ld a, [wPrinterConnectionOpen]
	bit 0, a
	jr nz, .printer

	ldh a, [hLinkPlayerNumber]
	inc a ; is it equal to CONNECTION_NOT_ESTABLISHED?
	jr z, .establish_connection

	ldh a, [rSB]
	ldh [hSerialReceive], a

	ldh a, [hSerialSend]
	ldh [rSB], a

	ldh a, [hLinkPlayerNumber]
	cp USING_INTERNAL_CLOCK
	jr z, .player2

	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	jr .player2

.printer
    call $1ed4
    jr .end

.establish_connection
	ldh a, [rSB]
	cp USING_EXTERNAL_CLOCK
	jr z, .player1
	cp USING_INTERNAL_CLOCK
	jr nz, .player2

.player1
	ldh [hSerialReceive], a
	ldh [hLinkPlayerNumber], a
	cp USING_INTERNAL_CLOCK
	jr z, ._player2

	xor a
	ldh [rSB], a
	ld a, 3
	ldh [rDIV], a

.wait_bit_7
	ldh a, [rDIV]
	bit 7, a
	jr nz, .wait_bit_7

	; Cycle the serial controller
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	jr .player2

._player2
	xor a
	ldh [rSB], a

.player2
	ld a, TRUE
	ldh [hFFCC], a
	ld a, SERIAL_NO_DATA_BYTE
	ldh [hSerialSend], a

.end
	pop hl
	pop de
	pop bc
	pop af
	reti

Serial_ExchangeBytes::
	ld a, 1
	ldh [hFFCE], a
.loop
	ld a, [hl]
	ldh [hSerialSend], a
    call Serial_ExchangeByte
	push bc
	ld b, a
	inc hl
	ld a, $30
.wait
	dec a
	jr nz, .wait
	ldh a, [hFFCE]
	and a
	ld a, b
	pop bc
	jr z, .load
	dec hl
	cp SERIAL_PREAMBLE_BYTE
	jr nz, .loop
	xor a
	ldh [hFFCE], a
	jr .loop

.load
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

Serial_ExchangeByte::
.loop
	xor a
	ldh [hFFCC], a
	ldh a, [hLinkPlayerNumber]
	cp 2
	jr nz, .not_player_2
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

.not_player_2
.loop2
	ldh a, [hFFCC]
	and a
	jr nz, .reset_ffcc
	ldh a, [hLinkPlayerNumber]
	cp 1
	jr nz, .not_player_1_or_wLinkTimeoutFrames_zero
	call CheckwLinkTimeoutFramesNonzero
	jr z, .not_player_1_or_wLinkTimeoutFrames_zero
	call .delay_15_cycles
	push hl
    ld hl, wce50
    inc [hl]
	jr nz, .no_rollover_up
	dec hl
	inc [hl]

.no_rollover_up
	pop hl
    call CheckwLinkTimeoutFramesNonzero
    jr nz, .loop2
    jp SerialDisconnected

.not_player_1_or_wLinkTimeoutFrames_zero
	ldh a, [rIE]
	and (1 << SERIAL) | (1 << TIMER) | (1 << LCD_STAT) | (1 << VBLANK)
	cp 1 << SERIAL
	jr nz, .loop2
    ld a, [wce51]
    dec a
    ld [wce51], a
    jr nz, .loop2
    ld a, [wce51 + 1]
    dec a
    ld [wce51 + 1], a
    jr nz, .loop2
    ldh a, [hLinkPlayerNumber]
    cp 1
    jr z, .reset_ffcc

	ld a, 255
.delay_255_cycles
	dec a
	jr nz, .delay_255_cycles

.reset_ffcc
	xor a
	ldh [hFFCC], a
	ldh a, [rIE]
	and (1 << SERIAL) | (1 << TIMER) | (1 << LCD_STAT) | (1 << VBLANK)
	sub 1 << SERIAL
	jr nz, .rIE_not_equal_8

	; LOW($5000)
    ld [wce51], a
	ld a, HIGH($5000)
    ld [wce51 + 1], a

.rIE_not_equal_8
	ldh a, [hSerialReceive]
	cp SERIAL_NO_DATA_BYTE
	ret nz
	call CheckwLinkTimeoutFramesNonzero
	jr z, .linkTimeoutFrames_zero
	push hl
    ld hl, wce50
	ld a, [hl]
	dec a
	ld [hld], a
	inc a
	jr nz, .no_rollover
	dec [hl]

.no_rollover
	pop hl
    call CheckwLinkTimeoutFramesNonzero
    jr z, SerialDisconnected

.linkTimeoutFrames_zero
	ldh a, [rIE]
	and (1 << SERIAL) | (1 << TIMER) | (1 << LCD_STAT) | (1 << VBLANK)
	cp 1 << SERIAL
	ld a, SERIAL_NO_DATA_BYTE
	ret z
	ld a, [hl]
	ldh [hSerialSend], a
	call DelayFrame
	jp .loop

.delay_15_cycles
	ld a, 15
.delay_cycles
	dec a
	jr nz, .delay_cycles
	ret

CheckwLinkTimeoutFramesNonzero::
    push hl
    ld hl, wce4f
	ld a, [hli]
	or [hl]
	pop hl
	ret

SerialDisconnected::
	dec a ; a is always 0 when called
    ld [wce4f], a
    ld [wce50], a
    ret

; This is used to exchange the button press and selected menu item on the link menu.
; The data is sent thrice and read twice to increase reliability.
Serial_ExchangeLinkMenuSelection::
    ld hl, wce4a
    ld de, wce45
	ld c, 2
	ld a, TRUE
	ldh [hFFCE], a
.asm_7f7
	call DelayFrame
	ld a, [hl]
	ldh [hSerialSend], a
	call Serial_ExchangeByte
	ld b, a
	inc hl
	ldh a, [hFFCE]
	and a
	ld a, 0
	ldh [hFFCE], a
	jr nz, .asm_7f7
	ld a, b
	ld [de], a
	inc de
	dec c
	jr nz, .asm_7f7
	ret

Serial_PrintWaitingTextAndSyncAndExchangeNybble::
    call $31c5
    ld hl, $4000
    ld a, $01
    rst $08
    call WaitLinkTransfer
    jp $31d1

Serial_SyncAndExchangeNybble::
    call $31c5
    ld hl, $4000
    ld a, $01
    rst $08
    jp WaitLinkTransfer

WaitLinkTransfer::
    ld a, $ff
    ld [wce46], a
.loop
	call LinkTransfer
	call DelayFrame
	call CheckwLinkTimeoutFramesNonzero
	jr z, .check
	push hl
    ld hl, wce50
	dec [hl]
	jr nz, .skip
	dec hl
	dec [hl]
	jr nz, .skip
	; We might be disconnected
	pop hl
	xor a
	jp SerialDisconnected

.skip
	pop hl

.check
    ld a, [wce46]
    inc a
    jr z, .loop

	ld b, 10
.receive
    call DelayFrame
    call LinkTransfer
    dec b
    jr nz, .receive

	ld b, 10
.acknowledge
    call DelayFrame
    call LinkDataReceived
    dec b
    jr nz, .acknowledge

    ld a, [wce46]
    ld [wce45], a
	ret

LinkTransfer::
	push bc
	ld b, SERIAL_TIMECAPSULE
    ld a, [wd03c]
	cp LINK_TIMECAPSULE
	jr z, .got_high_nybble
	ld b, SERIAL_TIMECAPSULE
	jr c, .got_high_nybble
	cp LINK_TRADECENTER
	ld b, SERIAL_TRADECENTER
	jr z, .got_high_nybble
	ld b, SERIAL_BATTLE

.got_high_nybble
    call .Receive
    ld a, [wce4a]
	add b
	ldh [hSerialSend], a
	ldh a, [hLinkPlayerNumber]
	cp USING_INTERNAL_CLOCK
	jr nz, .player_1
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a

.player_1
    call .Receive
    pop bc
    ret

.Receive:
    ldh a, [hSerialReceive]
    ld [wce45], a
	and $f0
	cp b
	ret nz
	xor a
	ldh [hSerialReceive], a
    ld a, [wce45]
    and $f
    ld [wce46], a
    ret

LinkDataReceived::
; Let the other system know that the data has been received.
	xor a
	ldh [hSerialSend], a
	ldh a, [hLinkPlayerNumber]
	cp USING_INTERNAL_CLOCK
	ret nz
	ld a, (0 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (1 << rSC_CLOCK)
	ldh [rSC], a
	ret

Unreferenced_Function8c9::
    ld a, [wd03c]
	and a
	ret nz
	ld a, USING_INTERNAL_CLOCK
	ldh [rSB], a
	xor a
	ldh [hSerialReceive], a
	ld a, (0 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ld a, (1 << rSC_ON) | (0 << rSC_CLOCK)
	ldh [rSC], a
	ret
