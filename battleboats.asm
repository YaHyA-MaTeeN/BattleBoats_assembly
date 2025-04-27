; BattleBoats.asm
.386
.model flat, stdcall
.stack 4096

include C:\Irvine\Irvine32.inc
includelib C:\Irvine\Irvine32.lib


; Constants

OCEAN_SIZE      EQU 20
INITIAL_HEALTH  EQU 3

; Data
.data

; Each ocean is 20 cells, each initially '.'
ocean1      BYTE OCEAN_SIZE DUP('.')
ocean2      BYTE OCEAN_SIZE DUP('.')

; Boat positions (0-based index; players will choose)
player1BoatPos  DWORD 0
player2BoatPos  DWORD 0

; Health for each boat
player1Health   DWORD INITIAL_HEALTH
player2Health   DWORD INITIAL_HEALTH

; Temporary storage for user input
userInput       DWORD ?

; Message strings
msgPlayer1      BYTE "Player 1's Turn",0dh,0ah,0
msgPlayer2      BYTE "Player 2's Turn",0dh,0ah,0
msgOcean        BYTE "Your Ocean: ",0
msgHealth       BYTE "Your Health: ",0
msgAction       BYTE 0dh,0ah,"Enter M for Move, A for Attack: ",0
msgMovePrompt   BYTE 0dh,0ah,"Enter new location (1-20): ",0
msgAttackPrompt BYTE 0dh,0ah,"Enter enemy location to attack (1-20): ",0
msgInvalid      BYTE 0dh,0ah,"Invalid entry. Try again.",0
msgUnavailable  BYTE 0dh,0ah,"Place unavailable.",0
msgAttackFail   BYTE 0dh,0ah,"Attack failed (location already marked X).",0
msgMiss         BYTE 0dh,0ah,"Miss! Location marked with X.",0
msgHit          BYTE 0dh,0ah,"Hit! Enemy boat damaged.",0
msgP1Wins       BYTE 0dh,0ah,"Player 1 wins!",0
msgP2Wins       BYTE 0dh,0ah,"Player 2 wins!",0
msgPressKey     BYTE 0dh,0ah,"Press any key to continue...",0

msgBoatPlacement1 BYTE 0dh,0ah,"Player 1, choose your boat position (1-20): ",0
msgBoatPlacement2 BYTE 0dh,0ah,"Player 2, choose your boat position (1-20): ",0

newline         BYTE 0dh,0ah,0


.code
main PROC

    ; Clear screen before starting boat placement for Player 1
    call ClrScr

    ; Step 1: Prompt Player 1 for initial boat position
    ; =================================================
    mov edx, OFFSET msgBoatPlacement1
    call WriteString
TryPos1:
    call ReadInt
    mov userInput, eax
    dec DWORD PTR userInput         ; convert 1-based to 0-based
    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae InvalidPos1
    cmp eax, 0
    jl InvalidPos1
    ; If valid, place boat
    mov player1BoatPos, eax
    mov ebx, OFFSET ocean1
    add ebx, eax
    mov BYTE PTR [ebx], 'B'
    jmp DonePos1

InvalidPos1:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp TryPos1

DonePos1:

    ; Step 2: Prompt Player 2 for initial boat position
    ; =================================================
    call ClrScr
    mov edx, OFFSET msgBoatPlacement2
    call WriteString
TryPos2:
    call ReadInt
    mov userInput, eax
    dec DWORD PTR userInput         ; convert 1-based to 0-based
    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae InvalidPos2
    cmp eax, 0
    jl InvalidPos2
    ; If valid, place boat
    mov player2BoatPos, eax
    mov ebx, OFFSET ocean2
    add ebx, eax
    mov BYTE PTR [ebx], 'B'
    jmp DonePos2

InvalidPos2:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp TryPos2

DonePos2:

    ; Wait for key before game starts.
    mov edx, OFFSET msgPressKey
    call WriteString
    call ReadChar

; MAIN GAME LOOP
; ==================================
game_loop:

    ; Check if either player is at 0 health
    mov eax, player1Health
    cmp eax, 0
    je end_game

    mov eax, player2Health
    cmp eax, 0
    je end_game

    ; ------------- Player 1 Turn -------------
    call ClrScr
    mov edx, OFFSET msgPlayer1
    call WriteString

    call DisplayOcean1
    call DisplayHealth1

getAction1:
    mov edx, OFFSET msgAction
    call WriteString
    call ReadChar
    cmp al, 'M'
    je player1_move
    cmp al, 'm'
    je player1_move
    cmp al, 'A'
    je player1_attack
    cmp al, 'a'
    je player1_attack

    mov edx, OFFSET msgInvalid
    call WriteString
    jmp getAction1

; ========== PLAYER 1 MOVE ==========
player1_move:
    mov edx, OFFSET msgMovePrompt
    call WriteString
    call ReadInt              ; result in EAX
    mov userInput, eax        ; store in userInput

    ; Convert 1-based input to 0-based index
    dec DWORD PTR userInput

    ; Check valid range: 0 <= userInput < OCEAN_SIZE
    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae invalid_move1   ; if >= OCEAN_SIZE, invalid
    cmp eax, 0
    jl invalid_move1    ; if < 0, invalid

    ; Check if destination is marked 'X'
    mov ebx, OFFSET ocean1
    add ebx, eax
    cmp BYTE PTR [ebx], 'X'
    je place_unavail1

    ; Clear old position
    mov eax, player1BoatPos
    mov ebx, OFFSET ocean1
    add ebx, eax
    mov BYTE PTR [ebx], '.'

    ; Place boat at new position
    mov eax, userInput
    mov player1BoatPos, eax
    mov ebx, OFFSET ocean1
    add ebx, eax
    mov BYTE PTR [ebx], 'B'

    jmp endTurn1

invalid_move1:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp player1_move

place_unavail1:
    mov edx, OFFSET msgUnavailable
    call WriteString
    jmp endTurn1

; ========== PLAYER 1 ATTACK ==========
player1_attack:
    mov edx, OFFSET msgAttackPrompt
    call WriteString
    call ReadInt
    mov userInput, eax
    dec DWORD PTR userInput

    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae invalid_attack1
    cmp eax, 0
    jl invalid_attack1

    ; Attack ocean2
    mov ebx, OFFSET ocean2
    add ebx, eax
    cmp BYTE PTR [ebx], 'X'
    je attack_retry1      ; if attacked location is marked 'X', let player attack again
    cmp BYTE PTR [ebx], 'B'
    je attack_hit1
    cmp BYTE PTR [ebx], '.'
    je attack_miss1

invalid_attack1:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp player1_attack

attack_retry1:
    mov edx, OFFSET msgAttackFail
    call WriteString
    jmp player1_attack

attack_hit1:
    mov edx, OFFSET msgHit
    call WriteString
    ; Decrement player2Health
    mov eax, player2Health
    dec eax
    mov player2Health, eax
    jmp endTurn1

attack_miss1:
    mov BYTE PTR [ebx], 'X'
    mov edx, OFFSET msgMiss
    call WriteString
    jmp endTurn1

endTurn1:
    mov edx, OFFSET msgPressKey
    call WriteString
    call ReadChar

    ; ------------- Player 2 Turn -------------
    call ClrScr
    mov edx, OFFSET msgPlayer2
    call WriteString

    call DisplayOcean2
    call DisplayHealth2

getAction2:
    mov edx, OFFSET msgAction
    call WriteString
    call ReadChar
    cmp al, 'M'
    je player2_move
    cmp al, 'm'
    je player2_move
    cmp al, 'A'
    je player2_attack
    cmp al, 'a'
    je player2_attack

    mov edx, OFFSET msgInvalid
    call WriteString
    jmp getAction2

; ========== PLAYER 2 MOVE ==========
player2_move:
    mov edx, OFFSET msgMovePrompt
    call WriteString
    call ReadInt
    mov userInput, eax
    dec DWORD PTR userInput

    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae invalid_move2
    cmp eax, 0
    jl invalid_move2

    ; Check if destination is 'X'
    mov ebx, OFFSET ocean2
    add ebx, eax
    cmp BYTE PTR [ebx], 'X'
    je place_unavail2

    ; Clear old position
    mov eax, player2BoatPos
    mov ebx, OFFSET ocean2
    add ebx, eax
    mov BYTE PTR [ebx], '.'

    ; Place boat at new location
    mov eax, userInput
    mov player2BoatPos, eax
    mov ebx, OFFSET ocean2
    add ebx, eax
    mov BYTE PTR [ebx], 'B'

    jmp endTurn2

invalid_move2:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp player2_move

place_unavail2:
    mov edx, OFFSET msgUnavailable
    call WriteString
    jmp endTurn2

; ========== PLAYER 2 ATTACK ==========
player2_attack:
    mov edx, OFFSET msgAttackPrompt
    call WriteString
    call ReadInt
    mov userInput, eax
    dec DWORD PTR userInput

    mov eax, userInput
    cmp eax, OCEAN_SIZE
    jae invalid_attack2
    cmp eax, 0
    jl invalid_attack2

    mov ebx, OFFSET ocean1
    add ebx, eax
    cmp BYTE PTR [ebx], 'X'
    je attack_retry2      ; if attacked location is 'X', let player attack again
    cmp BYTE PTR [ebx], 'B'
    je attack_hit2
    cmp BYTE PTR [ebx], '.'
    je attack_miss2

invalid_attack2:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp player2_attack

attack_retry2:
    mov edx, OFFSET msgAttackFail
    call WriteString
    jmp player2_attack

attack_hit2:
    mov edx, OFFSET msgHit
    call WriteString
    mov eax, player1Health
    dec eax
    mov player1Health, eax
    jmp endTurn2

attack_miss2:
    mov BYTE PTR [ebx], 'X'
    mov edx, OFFSET msgMiss
    call WriteString
    jmp endTurn2

endTurn2:
    mov edx, OFFSET msgPressKey
    call WriteString
    call ReadChar

    jmp game_loop

; ========== END GAME ==========
end_game:
    call ClrScr

    ; Check who is at 0
    mov eax, player1Health
    cmp eax, 0
    je announceP2

    mov eax, player2Health
    cmp eax, 0
    je announceP1

announceP1:
    mov edx, OFFSET msgP1Wins
    call WriteString
    jmp finish

announceP2:
    mov edx, OFFSET msgP2Wins
    call WriteString

finish:
    call ReadChar
    exit

; ==================================
; Display Procedures
; ==================================
DisplayOcean1 PROC
    mov edx, OFFSET msgOcean
    call WriteString

    mov ecx, OCEAN_SIZE
    mov esi, OFFSET ocean1
displayLoop1:
    mov al, [esi]
    call WriteChar
    mov al, ' '
    call WriteChar
    inc esi
    loop displayLoop1

    call Crlf
    ret
DisplayOcean1 ENDP

DisplayHealth1 PROC
    mov edx, OFFSET msgHealth
    call WriteString
    mov eax, player1Health
    call WriteDec
    call Crlf
    ret
DisplayHealth1 ENDP

DisplayOcean2 PROC
    mov edx, OFFSET msgOcean
    call WriteString

    mov ecx, OCEAN_SIZE
    mov esi, OFFSET ocean2
displayLoop2:
    mov al, [esi]
    call WriteChar
    mov al, ' '
    call WriteChar
    inc esi
    loop displayLoop2

    call Crlf
    ret
DisplayOcean2 ENDP

DisplayHealth2 PROC
    mov edx, OFFSET msgHealth
    call WriteString
    mov eax, player2Health
    call WriteDec
    call Crlf
    ret
DisplayHealth2 ENDP

main ENDP
END main
