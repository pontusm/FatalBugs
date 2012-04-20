.386p
jumps

code32	segment para public use32
        assume cs:code32, ds:code32

Include Pmode.inc
Include vvs.asm
include blue.asm
include textw.asm
include rotzoom.inc
include intro.asm
include font.inc
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                      Global Definitions for the Player
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;** Procedures **
Global AMS_GetGUSEnv:Near,AMS_Init:Near,AMS_LoadModule:Near,AMS_ErrorHandler:Near,AMS_ShutDown:Near
Global AMS_ReadCommandLine:Near,AMS_StartModule:Near,AMS_StopModule:Near,AMS_MemAlloc:Near

;** Init variables **
Global DMAPlay_Chan:Byte,GF1IRQ:Byte,TimerSelect:Byte,GUS_Baseport:Word

;** Music Sync variables **
Global Sync_Byte:Byte,CallRoutine:Dword

;** Loading variables **
Global ModNamePtr:Dword,LoadOffset:Dword

;** Playing Info **
Global CurrRow:Word,CurrPosition:Word,CurrPatt:Word,Vol:Byte:32

;** Song Info **
Global Composer:Byte:30,SongName:Byte:30

;** Other variables **
Global PositionJump:Word,MasterVolume:Byte

Global Sara4:Near,OwnMemory:Dword

Public _Main
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ModName         db      'fatal.exe',0
MemPtr          dd      0
ModSystem       db      "Och s† gick solen ner ”ver den vackra dalen...",10,13,'$'
ShutSystem      db      "V†r tjocka myrslok Mats vill inte simma idag...",10,13,'$'
NoEnvVariable   db      'ULTRASND Environment not found!',10,13
                db      'Please enter the middle number in your BasePort ("0"=autodetect)',10,13
                db      '>$'
EnterGF1IRQ     db      10,13,'Please Enter your GUS IRQ$'
EnterPlayDMA    db      10,13,'Please Enter DMA Channel used for playing$',10,13
IRQSelect       db      10,13,'1 = IRQ 2',10,13
                db      '2 = IRQ 3',10,13
                db      '3 = IRQ 5',10,13
                db      '4 = IRQ 7',10,13
                db      '5 = IRQ 11',10,13
                db      '6 = IRQ 12',10,13
                db      '7 = IRQ 15',10,13
                db      '>$'
DMASelect       db      10,13,'0 = Disable DMA',10,13
                db      '1 = DMA 1',10,13
                db      '2 = DMA 3',10,13
                db      '>$'

        align   4

; ------------

TimerFlag       dw      0       ; Flag that indicates if timer has changed vals
TimerDelay      dw      0       ; Flag to delay the timer
ExitFlag        dw      0

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                               The Main Routine
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_Main:
        lea     esi,ModSystem
        call    PrintText
        call    AMS_GetGUSEnv           ;To read the Environment instead
        jnc     EnvFound
        call    Setup                   ;Env NOT found, invoke Setup
EnvFound:

        lea     eax,UpdateStuff         ;The routine that you wanna call
        mov     CallRoutine,eax         ;approx. 102.4013045 times per sec.

        mov     OwnMemory,2000000
        call    AMS_Init                ;Init everyting

        mov     bl,1            ;Disable keyboard
        mov     al,1
        call    _setirqmask

        lea     edx,ModName             ;Ptr to Buffer
        mov     LoadOffset,45222
        call    AMS_LoadModule          ;Load the song

        mov     v86r_ax,13h     ; Screen mode 13h
        mov     al,10h          ; Real mode interrupt
        int     33h             ; Call it

        call    AMS_StartModule         ;Start the playing.


        ; Jump to parts

        call    VVS
        call    Rotatepart
        mov     ExitFlag,0
        mov     Cnt1,1234
        call    VVS
        call    WobblePicPart
        call    Flagga
        mov     Cnt4,1234
        mov     ExitFlag,0
        mov     ScreenPic,0
        call    VVS

        mov     MasterVolume,126
FadeVol:
        call    sync
        sub     MasterVolume,2
        jg      FadeVol

        mov     v86r_ax,03h     ; Screen mode 13h
        mov     al,10h          ; Real mode interrupt
        int     33h             ; Call it


        lea     esi,ShutSystem
        call    PrintText
        call    AMS_StopModule          ;Stops the playing.
        call    AMS_ShutDown            ;Shut down the MusicSystem
        mov     bl,1                    ;Enable keyboard
        mov     al,0
        call    _setirqmask
        mov     ax,gs:[41ah]    ;Clear KBD buffer
        mov     gs:[41ch],ax
        jmp     _exit

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                                  ErrorHandler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;When reaching this code, some Problem occured.
;
; * ESI points to a text string that describes the error
; * EBX contains a number describing the error (check the doc)
;
; You may replace the following code with an own errorhandler if you wish,
; This is just an example.
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

AMS_Errorhandler:
;       mov     V86R_AX,3       ;Set Screen Mode
;       mov     al,10h
;       int     33h
        call    PrintText
        jmp     _Exit

UpdateStuff:
        pushad
        inc     Syncspassed

        cmp     RotateFlag,0
        jz      BullKalas
        call    addandrotate            ;add and rotate rotozoom
BullKalas:

        xor     TimerDelay,1
        jz      @@ut

        ; Update stuff for first space vector

        cmp     Cnt4,1234
        jz      @@c3

        cmp     Cnt1,1234
        jz      @@c2

        cmp     Cnt1,0
        jnz     @@c1
        lea     esi,object1
        add     w ObjAngleX[esi],30
        and     w ObjAngleX[esi],16383
        add     w ObjAngleY[esi],97
        and     w ObjAngleY[esi],16383
        add     w ObjAngleZ[esi],20
        and     w ObjAngleZ[esi],16383
        mov     eax,Speed1
        sub     ObjPosX[esi],eax
        cmp     d ObjPosX[esi],1
        jnz     @@ut
        mov     Cnt1,1
        jmp     @@ut
@@c1:
        inc     Cnt1
        cmp     Cnt1,5
        jnz     @@c1b
        dec     Speed1
@@c1b:
        cmp     Cnt1,10
        jnz     @@c1c
        mov     Speed1,0
@@c1c:
        cmp     Cnt1,100
        jnz     @@c1d
        mov     Speed2,1
@@c1d:
        cmp     Cnt1,380
        jnz     @@c1e
        mov     ExitFlag,1

@@c1e:
        lea     esi,object1
        add     w ObjAngleX[esi],30
        and     w ObjAngleX[esi],16383
        add     w ObjAngleY[esi],97
        and     w ObjAngleY[esi],16383
        add     w ObjAngleZ[esi],20
        and     w ObjAngleZ[esi],16383
        mov     eax,Speed1
        sub     ObjPosX[esi],eax
        mov     eax,Speed2
        add     d ObjPosZ[esi],eax
        jmp     @@ut

@@c2:
        lea     esi,object1
        add     w ObjAngleX[esi],55
        and     w ObjAngleX[esi],16383
        add     w ObjAngleY[esi],17
        and     w ObjAngleY[esi],16383
        add     w ObjAngleZ[esi],36
        and     w ObjAngleZ[esi],16383


        mov     esi,object2ptr
        add     w ObjAngleX[esi],-70
        and     w ObjAngleX[esi],16383
        add     w ObjAngleY[esi],35
        and     w ObjAngleY[esi],16383
        add     w ObjAngleZ[esi],-40
        and     w ObjAngleZ[esi],16383


        lea     esi,object1
        cmp     d ObjPosZ[esi],200
        jz      @@c2b
        sub     d ObjPosZ[esi],2
@@c2b:
        inc     Cnt2
        cmp     Cnt2,200
        jl      @@c2c
        mov     esi,object2ptr
        add     d ObjPosY[esi],3
        cmp     d ObjPosZ[esi],250
        jz      @@c2c
        sub     d ObjPosZ[esi],2
@@c2c:
        cmp     Cnt2,550
        jl      @@c2d
        lea     esi,object1
        sub     d ObjPosY[esi],3

@@c2d:  cmp     Cnt2,800
        jnz     @@c2e
        mov     ExitFlag,1
@@c2e:  jmp     @@ut

@@c3:
        lea     esi,object1
        add     w ObjAngleX[esi],35
        and     w ObjAngleX[esi],16383
        add     w ObjAngleY[esi],9
        and     w ObjAngleY[esi],16383
        add     w ObjAngleZ[esi],26
        and     w ObjAngleZ[esi],16383

        inc     Cnt3

        lea     esi,object1
        mov     eax,Speed3
        sub     d ObjPosY[esi],eax
        mov     eax,Speed4
        sub     ObjPosZ[esi],eax
        lea     esi,lght
        mov     eax,speed5
        add     LightPosX[esi],eax
        mov     eax,speed6
        add     LightPosY[esi],eax

        cmp     Cnt3,200
        jnz     @@c3a
        dec     speed3
@@c3a:
        cmp     Cnt3,210
        jnz     @@c3b
        dec     speed3
@@c3b:
        cmp     Cnt3,220
        jnz     @@c3c
        dec     speed3
@@c3c:
        cmp     Cnt3,230
        jnz     @@c3d
        dec     speed3
@@c3d:
        cmp     Cnt3,240
        jnz     @@c3e
        dec     speed3
@@c3e:
        cmp     Cnt3,250
        jnz     @@c3f
        dec     speed3
        dec     speed4
@@c3f:

        cmp     Cnt3,300
        jnz     @@c3g
        dec     speed4
@@c3g:
        cmp     Cnt3,360
        jnz     @@c3h
        dec     speed4
@@c3h:
        cmp     Cnt3,380
        jnz     @@c3i
        dec     speed4
@@c3i:
        cmp     Cnt3,390
        jnz     @@c3j
        dec     speed4
@@c3j:
        cmp     Cnt3,450
        jnz     @@c3k
        dec     speed4
        inc     speed3
@@c3k:
        cmp     Cnt3,500
        jnz     @@c3l
        inc     speed3
        inc     speed4
@@c3l:
        cmp     Cnt3,550
        jnz     @@c3m
        dec     speed3
        mov     speed5,3
        inc     speed4
@@c3m:
        cmp     Cnt3,650
        jnz     @@c3n
        dec     speed3
        mov     speed5,-2
        mov     speed6,-2
        inc     speed4
@@c3n:
        cmp     Cnt3,1000
        jnz     @@c3o
        mov     ExitFlag,1
@@c3o:

@@ut:   mov     TimerFlag,1

        popad
        ret

Cnt1    dd      0
Cnt2    dd      0
Cnt3    dd      0
Cnt4    dd      0
Speed1  dd      3
Speed2  dd      0
Speed3  dd      5
Speed4  dd      4
Speed5  dd      0
speed6  dd      0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Prints a text in textmode
;Calls: ESI = Offset to  text
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintText       Proc    Near
        Pushad
        mov     edx,esi
        add     edx,_code32a
	ror	edx,4
	mov	V86R_DS,dx
	shr	edx,28
        mov     V86R_DX,dx
        mov     V86R_AH,9
        mov     al,21h
        int     33h
        Popad
        Ret
PrintText       EndP

HexTable        db        '0123456789ABCDEF'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Hex Value
;Calls:  DX = Scr Pos
;       EBX = Value to print
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PutHex  Proc    Near
        Pushad
        mov     cl,8
;       pushad
;       push    V86R_BX
;       mov     V86R_DX,dx
;       mov     V86R_BX,0
;       mov     V86R_AH,2
;       mov     al,10h
;       int     33h
;       pop     V86R_BX
;       popad
        movzx   ecx,cl
        shl     ecx,2
        ror     ebx,cl
        shr     ecx,2
PutLoopen:
        xor     eax,eax
        shld    eax,ebx,4
        shl     ebx,4
        mov     al,[HexTable+eax]
        mov     V86R_DL,al
        mov     V86R_AH,2
        mov     al,21h
        int     33h
        inc     edi
        loop    PutLoopen

        mov     V86R_DL,'<'
        mov     V86R_AH,2
        mov     al,21h
        int     33h

        mov     V86R_DL,'>'
        mov     V86R_AH,2
        mov     al,21h
        int     33h
        Popad
        Ret
PutHex  EndP

;Just a small, boring setup. But who cares?

IRQConvert      db      2,3,5,7,11,12,15
DMAConvert      db      0,1,3
Setup   Proc    Near
        pushad
        lea     esi,NoEnvVariable       ;Read BasePort
        call    PrintText
        mov     bx,0600h
        call    ReadDigit
        mov     ax,0
        cmp     bx,0
        jz      AutoDetection
        mov     ax,200h
        shl     bx,4
        or      ax,bx
AutoDetection:
        mov     GUS_BasePort,ax

        lea     esi,EnterGF1IRQ         ;Read GF1 IRQ
        call    PrintText
        lea     esi,IRQSelect
        call    PrintText
        mov     bx,0701h
        call    ReadDigit
        mov     al,[IRQConvert+ebx-1]
        mov     GF1IRQ,al

        lea     esi,EnterPlayDMA        ;Read Play DMA
        call    PrintText
        lea     esi,DMASelect
        call    PrintText
        mov     bx,0200h
        call    ReadDigit
        mov     al,[DMAConvert+ebx]
        mov     DMAPlay_Chan,al

        popad
        ret
Setup   EndP

;IN: bl=min,bh=max
;out ebx=digit
ReadDigit       Proc    Near
        cli
        push    ax
ReadAgain:
        in      al,60h
        cmp     al,2
        jb      ReadAgain
        cmp     al,11
        ja      ReadAgain
        dec     al
        cmp     al,10
        jnz     NotDigitZero
        mov     al,0
NotDigitZero:
        cmp     al,bl
        jb      ReadAgain
        cmp     al,bh
        ja      ReadAgain
        movzx   ebx,al
WaitDigitRelease:
        in      al,60h
        test    al,80h
        jz      WaitDigitRelease
        sti
        pop     ax
        ret
ReadDigit       EndP

sintab2 dd      0

;-------------------------------------------------------------------------------
;                      -+*+- Own allocation routine -+*+-
;-------------------------------------------------------------------------------
; Size of mem in EAX, pointer to mem will be returned in EAX too
Getmem  proc    near
        push    ebx
        mov     ecx,eax
        mov     ebx,AllocSize
        sub     ebx,eax
        jl      @@outofmem          ; Out of memory
        mov     AllocSize,ebx
        mov     ebx,eax
        mov     eax,OwnMemory
        add     OwnMemory,ebx

        pushad
        mov     edi,eax
        xor     ax,ax
        shr     ecx,1
        rep     stosw
        adc     ecx,0
        rep     stosb
        popad

        clc
        jmp     @@ut
@@outofmem:
        stc                     ; Indicate out of memory
@@ut:
        pop     ebx
        ret
        endp

AllocSize       dd      2000000

code32  ends
        end

