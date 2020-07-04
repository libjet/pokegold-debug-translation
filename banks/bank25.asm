unk_025_4000:
	dr $94000,$965f9

OverworldLoop::
	xor a
	ld [wd14b], a
.asm_65fd
	ld a, [wd14b]
	ld hl, .unkPointers_025_660c
	rst $28
	ld a, [wd14b]
	cp $03
	jr nz, .asm_65fd
	ret

.unkPointers_025_660c:
	dw $666D
	dw $6683
	dw $66B8
	dw $660B

Call_025_6614:
	dr $96614,$96706

Call_025_6706:
	ld a, [wd14c]
	cp $01
	ret z
	call UpdateTime
	call GetJoypad
	farcall UpdateDebugToolgear
	call $0352
	ret

Call_025_671c:
	dr $9671c,$96fb0

unk_025_6fb0:
	call GetScriptByte
	ld e, a
	farcall NPCTrade
	ret

unk_025_6fbb:
	dr $96fbb,$9731f

unk_025_731f:
	ld hl, wd172
	ld d, [hl]
	ld [hl], $00
	ld a, [wBattleResult]
	and $7f
	cp $01
	jr nz, jr_025_7336
	ld b, $04
	ld hl, $6735
	jp Jump_025_7463

jr_025_7336:
	bit 0, d
	jr z, jr_025_7342
	farcall MomTriesToBuySomething
	jr jr_025_7354

jr_025_7342:
	ld a, [wBattleResult]
	bit 7, a
	jr z, jr_025_7354
	ld b, $24
	ld de, $426d
	farcall LoadScriptBDE

jr_025_7354:
	jp Jump_025_7357

Jump_025_7357:
	dr $97357,$97463

Jump_025_7463:
	dr $97463,$97ad4

LoadScriptBDE::
	dr $97ad4,$98000
