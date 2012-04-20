
FontBuffPtr     dd      0

WriterText      db      "   - FATAL BUGS -   ",0
                db      "64K INTRO BY EXTREME",0
                db      "RELEASED AT ICING'95",0
                db      "                    ",0
                db      "        ",1
                db      "CODING.......VICIOUS",0
                db      "             BALDRIC",0
                db      "GRAPHICS.........TAP",0
                db      "MUSIC........VICIOUS",0
                db      "        ",1
                db      "READ THE TEXTFILE IF",0
                db      "YOU LIKE READING....",0
                db      " OR TRY TO FIND THE ",0
                db      "    HIDDEN PART!    ",0
                db      "        ",1
                db      " AFTER ALL, WE ONLY ",0
                db      " WANTED TO DIVE OUT ",0
                db      "OF THIS DIMENSION OF",0
                db      "     SOMETHING      ",0
                db      "        ",1
                db      "NEVER TRUST YOUR DOG",0
                db      "  BECAUSE INTERNAL  ",0
                db      "INJURIES CAN BE VERY",0
                db      "      VICIOUS!      ",0
                db      "        ",1,2

FontColor       equ     9
AliasColor      equ     1

ConvertFont     Proc    Near
        pushad
        lea     esi,Font+768
        mov     edi,FontBuffPtr
        add     edi,640+1

        mov     ecx,24
ConvertLineLoopen:
        push    ecx
        mov     ecx,320
ConvertRowLoopen:
        lodsb
        mov     ah,al
        mov     [edi+640],ax
        stosw
        loop    ConvertRowLoopen
        add     edi,640
        pop     ecx
        loop    ConvertLineLoopen


        mov     esi,FontBuffPtr
        add     esi,640+1
        mov     edi,esi
        mov     ecx,640*24*2
AntiAliasRowLoopen:
        push    ecx
        xor     eax,eax
        cmp     byte ptr [esi],FontColor
        jz      Count1
        cmp     byte ptr [esi-1],AliasColor
        jz      DontCount1
Count1:
        add     al,[esi-1]
DontCount1:
        cmp     byte ptr [esi],FontColor
        jz      Count2
        cmp     byte ptr [esi-640],AliasColor
        jz      DontCount2
Count2:
        add     al,[esi-640]
DontCount2:
        cmp     byte ptr [esi],FontColor
        jz      Count3
        cmp     byte ptr [esi+1],AliasColor
        jz      DontCount3
Count3:
        add     al,[esi+1]
DontCount3:
        cmp     byte ptr [esi],FontColor
        jz      Count4
        cmp     byte ptr [esi+640],AliasColor
        jz      DontCount4
Count4:
        add     al,[esi+640]
DontCount4:
        cmp     al,FontColor*2
        jnz     DontAlias
        mov     al,AliasColor
        mov     [edi],al
DontAlias:
        inc     edi
        inc     esi
        pop     ecx
        loop    AntiAliasRowLoopen


        popad
        ret
ConvertFont     EndP


DumpBuffer      dd      0
ScreenWidth2    equ     320
ScreenHeight2   equ     100
WaitTime        equ     ScreenHeight2/4

TextOffset      dd      WriterText
GetPosition     dd      8 dup(0)        ;source offset
PutPosition     dd      8 dup(0)        ;dest offset
Priority        db      8 dup(0)
CurrentLetter   db      0
CurrentMask     db      0
Cursor          dd      0;320*40
WaitPage        dw      0
NoMoreText      db      0

Writer  Proc    Near
;       call    sync
        cmp     NoMoreText,1
        jz      _ret
        pushad
        dec     WaitPage
        jl      Buffel
        cmp     WaitPage,WaitTime
        jbe     NewPageCheck
        jmp     WaitRead
Buffel:
        mov     WaitPage,0

        mov     esi,FontBuffPtr
        add     esi,640+1

        mov     ebp,TextOffset
        movzx   eax,byte ptr [ebp]
        inc     TextOffset
        cmp     al,0
        jz      NewRow
        cmp     al,1
        jz      NewPage
        cmp     al,2
        jz      EndText
        sub     eax,32
        shl     eax,4
        cmp     eax,640
        jb      NoiFisk
        add     eax,23*640
NoiFisk:
        add     esi,eax
        movzx   ebx,CurrentLetter
        mov     [GetPosition+ebx*4],esi
        inc     CurrentLetter
        and     CurrentLetter,7
        mov     esi,Cursor
        add     esi,DumpBuffer
        mov     [PutPosition+ebx*4],esi
        mov     [Priority+ebx],0
        add     Cursor,16
Snurvel:
        mov     ecx,8
        xor     ebp,ebp
PrintoutLetters:
        push    ecx

        inc     [Priority+ebp]
        mov     edi,[PutPosition+ebp*4]
        mov     esi,[GetPosition+ebp*4]
        cmp     edi,0
        jz      SkipOneLetter

;       call    sync

        movzx   ecx,[Priority+ebp]
        lea     ecx,[ecx+ecx*2]
        add     esi,640*24
        mov     eax,640
        mul     ecx
        sub     esi,eax
CopyLoopen:
        push    ecx
        push    esi
        push    edi

        movzx   ecx,[Priority+ebp]
        shl     ecx,1
        add     esi,16
        sub     esi,ecx
        rep     movsb

        pop     edi
        pop     esi
        add     edi,ScreenWidth2
        add     esi,640
        pop     ecx
        loop    CopyLoopen

SkipOneLetter:
        inc     ebp
        pop     ecx
        loop    PrintoutLetters
        popad
        ret
NewRow:
        mov     eax,Cursor
        mov     ebx,ScreenWidth2
        xor     edx,edx
        div     ebx
        add     eax,24
        mul     ebx
;       add     eax,16
        mov     Cursor,eax
        popad
        ret
EndText:
        mov     NoMoreText,1
        popad
        ret
NewPage:
        mov     WaitPage,70*2
        popad
        ret

TuffTuffT†g     dd      0
NewPageCheck:
        mov     edi,DumpBuffer
        add     edi,ScreenHeight2/2*ScreenWidth2-ScreenWidth2
        add     edi,TuffTuffT†g
        add     TuffTuffT†g,ScreenWidth2*2
        mov     ecx,ScreenWidth2
        mov     ax,0
        rep     stosw

        mov     edi,DumpBuffer
        add     edi,ScreenWidth2*ScreenHeight2/2+ScreenWidth2
        sub     edi,TuffTuffT†g
        mov     ecx,ScreenWidth2
        mov     ax,0
        rep     stosw

        cmp     TuffTuffT†g,ScreenWidth2*ScreenHeight2/2
        jbe     WaitRead
        mov     Cursor,0;320*40
        mov     TuffTuffT†g,0
WaitRead:
;       call    sync
        popad
        ret
Writer  EndP


