DebugFightMenu:
    ld a, 1
    ldh [hInMenu], a

    ld a, 1 << RISINGBADGE ; All pokemon will obey
    ld [wJohtoBadges], a

    ld hl, wNumKeyItems
    xor a
    ld [hli], a
    dec a
    ld [hl], a

    xor a
    ld hl, wNumBalls
    ld [hli], a
    dec a
    ld [hl], a

    ld hl, wNumItems
    xor a
    ld [hli], a
    dec a
    ld [hld], a

    ld de, .fight_items
.load_items
    ld a, [de]
    cp $ff
    jr z, .ChoosePlayerParty
    inc de
    ld [wcffc], a
    ld a, [de]
    inc de
    ld [wd003], a
    push de
    call ReceiveItem
    pop de
    jr .load_items

.ChoosePlayerParty:
	callfar unk_03e_40a6
    call ClearTilemap
    call ClearSprites

    hlcoord 0, 0
    ld b, 1
    ld c, 18
    call Textbox

    hlcoord 6, 1
    ld de, DebugFightMenu_TestFightText
    call PlaceString

    hlcoord 4, 4
    ld de, DebugFightMenu_HeaderText
    call PlaceString

    hlcoord 1, 6
    ld de, DebugFightMenu_DefaultPlayerPartyText
    call PlaceString

    xor a
    ld [wCurPartyMon], a
    ld [wEnemyMon], a
    ld [wEnemyMonLevel], a
    ld [wd10f], a
    ld [wdcb3], a
    ld b, a
    ld c, a
    ld hl, wDebugFightMonLevel
    call .reset_party
    ld hl, wPartyCount
    call .reset_party

    ld de, wPartySpecies
    hlcoord 4, 6
.place_arrow
    push hl
    push bc
    dec hl
    ld a, "▶"
    ld [hl], a
    ld bc, 11
    add hl, bc
    ld a, " "
    ld [hl], a
    push de ; Extra code?
    pop de
    pop bc
    pop hl

.check_joypad_speciescolumn:
    push bc
    push de
    call DelayFrame
    call JoyTextDelay
    pop de
    pop bc

    ldh a, [hJoyLast]
    bit A_BUTTON_F, a
    jp nz, .a_button_species
    bit B_BUTTON_F, a
    jp nz, .b_button_species
    bit START_F, a
    jp nz, .start_button
    bit D_RIGHT_F, a
    jp nz, .d_right_species
    bit D_UP_F, a
    jp nz, .d_up_species
    bit D_DOWN_F, a
    jp nz, .d_down_species
    bit SELECT_F, a
    jr z, .check_joypad_speciescolumn

    ld hl, wDebugFlags
    res 0, [hl]
    ld a, 1
    jp Predef

.reset_party
    xor a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

.fight_items:
	db MASTER_BALL, 99
	db ULTRA_BALL, 99
	db GREAT_BALL, 99
	db POKE_BALL, 99
	db HEAVY_BALL, 99
	db LEVEL_BALL, 99
	db LURE_BALL , 99
	db FAST_BALL, 99
	db FRIEND_BALL, 99
	db MOON_BALL, 99
	db LOVE_BALL, 99

	db FULL_RESTORE, 99
	db REVIVE, 99
	db MAX_REVIVE, 99
	db X_ATTACK, 99
	db X_DEFEND, 99
	db X_SPEED, 99
	db X_SPECIAL, 99
	db ETHER, 99
	db MAX_ETHER, 99
	db ELIXER, 99
	db GUARD_SPEC, 99
	db POKE_DOLL, 99
	db X_ACCURACY, 99

	db FULL_HEAL, 99
	db SUPER_POTION, 99
	db ANTIDOTE, 99
	db BURN_HEAL, 99
	db ICE_HEAL, 99
	db AWAKENING, 99
	db PARLYZ_HEAL, 99
	db -1

.a_button_species:
    inc b
    ld a, b
    cp 254
    jr c, .print_dexnumber
    xor a
    ld b, a

.print_dexnumber:
; Print the ID of the Pokemon to be displayed and clear out the old name

    ld [de], a
    ld [wDeciramBuffer], a
    push bc
    push hl
    push de
    lb bc, PRINTNUM_LEADINGZEROS | 1, 3
    call PrintNum

    inc hl
    push hl
    ld de, DebugFightMenu_EmptyText
    call PlaceString

    ld bc, -20
    add hl, bc
    ld de, DebugFightMenu_EmptyText
    call PlaceString

    pop hl
    ld a, [wDeciramBuffer]
    and a
    jr nz, .print_monstername
    ld de, DebugFightMenu_HyphenText
    jr .dex_zero

.print_monstername
    call GetPokemonName
.dex_zero
    call PlaceString
    pop de
    pop hl
    pop bc
    jp .check_joypad_speciescolumn

.b_button_species:
    dec b
    ld a, b
    cp 254
    jp c, .print_dexnumber
    ld a, 253
    ld b, a
    jp .print_dexnumber

.d_up_species:
    ld a, [wCurPartyMon]
    dec a
    cp $ff
    jp z, .check_joypad_speciescolumn
    ld [wCurPartyMon], a
    dec de
    dec hl
    ld a, " "
    ld [hl], a
    push bc
    ld bc, -40
    add hl, bc
    pop bc
    ld a, "▶"
    ld [hl], a
    inc hl
    push hl
    call .LoadSelectedSpecies
    pop hl
    jp .check_joypad_speciescolumn

.d_down_species:
    ld a, [wCurPartyMon]
    inc a
    cp 6
    jp nc, .check_joypad_speciescolumn
    ld [wCurPartyMon], a
    inc de
    dec hl
    ld a, " "
    ld [hl], a
    ld bc, 40
    add hl, bc
    ld a, "▶"
    ld [hl], a
    inc hl
    push hl
    call .LoadSelectedSpecies
    pop hl
    jp .check_joypad_speciescolumn

.d_right_species:
    push hl
    push bc
    dec hl
    ld a, " "
    ld [hl], a
    ld bc, 11
    add hl, bc
    ld a, "▶"
    ld [hl], a
    pop bc
    pop hl

.check_joypad_levelcolumn:
    push bc
    push de
    call DelayFrame
    call JoyTextDelay
    pop de
    pop bc

    ldh a, [hJoyLast]
    bit A_BUTTON_F, a
    jp nz, .a_button_level
    bit B_BUTTON_F, a
    jp nz, .b_button_level
    bit START_F, a
    jp nz, .start_button
    bit D_LEFT_F, a
    jp nz, .place_arrow
    bit D_UP_F, a
    jp nz, .d_up_level
    bit D_DOWN_F, a
    jp nz, .d_down_level
    jr .check_joypad_levelcolumn

.a_button_level:
    inc c
    ld a, c
    cp MAX_LEVEL + 1
    jr c, .print_level
    ld a, 1
    ld c, a

.print_level:
    ld a, [wCurPartyMon]
    push de
    ld de, wDebugFightMonLevel ; dcc7
    add e
    ld e, a
    jr nc, .asm_50de
    inc d
.asm_50de
    ld a, c
    ld [de], a
    push bc
    push hl
    ld bc, 11
    add hl, bc
    lb bc, PRINTNUM_LEADINGZEROS | 1, 3
    call PrintNum
    pop hl
    pop bc
    pop de
    jp .check_joypad_levelcolumn

.b_button_level:
    dec c
    ld a, c
    cp MAX_LEVEL + 1
    jr nc, .level_100
    and a
    jp nz, .print_level

.level_100
    ld a, 100
    ld c, a
    jp .print_level

.d_up_level:
    ld a, [wCurPartyMon]
    dec a
    cp $ff
    jp z, .check_joypad_levelcolumn

    ld [wCurPartyMon], a
    dec de

    push hl
    ld bc, 10
    add hl, bc
    ld a, " "
    ld [hl], a
    pop hl
    ld bc, hBGMapAddress
    add hl, bc

    push hl
    ld bc, 10
    add hl, bc
    ld a, "▶"
    ld [hl], a
    call .LoadSelectedSpecies
    pop hl
    jp .check_joypad_levelcolumn

.d_down_level:
    ld a, [wCurPartyMon]
    inc a
    cp 6
    jp nc, .check_joypad_levelcolumn

    ld [wCurPartyMon], a
    inc de
    push hl
    ld bc, 10
    add hl, bc
    ld a, " "
    ld [hl], a
    pop hl
    ld bc, 40
    add hl, bc
    push hl
    ld bc, 10
    add hl, bc
    ld a, "▶"
    ld [hl], a
    call .LoadSelectedSpecies
    pop hl
    jp .check_joypad_levelcolumn

.LoadSelectedSpecies:
    ld hl, wPartySpecies
    ld a, [wCurPartyMon]
    add l
    ld l, a
    jr nc, .enemy_species
    inc h
.enemy_species
    ld a, [hl]
    ld b, a
    ld hl, wDebugFightMonLevel
    ld a, [wCurPartyMon]
    add l
    ld l, a
    jr nc, .done
    inc h
.done
    ld a, [hl]
    ld c, a
    ret

.start_button:
    ld hl, wPartyCount
    ld de, wDebugFightMonLevel - 1
    xor a
    ld [hl], a
    inc hl
    ld a, [hli]
    ld b, a
    ld c, 6
    xor a
    ld [wBattleMode], a
.asm_5180:
    ld a, b
    ld [wCurPartySpecies], a
    ld a, [hl]
    ld b, a
    inc de
    ld a, [de]
    and a
    jr z, .asm_51a3
    ld [wd03a], a
    xor a
    ld [wce53], a
    ld a, [wCurPartySpecies]
    and a
    jr z, .asm_51a3
    push hl
    push de
    push bc
    ld a, 6
    call Predef
    pop bc
    pop de
    pop hl
.asm_51a3
    inc hl
    dec c
    jr nz, .asm_5180

    ld b, 7
    ld hl, wPartySpecies
    ld de, wDebugFightMonLevel - 1
.asm_51af:
    inc de
    dec b
    jp z, DebugFightMenu
    ld a, [hli]
    and a
    jr z, .asm_51af
    ld a, [de]
    and a
    jr z, .asm_51af

    ld hl, wTilemap + 60
    ld b, 15
    ld c, 20
    call ClearBox
    ld hl, wTilemap + 60
    ld b, 15
    ld c, 20
    call ClearBox
    ld hl, wTilemap + 60
    ld b, 15
    ld c, 20
    call ClearBox

    ld c, 20
    call DelayFrames

    ld a, 1
    ld [wBattleMode], a
    ld de, unkData_03f_578a
    ld a, [wdcb3]
    cp 101
    jr c, .asm_51f6
    ld a, 2
    ld [wBattleMode], a
    ld de, unkData_03f_5794
.asm_51f6:
    ld hl, wTilemap + 81
    call PlaceString

    ld hl, wTilemap + 121
    ld de, unkData_03f_579e
    call PlaceString

    ld hl, wTilemap + 180
    ld b, 9
    ld c, 20
    call ClearBox

    ld a, [wEnemyMon]
    ld b, a
    ld a, [wBattleMode]
    dec a
    jr z, .asm_524c

    ld a, [wd10f]
    ld [wDeciramBuffer], a
    ld b, a
    ld de, wDeciramBuffer
    ld hl, wTilemap + 161
    push bc
    lb bc, PRINTNUM_LEADINGZEROS | 1, 3
    call PrintNum

    ld hl, wTilemap + 165
    ld de, unkData_03f_57c4
    call PlaceString

    ld a, [wd10f]
    ld c, a
    ld hl, $5534
    ld a, $0e
    rst FarCall

    ld hl, wTilemap + 165
    ld de, wcb2a
    call PlaceString
    pop bc
    jr .asm_5271

.asm_524c:
    ld a, b
    and a
    jr z, .asm_5271

    ld de, wDeciramBuffer
    ld [de], a
    ld hl, wTilemap + 161
    push bc
    lb bc, PRINTNUM_LEADINGZEROS | 1, 3
    call PrintNum

    ld hl, wTilemap + 165
    ld de, unkData_03f_57c4
    call PlaceString
    call GetPokemonName
    ld hl, wTilemap + 165
    call PlaceString
    pop bc

.asm_5271:
    ld a, [wEnemyMonLevel]
    ld c, a
    ld de, wDeciramBuffer
    ld [de], a
    ld hl, wTilemap + 176
    push bc
    lb bc, PRINTNUM_LEADINGZEROS | 1, 3
    call PrintNum
    pop bc

.Jump_03f_5284:
    ld a, " "
    ld [$c440], a
    ld [$c44f], a
    ld a, "▶"
    ld [$c3f0], a

.Jump_03f_5291:
    push bc
    call DelayFrame
    call JoyTextDelay
    pop bc
    ldh a, [hJoyLast]
    bit 0, a
    jp nz, .Jump_03f_52ac
    bit 3, a
    jp nz, .Jump_03f_55df
    bit 7, a
    jp nz, .Jump_03f_5307
    jr .Jump_03f_5291

.Jump_03f_52ac:
    ld hl, $c441
    ld de, $57b1
    call PlaceString
    ld hl, $c431
    ld de, $57c4
    call PlaceString
    xor a
    ld b, a
    ld c, a
    ld a, [wBattleMode]
    dec a
    jr nz, .jr_03f_52e7

    ld a, $02
    ld [wBattleMode], a
    ld a, $7f
    ld [$c3e0], a
    ld hl, $c3f1
    ld de, $5794
    call PlaceString
    ld hl, $c454
    ld b, $09
    ld c, $14
    call ClearBox
    jp .Jump_03f_5291

.jr_03f_52e7:
    ld a, $01
    ld [wBattleMode], a
    ld a, $7f
    ld [$c3dd], a
    ld hl, $c3f1
    ld de, $578a
    call PlaceString
    ld hl, $c454
    ld b, $09
    ld c, $14
    call ClearBox
    jp .Jump_03f_5291

.Jump_03f_5307:
    ld a, $ed
    ld [$c440], a
    ld a, $7f
    ld [$c44f], a
    ld [$c3f0], a

.Jump_03f_5314:
.jr_03f_5314:
    push bc
    call DelayFrame
    call JoyTextDelay
    pop bc
    ldh a, [hJoyLast]
    bit 0, a
    jp nz, .Jump_03f_533e

    bit 1, a
    jp nz, .Jump_03f_53b4

    bit 3, a
    jp nz, .Jump_03f_55df

    bit 4, a
    jp nz, .Jump_03f_53ec

    bit 6, a
    jp nz, .Jump_03f_5284

    bit 7, a
    jp nz, .Jump_03f_54cd

    jr .jr_03f_5314

.Jump_03f_533e:
    push bc
    ld hl, $c431
    ld de, $57c4
    call PlaceString
    ld hl, $c445
    ld de, $57c4
    call PlaceString
    pop bc
    ld a, [wBattleMode]
    dec a
    jr z, .jr_03f_538b

    inc b
    ld a, b
    cp $43
    jr c, .jr_03f_5360

    ld b, $01

.Jump_03f_5360:
.jr_03f_5360:
    ld a, b
    ld [wDeciramBuffer], a
    ld de, wDeciramBuffer
    ld hl, $c441
    push bc
    ld bc, $8103
    call PrintNum
    ld a, [wDeciramBuffer]
    ld [wd10f], a
    ld c, a
    ld hl, $5534
    ld a, $0e
    rst $08
    ld hl, $c445
    ld de, wcb2a
    call PlaceString
    pop bc
    jp .Jump_03f_5314


.jr_03f_538b:
    inc b
    ld a, b
    cp $fe
    jr c, .jr_03f_5393

    ld b, $01

.Jump_03f_5393:
.jr_03f_5393:
    ld a, b
    ld [wDeciramBuffer], a
    ld de, wDeciramBuffer
    ld hl, $c441
    push bc
    ld bc, $8103
    call PrintNum
    call GetPokemonName
    ld hl, $c445
    call PlaceString
    pop bc
    call .Call_03f_544d
    jp .Jump_03f_5314


.Jump_03f_53b4:
    push bc
    ld hl, $c431
    ld de, $57c4
    call PlaceString
    ld hl, $c445
    ld de, $57c4
    call PlaceString
    pop bc
    ld a, [wBattleMode]
    dec a
    jr z, .jr_03f_53dd

    dec b
    ld a, b
    cp $43
    jr nc, .jr_03f_53d8

    and a
    jp nz, .Jump_03f_5360

.jr_03f_53d8:
    ld b, $3d
    jp .Jump_03f_5360


.jr_03f_53dd:
    dec b
    ld a, b
    cp $fe
    jr nc, .jr_03f_53e7

    and a
    jp nz, .Jump_03f_5393

.jr_03f_53e7:
    ld b, $fd
    jp .Jump_03f_5393


.Jump_03f_53ec:
    ld a, $7f
    ld [$c440], a
    ld a, $ed
    ld [$c44f], a

.Jump_03f_53f6:
.jr_03f_53f6:
    push bc
    call DelayFrame
    call JoyTextDelay
    pop bc
    ldh a, [hJoyLast]
    bit 0, a
    jp nz, .Jump_03f_5420

    bit 1, a
    jp nz, .Jump_03f_543e

    bit 3, a
    jp nz, .Jump_03f_55df

    bit 5, a
    jp nz, .Jump_03f_5307

    bit 6, a
    jp nz, .Jump_03f_5284

    bit 7, a
    jp nz, .Jump_03f_54cd

    jr .jr_03f_53f6

.Jump_03f_5420:
    inc c
    ld a, c
    cp $65
    jr c, .jr_03f_5428

    ld c, $01

.Jump_03f_5428:
.jr_03f_5428:
    ld hl, $c450
    ld a, c
    ld de, wd03a
    ld [de], a
    push bc
    ld bc, $8103
    call PrintNum
    pop bc
    call .Call_03f_544d
    jp .Jump_03f_53f6


.Jump_03f_543e:
    dec c
    ld a, c
    cp $65
    jr nc, .jr_03f_5448

    and a

.Jump_03f_5445:
    jp nz, .Jump_03f_5428

.jr_03f_5448:
    ld c, $64
    jp .Jump_03f_5428


.Call_03f_544d:
    ld a, [wBattleMode]
    dec a
    ret nz

    push bc
    ld a, b
    ld [wCurPartySpecies], a
    ld hl, $c454
    ld b, $09
    ld c, $14
    call ClearBox
    xor a
    ld [wd0c5], a
    ld hl, wd13b
    ld bc, $0004
    call ByteFill
    ld de, wd13b
    ld a, $1b
    call Predef
    ld a, $28
    ld [wd0c5], a
    ld hl, $c46d
    ld a, $20
    call Predef
    call .Call_03f_55ce
    ld hl, $c469
    ld de, wd13b
    ld b, $04

.jr_03f_548e:
    ld a, [de]
    and a
    jr z, .jr_03f_54cb

    push bc
    push hl
    push de
    push hl
    ld de, wStringBuffer1
    ld [de], a
    ld bc, $0103
    push af
    call PrintNum
    pop af
    dec a
    ld hl, $5c71
    ld bc, $0007
    call AddNTimes
    ld a, $10
    call GetFarByte
    ld de, wStringBuffer1
    ld [de], a
    pop hl
    ld bc, $000f
    add hl, bc
    ld bc, $0103
    call PrintNum
    pop de
    pop hl
    inc de
    ld bc, $0028
    add hl, bc
    pop bc
    dec b
    jr nz, .jr_03f_548e

.jr_03f_54cb:
    pop bc
    ret


.Jump_03f_54cd:
    ld hl, $c440
    ld [hl], $7f
    ld hl, $c44f
    ld [hl], $7f
    ld a, [wBattleMode]
    dec a
    jp nz, .Jump_03f_5307

    push bc
    ld hl, $c468
    ld [hl], $ed
    ld de, wd13b
    ld b, $01

.Jump_03f_54e9:
.jr_03f_54e9:
    call DelayFrame
    call JoyTextDelay
    ldh a, [hJoyLast]
    bit 0, a
    jp nz, .Jump_03f_550c

    bit 1, a
    jp nz, .Jump_03f_5514

    bit 3, a
    jp nz, .Jump_03f_55ca

    bit 6, a
    jp nz, .Jump_03f_559b

    bit 7, a
    jp nz, .Jump_03f_55ad

    jr .jr_03f_54e9

.Jump_03f_550c:
    ld a, [de]
    inc a
    cp $fc
    jr c, .jr_03f_553d

    jr .jr_03f_551e

.Jump_03f_5514:
    ld a, [de]
    and a
    ld a, $fb
    jr z, .jr_03f_553d

    ld a, [de]
    dec a
    jr nz, .jr_03f_553d

.jr_03f_551e:
    xor a
    ld [de], a
    push de
    push bc
    push hl
    ld bc, hClockResetTrigger
    add hl, bc
    ld bc, $020b
    call ClearBox
    pop hl
    push hl
    ld bc, $0011
    add hl, bc
    ld a, $7f
    ld [hli], a
    ld [hl], a
    pop hl
    pop bc
    pop de
    jp .Jump_03f_54e9


.jr_03f_553d:
    ld [de], a
    ld [wCurSpecies], a
    push hl
    push de
    push bc
    push hl
    push hl
    ld bc, hClockResetTrigger
    add hl, bc
    ld bc, $020b
    call ClearBox
    pop hl
    push hl
    ld bc, $0011
    add hl, bc
    ld a, $7f
    ld [hli], a
    ld [hl], a
    pop hl
    ld de, wCurSpecies
    ld bc, $0103
    inc hl
    call PrintNum
    ld a, $02
    ld [wNamedObjectTypeBuffer], a
    call GetName
    ld de, wStringBuffer1
    inc hl
    call PlaceString
    ld a, [wCurSpecies]
    dec a
    ld hl, $5c71
    ld bc, $0007
    call AddNTimes
    ld a, $10
    call GetFarByte
    ld de, wStringBuffer1
    ld [de], a
    pop hl
    ld bc, $0010
    add hl, bc
    ld bc, $0103
    call PrintNum
    pop bc
    pop de
    pop hl
    jp .Jump_03f_54e9


.Jump_03f_559b:
    ld [hl], $7f
    dec b
    jp z, .Jump_03f_55c6

    dec de
    push bc
    ld bc, hBGMapAddress
    add hl, bc
    pop bc
    ld [hl], $ed
    jp .Jump_03f_54e9


.Jump_03f_55ad:
    inc b
    ld a, b
    cp $05
    jr nc, .jr_03f_55c1

    inc de
    ld [hl], $7f
    push bc
    ld bc, $0028
    add hl, bc
    pop bc
    ld [hl], $ed
    jp .Jump_03f_54e9


.jr_03f_55c1:
    ld b, $04
    jp .Jump_03f_54e9


.Jump_03f_55c6:
    pop bc
    jp .Jump_03f_5307


.Jump_03f_55ca:
    pop bc
    jp .Jump_03f_55df


.Call_03f_55ce:
    ld hl, $c475
    ld de, $0027
    ld b, $04
    ld a, $3e

.jr_03f_55d8:
    ld [hli], a
    ld [hl], a
    add hl, de
    dec b
    jr nz, .jr_03f_55d8
    ret


.Jump_03f_55df:
    ld a, b
    and a
    jp z, .Jump_03f_5284

    ld a, c
    and a
    jp z, .Jump_03f_5284

    ld a, [wBattleMode]
    dec a
    jr z, .jr_03f_55f9

    ld a, b
    ld [wOtherTrainerClass], a
    ld a, c
    ld [wd10d], a
    jr .jr_03f_5601

.jr_03f_55f9:
    ld a, c
    ld [wd03a], a
    ld a, b
    ld [wd109], a

.jr_03f_5601:
    call SetPalettes
    ld a, $80
    ld [wJohtoBadges], a
    ld hl, $57cf
    ld de, wd1b5
    ld bc, $0006
    call CopyBytes
    ld a, $16
    call Predef
    ld a, $01
    ldh [hBGMapMode], a
    ldh [hInMenu], a
    xor a
    ld [wd145], a
    ld hl, wPlayerSubStatus1
    ld bc, $0005
    call ByteFill
    ld hl, wEnemySubStatus1
    ld bc, $0005
    call ByteFill
    call LoadStandardFont
    ld hl, $40a6
    ld a, $3e
    rst $08
    call ClearTilemap
    call ClearSprites
    ld a, $e4
    call DmgToCgbBGPals
    ld de, $e4e4
    call DmgToCgbObjPals
    ld hl, wTilemap
    ld b, $01
    ld c, $12
    call Textbox
    ld hl, $c3ba
    ld de, $56fa
    call PlaceString
    ld hl, $c3f4
    ld de, $5703
    call PlaceString
    ld hl, $c419
    ld de, $5712
    call PlaceString
    ld de, wPartyCount
    xor a
    ld [de], a
    ld [wCurPartyMon], a
    inc de
    ld hl, $c41c
    push de
    push hl

.Jump_03f_5683:
    ld a, [wCurPartyMon]
    ld de, wPartySpecies
    add e
    ld e, a
    jr nc, .jr_03f_568e

    inc d

.jr_03f_568e:
    ld a, [de]
    cp $ff
    jp z, .Jump_03f_56e9

    ld [wDeciramBuffer], a
    push hl
    ld bc, $8103
    call PrintNum
    inc hl
    ld de, $577e
    call PlaceString
    call GetPokemonName
    call PlaceString
    pop hl
    push hl
    ld bc, $000b
    add hl, bc
    push hl
    ld a, [wCurPartyMon]
    ld hl, wPartyMon1Level
    ld bc, $0030
    call AddNTimes
    ld d, h
    ld e, l
    ld a, [de]
    ld [wd03a], a
    pop hl
    ld bc, $8103
    call PrintNum
    ld a, [wCurPartyMon]
    ld de, wDebugFightMonLevel
    add e
    ld e, a
    jr nc, .jr_03f_56d6

    inc d

.jr_03f_56d6:
    ld a, [wd03a]
    ld [de], a
    pop hl
    ld a, [wCurPartyMon]
    inc a
    ld [wCurPartyMon], a
    ld bc, $0028
    add hl, bc
    jp .Jump_03f_5683


.Jump_03f_56e9:
    pop hl
    pop de
    ld a, [wPartyMon1]
    ld b, a
    ld a, [wPartyMon1Level]
    ld c, a
    xor a
    ld [wCurPartyMon], a
    jp DebugFightMenu.place_arrow

DebugFightMenu_TestFightText:
	db "テスト ファイト@" ; Test Fight

DebugFightMenu_HeaderText:
	db "№．  なまえ    レべル@" ; No.  Name    Level

DebugFightMenu_DefaultPlayerPartyText:
	db "1．▶000 -----  000<NEXT>"
	db "2． 000 -----  000<NEXT>"
	db "3． 000 -----  000<NEXT>"
	db "4． 000 -----  000<NEXT>"
	db "5． 000 -----  000<NEXT>"
	db "6． 000 -----  000@"

DebugFightMenu_EmptyText:
	db "     @"

DebugFightMenu_HyphenText:
	db "-----@"

unkData_03f_578a:
	db "ワイルドモンスター@" ; Wild Monster

unkData_03f_5794:
	db "ディーラー    @" ; Dealer (Trainer)

unkData_03f_579e:
	dr $fd79e,$fd7c4

unkData_03f_57c4:
	db "          @"

unkData_03f_57cf:
	db "ゴールド@" ; GOLD