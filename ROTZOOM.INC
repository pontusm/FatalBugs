
Titel2          db      256*256 dup(0)
Titel           db      256*256 dup(0)

TitelPtr        dd      Titel
Titel2Ptr       dd      Titel2
DrawOffs        dd      0

RotatePart:
        pushad
        mov     edi,TitelPtr            ;make pic
        mov     dword ptr [pic+2],edi
        mov     ecx,256*256
        mov     al,0
        rep     stosb

        mov     edi,Titel2Ptr
        mov     ecx,256*256
        mov     al,255
        rep     stosb

        lea     esi,Logo5+768
        mov     edi,Titel2Ptr
        add     edi,256*3
        mov     edx,5
LoopAgain2:
        push    esi

        push    esi
        push    edx
        mov     edx,24
LoopAgain:
        push    esi
        mov     ecx,124
        rep     movsb
        add     edi,4
        pop     esi
        mov     ecx,124
        rep     movsb
        add     edi,256-124-124-4
        dec     edx
        jnz     LoopAgain
        pop     edx
        pop     esi

        add     edi,256
        push    edx
        mov     edx,24
LoopAgain3:
        push    esi
        add     esi,62
        mov     ecx,62
        rep     movsb
        add     edi,4
        pop     esi
        push    esi
        mov     ecx,124
        rep     movsb
        pop     esi
        add     edi,4
        mov     ecx,62
        rep     movsb
        add     edi,256-62-62-8-124
        add     esi,62
        dec     edx
        jnz     LoopAgain3
        pop     edx
        add     edi,256

        dec     edx
        pop     esi
        jnz     LoopAgain2

        lea     esi,logo5+224*3
        mov     dx,3c8h
        mov     al,224
        out     dx,al
        inc     dx
        mov     ecx,32*3
paletteloop:
        nop
        nop
        outsb
        loop    paletteloop

        call    rotatethepicture

        mov     ecx,70*2
ab:     call    sync
        loop    ab

        lea     edi,TmpPal
        lea     esi,logo5+224*3
        mov     ecx,32*3
        rep     movsb

        mov     ecx,32
PaletteLoop2:
        push    ecx
        lea     esi,TmpPal
        mov     ecx,32*3
DecLoop:
        dec     byte ptr [esi]
        jge     NoZero
        mov     byte ptr [esi],0
NoZero:
        inc     esi
        loop    DecLoop

        lea     esi,TmpPal
        mov     dx,3c8h
        mov     al,224
        out     dx,al
        inc     dx
        mov     ecx,32*3
paletteloop3:
        nop
        nop
        outsb
        loop    paletteloop3
        call    sync
        pop     ecx
        loop    PaletteLoop2

        popad
        ret

Sync    Proc    Near
        Pusha
        in      al,60h
        Mov     Dx,3dah
@l1:
        In      Al,dx
        Test    Al,8
        Jne     @l1
@l2:
        In      Al,dx
        Test    Al,8
        Je      @l2
        Popa
        Ret
EndP
TmpPal  db      32*3    dup(0)
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;                                Add and Rotate
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Waiting dd      0
ExtraSpd dd     4*45
pekare  dd      0
AddandRotate            proc    near
        pushad
        mov     eax,DrawOffs
        cmp     eax,256*256
        jae     NotPutPic
        mov     esi,Titel2Ptr
        add     esi,eax
        mov     edi,TitelPtr
        add     edi,eax
        mov     ecx,256*2
        rep     movsb
        add     DrawOffs,256*2
NotPutPic:
        inc     waiting
        cmp     waiting,90
        jb      Cont
        cmp     waiting,135
        jb      AddSpd
        cmp     waiting,270
        jb      SubSpeed
;       cmp     waiting,360
;       jb      skippas
;       cmp     waiting,400
;       jb      AddSpd2
;       jmp     Cont
SubSpeed:
        sub     ExtraSpd,4*2
        jmp     Cont
AddSpd:
        add     ExtraSpd,4*5
;        jmp     Cont
;AddSpd2:
;        add     ExtraSpd,4*2
Cont:
        mov     ebx,ExtraSpd
        add     rotateangle,ebx
        and     rotateangle,16383*4

        mov     ebx,Pekare
        add     ebx,SinTab
        mov     eax,[ebx]
        add     eax,256
        shl     eax,2
        add     eax,512
        mov     rotatezoom,eax
        add     pekare,4*45
        and     pekare,16383*4
skippas:
        popad
        ret
AddandRotate            endp
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;                               RotateThePicture
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

RotateZoom      dd      2*1024
RotateAngle     dd      4*2048*2
SaveRegister    dd      0
Sx1             dd     -128+100
Sx2             dd      128+200
Sx3             dd      128+50
Sx4             dd     -128+150
Sy1             dd     -128+50
Sy2             dd     -128+50
Sy3             dd      128+250
Sy4             dd      128+150
;Xnew            dd      -128, 128, 128,-128
;Ynew            dd       128, 128,-128,-128
Xnew            dd      0,0,0,0; -116*2,-139*2, 116*2, 139*2
Ynew            dd      0,0,0,0; -139*2, 116*2, 139*2,-116*2
Xnow1           dd      0
Ynow1           dd      0
Xnow2           dd      0
Ynow2           dd      0
saveBL          db      0
saveBH          db      0
saveEBP         dd      0
saveESI         dd      0
RotateFlag      db      0
RotateThePicture        proc    near
        pushad
        mov     RotateFlag,1
MainRotateLoop:
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켐袴袴袴袴袴� Calculate NewX
        lea     esi,Sx1
        lea     edi,Xnew
        mov     ecx,4

        mov     ebp,rotatezoom
Calcxloop:
        push    ecx
        mov     eax,[esi+16]
        mov     edx,rotateangle
        add     edx,SinTab
        mov     ebx,[edx]
        imul    ebx
        imul    ebp
        mov     ebx,262144
        idiv    ebx
        mov     saveregister,eax
        mov     eax,[esi]
        mov     edx,rotateangle
        add     edx,CosTab
        mov     ebx,[edx]
        imul    ebx
        imul    ebp
        mov     ebx,262144
        idiv    ebx
        sub     eax,saveregister
        stosd
        add     esi,4
        pop     ecx
        loop    calcxloop
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켐袴袴袴袴袴� Calculate NewY
        lea     esi,Sx1
        lea     edi,Ynew
        mov     ecx,4
        mov     ebp,rotatezoom
Calcyloop:
        push    ecx
        mov     eax,[esi+16]
        mov     edx,RotateAngle
        add     edx,CosTab
        mov     ebx,[edx]
        imul    ebx
        imul    ebp
        mov     ebx,262144
        idiv    ebx
        mov     saveregister,eax
        mov     eax,[esi]
        mov     edx,rotateangle
        add     edx,SinTab
        mov     ebx,[edx]
        imul    ebx
        imul    ebp
        mov     ebx,262144
        idiv    ebx
        add     eax,saveregister
        stosd
        add     esi,4
        pop     ecx
        loop    calcyloop
;郞袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
;�                               Put line loop                                 �
;突袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
        move    edi,0a0000h

        mov     ecx,200
PutLineLoopen:
        push    ecx
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켐袴袴袴袴袴� Calculate NewStartdot
        dec     ecx
        mov     ebx,256                         ;y
        mov     ebp,199
        mov     eax,[ynew+0*4]
        sub     eax,[ynew+3*4]
        imul    ecx
        idiv    ebp
        add     eax,[ynew+3*4]
        mov     ynow1,eax
        cdq
        idiv    ebx
        add     edx,128
        mov     saveBH,dl
                                                ;x
        mov     eax,[xnew+0*4]
        sub     eax,[xnew+3*4]
        imul    ecx
        idiv    ebp
        add     eax,[xnew+3*4]
        mov     xnow1,eax
        cdq
        idiv    ebx
        add     edx,128
        mov     saveBL,dl

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켐袴袴袴袴袴� Calculate NewEnddot
        mov     eax,[ynew+1*4]                  ;y
        sub     eax,[ynew+2*4]
        imul    ecx
        idiv    ebp
        add     eax,[ynew+2*4]
        mov     ynow2,eax
                                                ;x
        mov     eax,[xnew+1*4]
        sub     eax,[xnew+2*4]
        imul    ecx
        idiv    ebp
        add     eax,[xnew+2*4]
        mov     xnow2,eax
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켐袴袴袴袴袴� Prepare k
;Xnew            dd       -232 -278
;Ynew            dd       -278  232
        mov     eax,ynow2                       ;y
        sub     eax,ynow1
        sal     eax,16
        cdq
        mov     ebx,320
        idiv    ebx
        mov     ebx,0ffffh
        cdq
        idiv    ebx
;------------------------------
        cmp     eax,0
        jl      sura
        cmp     edx,0
        jge     sippa
sura:
        dec     eax
        neg     edx
        mov     ecx,65535
        sub     ecx,edx
        mov     edx,ecx
sippa:
;------------------------------
        mov     byte ptr [addasY+2],al
        sal     edx,16
        mov     saveESI,edx
                                                ;x
        mov     eax,xnow2
        sub     eax,xnow1
        sal     eax,16
        cdq
        mov     ebx,320
        idiv    ebx
        mov     ebx,0ffffh
        cdq
        idiv    ebx
;------------------------------
        cmp     eax,0
        jl      sura2
        cmp     edx,0
        jge     sippa2
sura2:
        dec     eax
        neg     edx
        mov     ecx,65535
        sub     ecx,edx
        mov     edx,ecx
sippa2:
;------------------------------
        mov     byte ptr [addasX+2],al
        sal     edx,16
        mov     saveEBP,edx

;郞袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
;�                               Put the line                                  �
;突袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
                                                ; adda regdec x = edx
                                                ; adda regdec y = esp
                                                ; adda on x     = ebp
                                                ; adda on y     = esi
                                                ; x cord        = bl
                                                ; y cord        = bh
                                                ; adda on int x = [addasX+3]
                                                ; adda on int y = [addasY+3]
        mov     bl,saveBL
        mov     bh,saveBH
        mov     ebp,saveEBP
        mov     esi,SaveESI
        mov     d [addasY-4],esi
        xor     esi,esi
        xor     edx,edx
        mov     ecx,320
Putthelineloop:
        add     edx,ebp
addasX: adc     bl,255
        add     esi,088888888h
addasY: adc     bh,255
pic:    mov     al,[Titel2+ebx]
        stosb
        loop    putthelineloop
        pop     ecx
        loop    PutLineLoopen


        cmp     Waiting,270
        jb      mainrotateloop
        mov     RotateFlag,0

        popad
        ret

RotateThePicture        endp

align 4
tst     dd      0
Logo5 Db 0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,53,29,29,51,27,27,50,25,25,49,23,24,47,20,22,46,18,20,45,17,19,44,15,18,42,13,17,41,12,16,40,10,14,38,9,13,37,7,12,36,6,11,35,5,11,20,20
Db 20,22,22,22,25,25,25,28,28,28,30,30,30,33,33,33,36,36,36,38,38,38,41,41,41,44,44,44,46,46,46,49,49,49,52,52,52,54,54,54,57,57,57,60,60,60,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
Db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
Db 240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,255,240,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249
Db 249,250,250,251,251,252,240,241,241,242,242,243,243,244,248,249,249,250,250,251,251,252,240,241,241,242,242,243,243,244,240,255,255,240,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250
Db 250,251,251,252,252,241,241,242,242,243,243,244,244,249,249,250,250,251,251,252,252,241,241,242,242,243,243,244,244,240,255,255,240,241,242,242,243,243,244,244,245,249,250,249,249,249,249,249,248,243,243,243,243,243,243,244,245,247,249,250,251,251,252,252,253,244,243,243,243,243,244,243,245,246,248,248,249,249,249,249,248,243,242,242,243,243,243,243,245,246,247,247,248,248,249,250,253,241,242,242,243,243,244,244,245,246,247,247,247,248,248,249,247,242,242,242,243,243,244,244,245,249,250,250,251
Db 251,252,252,253,241,242,242,243,243,244,244,245,245,246,246,247,247,247,247,245,241,241,242,243,243,244,244,245,240,255,255,240,242,242,243,243,244,243,244,245,250,247,227,226,226,225,226,225,226,225,226,225,226,225,226,225,226,225,249,251,252,251,252,249,227,226,227,226,227,227,227,227,227,227,228,227,228,227,228,227,228,228,242,243,243,228,229,228,229,229,230,229,230,229,230,246,242,242,243,243,244,243,244,243,231,231,232,231,232,232,233,232,233,232,242,243,244,243,242,233,234,246,251,251,247
Db 234,235,245,242,242,243,243,244,243,244,242,237,237,238,237,238,238,238,238,239,238,241,243,244,243,244,245,240,255,255,240,242,243,242,244,243,245,245,245,227,227,227,227,226,226,225,225,225,225,225,225,239,225,225,226,226,226,226,248,251,253,251,226,226,227,226,227,227,239,227,227,227,227,227,228,227,228,228,228,228,228,228,243,226,229,229,229,229,229,229,230,229,230,230,230,230,242,242,244,243,242,231,231,231,231,231,232,232,232,232,232,232,233,239,242,242,233,233,234,234,234,246,246,234,235
Db 235,235,235,241,242,244,243,242,236,237,237,237,237,238,238,238,238,238,238,239,239,242,243,245,245,246,240,255,255,240,242,243,244,243,244,245,245,228,228,227,227,226,239,239,239,225,226,225,226,225,239,225,226,225,226,225,226,239,249,253,250,226,227,226,227,226,227,239,227,227,228,239,228,227,228,227,228,228,239,228,229,228,228,228,229,239,239,239,239,239,239,229,230,230,230,230,242,243,244,230,231,231,232,231,239,239,239,232,232,232,233,232,239,241,234,233,234,233,234,234,235,234,235,234,235
Db 235,236,235,242,243,244,236,237,236,237,237,239,239,239,237,238,238,239,238,239,242,244,245,245,246,240,255,255,240,242,244,243,245,244,246,245,228,227,227,227,227,239,225,225,226,226,226,226,226,239,226,226,226,226,226,226,239,245,249,249,226,226,227,226,227,230,239,227,227,227,239,227,227,227,228,228,228,239,228,228,228,239,229,229,239,250,252,251,253,252,254,230,230,230,230,230,245,226,231,231,231,231,232,239,227,225,232,232,232,232,233,239,231,233,234,233,234,234,234,234,234,234,235,235,235
Db 235,236,239,245,241,236,236,237,237,237,239,227,244,238,238,238,238,239,239,243,244,246,246,247,240,255,255,240,248,249,249,250,250,248,229,228,228,227,227,226,239,243,243,226,227,226,227,226,239,225,227,226,226,226,227,226,226,226,227,226,227,226,227,230,239,239,227,227,227,239,228,227,228,227,228,227,239,228,229,228,239,228,229,239,240,241,241,242,242,243,230,229,230,230,231,227,231,231,231,231,232,231,239,229,244,232,233,232,233,232,239,232,233,233,234,233,234,234,235,234,235,234,235,235,236
Db 235,236,228,236,236,237,236,237,237,239,241,243,238,238,238,239,238,239,245,250,251,251,252,240,255,255,240,249,249,250,250,251,249,228,228,228,227,227,227,239,242,244,243,239,239,239,239,239,247,249,225,226,227,226,227,226,227,226,227,227,227,230,239,239,225,227,227,227,239,227,228,227,228,228,228,239,228,228,228,239,229,229,239,241,241,242,242,243,230,230,230,230,230,230,239,231,231,231,231,231,231,239,241,243,242,239,239,239,239,239,233,233,233,233,234,234,234,234,234,234,235,235,235,235,236
Db 235,239,236,236,236,237,237,237,239,241,243,241,239,239,239,239,239,247,251,251,252,252,240,255,255,240,249,250,250,251,251,249,229,228,228,227,227,227,239,242,244,245,246,246,246,247,248,252,252,248,239,226,227,227,227,227,227,227,227,239,239,239,246,247,228,227,228,239,228,227,228,227,228,228,239,228,229,228,239,228,229,229,229,229,230,229,230,229,230,230,230,230,231,239,231,230,231,231,232,231,239,241,243,244,242,243,245,246,245,233,234,233,234,233,234,234,235,234,235,234,235,235,236,235,236
Db 239,236,236,237,236,237,237,239,241,243,244,242,243,245,246,248,251,251,252,252,253,240,255,255,240,250,250,251,251,252,249,229,228,228,228,227,227,227,228,242,245,250,250,251,251,252,251,252,248,242,228,227,227,227,228,227,227,227,239,226,247,252,251,248,239,239,239,228,228,228,228,228,228,239,227,239,239,239,229,229,229,229,229,229,229,229,230,230,230,230,230,230,239,230,231,231,231,231,232,232,232,242,243,244,245,250,250,246,233,233,234,233,234,234,239,234,234,239,235,235,235,235,236,236,239
Db 236,236,236,237,237,237,237,237,242,243,244,245,250,250,251,251,252,251,252,253,240,255,255,240,250,251,250,252,251,249,229,228,228,228,228,228,239,239,239,244,247,248,248,249,251,253,249,228,228,228,228,227,228,228,228,227,228,228,228,248,251,253,253,248,242,229,229,228,228,228,229,228,239,246,247,247,245,228,229,228,229,229,230,229,230,229,230,239,239,239,239,239,231,230,231,231,232,231,239,239,239,242,243,245,246,248,247,233,233,233,234,233,234,239,232,239,239,234,235,235,236,235,236,239,236
Db 236,237,236,237,237,239,239,239,241,242,243,245,248,250,252,251,253,253,254,240,255,255,240,250,251,252,251,252,249,229,229,228,229,228,229,239,230,229,229,229,230,229,229,247,248,229,229,228,229,228,229,228,228,228,229,228,228,228,229,249,253,253,254,245,229,228,229,229,229,229,229,239,247,252,251,248,229,229,229,229,229,229,230,229,230,230,239,226,245,247,245,231,231,231,231,231,231,239,232,232,232,232,232,232,233,226,233,233,233,233,234,234,239,241,242,229,235,235,235,235,236,236,239,236,236
Db 236,237,237,237,239,232,238,238,238,238,238,239,247,251,252,253,253,254,240,255,255,240,250,252,251,253,252,248,229,229,230,229,230,229,239,228,230,230,230,230,230,230,239,229,230,229,230,229,229,239,239,239,239,229,229,228,229,229,229,248,254,255,245,229,229,229,230,229,230,229,239,246,251,253,247,229,230,229,230,239,230,229,230,229,230,230,230,248,251,253,231,230,231,231,232,231,239,229,232,232,233,232,233,232,239,233,234,233,234,233,234,239,242,245,243,234,235,235,236,235,236,239,236,236,237
Db 236,237,237,239,230,238,237,238,238,239,238,239,247,252,254,254,255,240,255,255,240,240,241,241,242,242,244,230,230,230,230,230,230,239,228,230,231,231,231,231,231,239,231,230,230,230,230,230,239,242,246,244,230,229,230,229,229,229,239,245,244,245,230,229,230,229,230,230,230,239,242,241,242,243,230,230,230,230,230,228,230,230,230,230,230,230,231,243,242,231,231,231,231,231,232,239,228,232,232,232,232,232,233,239,233,233,234,234,234,234,239,245,250,245,235,235,235,235,236,236,239,236,236,236,237
Db 237,237,239,230,237,238,238,238,238,239,239,242,242,243,243,244,240,255,255,240,241,241,242,242,243,243,231,230,231,230,231,230,231,231,232,231,232,231,232,231,239,231,232,231,231,230,234,239,246,251,249,230,230,230,231,230,230,239,242,244,245,230,231,230,230,230,231,230,239,240,242,242,242,230,231,230,231,230,231,228,239,231,231,230,231,231,231,230,231,231,232,231,232,231,232,231,232,232,233,232,233,232,239,233,233,233,234,233,234,239,246,250,247,234,235,235,236,235,236,239,236,236,237,236,237
Db 237,238,237,238,238,239,238,239,238,239,241,243,243,244,244,240,255,255,240,241,242,242,243,243,243,231,231,231,232,231,232,232,232,232,232,232,233,233,233,239,232,232,232,232,234,239,239,248,252,252,248,231,231,231,231,231,239,242,245,246,231,231,231,231,231,231,231,239,241,242,243,243,231,231,231,231,231,231,239,225,231,231,232,231,232,231,239,231,232,232,232,232,232,232,232,232,232,232,233,232,233,239,233,233,233,233,234,234,239,246,251,249,235,235,235,235,236,236,239,236,236,236,237,237,237
Db 237,238,238,238,238,238,238,239,239,242,243,244,244,245,240,255,249,240,242,242,243,243,244,243,242,239,239,239,239,239,239,239,239,239,239,239,239,239,239,243,239,239,239,239,239,247,252,251,252,253,244,239,239,239,239,239,243,245,250,246,239,239,239,239,239,239,239,242,243,243,244,242,239,239,239,239,239,239,248,247,239,239,239,239,239,239,229,239,239,239,239,239,239,239,239,239,239,239,239,239,239,230,239,239,239,239,239,239,248,251,252,247,239,239,239,239,239,239,230,239,239,239,239,239,239
Db 239,239,239,239,239,239,239,239,242,244,243,244,245,240,255,248,240,242,243,242,244,243,245,245,245,246,247,247,247,247,248,248,247,242,241,241,242,242,245,243,244,245,247,248,252,251,253,253,254,242,242,241,242,242,243,245,246,250,251,248,247,247,248,248,247,243,243,242,244,243,245,243,244,246,247,247,248,251,253,250,247,242,241,241,242,243,243,243,244,246,247,247,247,247,248,248,247,242,241,242,244,242,242,243,244,245,248,250,252,251,253,249,247,243,241,241,242,243,243,243,244,245,247,247,247
Db 247,248,248,247,243,241,242,243,243,245,245,246,240,255,255,252,242,252,255,252,244,255,255,252,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252,253,253,254,242,243,244,243,244,245,245,246,250,251,252,251,252
Db 253,253,254,242,243,244,243,244,245,245,246,240,255,248,255,242,255,243,255,244,255,246,255,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254,254,255,242,244,243,245,244,246,246,247,250,252,251,253,252,254
Db 254,255,242,244,243,245,244,246,246,247,240,255,249,255,240,255,255,255,240,255,255,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
Db 240,240,240,240,240,240,240,240,240,240,255,248,255,248,255,248,255,248,255,248,249,249,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
Db 255,255,255,255,255,255,255,255,255,255

