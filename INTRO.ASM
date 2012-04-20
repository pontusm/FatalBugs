
;-------------------------------------------------------------------------------
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.
;                            -+*+- Flag Part -+*+-
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.
;-------------------------------------------------------------------------------
FlagPart proc near
        pushad
        move    edi,0a0000h+100*320
        mov     DumpBuffer,edi

        call    ConvertFont

        ; Make the flag...
@@flag:
        mov     ecx,Syncspassed
        sub     ecx,1
        jle     @@noupdate

        ; Update variables
@@update:
        mov     ebx,RealFlagXspeed1
        add     RealFlagXptr,ebx
        and     RealFlagXptr,16383

        mov     ebx,RealFlagYspeed1
        add     RealFlagYptr,ebx
        and     RealFlagYptr,16383
        loop    @@update

        mov     Syncspassed,0

        cmp     NoClear,0
        jnz     @@skipclr
        call    ClrFlag
@@skipclr:
        call    MoveFlag
        call    Writer
        call    DumpScr
        inc     FlagCounter

        ; Do some different stuff, depending on the counter
        cmp     FlagCounter,500
        jnz     @@not100
        mov     NoClear,1
@@not100:
        cmp     FlagCounter,1200
        jb      @@not101
        inc     ClipCheck
        add     AddValue,320
@@not101:


@@noupdate:
        cmp     ClipCheck2,200
        jae     @@ut
;       in      al,60h
;       cmp     al,1
;       jnz     @@flag
        jmp     @@Flag

@@ut:
        popad
        ret
        endp

FlagCounter     dd      0

;-------------------------------------------------------------------------------
;                            -+*+- Clear Flag -+*+-
;-------------------------------------------------------------------------------
ClrFlag proc    near
        pushad
        mov     edi,TempScr2
        mov     ecx,DumpHeight*DumpWidth/4
        xor     eax,eax
        rep     stosd
        popad
        ret
        endp


;-------------------------------------------------------------------------------
;                           -+*+- Dump Screen -+*+-
;-------------------------------------------------------------------------------

AddValue        dd      0
AddValue2       dd      0
ClipCheck       dd      0
ClipCheck2      dd      0
DumpWidth=320
DumpHeight=100
DumpScr proc    near
        pushad
        mov     esi,TempScr2
        move    edi,0a0000h
        mov     ecx,AddValue
        add     AddValue2,ecx
        mov     ecx,ClipCheck
        add     ClipCheck2,ecx

        push    edi
        mov     ecx,AddValue2
        shr     ecx,2
        xor     eax,eax
        rep     stosd
        pop     edi

        add     edi,AddValue2

        mov     ecx,200
        sub     ecx,ClipCheck2
        cmp     ecx,DumpHeight
        jb      @@nxtrow
        mov     ecx,DumpHeight
@@nxtrow:
        push    ecx
        mov     ecx,DumpWidth/4
        rep     movsd
        add     edi,320-DumpWidth
        add     esi,320-DumpWidth
        pop     ecx
        loop    @@nxtrow
        popad
        ret
        endp

;-------------------------------------------------------------------------------
;                        -+*+- Motion Blur Screen -+*+-
;-------------------------------------------------------------------------------
BlurWidth=160
BlurHeight=170
BlurStart=(320-80)/2
MotionBlur proc near
        pushad
;        move    esi,0a0000h+BlurStart
        mov     esi,TempScr2

        mov     ecx,BlurHeight
@@nxtrow:
        push    ecx
        mov     ecx,BlurWidth
@@nxtpixel:
        cmp     b [esi],0
        jz      @@noblur
        dec     b [esi]           ; Decrease pixel value
@@noblur:
        inc     esi
        loop    @@nxtpixel

        add     esi,(320-BlurWidth)
        pop     ecx
        loop    @@nxtrow

        popad
        ret
        endp


;-------------------------------------------------------------------------------
;                            -+*+- Move Flag -+*+-
;-------------------------------------------------------------------------------
RealFlagXptr    dd      0
RealFlagYptr    dd      0

FlagXptr        dd      0
FlagYptr        dd      0

;FlagXspeed1     dd      6*4
;FlagXspeed2     dd      21*4

;FlagYspeed1     dd      7*4
;FlagYspeed2     dd      19*4

;RealFlagXspeed1 dd      6*4
;RealFlagXspeed2 dd      11*4

;RealFlagYspeed1 dd      7*4
;RealFlagYspeed2 dd      17*4

FlagXspeed1     dd      12*4
FlagXspeed2     dd      21*4

FlagYspeed1     dd      14*4
FlagYspeed2     dd      19*4

RealFlagXspeed1 dd      23*4
RealFlagXspeed2 dd      29*4

RealFlagYspeed1 dd      26*4
RealFlagYspeed2 dd      27*4

PicSinX         dd      0
PicSinY         dd      0

PicXspeed       dd      31*4     ; 11*4
PicYspeed       dd      23*4     ; 4*4

MoveFlag proc   near
        pushad

        mov     esi,Titel2Ptr
        add     esi,60*320+25           ; Point at middle of pic

        mov     ebp,SinTab2             ; Costab is EBP+Sinetab_Length

        ; Add Pic sinus X
        mov     eax,PicSinX
        mov     eax,[ebp+eax]   ; Get sinus
        sar     eax,12
        add     esi,eax
        mov     eax,PicXspeed
        add     PicSinX,eax
        and     PicSinX,16383

        ; Add Pic sinus Y
        mov     eax,PicSinY
        mov     eax,[ebp+eax]   ; Get sinus
        sar     eax,12
        shl     eax,8           ; * Width of picture
        add     esi,eax
        mov     eax,PicYspeed
        add     PicSinY,eax
        and     PicSinY,16383


        ; Point at screen
;        move    edi,0a0000h+(40*320)+60
        mov     edi,TempScr2
        add     edi,(20*320)+64

        mov     eax,RealFlagXptr
        mov     FlagXptr,eax
        mov     ebx,RealFlagXspeed1
        add     RealFlagXptr,ebx
        and     RealFlagXptr,16383

        mov     eax,RealFlagYptr
        mov     FlagYptr,eax
        mov     ebx,RealFlagYspeed1
        add     RealFlagYptr,ebx
        and     RealFlagYptr,16383

        mov     ecx,64          ; 64 points high
@@nxtline:
        push    ecx

        mov     eax,FlagXptr
        mov     ebx,FlagXspeed1
        add     FlagXptr,ebx
        and     FlagXptr,16383

        mov     ebx,FlagYptr
        mov     ecx,FlagYspeed1
        add     FlagYptr,ecx
        and     FlagYptr,16383

        push    edi
        push    esi
        mov     ecx,64          ; 64 points wide
@@nxtpoint:
        push    ecx
        mov     ecx,[ebp+eax]   ; Get sinus for X
;        shl     ecx,2           ; Radius 4
        sar     ecx,12
        mov     edx,[ebp+ebx]   ; Get sinus for Y
;        shl     edx,2           ; Radius 4
        sar     edx,12

        shl     edx,6
        lea     edx,[edx+edx*4] ; *320
        add     ecx,edx         ; Offset on picture
        mov     dl,[esi]        ; Get pixel from that point
        mov     [edi+ecx],dl    ; Set pixel

        ; Add to sinus pointers
        add     eax,FlagXspeed2
        and     eax,16383
        add     ebx,FlagYspeed2
        and     ebx,16383

        inc     esi
        add     edi,3
        pop     ecx
        loop    @@nxtpoint

        pop     esi
        pop     edi
        add     esi,256         ; Next row of pixels
        add     edi,320*1      ; Next line

        mov     eax,RealFlagXspeed2
        add     FlagXptr,eax
        and     FlagXptr,16383
        mov     eax,RealFlagYspeed2
        add     FlagYptr,eax
        and     FlagYptr,16383
        pop     ecx
        loop    @@nxtline

        popad
        ret
        endp

kanske  db      63,63,63
Flagga  Proc    Near
        mov     Syncspassed,0

        move    edi,0a0000h
        mov     ecx,64000
        mov     al,255
        rep     stosb


        mov     ecx,63
zaas:
        push    ecx
        lea     esi,kanske
        mov     dx,3c8h
        mov     al,255
        out     dx,al
        inc     dx
        mov     ecx,3
@@setpak:
        lodsb
        out     dx,al
        loop    @@setpak
        call    sync

        dec     [kanske+0]
        dec     [kanske+1]
        dec     [kanske+2]
        pop     ecx
        loop    zaas

        move    edi,0a0000h
        mov     ecx,64000
        mov     al,0
        rep     stosb

        mov     edi,ScreenPic
        mov     TempScr2,edi

        mov     eax,322*26*4
        call    GetMem
        mov     FontBuffPtr,eax
        jc      ams_errorhandler

        ; Set palette
        lea     esi,Logo5
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     ecx,256*3
@@setpal:lodsb
        out     dx,al
        loop    @@setpal

        call    FlagPart

        ret
flagga  endp

Syncspassed     dd      0

comment %

;-------------------------------------------------------------------------------
;                     -+*+- Variables and such shit -+*+-
;-------------------------------------------------------------------------------

; Allocations
M1=sinetab_length2*5     ; For sine tables
M2=160*102              ; For Tempscr (2 additional empty lines at top+bottom)
M3=320*200              ; For Tempscr 2

SinValue        dd      0
CosValue        dd      0

LogoPtr dd      Logo1+768
TempScr dd      0
TempScr2 dd     0

SinTab  dd      0
CosTab  dd      0

DebugFlag       dw      0

; Some flags
NoClear db      0

        align   4

Logo1   label
;       include planets.inc

        Include Font.inc
code32  ends
        end
%
