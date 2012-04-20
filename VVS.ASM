;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                     -+*+- Vicious Vector System -+*+-                       บ
;วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
;บ                               Version 1.00                                  บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
locals

b       equ     byte ptr
w       equ     word ptr
d       equ     dword ptr

SetPalette=1    ; Set to 0 if you don't want to set the palette
DebugStuff=1    ; Set if you want to include debugging stuff


; *** VVS Include definitions ***

FLAG    macro   L,B
L       equ     1 shl B
        endm

RESETOFFS macro
        offs=0
        endm

OFFSB   macro   N
        N=offs
        offs=offs+1
        endm

OFFSW   macro   N
        N=offs
        offs=offs+2
        endm

OFFSD   macro   N
        N=offs
        offs=offs+4
        endm

; ObjFlags
        flag    ObjVisible,15   ; Name,bitnr
        flag    ObjGouraud,14

; PolygonFlags
        flag    PolyVisible,15
        flag    Dots,14
        flag    Lines,13
        flag    Fill,12
        flag    Texture,11
        flag    Lambert,10
        flag    Gouraud,9
        flag    Phong,8
        flag    Spline,7
        flag    Transparent,6
        flag    WrapNormal,5

; Light flags
        flag    Omni,15
        flag    Spotlight,14


; Camera structure offsets
        resetoffs
        offsd   NxtCamera
        offsd   AttachCamera
        offsd   AttachViewpoint
        offsd   CameraPosX
        offsd   CameraPosY
        offsd   CameraPosZ
        offsd   ViewPointPosX
        offsd   ViewPointPosY
        offsd   ViewPointPosZ

; Light structure offsets
        resetoffs
        offsd   NxtLight
        offsd   AttachLight
        offsd   AttachHotSpot
        offsd   LightPosX
        offsd   LightPosY
        offsd   LightPosZ
        offsd   HotspotPosX
        offsd   HotspotPosY
        offsd   HotspotPosZ

; Object structure offsets
        resetoffs
        offsd   NxtObject
        offsd   ChildObj
        offsw   ObjFlags
        offsw   ObjLightGroup
        offsw   ObjAngleX
        offsw   ObjAngleY
        offsw   ObjAngleZ
        offsw   ParentAngleX
        offsw   ParentAngleY
        offsw   ParentAngleZ
        offsd   ObjPosX
        offsd   ObjPosY
        offsd   ObjPosZ
        offsd   ParentOriginX
        offsd   ParentOriginY
        offsd   ParentOriginZ
        offsd   ParentPosX
        offsd   ParentPosY
        offsd   ParentPosZ
        offsd   GouraudPtr
        offsd   Polygons
        offsd   ObjPoints
        offsd   Points

; Object List offsets
        resetoffs
        offsd   NxtListObj
        offsd   PrevListObj
        offsd   ObjectPtr
        offsd   MinZ

; Polygon structure offsets
        resetoffs
        offsw   PolygonFlags
        offsw   OffsNxtPolygon
        offsw   NrOfPoints
        offsw   Colour
        offsd   ExpandStruc
        offsd   VectorPoint1

; Expand structure+Texture structure offsets (Both part of the Poly struc)
        resetoffs
        offsd   RotFaceNormalX
        offsd   RotFaceNormalY
        offsd   RotFaceNormalZ
        offsd   FaceNormalX
        offsd   FaceNormalY
        offsd   FaceNormalZ
        offsd   LightIntensity

        offsd   Material        ; This is the beginning of the Texture struc
        offsw   Edges           ; This continues <nrofedges*2> times (for X&Y)

; Material structure
        resetoffs
        offsd   MaterialSize
        offsw   MatWidth
        offsw   MatHeight
        offsb   Ambience
        offsb   Reflection
        offsb   BaseColour
        offsb   ShadingLevels
        offsw   Levelsize
        offsd   BitmapData
        offsd   ShadingTable

; Polygon Buffer offsets
        resetoffs
        offsd   OffsData
        offsw   Xcoord1
        offsw   Zcoord1
        offsw   TextureX1
        offsw   TextureY1
        offsw   LightLevel1
        offsw   Xcoord2
        offsw   Zcoord2
        offsw   TextureX2
        offsw   TextureY2
        offsw   LightLevel2

; Light structure
        resetoffs
        offsd   NxtLight
        offsd   AttachLight
        offsd   AttachHotspot
        offsd   LightPosX
        offsd   LightPosY
        offsd   LightPosZ
        offsd   HotspotPosX
        offsd   HotspotPosY
        offsd   HotspotPosZ
        offsw   LightGroup
        offsw   LightFlags

; Gouraud structure
        resetoffs
        offsd   ConnectList
        offsd   MeanNormal1

; Connectlist structure
        resetoffs
        offsd   Connections1
        offsd   Polygon1

; *******************************

; This will show a value in a REG on screen line POS.
Debug   macro   reg,pos
        local   wtkey,relkey
        pushad
        mov     eax,REG
        call    ConvNR
        mov     dx,pos
        shl     dx,8
        call    Locate
        lea     esi,AsciiNr
        call    PrintText

;       cmp     debugflag,1
;       jz      relkey
        cli
wtkey:  in      al,60h
        cmp     al,1
        jnz     wtkey
relkey: in      al,60h
        cmp     al,1
        jz      relkey
        sti
        mov     DebugFlag,1
        popad
        endm

; Same as DEBUG but shows value in HEX.
DebugH  macro   reg,pos
        local   wtkey,relkey
        pushad
        mov     eax,REG
        call    HexNr
        mov     dx,pos
        shl     dx,8
        call    Locate
        lea     esi,AsciiNr
        call    PrintText

;       cmp     debugflag,1
;       jz      relkey
        cli
wtkey:  in      al,60h
        cmp     al,1
        jnz     wtkey
relkey: in      al,60h
        cmp     al,1
        jz      relkey
        sti
        mov     DebugFlag,1
        popad
        endm



; Draw a line for gouraudshaded textured polygon
; Needs X1,Y1,Z1 in ESI, X2,Y2,Z2 in EDI, and Texture edges in X1edge-Y2edge
DRAWGOURAUDTEXT    MACRO
        local   Y1higher,waszero,doLine,doL,TextLineOK,UpOK,UpOK2,DownOK,DownOK2,noUpClip

        push    ebp                     ; Remember Expand struc
        mov     ebp,Polygonbuffer       ; Get pointer to Polygon buffer

        mov     ecx,4[edi]              ; Get Y2
        sub     ecx,4[esi]              ; Y2-Y1
        jz      waszero                 ; Line totally horisontal?
        js      Y1higher

        mov     eax,4[esi]              ; Y1 is start coord
        mov     LineHeight,ecx

        ; Clip Up
        mov     UpSkip,0                ; Nothing to skip=0
        cmp     eax,ClipUp
        jge     UpOK
        mov     ebx,ClipUp
        sub     ebx,eax
        mov     UpSkip,ebx              ; How many rows to skip
        sub     LineHeight,ebx
        mov     eax,ClipUp
UpOK:

        ; Clip Down
        cmp     eax,ClipDown
        jge     TextLineOK              ; Entire line outside lower border
        mov     ebx,eax
        add     ebx,LineHeight
        cmp     ebx,ClipDown
        jl      DownOK
        mov     edx,ClipDown
        sub     ebx,edx
        sub     LineHeight,ebx
DownOK:

        shl     eax,5                   ; Each line in the polybuffer=32 bytes
        add     ebp,eax                 ; Point at correct row

        mov     eax,[edi]               ; Get X2
        sub     eax,[esi]               ; X2-X1
        shl     eax,16
        cdq
        idiv    ecx
        mov     Xadder,eax

        mov     eax,8[edi]              ; Get Z2
        sub     eax,8[esi]              ; Z2-Z1
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     eax,X2edge              ; Get TxtX2 edge
        sub     eax,X1edge              ; TxtX2-TxtX1 edge
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtXadd,eax

        mov     eax,Y2edge              ; Get TxtY2 edge
        sub     eax,Y1edge              ; TxtY2-TxtY1 edge
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtYadd,eax

        mov     eax,TempIntensity2      ; Get I2
        sub     eax,TempIntensity       ; I2-I1
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        ; Set start coords
        mov     eax,[esi]               ; X1
        mov     Xstart,eax
        mov     eax,8[esi]              ; Z1
        mov     Zstart,eax
        mov     eax,X1edge              ; TxtX1
        mov     TxtXstart,eax
        mov     eax,Y1edge              ; TxtY1
        mov     TxtYstart,eax
        mov     eax,TempIntensity       ; I1
        mov     Istart,eax

        jmp     doLine

Y1higher:
        neg     ecx                     ; Make counter positive

        mov     eax,4[edi]              ; Y2 is start coord
        mov     LineHeight,ecx

        ; Clip Up
        mov     UpSkip,0                ; Nothing to skip=0
        cmp     eax,ClipUp
        jge     UpOK2
        mov     ebx,ClipUp
        sub     ebx,eax
        mov     UpSkip,ebx              ; How many rows to skip
        sub     LineHeight,ebx
        mov     eax,ClipUp
UpOK2:

        ; Clip Down
        cmp     eax,ClipDown
        jge     TextLineOK              ; Entire line outside lower border
        mov     ebx,eax
        add     ebx,LineHeight
        cmp     ebx,ClipDown
        jl      DownOK2
        mov     edx,ClipDown
        sub     ebx,edx
        sub     LineHeight,ebx
DownOK2:

        shl     eax,5
        add     ebp,eax

        mov     eax,[esi]               ; Get X1
        sub     eax,[edi]               ; X1-X2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Xadder,eax

        mov     eax,8[esi]              ; Get Z1
        sub     eax,8[edi]              ; Z1-Z2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     eax,X1edge              ; Get TxtX1 edge
        sub     eax,X2edge
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtXadd,eax

        mov     eax,Y1edge              ; Get TxtY1
        sub     eax,Y2edge
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtYadd,eax

        mov     eax,TempIntensity       ; Get I1
        sub     eax,TempIntensity2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        ; Set start coords
        mov     eax,[edi]               ; X2
        mov     Xstart,eax
        mov     eax,8[edi]              ; Z2
        mov     Zstart,eax
        mov     eax,X2edge              ; TxtX2
        mov     TxtXstart,eax
        mov     eax,Y2edge              ; TxtY2
        mov     TxtYstart,eax
        mov     eax,TempIntensity2      ; I2
        mov     Istart,eax

        jmp     doLine


        ; Line was totally horisontal, so no interpolation needed.
waszero:
        mov     eax,4[esi]              ; Get coord of line

        ; Clip Up
        cmp     eax,ClipUp
        jl      TextLineOK

        ; Clip Down
        cmp     eax,ClipDown
        jge     TextLineOK

        shl     eax,5
        add     ebp,eax

        cmp     d [ebp],14              ; Row full?
        jz      TextLineOK

        mov     d [ebp],14              ; Indicate that two points are set
        mov     eax,[esi]               ; Get X1
        mov     4[ebp],ax               ; Set X1
        mov     eax,8[esi]              ; Get Z1
        mov     6[ebp],ax               ; Set Z1
        mov     eax,X1edge              ; Get Texture X1
        mov     8[ebp],ax               ; Set it
        mov     eax,Y1edge              ; Get Texture Y1
        mov     10[ebp],ax              ; Set it
        mov     eax,TempIntensity       ; Get I1
        mov     12[ebp],ax              ; Set I1

        mov     eax,[edi]               ; Get X2
        mov     14[ebp],ax              ; Set X2
        mov     eax,8[edi]              ; Get Z2
        mov     16[ebp],ax              ; Set Z2
        mov     eax,X2edge              ; Get Texture X2
        mov     18[ebp],ax              ; Set it
        mov     eax,Y2edge              ; Get Texture Y2
        mov     20[ebp],ax              ; Set it
        mov     eax,TempIntensity2      ; Get I2
        mov     22[ebp],ax

        jmp     TextLineOK

doLine:

        ; Should we clip top?
        cmp     UpSkip,0
        jz      noUpClip
        mov     ebx,UpSkip      ; Get pixels to skip
        sub     ecx,ebx         ; Get new height of line
        jle     TextLineOK      ; Entire line outside screen

        mov     eax,ebx         ; Pixels in EAX
        imul    Xadder          ; *Xadder
        rol     eax,16
        add     Xstart,eax      ; Fix Xstart

        mov     eax,ebx         ; Pixels in EAX
        imul    Zadder          ; *Zadder
        rol     eax,16
        add     Zstart,eax      ; Fix Zstart

        mov     eax,ebx         ; Pixels in EAX
        imul    TxtXadd         ; *TxtXadd
        rol     eax,16
        add     TxtXStart,eax   ; Fix start

        mov     eax,ebx         ; Pixels in EAX
        imul    TxtYadd         ; *TxtYadd
        rol     eax,16
        add     TxtYStart,eax   ; Fix start

        mov     eax,ebx         ; Pixels in EAX
        imul    Iadder          ; *Iadder
        rol     eax,16
        add     IStart,eax      ; Fix start

noUpClip:

        ; Mix adders...
        mov     eax,Xadder
        mov     ebx,Zadder
        mov     w Xadder,bx             ; Zadd frac in Xadd
        mov     ebx,TxtXadd
        mov     w Zadder,bx             ; TxtX frac in Zadd
        mov     ebx,TxtYadd
        mov     w TxtXadd,bx            ; TxtY frac in TxtXadd
        mov     ebx,Iadder
        mov     w TxtYadd,bx            ; Iadd frac in TxtYadd
        mov     w Iadder,ax             ; Xadd frac in Iadd

        ; Get adders and modify code...
        mov     eax,Xadder
        rol     eax,16
        mov     Xadder,eax
        mov     eax,Zadder
        rol     eax,16
        mov     Zadder,eax
        mov     eax,TxtXadd
        rol     eax,16
        mov     TxtXadd,eax
        mov     eax,TxtYadd
        rol     eax,16
        mov     TxtYadd,eax
        mov     eax,Iadder
        rol     eax,16
        mov     Iadder,eax

        ; Get start values
        push    esi
        push    edi
        mov     eax,TxtXstart
        mov     ebx,TxtYstart
        mov     edx,Istart
        mov     edi,Xstart
        mov     esi,Zstart
        mov     ecx,LineHeight  ; Get (clipped) LineHeight

doL:
        push    ecx
        mov     ecx,[ebp]       ; Get OffsData
        mov     [ebp+ecx],di    ; Store index part of X coord
        mov     [ebp+ecx+2],si  ; Store index part of Z coord
        mov     [ebp+ecx+4],ax  ; Store index part of TxtX
        mov     [ebp+ecx+6],bx  ; Store index part of TxtY
        mov     [ebp+ecx+8],dx  ; Store index part of I
        mov     d [ebp],14      ; OffsData can only contain one more value
        adc     edi,Xadder
        adc     esi,Zadder
        adc     eax,TxtXadd
        adc     ebx,TxtYadd
        adc     edx,Iadder

        lea     ebp,[ebp+32]
        pop     ecx
        dec     cx
        jnz     doL

        pop     edi
        pop     esi

TextLineOK:

        pop     ebp
        endm


; Draw a line in the Polygon Buffer for GOURAUD FILLED polygons
; ESI must point to X1,Y1,Z1 and EDI to X2,Y2,Z2
DRAWGOURAUD macro
        local   Y1higher, doLine, doL, noLine,UpOK,UpOK2,DownOK,DownOK2,noUpClip

        push    ebp

        mov     ebp,PolygonBuffer       ; Get the Polygon buffer
        mov     ecx,4[edi]              ; Get Y2
        sub     ecx,4[esi]              ; Y2-Y1
        jz      noLine
        js      Y1higher

        mov     eax,4[esi]              ; Y1 is start coord
        mov     LineHeight,ecx

        ; Clip Up
        mov     UpSkip,0                ; Nothing to skip=0
        cmp     eax,ClipUp
        jge     UpOK
        mov     ebx,ClipUp
        sub     ebx,eax
        mov     UpSkip,ebx              ; How many rows to skip
        sub     LineHeight,ebx
        mov     eax,ClipUp
UpOK:

        ; Clip Down
        cmp     eax,ClipDown
        jge     noLine                  ; Entire line outside lower border
        mov     ebx,eax
        add     ebx,LineHeight
        cmp     ebx,ClipDown
        jl      DownOK
        mov     edx,ClipDown
        sub     ebx,edx
        sub     LineHeight,ebx
DownOK:


        shl     eax,5                   ; Each line in the polybuffer=32 bytes
        add     ebp,eax                 ; Point at correct row

        mov     eax,[edi]               ; Get X2
        sub     eax,[esi]               ; X2-X1
        shl     eax,16
        cdq
        idiv    ecx
        mov     Xadder,eax

        mov     eax,8[edi]              ; Get Z2
        sub     eax,8[esi]              ; Z2-Z1
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     eax,TempIntensity2      ; Get I for point 2
        sub     eax,TempIntensity
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        mov     eax,[esi]       ; X1 is start coord
        mov     Xstart,eax
        mov     eax,8[esi]      ; Z1 is start coord
        mov     Zstart,eax
        mov     eax,TempIntensity       ; I1 is start coord
        mov     Istart,eax

        jmp     doLine

Y1higher:
        neg     ecx             ; Loop counter must be positive

        mov     eax,4[edi]              ; Y2 is start coord
        mov     LineHeight,ecx

        ; Clip Up
        mov     UpSkip,0                ; Nothing to skip=0
        cmp     eax,ClipUp
        jge     UpOK2
        mov     ebx,ClipUp
        sub     ebx,eax
        mov     UpSkip,ebx              ; How many rows to skip
        sub     LineHeight,ebx
        mov     eax,ClipUp
UpOK2:

        ; Clip Down
        cmp     eax,ClipDown
        jge     noLine                  ; Entire line outside lower border
        mov     ebx,eax
        add     ebx,LineHeight
        cmp     ebx,ClipDown
        jl      DownOK2
        mov     edx,ClipDown
        sub     ebx,edx
        sub     LineHeight,ebx
DownOK2:

        shl     eax,5
        add     ebp,eax                 ; Point at correct row

        mov     eax,[esi]               ; Get X1
        sub     eax,[edi]               ; X1-X2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Xadder,eax

        mov     eax,8[esi]              ; Get Z1
        sub     eax,8[edi]              ; Z1-Z2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     eax,TempIntensity       ; Get I1
        sub     eax,TempIntensity2      ; I1-I2
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        mov     eax,[edi]       ; X2 is start coord
        mov     Xstart,eax
        mov     eax,8[edi]      ; Z2 is start coord
        mov     Zstart,eax
        mov     eax,TempIntensity2      ; I2 is start coord
        mov     Istart,eax

doLine:

        ; Should we clip top?
        cmp     UpSkip,0
        jz      noUpClip
        mov     ebx,UpSkip      ; Get pixels to skip
        sub     ecx,ebx         ; Get new height of line
        jle     noLine          ; Entire line outside screen

        mov     eax,ebx         ; Pixels in EAX
        imul    Xadder          ; *Xadder
        rol     eax,16
        add     Xstart,eax      ; Fix Xstart

        mov     eax,ebx         ; Pixels in EAX
        imul    Zadder          ; *Zadder
        rol     eax,16
        add     Zstart,eax      ; Fix Zstart

        mov     eax,ebx         ; Pixels in EAX
        imul    Iadder          ; *Iadder
        rol     eax,16
        add     IStart,eax      ; Fix start

noUpClip:

        push    edi
        push    esi

        ; Mix adders...
        mov     eax,Xadder
        mov     ebx,Zadder
        mov     w Xadder,bx             ; Zadd frac in Xadd
        mov     ebx,Iadder
        mov     w Zadder,bx             ; Iadd frac in Zadd
        mov     w Iadder,ax            ; Xadd frac in Iadd

        ; Modify code
        mov     eax,Xadder
        rol     eax,16
        mov     Xadder,eax
        mov     eax,Zadder
        rol     eax,16
        mov     Zadder,eax
        mov     eax,Iadder
        rol     eax,16
        mov     Iadder,eax

        ; Get start values
        mov     eax,Istart
        mov     edi,Xstart
        mov     esi,Zstart
        mov     ecx,LineHeight

        ; Draw line in polygon buffer
doL:    mov     edx,[ebp]       ; Get OffsData
        mov     [ebp+edx],di    ; Store index part of X coord
        mov     [ebp+edx+2],si  ; Store index part of Z coord
        mov     [ebp+edx+8],ax  ; Store index part of Intensity
        mov     d [ebp],14      ; OffsData can only contain one more value
        adc     edi,Xadder
        adc     esi,Zadder
        adc     eax,Iadder
        lea     ebp,[ebp+32]
        dec     cx
        jnz     doL
        pop     esi
        pop     edi

noLine:
        pop     ebp
        endm



GOURAUDFILLPOLY MACRO
        local   chkLinesF, chkLF, FillLine, X1higher, doFill, doF,doFblur, noFill,noFillblur, noFillLine, intensity0,LeftOK,LeftOK2,RightOK,RightOK2,noLeftClip

        mov     edi,ZbufferPtr
        mov     esi,PolygonBuffer

        mov     ecx,200                 ; 200 lines
chkLinesF:
        cmp     d [esi],14                ; Anything on row?
        jz      FillLine
chkLF:
        add     esi,32                  ; Next row
        add     edi,320*4               ; Next row in the Zbuff too
        loop    chkLinesF

        pop     esi                     ; Get back point structure
        jmp     @@PolyOK

FillLine:
        push    ecx
        push    edi
        mov     cx,w Xcoord2[esi]       ; Get X2
        sub     cx,w Xcoord1[esi]       ; X2-X1
        jz      noFillLine            ; Nothing to draw
        js      X1higher

        movzx   ecx,cx
        mov     LineWidth,ecx
        movzx   eax,w Xcoord1[esi]      ; Get start X

        ; Clip Left
        mov     LeftSkip,0              ; Nothing to skip=0
        cmp     eax,ClipLeft
        jge     LeftOK
        mov     ebx,ClipLeft
        sub     ebx,eax
        mov     LeftSkip,ebx            ; How many pixels to skip
        sub     LineWidth,ebx
        mov     eax,ClipLeft            ; This is new start coord...
LeftOK:

        ; Clip Right
        cmp     eax,ClipRight
        jge     noFillLine              ; Entire line outside right border
        mov     ebx,eax                 ; Start coord in EBX
        add     ebx,LineWidth           ; Is this outside right border?
        cmp     ebx,ClipRight
        jl      RightOK
        mov     edx,ClipRight
        sub     ebx,edx                 ; How much outside border it is
        sub     LineWidth,ebx          ; Decrease counter
RightOK:

        lea     eax,[eax*4]             ; *4
        add     edi,eax                 ; Point at correct position

        mov     ax,Zcoord2[esi]         ; Get Z2
        sub     ax,Zcoord1[esi]         ; Z2-Z1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     ax,LightLevel2[esi]     ; Get I2
        sub     ax,LightLevel1[esi]     ; I2-I1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        movsx   ebx,w Zcoord1[esi]      ; Z1 is start coord
        mov     Zstart,ebx
        movsx   edx,w LightLevel1[esi]  ; I1 is start coord
        mov     Istart,edx
        jmp     doFill

X1higher:
        neg     cx              ; Loop counter must be positive
        movzx   ecx,cx
        movzx   eax,w Xcoord2[esi]      ; Get start X

        mov     LineWidth,ecx

        ; Clip Left
        mov     LeftSkip,0              ; Nothing to skip=0
        cmp     eax,ClipLeft
        jge     LeftOK2
        mov     ebx,ClipLeft
        sub     ebx,eax
        mov     LeftSkip,ebx            ; How many pixels to skip
        sub     LineWidth,ebx
        mov     eax,ClipLeft            ; This is new start coord...
LeftOK2:

        ; Clip Right
        cmp     eax,ClipRight
        jge     noFillLine              ; Entire line outside right border
        mov     ebx,eax                 ; Start coord in EBX
        add     ebx,LineWidth           ; Is this outside right border?
        cmp     ebx,ClipRight
        jl      RightOK2
        mov     edx,ClipRight
        sub     ebx,edx                 ; How much outside border it is
        sub     LineWidth,ebx          ; Decrease counter
RightOK2:

        lea     eax,[eax*4]
        add     edi,eax                 ; Point at correct position

        mov     ax,Zcoord1[esi]         ; Get Z1
        sub     ax,Zcoord2[esi]         ; Z1-Z2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     ax,LightLevel1[esi]     ; Get I1
        sub     ax,LightLevel2[esi]     ; I1-I2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        movsx   ebx,w Zcoord2[esi]      ; Z2 is start coord
        mov     Zstart,ebx
        movsx   edx,w LightLevel2[esi]  ; I2 is start coord
        mov     Istart,edx

doFill:
        ; Should we clip left?
        cmp     LeftSkip,0
        jz      noLeftClip
        mov     ebx,LeftSkip    ; Get pixels to skip
        sub     ecx,ebx         ; Get new width of line
        jle     noFillLine      ; Entire line outside screen

        mov     eax,ebx         ; Pixels in EAX
        imul    Zadder          ; *Zadder
        rol     eax,16
        add     Zstart,eax      ; Fix Zstart

        mov     eax,ebx         ; Pixels in EAX
        imul    Iadder          ; *Iadder
        rol     eax,16
        add     Istart,eax   ; Fix start

noLeftClip:

        push    esi

        mov     eax,Zadder
        mov     esi,Iadder
        mov     w Zadder,si
        mov     w Iadder,ax     ; Swap fraction parts

        mov     eax,Zadder      ; Get Zadder
        rol     eax,16
        mov     esi,Iadder      ; Get Iadder
        rol     esi,16

        mov     ebx,Zstart
        mov     edx,Istart

        mov     ecx,LineWidth
        cmp     Blur,1
        jz      doFblur

doF:
        cmp     [edi],bx        ; Check Z value
        jle     noFill
        mov     [edi],bx        ; Set new Z value
        mov     2[edi],dx       ; Set colour
noFill:
        add     edi,4
        add     ebx,eax         ; Add Z adder and Iadd frac part
        adc     edx,esi         ; Add Iadder and Zadd frac part
        adc     ebx,0           ; Fix carry

        dec     cx
        jnz     doF

        pop     esi
        jmp     noFillLine


doFblur:
        cmp     [edi],bx        ; Check Z value
        jle     noFillblur
        mov     [edi],bx        ; Set new Z value
        cmp     dx,4
        jle     noFillblur
        mov     2[edi],dx       ; Set colour
noFillblur:
        add     edi,4
        add     ebx,eax         ; Add Z adder and Iadd frac part
        adc     edx,esi         ; Add Iadder and Zadd frac part
        adc     ebx,0           ; Fix carry

        dec     cx
        jnz     doFblur

        pop     esi

noFillLine:
        pop     edi
        pop     ecx
        jmp     chkLF
        endm


; Fill polygon with GOURAUD SHADED TEXTURE
GOURAUDTEXTFILLPOLY MACRO
        local   chkLinesT,chkLT,TextLine,X1higherT,doText,doT,noText,noTextLine,LeftOK,LeftOK2,noLeftClip,RightOK,RightOK2,mud1,mud2,mud3,mud4

        mov     edi,Zbufferptr
        mov     esi,PolygonBuffer

        mov     ecx,200                 ; 200 lines
chkLinesT:
        cmp     d [esi],14              ; Anything on row?
        jz      TextLine                ; Yep, do a textured line
chkLT:
        add     esi,32                  ; Next line in PolyBuff
        add     edi,320*4               ; Next line in Zbuff
        loop    chkLinesT

        pop     esi             ; Get back Point structure

        jmp     @@PolyOK

TextLine:
        push    ecx
        push    edi
        mov     cx,w Xcoord2[esi]       ; Get X2
        sub     cx,w Xcoord1[esi]       ; X2-X1
        jz      noTextLine              ; Nothing to draw
        js      X1higherT

        movzx   eax,w Xcoord1[esi]      ; Get start X

        movzx   ecx,cx                  ; Extend counter for div
        mov     LineWidth,ecx

        ; Clip Left
        mov     LeftSkip,0              ; Nothing to skip=0
        cmp     eax,ClipLeft
        jge     LeftOK
        mov     ebx,ClipLeft
        sub     ebx,eax
        mov     LeftSkip,ebx            ; How many pixels to skip
        sub     LineWidth,ebx
        mov     eax,ClipLeft            ; This is new start coord...
LeftOK:

        ; Clip Right
        cmp     eax,ClipRight
        jge     noTextLine              ; Entire line outside right border
        mov     ebx,eax                 ; Start coord in EBX
        add     ebx,LineWidth           ; Is this outside right border?
        cmp     ebx,ClipRight
        jl      RightOK
        mov     edx,ClipRight
        sub     ebx,edx                 ; How much outside border it is
        sub     LineWidth,ebx          ; Decrease counter
RightOK:

        lea     eax,[eax*4]             ; *4
        add     edi,eax                 ; Point at correct position

        mov     ax,Zcoord2[esi]         ; Get Z2
        sub     ax,Zcoord1[esi]         ; Z2-Z1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     ax,TextureX2[esi]       ; Get TxtX2
        sub     ax,TextureX1[esi]       ; TxtX2-TxtX1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtXadd,eax

        mov     ax,TextureY2[esi]       ; Get TxtY2
        sub     ax,TextureY1[esi]       ; TxtY2-TxtY1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtYadd,eax

        mov     ax,LightLevel2[esi]     ; Get I2
        sub     ax,LightLevel1[esi]     ; I2-I1
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        ; Set start coords
        movsx   eax,w Zcoord1[esi]      ; Z1 is start coord
        mov     Zstart,eax
        movsx   eax,w TextureX1[esi]    ; TxtX1 is start coord
        mov     TxtXstart,eax
        movsx   eax,w TextureY1[esi]    ; TxtY1 is start
        mov     TxtYstart,eax
        movsx   eax,w LightLevel1[esi]  ; I1 is start
        mov     Istart,eax

        jmp     doText

X1higherT:
        neg     cx              ; Counter must be positive
        movzx   ecx,cx
        mov     LineWidth,ecx

        movzx   eax,w Xcoord2[esi]      ; Get start X

        ; Clip Left
        mov     LeftSkip,0              ; Nothing to skip=0
        cmp     eax,ClipLeft
        jge     LeftOK2
        mov     ebx,ClipLeft
        sub     ebx,eax
        mov     LeftSkip,ebx            ; How many pixels to skip
        sub     LineWidth,ebx
        mov     eax,ClipLeft            ; This is new start coord...
LeftOK2:

        ; Clip Right
        cmp     eax,ClipRight
        jge     noTextLine              ; Entire line outside right border
        mov     ebx,eax                 ; Start coord in EBX
        add     ebx,LineWidth           ; Is this outside right border?
        cmp     ebx,ClipRight
        jl      RightOK2
        mov     edx,ClipRight
        sub     ebx,edx                 ; How much outside border it is
        sub     LineWidth,ebx          ; Decrease counter
RightOK2:

        lea     eax,[eax*4]
        add     edi,eax                 ; Point at correct pos

        mov     ax,Zcoord1[esi]         ; Get Z1
        sub     ax,Zcoord2[esi]         ; Z1-Z2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Zadder,eax

        mov     ax,TextureX1[esi]       ; Get TxtX1
        sub     ax,TextureX2[esi]       ; TxtX1-TxtX2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtXadd,eax

        mov     ax,TextureY1[esi]       ; Get TxtY1
        sub     ax,TextureY2[esi]       ; TxtY1-TxtY2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     TxtYadd,eax

        mov     ax,LightLevel1[esi]     ; Get I1
        sub     ax,LightLevel2[esi]     ; I1-I2
        movsx   eax,ax
        shl     eax,16
        cdq
        idiv    ecx
        mov     Iadder,eax

        ; Set start coords
        movsx   eax,w Zcoord2[esi]      ; Z2 is start coord
        mov     Zstart,eax
        movsx   eax,w TextureX2[esi]    ; TxtX2 is start coord
        mov     TxtXstart,eax
        movsx   eax,w TextureY2[esi]    ; TxtY2 is start
        mov     TxtYstart,eax
        movsx   eax,w LightLevel2[esi]  ; I2 is start
        mov     Istart,eax

doText:

        ; Should we clip left?
        cmp     LeftSkip,0
        jz      noLeftClip
        mov     ebx,LeftSkip    ; Get pixels to skip
        sub     ecx,ebx         ; Get new width of line
        jle     noTextLine      ; Entire line outside screen

        mov     eax,ebx         ; Pixels in EAX
        imul    Zadder          ; *Zadder
        rol     eax,16
        add     Zstart,eax      ; Fix Zstart

        mov     eax,ebx         ; Pixels in EAX
        imul    TxtXadd         ; *TxtXadd
        rol     eax,16
        add     TxtXStart,eax   ; Fix start

        mov     eax,ebx         ; Pixels in EAX
        imul    TxtYadd         ; *TxtYadd
        rol     eax,16
        add     TxtYStart,eax   ; Fix start

        mov     eax,ebx         ; Pixels in EAX
        imul    Iadder          ; *Iadder
        rol     eax,16
        add     IStart,eax      ; Fix start

noLeftClip:

        ; Fix adders...
        mov     eax,Zadder
        mov     ebx,TxtXadd
        mov     w Zadder,bx               ; Set frac part of TxtXadd in Zadd
        mov     ebx,TxtYadd
        mov     w TxtXadd,bx
        mov     ebx,Iadder
        mov     w TxtYadd,bx
        mov     w Iadder,ax

        ; Make them shifted...
        mov     eax,Zadder
        rol     eax,16
;        mov     Zadder,eax
        mov     d[mud1-4],eax
        mov     eax,TxtXadd
        rol     eax,16
;        mov     TxtXadd,eax
        mov     d[mud2-4],eax
        mov     eax,TxtYadd
        rol     eax,16
;        mov     TxtYadd,eax
        mov     d[mud3-4],eax
        mov     eax,Iadder
        rol     eax,16
;        mov     Iadder,eax
        mov     d[mud4-4],eax

        push    esi
        push    ebp

        ; Get start values
        mov     esi,Zstart
        mov     eax,TxtXstart
        mov     ebx,TxtYstart
        mov     ebp,PicPointer
        mov     edx,Istart
        mov     ecx,LineWidth          ; Get (clipped) counter

doT:
        cmp     [edi],si        ; Check Z value
        jle     noText
        mov     [edi],si        ; Set new Z value

        ; Fetch colour from picture
        push    eax
        push    edx
        push    esi
        movzx   edx,dx
;        mov     esi,ShadeTable  ; Get the shade table
        mov     esi,ShadPt
        mov     dx,[esi+edx*2]    ; Get shade level
        mov     ah,bl           ; Y coord in upper part of AX
        movzx   eax,ax
        mov     al,[ebp+eax]    ; Get colour
        add     dl,al           ; Add to shade level
        mov     2[edi],dx       ; Store colour

        pop     esi
        pop     edx
        pop     eax
noText:
        add     edi,4
;        add     esi,Zadder
;        adc     eax,TxtXadd
;        adc     ebx,TxtYadd
;        adc     edx,Iadder
        add     esi,088888888h
mud1:   adc     eax,088888888h
mud2:   adc     ebx,088888888h
mud3:   adc     edx,088888888h
mud4:   adc     esi,0           ; Fix Z value
        dec     cx
        jnz     doT

        pop     ebp
        pop     esi

noTextLine:
        pop     edi
        pop     ecx
        jmp     chkLT
        endm


; This macro rotates a vector coord, using ObjAngles.
; ESI must point at X,Y,Z
ROTATECOORD macro
        local   wasrotated
;        mov     eax,[esi]               ; Get rotated coords
;        add     eax,4[esi]
;        add     eax,8[esi]              ; Determine if we have a rotated coord
;        jnz     wasrotated

        ; Rotate Z
        mov     eax,12[esi]             ; Get X
        mov     ecx,eax                 ; Remember X
        imul    ObjCosZ
        mov     ebx,16[esi]             ; Get Y
        imul    ebx,ObjSinZ
        sub     eax,ebx
        sar     eax,8
        mov     [esi],eax               ; Store new X
        imul    ecx,ObjSinZ
        mov     eax,16[esi]             ; Get Y again
        imul    ObjCosZ
        add     eax,ecx
        sar     eax,8
        mov     4[esi],eax              ; Store new Y

        ; Rotate Y
        mov     eax,[esi]               ; Get X
        mov     ecx,eax                 ; Remember X
        imul    ObjCosY
        mov     ebx,20[esi]             ; Get Z
        imul    ebx,ObjSinY
        sub     eax,ebx
        sar     eax,8
        mov     [esi],eax               ; Store new X
        imul    ecx,ObjSinY
        mov     eax,20[esi]             ; Get Z
        imul    ObjCosY
        add     eax,ecx
        sar     eax,8
        mov     8[esi],eax              ; Store new Z

        ; Rotate X
        mov     eax,8[esi]              ; Get Z
        mov     ecx,eax                 ; Remember Z
        imul    ObjCosX
        mov     ebx,4[esi]              ; Get Y
        push    ebx
        imul    ebx,ObjSinX
        sub     eax,ebx
        sar     eax,8
        mov     8[esi],eax              ; Store new Z
        imul    ecx,ObjSinX
        pop     eax                     ; Get Y
        imul    ObjCosX
        add     eax,ecx
        sar     eax,8
        mov     4[esi],eax              ; Store new Y

wasrotated:
        endm




;             ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;             ณษอออออออออออออออออออออออออออออออออออออออออออออออปณ
;             ณบษอออออออออออออออออออออออออออออออออออออออออออออปบณ
;             ณบบ                                             บบณ
;             ณบบ   OOOO OOOOOOOOO   OOOOO   OOOOO OOOOOOOOO  บบณ
;             ณบบ  OOOOOO OOOOOOOOO OOOOOOO OOOOOOO OOOOOOOOO บบณ
;             ณบบ  OOOO      OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ  OOOOOO    OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ   OOOOOO   OOO    OOOOOOO OOOOOO     OOO    บบณ
;             ณบบ     OOOO   OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ     OOOO   OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ OOOOOOOO   OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ  OOOOOO    OOO    OOO  OO OOO  OO    OOO    บบณ
;             ณบบ                                          :-)บบณ
;             ณบศอออออออออออออออออออออออออออออออออออออออออออออผบณ
;             ณศอออออออออออออออออออออออออออออออออออออออออออออออผณ
;             ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
;xxxxxxxxxxxxxxxxxxxxxxxxx
VVS:
;        mov     NrofRuns,2

        ; Set cols
        cmp     NrofRuns,0
        jnz     @@not0
        lea     esi,bitmap
        mov     b [esi],63        ; Set background
        mov     b 1[esi],0
        mov     b 2[esi],0
        jmp     @@ColsOK
@@not0: cmp     NrofRuns,1
        jnz     @@not1
        lea     esi,bitmap
        mov     b [esi],50        ; Set background
        mov     b 1[esi],63
        mov     b 2[esi],0
        mov     NumOfFadeCols,224*3

        ; Copy screen to buffer
        mov     eax,320*200
        call    getmem
        jc      AMS_Errorhandler
        mov     ScreenPic,eax
        move    esi,0a0000h
        mov     edi,eax
        mov     ecx,320*200/4
        rep     movsd
        jmp     @@colsOK
@@not1:
        lea     esi,bitmap
        mov     b [esi],0        ; Set background
        mov     b 1[esi],0
        mov     b 2[esi],0
        lea     esi,material1
        mov     b ShadingLevels[esi],256/8
        mov     w Levelsize[esi],3
        mov     NumOfFadeCols,256*3
        mov     SpecularFlag,1

@@colsOK:
        call    VVS_Init

        cmp     NrofRuns,0
        jnz     @@not0b
        lea     esi,object1
        mov     d ObjPosX[esi],1000
        mov     d ObjPosY[esi],0
        mov     d ObjPosZ[esi],0
        lea     eax,FlipTab3
        mov     FlipTabPtr,eax
        lea     edi,object1
        call    FlipNorms
        jmp     IncRuns
@@not0b:
        ; Second run
        cmp     NrofRuns,1
        jnz     @@not1b
        lea     esi,object1
        mov     d ObjPosX[esi],200
        mov     d ObjPosY[esi],50
        mov     d ObjPosZ[esi],1000
        mov     d ObjAngleX[esi],0
        mov     d ObjAngleY[esi],0
        mov     d ObjAngleZ[esi],0

        mov     Blur,0                  ; Blur off
        mov     ScreenZ,0280h           ; Set screen Z position
        lea     edi,object1
        call    FlipNorms               ; Flip back normals
        lea     eax,FlipTab2
        mov     FlipTabPtr,eax
        lea     edi,object1
        call    FlipNorms

        ; Enable second object
        lea     esi,objlist
        lea     edi,o1
        mov     [esi],edi               ; Set ptr to next object
        mov     eax,Object2ptr
        mov     8[edi],eax              ; Set object 2

        mov     edi,Object2ptr
        call    FlipNorms               ; Fix normals for object 2 too

        mov     esi,object2ptr
        mov     d ObjPosX[esi],0
        mov     d ObjPosY[esi],-1000
        mov     d ObjPosZ[esi],500

        mov     HiddenFaceOn,1          ; Enable hidden face

        jmp     IncRuns
@@not1b:

        ; Third run
        lea     esi,object1
        mov     d ObjPosX[esi],0
        mov     d ObjPosY[esi],1000
        mov     d ObjPosZ[esi],1100
        mov     d ObjAngleX[esi],0
        mov     d ObjAngleY[esi],0
        mov     d ObjAngleZ[esi],0
        lea     edi,object1
        call    FlipNorms               ; Flip back old normals
        lea     eax,FlipTab1
        mov     FlipTabPtr,eax
        lea     edi,object1
        call    FlipNorms

;        lea     esi,lght
;        mov     d LightPosX[esi],0
;        mov     d LightPosY[esi],0
;        mov     d LightPosZ[esi],-100


        ; Disable other object
        lea     esi,objlist
        mov     d[esi],0                ; Ptr to next obj
        lea     esi,o1
        mov     d 8[esi],0

        mov     ScreenZ,7fffh
        mov     Blur,0
        mov     ScreenPic,0

        mov     HiddenFaceOn,1

        ; *** Init object ***
        lea     esi,object1
        mov     esi,Polygons[esi]
@@nxtpoly:
        mov     w PolygonFlags[esi],Texture+Gouraud
        movzx   eax,w OffsNxtPolygon[esi]
        add     esi,eax
        cmp     eax,0
        jnz     @@nxtpoly


IncRuns:
        inc     NrOfRuns

MainLoop:
        call    VVS_Update       ; Update vectors
@@wttimer:cmp   TimerFlag,0
        jz      @@wttimer

;       in      al,60h
;       cmp     al,1
;       jz      quit

        cmp     ExitFlag,1
        jnz     MainLoop

;        cmp     DebugFlag,0
;        jnz     quit


Quit:
        ret


;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                       -+*+- VVS Initialization -+*+-                        บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

VVS_Init proc near
        pushad

        cmp     NrOfRuns,0
        jnz     @@skipalloc

        ; Alloc mem for sin+costable
        mov     eax,sinetab_length*5
        call    GetMem
        jc      AMS_Errorhandler
        mov     SinTab,eax
        add     eax,sinetab_length
        mov     costab,eax
        call    generate_taylor_sinetab


        ; Alloc mem for Z buffer
        movzx   eax,ScreenWidth
        movzx   ebx,ScreenHeight
        mul     ebx
        shl     eax,2                   ; Each pixel in the buffer is 4 bytes
        call    GetMem
        jc      AMS_Errorhandler
        mov     Zbufferptr,eax
        mov     edi,eax

        ; Allocate memory for the PolygonBuffer
        movzx   eax,ScreenHeight
        shl     eax,5                   ; Each buffer line is 32 bytes
        call    GetMem
        jc      AMS_Errorhandler
        mov     PolygonBuffer,eax

        ;*** INIT Materials (Should be done while loading them) ***

        ; Allocate memory for a shading table
        mov     eax,256*2       ; Alloc 128 words
        call    GetMem
        jc      AMS_Errorhandler
        add     eax,128*2
        mov     ShadPt,eax

        ; *** Init object(s) ***

        ; Create second object
        mov     eax,Object1end-Object1  ; Size of object
        mov     ecx,eax                 ; Store in ECX
        call    getmem
        jc      AMS_Errorhandler
        mov     edi,eax                 ; Object2
        mov     Object2ptr,eax
        lea     esi,object1
        rep     movsb

        ; Set pointers in object 1
        lea     esi,Object1
        add     Polygons[esi],esi       ; Add start addr to offset
        add     GouraudPtr[esi],esi
        mov     ebp,Gouraudptr[esi]

        add     [ebp],esi               ; Fix Connectlist ptr

        ; Fix connectlist
        mov     ebp,GouraudPtr[esi]     ; Get pointer to Gouraud struc
        mov     ebp,[ebp]               ; Get pointer to connectlist
        mov     ecx,ObjPoints[esi]
@@nxtcon:
        push    ecx
        mov     ecx,[ebp]               ; Get nr of connections
@@nxtconB:
        add     ebp,4
        mov     edi,[ebp]             ; Get offs
        add     edi,esi                 ; Point at expand struc ptr
        add     edi,ExpandStruc[edi]     ; Add expand struc to ptr
        mov     [ebp],edi             ; Store ptr to expand struc

        loop    @@nxtconB
        add     ebp,4
        pop     ecx
        loop    @@nxtcon


        ; Fix expand struc ptrs and material ptrs in all polys
        lea     eax,Material1
        mov     ecx,ShadPt
        mov     ebp,Polygons[esi]
@@nxtpoly:
        add     ExpandStruc[ebp],ebp
        mov     edi,ExpandStruc[ebp]
        mov     Material[edi],eax       ; Store ptr to material
;        mov     ShadingTable[eax],ecx
        movzx   ebx,w OffsNxtPolygon[ebp]
        add     ebp,ebx
        cmp     ebx,0
        jnz     @@nxtpoly

        ; Set pointers in object 2
        mov     esi,Object2ptr
        add     Polygons[esi],esi       ; Add start addr to offset
        add     GouraudPtr[esi],esi
        mov     ebp,Gouraudptr[esi]

        add     [ebp],esi               ; Fix Connectlist ptr

        ; Fix connectlist
        mov     ebp,GouraudPtr[esi]     ; Get pointer to Gouraud struc
        mov     ebp,[ebp]               ; Get pointer to connectlist
        mov     ecx,ObjPoints[esi]
@@nxtcon2:
        push    ecx
        mov     ecx,[ebp]               ; Get nr of connections
@@nxtconB2:
        add     ebp,4
        mov     edi,[ebp]             ; Get offs
        add     edi,esi                 ; Point at expand struc ptr
        add     edi,ExpandStruc[edi]     ; Add expand struc to ptr
        mov     [ebp],edi             ; Store ptr to expand struc

        loop    @@nxtconB2
        add     ebp,4
        pop     ecx
        loop    @@nxtcon2


        ; Fix expand struc ptrs and material ptrs in all polys
        lea     eax,Material1
        mov     ecx,ShadPt
        mov     ebp,Polygons[esi]
@@nxtpoly2:
        add     ExpandStruc[ebp],ebp
        mov     edi,ExpandStruc[ebp]
        mov     Material[edi],eax       ; Store ptr to material
;        mov     ShadingTable[eax],ecx
        movzx   ebx,w OffsNxtPolygon[ebp]
        add     ebp,ebx
        cmp     ebx,0
        jnz     @@nxtpoly2

@@skipalloc:

        mov     edi,ShadPt      ; Shading table in EDI
        lea     esi,Material1   ; Material in ESI
        call    InitMaterial

        ; Clear and init Polygon buffer
        mov     esi,ZbufferPtr
        mov     ebp,ScreenPic
        cmp     ebp,0
        jnz     @@putpic

        ; Clear Polygon buffer
        xor     bx,bx
        mov     dx,ScreenZ
        mov     ecx,320*200
@@nxtpixelB:
        mov     [esi],dx
        mov     2[esi],bx
        add     esi,4
        dec     ecx
        jnz     @@nxtpixelB
        jmp     @@cleaned

        ; Put pixels on screen and put screen pic at the same time
@@putpic:
;        move    edi,0a0000h
        xor     bx,bx
        mov     dx,ScreenZ
        mov     ecx,320*200
@@nxtpixel:
;        mov     ax,[esi]                ; Get colour
        mov     bl,[ebp]
        mov     2[esi],bx                ; Set pixel from screenpic
        mov     [esi],dx
        add     esi,4
        inc     ebp
;        mov     [edi],al
;        inc     edi
        dec     ecx
        jnz     @@nxtpixel

@@cleaned:

        ; Init coprocessor
        finit

@@ut:   popad
        ret
        endp

FlipTabPtr      dd      0

; Texture+Gouraud
FlipTab1 db      1,1,-1,-1,-1,-1
         db      -1,-1,-1,-1,1,1
         db      0

; Gouraud
FlipTab2 db      1,1,-1,-1,-1,1
         db      1,-1,-1,-1,1,1
         db      0


; Flower
FlipTab3 db      1,1,-1,-1,-1,1
         db      1,-1,-1,-1,1
         db      0

; EDI=Object
FlipNorms proc  near
        pushad

        ; Flip some normals...
        mov     edi,Polygons[edi]
        mov     esi,FlipTabPtr
@@nxtfejs:
        cmp     b[esi],-1
        jnz     @@noflip
        mov     ebp,ExpandStruc[edi]
        neg     d FaceNormalX[ebp]
        neg     d FaceNormalY[ebp]
        neg     d FaceNormalZ[ebp]
@@noflip:
        inc     esi
        cmp     b[esi],0
        jnz     @@notend
        mov     esi,FlipTabPtr
@@notend:
        movzx   eax,w OffsNxtPolygon[edi]
        add     edi,eax
        cmp     eax,0
        jnz     @@nxtfejs
        popad
        ret
        endp


;                       -+*+- Initialize Material -+*+-
; ESI-Material   EDI-Shading Table
InitMaterial proc near
        pushad
        movzx   ax,b Ambience[esi]      ; Get ambience
        mov     TempAmb,ax
        movzx   ax,b Reflection[esi]    ; Get reflection
        mov     TempRefl,ax
        movzx   ax,b BaseColour[esi]    ; Get base colour
        mov     TempBC,ax
        movzx   eax,b ShadingLevels[esi] ; Get shading levels
        shl     eax,16                  ; *10000h
        cdq

        mov     ecx,128         ; Create 128 shading levels
        idiv    ecx             ; Level adder is now in EAX
        rol     eax,16
        xor     ebx,ebx         ; Current level

@@nxtLevel:
        push    ecx
        mov     dx,bx           ; Level in DX
        mov     cx,LevelSize[esi]       ; Get levelsize
        shl     dx,cl                   ; Fix levelsize
;        add     dx,TempBC               ; Add basecolour
        mov     [edi],dx                ; Store it in Shading Table

        add     ebx,eax         ; Increase level
        adc     ebx,0

        add     edi,2
        pop     ecx
        loop    @@nxtLevel

        ; Calculate palette
;        movzx   eax,TempBC      ; Get basecolour
;        lea     eax,[eax+eax*2] ; *3
;        add     edi,eax         ; Point at basecolour palette entry

        movzx   ecx,w LevelSize[esi]             ; Get levelsize
        mov     edx,1
        shl     edx,cl                  ; Shift to get colours in one level        mov     ecx,eax

        mov     ecx,edx                 ; Nr of colours in each level
        lea     edx,[edx+edx*2]         ; *3
        mov     TempLevSize,edx

        movzx   ebx,b ShadingLevels[esi]        ; Get shading levels
        mov     eax,4096
        xor     edx,edx
        div     ebx
        mov     TempStep,eax

        lea     ebp,palette
        mov     edx,ebx
        xor     ecx,ecx
@@nxtlevel2:

        lea     edi,bitmap      ; This is the bitmap palette
        push    edx
        mov     edx,TempLevSize
@@nxtcolor:
        push    edx
        mov     ebx,SinTab              ;cos tab ptr
        mov     ebx,[ebx+ecx*4+12288*4]        ;cos value
        add     ebx,256
        movzx   eax,b [edi]             ;diffuse
        imul    ebx                     ;diffuse*cos(x)
        push    eax
        movzx   eax,TempRefl            ;specular
        cmp     SpecularFlag,0
        jz      @@noxtra
        imul    ebx,ebx
        sar     ebx,8
@@noxtra:
        imul    ebx                     ;specular*cos(x)
        pop     ebx
        add     eax,ebx                 ;diffuse*cos(x)+specular*cos(x)
        sar     eax,8                   ;/256
        add     ax,TempAmb              ;ambient+diffuse*cos(x)+specular*cos(x)
        adc     eax,0
        cmp     al,63                   ;max?
        jbe     @@nochange
        mov     al,63
@@nochange:
        mov     [ebp],al                ;col
        inc     ebp
        inc     edi

        pop     edx
        dec     edx
        jnz     @@nxtcolor

        add     ecx,TempStep
        pop     edx
        dec     edx
        jnz     @@nxtlevel2

        ; Set the new palette
if SETPALETTE eq 1
        lea     esi,palette
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        movzx   ecx,NumOfFadeCols
@@setpal:lodsb
        out     dx,al
        nop
        loop    @@setpal
endif

        popad
        ret
        endp

NumOfFadeCols   dw      256*3
TempAmb dw      0
TempRefl dw     0
TempBC  dw      0
TempStep        dd      0

TempLevSize     dd      0

RedAdd  dd      0
GreenAdd dd     0
BlueAdd dd      0

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                            -+*+- VVS Main -+*+-                             บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

VVS_Update proc    near
        pushad

        call    UpdateCamera
        call    DoObjects

        call    RenderObjects
        call    DrawScreen

        popad
        ret
        endp

;-------------------------------------------------------------------------------
;                         -+*+- Process Objects -+*+-
;-------------------------------------------------------------------------------
DoObjects proc near
        pushad
        mov     esi,objectlistptr       ; Get pointer to first object in list
        cmp     esi,0                   ; No objects?
        jz      @@ut

@@nxtobj:
        mov     edi,ObjectPtr[esi]      ; Get object from list
        call    ResetObject
        call    RotateObject

        call    LightObject

        mov     esi,NxtListObj[esi]     ; Any more objects in the list?
        cmp     esi,0
        jnz     @@nxtobj

@@ut:
        popad
        ret
        endp

;                           -+*+- Reset Object -+*+-
; EDI=Ptr to object
ResetObject proc near
        pushad
        lea     ebp,Points[edi]         ; Get point struc
        xor     eax,eax
        mov     ebx,24
        mov     ecx,ObjPoints[edi]      ; Get nr of points in object
@@nxtpoint:
        mov     [ebp],eax               ; Reset all rotated coords
        mov     4[ebp],eax
        mov     8[ebp],eax
        add     ebp,ebx
        loop    @@nxtpoint

        popad
        ret
        endp

;                         -+*+- Enlighten object -+*+-
; EDI=ptr to object
LightObject proc near
        pushad

        mov     ebp,Polygons[edi]       ; Get polygon struc

@@nxtPoly:
        push    ebp                     ; Remember Polygon struc

        ; Check if polygon needs light
        mov     ax,PolygonFlags[ebp]
;        mov     TempFlags,ax
;        test    ax,Lambert
;        jnz     @@lightPoly
;        test    ax,Gouraud
;        jnz     @@lightPoly
;        test    ax,Phong
;        jz      @@NoLight

@@lightPoly:
        mov     ebp,ExpandStruc[ebp]    ; Get EXPAND structure
        mov     d LightIntensity[ebp],0   ; Clear old intensity

        mov     esi,LightStructure      ; Get pointer to lights
        mov     ecx,NrOfLights
@@nxtlight:
        push    ecx
        push    esi
;        mov     ax,LightGroup[esi]      ; Get light group
;        cmp     ax,ObjLightGroup[edi]   ; Same as the object light group?
;        jnz     @@LightOK

;        mov     ax,LightFlags[esi]      ; Check light flags
;
;        test    ax,Omni                 ; Omni light?
;        jnz     @@doOmni

;        jmp     @@LightOK               ; Unknown light type, so let's exit

        ; *** OMNI Light ***
@@doOmni:

        ; Translate light
        mov     eax,LightPosX[esi]
;        sub     eax,ObjPosX[edi]
;        sub     eax,ParentPosX[edi]
        mov     LightTempX,eax

        mov     eax,LightPosY[esi]
;        sub     eax,ObjPosY[edi]
;        sub     eax,ParentPosY[edi]
        mov     LightTempY,eax

        mov     eax,LightPosZ[esi]
;        sub     eax,ObjPosZ[edi]
;        sub     eax,ParentPosZ[edi]
        mov     LightTempZ,eax

        ; Calculate unit vector of light
        fild    LightTempX
        fimul   LightTempX      ; ^2
        fild    LightTempY
        fimul   LightTempY      ; ^2
        fadd                    ; Add X^2 and Y^2 together and pop
        fild    LightTempZ
        fimul   LightTempZ      ; ^2
        fadd                    ; And add Z^2
        fsqrt                   ; Get length of vector
        fistp   LightVecLen

        mov     ebx,LightVecLen
        cmp     ebx,0
        jz      @@LightOK       ; Light was at object pivot point=Fault

        mov     eax,LightTempX
        shl     eax,15          ; *8000h
        cdq
        idiv    ebx             ; X/Vector Length
        mov     LightTempX,eax  ; Store new X

        mov     eax,LightTempY
        shl     eax,15          ; *8000h
        cdq
        idiv    ebx             ; Y/Vector length
        mov     LightTempY,eax

        mov     eax,LightTempZ
        shl     eax,15          ; *8000h
        cdq
        idiv    ebx             ; Z/Vector length
        mov     LightTempZ,eax

        ; * Rotate normal *

        ; Rotate Z
        mov     eax,FaceNormalX[ebp]    ; Get X
        mov     ecx,eax                 ; Remember X
        imul    ObjCosZ                 ; This is still here...
        mov     ebx,FaceNormalY[ebp]    ; Get Y
        imul    ebx,ObjSinZ
        sub     eax,ebx
        sar     eax,8
        mov     RotFaceNormalX[ebp],eax         ; Store new X
        imul    ecx,ObjSinZ
        mov     eax,FaceNormalY[ebp]    ; Get Y again
        imul    ObjCosZ
        add     eax,ecx
        sar     eax,8
        mov     RotFaceNormalY[ebp],eax         ; Store new Y

        ; Rotate Y
        mov     eax,RotFaceNormalX[ebp]         ; Get X
        mov     ecx,eax                 ; Remember X
        imul    ObjCosY
        mov     ebx,FaceNormalZ[ebp]    ; Get Z
        imul    ebx,ObjSinY
        sub     eax,ebx
        sar     eax,8
        mov     RotFaceNormalX[ebp],eax         ; Store new X
        imul    ecx,ObjSinY
        mov     eax,FaceNormalZ[ebp]    ; Get Z
        imul    ObjCosY
        add     eax,ecx
        sar     eax,8

        ; Rotate X
        mov     ecx,eax                 ; Remember Z
        imul    ObjCosX
        mov     ebx,RotFaceNormalY[ebp]         ; Get Y
        push    ebx
        imul    ebx,ObjSinX
        sub     eax,ebx
        sar     eax,8
        mov     RotFaceNormalZ[ebp],eax         ; Store new Z
        imul    ecx,ObjSinX
        pop     eax                     ; Get Y
        imul    ObjCosX
        add     eax,ecx
        sar     eax,8
        mov     RotFaceNormalY[ebp],eax         ; Store new Y

        ; Calculate Dot Product
        mov     eax,RotFaceNormalX[ebp]
        imul    LightTempX
        mov     ebx,RotFaceNormalY[ebp]
        imul    ebx,LightTempY
        mov     ecx,RotFaceNormalZ[ebp]
        imul    ecx,LightTempZ
        sar     eax,15
        sar     ebx,15
        sar     ecx,15
        add     eax,ebx
        add     eax,ecx
        sar     eax,8           ; Convert to 0-128 (128 is max intensity)

;        cmp     eax,0           ; Check if it's negative
;        jge     @@notneg

;        test    TempFlags,WrapNormal    ; Wrap normal?
;        jz      @@no

;        neg     eax             ; Invert normal
;        jmp     @@notneg
;@@no:
;        xor     eax,eax         ; Make normal=0
;@@notneg:

;        add     eax,eax
        add     eax,LightIntensity[ebp] ; Add old intensity
        cmp     eax,128
        jl      @@notabove
        mov     eax,127
@@notabove:
        mov     LightIntensity[ebp],eax ; Store light intensity

@@LightOK:
        pop     esi
        mov     esi,NxtLight[esi]       ; Get next light
        pop     ecx
        loop    @@nxtlight

@@NoLight:
        pop     ebp                             ; Get back polygon struc

        ; Check hidden face (old way)
;        and     w PolygonFlags[ebp],not PolyVisible
;        cmp     eax,0
;        jl      @@notvisible
        or      w PolygonFlags[ebp],PolyVisible

        cmp     HiddenFaceOn,0
        jz      @@nohidden

        ; Check if face is visible (New way)
        and     w PolygonFlags[ebp],not PolyVisible
        push    esi
        mov     esi,ExpandStruc[ebp]    ; Get expand struc
        cmp     d RotFaceNormalZ[ebp],0
        jl      @@notvisible
        or      w PolygonFlags[ebp],PolyVisible
@@notvisible:
        pop     esi
@@nohidden:

        movzx   eax,w OffsNxtPolygon[ebp]       ; Get next poly
        add     ebp,eax                        ;ÿÿOffset to next poly
        cmp     eax,0
        jnz     @@nxtPoly



        ; *** Is there any Gouraud shading in the object? ***
;        mov     ax,ObjFlags[edi]
;        test    ax,ObjGouraud
;        jz      @@noGouraud

        ; Then we'll calculate some mean normals...
        mov     esi,GouraudPtr[edi]     ; Get pointer to Gouraud struc
        mov     edi,ConnectList[esi]    ; Get connectlist
        add     esi,4
@@nxtGPoly:

        mov     ecx,[edi]               ; Get nr of connections
        cmp     ecx,0                   ; End of list?
        jz      @@noGouraud
        add     edi,4
        mov     ebx,ecx                 ; Save them in EBX
        xor     eax,eax                 ; Intensity
@@nxtConnection:
        mov     ebp,[edi]               ; Get pointer to expand struc
        add     eax,LightIntensity[ebp] ; Add intensity
        add     edi,4
        loop    @@nxtConnection

        cdq
        idiv    ebx             ; Calc mean value
        mov     [esi],eax       ; Store mean value
        add     esi,4
        jmp     @@nxtGPoly

@@noGouraud:
        popad
        ret
        endp

;TempFlags       dw      0

;                          -+*+- Rotate Object -+*+-
; EDI=ptr to object
RotateObject proc near
        pushad

        ; Get sinus and cosinus for all angles
        mov     esi,SinTab              ; Get sintable
        mov     ebp,CosTab              ; Get costable

        movzx   ebx,w ObjAngleX[edi]      ; Get angle X for object
        lea     ebx,[ebx*4]
        mov     eax,[esi+ebx]
        mov     ObjSinX,eax
        mov     eax,[ebp+ebx]
        mov     ObjCosX,eax

        movzx   ebx,w ObjAngleY[edi]      ; Get angle Y for object
        lea     ebx,[ebx*4]
        mov     eax,[esi+ebx]
        mov     ObjSinY,eax
        mov     eax,[ebp+ebx]
        mov     ObjCosY,eax

        movzx   ebx,w ObjAngleZ[edi]      ; Get angle Z for object
        lea     ebx,[ebx*4]
        mov     eax,[esi+ebx]
        mov     ObjSinZ,eax
        mov     eax,[ebp+ebx]
        mov     ObjCosZ,eax

; ***************** SKIP THIS CONSTANT CALCULATION *******************
comment |
        ; Calculate constants for X rotation
        mov     eax,ObjCosY
        mov     ebx,eax         ; Remember ObjCosY
        imul    ObjCosZ
        sar     eax,15
        mov     Const1,eax

        imul    ebx,ObjSinZ
        sar     ebx,15
        mov     Const2,ebx

        mov     eax,ObjSinY
        mov     Const3,eax

        ; Calculate constants for Y rotation
        mov     ebx,ObjCosX
        imul    ebx,ObjSinZ
        sar     ebx,15
        mov     eax,ObjSinX
        imul    ObjSinY
        sar     eax,15
        imul    ObjCosZ
        sar     eax,15
        add     eax,ebx
        mov     Const4,eax

        mov     eax,ObjSinX
        imul    ObjSinY
        sar     eax,15
        imul    ObjSinZ
        sar     eax,15
        mov     ebx,ObjCosX
        imul    ebx,ObjCosZ
        sar     ebx,15
        sub     eax,ebx
        mov     Const5,eax

        mov     eax,ObjSinX
        imul    ObjCosY
        sar     eax,15
        neg     eax
        mov     Const6,eax

        ; Calculate constants for Z rotation
        mov     eax,ObjSinX
        imul    ObjSinZ
        sar     eax,15
        mov     ebx,ObjCosX
        imul    ebx,ObjSinY
        sar     ebx,15
        imul    ebx,ObjCosZ
        sar     ebx,15
        sub     eax,ebx
        mov     Const7,eax

        mov     eax,ObjSinX
        neg     eax
        imul    ObjCosZ
        sar     eax,15
        mov     ebx,ObjCosX
        imul    ebx,ObjSinY
        sar     ebx,15
        imul    ebx,ObjSinZ
        sar     ebx,15
        sub     eax,ebx
        mov     Const8,eax

        mov     eax,ObjCosX
        imul    ObjCosY
        sar     eax,15
        mov     Const9,eax
|


        ; Find Point structure and Polygon structure
        lea     esi,Points[edi]         ; Get Point structure
        mov     ebp,Polygons[edi]       ; Get Polygon structure

        mov     eax,ObjPosX[edi]
        mov     TempPosX,eax
        mov     eax,ObjPosY[edi]
        mov     TempPosY,eax
        mov     eax,ObjPosZ[edi]
        mov     TempPosZ,eax

@@nxtPoly:
        push    ebp
        movzx   ecx,w NrOfPoints[ebp]     ; Get number of points in polygon

        push    edi                     ; Remember Object structure
        lea     edi,VectorPoint1[ebp]   ; Point at vector points

@@nxtPoint:
        push    ecx
        mov     ebx,[edi]               ; Get Vectorpoint nr
        add     edi,4
        push    esi                     ; Remember Point structure
        lea     esi,[esi+ebx]           ; ESI points at current X,Y,Z

        ROTATECOORD

        ; Convert to 2d
        mov     ebx,8[esi]              ; Get Z
        add     ebx,TempPosZ
        mov     8[esi],ebx
        add     ebx,Distance            ; Add distance from camera to viewpoint
        mov     eax,[esi]               ; Get X
        add     eax,TempPosX
        mov     [esi],eax

        mov     ecx,LensSize
        shl     eax,cl                  ; *Depth
        cdq
        idiv    ebx                     ; /Z+dist
        add     eax,160
        mov     [esi],eax               ; Store 2d X

        mov     eax,4[esi]              ; Get Y
        add     eax,TempPosY
        mov     4[esi],eax

        shl     eax,cl
        cdq
        idiv    ebx                     ; /Z+dist
        add     eax,100
        mov     4[esi],eax              ; Store 2d Y

        pop     esi
        pop     ecx
        loop    @@nxtPoint

        pop     edi

        pop     ebp             ; Get back Polygon structure

        movzx   eax,w OffsNxtPolygon[ebp]       ; Get offset to next polygon
        add     ebp,eax
        cmp     eax,0
        jnz     @@nxtPoly

@@PolyOK:

@@ut:
        popad
        ret
        endp

ObjSinX         dd      0
ObjCosX         dd      0
ObjSinY         dd      0
ObjCosY         dd      0
ObjSinZ         dd      0
ObjCosZ         dd      0
Const1          dd      0
Const2          dd      0
Const3          dd      0
Const4          dd      0
Const5          dd      0
Const6          dd      0
Const7          dd      0
Const8          dd      0
Const9          dd      0

TempPosX        dd      0
TempPosY        dd      0
TempPosZ        dd      0

;-------------------------------------------------------------------------------
;                          -+*+- Render Objects -+*+-
;-------------------------------------------------------------------------------
RenderObjects proc near
        pushad

        mov     esi,objectlistptr       ; Get pointer to first object in list
        cmp     esi,0                   ; No objects?
        jz      @@ut

@@nxtobj:
        mov     edi,ObjectPtr[esi]      ; Get object from list

        ; Render object in Zbuffer
        pushad

        ; Find Point structure and Polygon structure
        lea     esi,Points[edi]         ; Get Point structure

        mov     ebp,Polygons[edi]       ; Get polygon struc

@@nxtPoly:
        push    ebp                     ; Remember Polygon structure
        push    edi

        ; Clear Polygon Buffer
        push    esi
        mov     esi,PolygonBuffer
        mov     eax,4
        mov     cx,200
@@clrit:mov     [esi],eax
        add     esi,32
        dec     cx
        jnz     @@clrit
        pop     esi

        mov     ax,PolygonFlags[ebp]    ; Get flags

        ; Check if polygon is visible
        test    ax,PolyVisible
        jz      @@PolyOK

        ; Test the supported light types...
        test    ax,Gouraud              ; Check Gouraud
        jz      @@noGouraud

        test    ax,Texture
        jnz     @@GouraudTxtPoly

        test    ax,Fill
        jnz     @@GouraudFillPoly

@@noGouraud:

        ; If we reach this point, there was no supported polygon type chosen
        ; so we proceed to the next one...
        jmp     @@PolyOK


        ; *** Make GOURAUD TEXTURED poygon ***
@@GouraudTxtPoly:
        movzx   ecx,w NrOfPoints[ebp]   ; Get number of points in polygon

        mov     eax,GouraudPtr[edi]     ; Get Gouraud struc
        add     eax,4
        mov     TempGStruc,eax

        lea     edi,VectorPoint1[ebp]   ; Point at first vector point
        mov     ebx,[edi]
        mov     FirstPoint,ebx

        mov     ebp,ExpandStruc[ebp]    ; Get EXPAND structure

        movzx   ebx,w Edges[ebp]        ; Get first X edge
        mov     FirstedgeX,ebx          ; Store it
        movzx   ebx,w Edges+2[ebp]      ; Get first Y edge
        mov     FirstedgeY,ebx          ; Store it too

        push    esi
        mov     esi,Material[ebp]       ; Get pointer to material
        lea     eax,bitmap
;        mov     eax,BitmapData[esi]     ; Get pointer to bitmapdata
        mov     PicPointer,eax
        mov     eax,ShadingTable[esi]
        mov     ShadeTable,eax
        pop     esi


        sub     ecx,1                   ; Last line we connect ourselves

@@nxtGTextPoint:
        push    ecx

        mov     eax,[edi]               ; Get first Vectorpoint nr
        mov     ebx,4[edi]              ; Get second Vectorpoint nr
        add     edi,4

        ; Find Intensity for the two points
        push    eax
        push    ebx
        push    ebp
        mov     ecx,6                   ; Divide with 6
        mov     ebp,TempGStruc          ; Get pointer to gouraud struc
        cdq
        idiv    ecx                     ; First point/6
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity,eax       ; And store it
        mov     eax,ebx                 ; Second point in EAX
        cdq
        idiv    ecx                     ; Second point/6
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity2,eax      ; And store it
        pop     ebp
        pop     ebx
        pop     eax

        push    edi
        push    esi
        lea     edi,[esi+ebx]           ; EDI points at X2,Y2,Z2
        lea     esi,[esi+eax]           ; ESI points at X1,Y1,Z1

        ; Get texture edges...
        movzx   eax,w Edges[ebp]        ; Get X edge for point 1
        movzx   ebx,w Edges+2[ebp]      ; Get Y edge for point 1
        mov     X1edge,eax
        mov     Y1edge,ebx
        movzx   eax,w Edges+4[ebp]      ; Get X edge for point 2
        movzx   ebx,w Edges+6[ebp]      ; Get Y edge for point 2
        mov     X2edge,eax
        mov     Y2edge,ebx
        add     ebp,4

        DRAWGOURAUDTEXT            ; Draw a line for gouraud texture polygons

        pop     esi
        pop     edi

        pop     ecx
        loop    @@nxtGTextPoint

        ; Do the last line too...
        mov     eax,[edi]               ; Get last point
        mov     ebx,Firstpoint          ; Connect with first point

        ; Find Intensity for the two points
        push    eax
        push    ebx
        push    ebp
        mov     ecx,6                   ; Divide with 6
        mov     ebp,TempGStruc          ; Get pointer to gouraud struc
        cdq
        idiv    ecx                     ; First point/6
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity,eax       ; And store it
        mov     eax,ebx                 ; Second point in EAX
        cdq
        idiv    ecx                     ; Second point/6
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity2,eax      ; And store it
        pop     ebp
        pop     ebx
        pop     eax

        push    esi
        lea     edi,[esi+ebx]           ; EDI points at X2,Y2,Z2
        lea     esi,[esi+eax]           ; ESI points at X1,Y1,Z1

        movzx   eax,w Edges[ebp]        ; Get X edge for last point
        movzx   ebx,w Edges+2[ebp]      ; Get Y edge for last point
        mov     X1edge,eax
        mov     Y1edge,ebx
        mov     eax,FirstEdgeX          ; Get first edge again
        mov     ebx,FirstEdgeY
        mov     X2edge,eax
        mov     Y2edge,ebx

        DRAWGOURAUDTEXT

        ; Draw Textured polygon in Z-buffer

        GOURAUDTEXTFILLPOLY


        ; *** Make GOURAUD FILLED polygon ***
@@GouraudFillPoly:
        movzx   ecx,w NrOfPoints[ebp]   ; Get number of points in polygon

        mov     eax,GouraudPtr[edi]     ; Get Gouraud struc to EAX

        lea     edi,VectorPoint1[ebp]   ; Point at vector points
        mov     ebx,[edi]
        mov     FirstPoint,ebx          ; Store first point

        push    esi
        mov     ebp,ExpandStruc[ebp]    ; Get EXPAND structure
        mov     esi,Material[ebp]       ; Get pointer to material
        mov     ebx,ShadingTable[esi]   ; Get pointer to shadingtable
        mov     ShadeTable,ebx
        pop     esi

        mov     ebp,eax                 ; Gouraud ptr in EBP
        add     ebp,4                   ; Skip ConnectList

        sub     ecx,1                   ; Last line we connect ourselves

@@nxtGFillPoint:
        push    ecx
        mov     eax,[edi]               ; Get first Vectorpoint nr
        mov     ebx,4[edi]              ; Get second Vectorpoint nr
        add     edi,4

        ; Find Intensity for the two points
        push    eax
        push    ebx
        mov     ecx,6                   ; Divide with 6
        cdq
        idiv    ecx                     ; First point/3
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity,eax       ; And store it
        mov     eax,ebx                 ; Second point in EAX
        cdq
        idiv    ecx                     ; Second point/3
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity2,eax      ; And store it
        pop     ebx
        pop     eax

        push    edi
        push    esi
        lea     edi,[esi+ebx]           ; EDI points at X2,Y2,Z2
        lea     esi,[esi+eax]           ; ESI points at X1,Y1,Z1

        ; We draw a line in the PolygonBuffer using these two coords

        DRAWGOURAUD

        pop     esi
        pop     edi

        pop     ecx
        loop    @@nxtGFillPoint

        ; Do the last line too...
        push    esi                     ; Remember point structure
        mov     eax,[edi]               ; Get last vector point
        mov     ebx,FirstPoint
        lea     edi,[esi+ebx]           ; Point at X2,Y2,Z2
        lea     esi,[esi+eax]           ; And at X1,Y1,Z1

        ; Find Intensity for the two points
        push    eax
        push    ebx
        mov     ecx,6                   ; Divide with 6
        cdq
        idiv    ecx                     ; First point/3
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity,eax       ; And store it
        mov     eax,ebx                 ; Second point in EAX
        cdq
        idiv    ecx                     ; Second point/3
        mov     eax,[ebp+eax]           ; Get intensity for point
        mov     TempIntensity2,eax      ; And store it
        pop     ebx
        pop     eax

        DRAWGOURAUD

        ; Draw Gouraud shaded filled polygon in Z buffer

        GOURAUDFILLPOLY

@@PolyOK:

        pop     edi
        pop     ebp                     ; Get back polygon structure

        movzx   eax,w OffsNxtPolygon[ebp]
        add     ebp,eax                 ; Add offset
        cmp     eax,0
        jnz     @@nxtPoly

        popad

        ; Hoppa till nxtObject hr
        mov     esi,NxtListObj[esi]     ; Any more objects?
        cmp     esi,0
        jnz     @@nxtobj

@@ut:
        popad
        ret
        endp


Xadder  dd      0
Zadder  dd      0
TxtXadd dd      0
TxtYadd dd      0
Iadder  dd      0

X1edge  dd      0
Y1edge  dd      0
X2edge  dd      0
Y2edge  dd      0

Xstart          dd      0
Zstart          dd      0
TxtXstart       dd      0
TxtYstart       dd      0
Istart          dd      0

FirstPoint      dd      0               ; First vec point in the polygon
FirstedgeX      dd      0
FirstedgeY      dd      0

TempIntensity   dd      0               ; Temp intensity used in Lambert/Gouraud
TempIntensity2  dd      0               ; Temp intensity used in Gouraud
TempGStruc      dd      0               ; Temporary Gouraud struc pointer

PicPointer      dd      0               ; Pointer to the RAW bitmap data
ShadeTable      dd      0               ; Pointer to shading table

;-------------------------------------------------------------------------------
;                          -+*+- Update Camera -+*+-
;-------------------------------------------------------------------------------
UpdateCamera proc near
        pushad

        mov     esi,CurrentCamera

        ; * Camera Z *

        ; Check current octant
        mov     eax,ViewpointPosX[esi]  ; Get Viewpoint
        sub     eax,CameraPosX[esi]     ; Sub with camera
        jg      @@Zoct14                ; Are we in octant 1 or 4?
        neg     eax
        mov     Xdiff,eax               ; Store X difference

        mov     eax,ViewPointPosY[esi]
        sub     eax,CameraPosY[esi]
        jl      @@Zoct2                 ; Are we in oct 2?
        cmp     Xdiff,0                 ; If Xdiff is zero, we're in oct 4
        jz      @@Zoct4
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,3                   ; Set octant nr
        jmp     @@octOK
@@Zoct2:
        neg     eax                     ; We think we're in oct 2
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,2                   ; Set octant nr
        jmp     @@octOK

@@Zoct14:
        mov     Xdiff,eax               ; Store X difference

        mov     eax,ViewPointPosY[esi]
        sub     eax,CameraPosY[esi]
        jle     @@Zoct1                 ; Are we in octant 1?
@@Zoct4:
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,4                   ; Set octant nr
        jmp     @@octOK

@@Zoct1:
        neg     eax                     ; We know that we are in octant 4
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,1                   ; Set octant nr


@@octOK:

        ; Calc length from Camera to Viewpoint
        mov     eax,Xdiff
        mov     ebx,eax         ; X diff in ebx
        mul     eax
        mov     ecx,eax         ; X diff^2 in ecx
        mov     eax,Ydiff
        mul     eax
        add     eax,ecx         ; X^2+Y^2
        jz      @@ZeroZ

        mov     Cam2VPLen,eax
        fild    Cam2VPLen       ; Load coprocessor
        fsqrt
        fistp   Cam2VPLen

        mov     eax,ebx         ; X diff in eax
        shl     eax,16          ; *10000h
        cdq
        mov     ebx,Cam2VPLen
        idiv    ebx
        mov     CosWorldAngleZ,eax

        mov     eax,Ydiff
        shl     eax,16
        cdq
        idiv    ebx
        mov     SinWorldAngleZ,eax

        ; Put angle in correct octant
        cmp     oct,4
        jnz     @@Znot4
        neg     SinWorldAngleZ
        jmp     @@AngleOKZ
@@Znot4:cmp     oct,3
        jnz     @@Znot3
        neg     SinWorldAngleZ
        neg     CosWorldAngleZ
        jmp     @@AngleOKZ
@@Znot3:cmp     oct,2
        jnz     @@AngleOKZ
        neg     CosWorldAngleZ
@@AngleOKZ:


        ; * Camera X *
@@calcX:

        ; Check current octant
        mov     eax,ViewpointPosZ[esi]  ; Get Viewpoint
        sub     eax,CameraPosZ[esi]     ; Sub with camera
        jg      @@Xoct14                ; Are we in octant 1 or 4?
        neg     eax
        mov     Zdiff,eax               ; Store Z difference

        mov     eax,ViewPointPosY[esi]
        sub     eax,CameraPosY[esi]
        jl      @@Xoct2                 ; Are we in oct 2?
        cmp     Zdiff,0                 ; If Zdiff is zero, we're in oct 4
        jz      @@Xoct4
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,3                   ; Set octant nr
        jmp     @@XoctOK
@@Xoct2:
        neg     eax
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,2                   ; Set octant nr
        jmp     @@XoctOK

@@Xoct14:
        mov     Zdiff,eax               ; Store X difference
        mov     eax,ViewPointPosY[esi]
        sub     eax,CameraPosY[esi]
        jle     @@Xoct1                 ; Are we in octant 1?
@@Xoct4:
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,4                   ; Set octant nr
        jmp     @@XoctOK

@@Xoct1:
        neg     eax                     ; We know that we are in octant 4
        mov     Ydiff,eax               ; Store Y difference
        mov     Oct,1                   ; Set octant nr


@@XoctOK:

        ; Calc length from Camera to Viewpoint
        mov     eax,Zdiff
        mov     ebx,eax         ; Z diff in ebx
        mul     eax
        mov     ecx,eax         ; Z diff^2 in ecx
        mov     eax,Ydiff
        mul     eax
        add     eax,ecx         ; Z^2+Y^2
        jz      @@ZeroX

        mov     Cam2VPLen,eax
        fild    Cam2VPLen       ; Load coprocessor
        fsqrt
        fistp   Cam2VPLen

        mov     eax,ebx         ; Z diff in eax
        shl     eax,16          ; *10000h
        cdq
        mov     ebx,Cam2VPLen
        idiv    ebx
        mov     CosWorldAngleX,eax

        mov     eax,Ydiff
        shl     eax,16
        cdq
        idiv    ebx
        mov     SinWorldAngleX,eax

        ; Put angle in correct octant
        cmp     oct,4
        jnz     @@Xnot4
        neg     SinWorldAngleX
        jmp     @@AngleOKX
@@Xnot4:cmp     oct,3
        jnz     @@Xnot3
        neg     SinWorldAngleX
        neg     CosWorldAngleX
        jmp     @@AngleOKX
@@Xnot3:cmp     oct,2
        jnz     @@AngleOKX
        neg     CosWorldAngleX
@@AngleOKX:



        ; * Camera Y *
@@calcY:

        ; Check current octant
        mov     eax,ViewpointPosX[esi]  ; Get Viewpoint
        sub     eax,CameraPosX[esi]     ; Sub with camera
        jg      @@Yoct14                ; Are we in octant 1 or 4?
        neg     eax
        mov     Xdiff,eax               ; Store X difference

        mov     eax,ViewPointPosZ[esi]
        sub     eax,CameraPosZ[esi]
        jl      @@Yoct2                 ; Are we in oct 2?
        cmp     Xdiff,0                 ; If Xdiff is zero, we're in oct 4
        jz      @@Yoct4
        mov     Zdiff,eax               ; Store Y difference
        mov     Oct,3                   ; Set octant nr
        jmp     @@YoctOK
@@Yoct2:
        neg     eax                     ; We think we're in oct 2
        mov     Zdiff,eax               ; Store Z difference
        mov     Oct,2                   ; Set octant nr
        jmp     @@YoctOK

@@Yoct14:
        mov     Xdiff,eax               ; Store X difference

        mov     eax,ViewPointPosZ[esi]
        sub     eax,CameraPosZ[esi]
        jle     @@Yoct1                 ; Are we in octant 1?
@@Yoct4:
        mov     Zdiff,eax               ; Store Z difference
        mov     Oct,4                   ; Set octant nr
        jmp     @@YoctOK

@@Yoct1:
        neg     eax                     ; We know that we are in octant 4
        mov     Zdiff,eax               ; Store Z difference
        mov     Oct,1                   ; Set octant nr


@@YoctOK:

        ; Calc length from Camera to Viewpoint
        mov     eax,Xdiff
        mov     ebx,eax         ; X diff in ebx
        mul     eax
        mov     ecx,eax         ; X diff^2 in ecx
        mov     eax,Zdiff
        mul     eax
        add     eax,ecx         ; X^2+Z^2
        jz      @@ZeroY

        mov     Cam2VPLen,eax
        fild    Cam2VPLen       ; Load coprocessor
        fsqrt
        fistp   Cam2VPLen

        mov     eax,ebx         ; X diff in eax
        shl     eax,16          ; *10000h
        cdq
        mov     ebx,Cam2VPLen
        idiv    ebx
        mov     CosWorldAngleY,eax

        mov     eax,Zdiff
        shl     eax,16
        cdq
        idiv    ebx
        mov     SinWorldAngleY,eax

        ; Put angle in correct octant
        cmp     oct,1
        jnz     @@Ynot1
        neg     SinWorldAngleY
        jmp     @@AngleOKY
@@Ynot1:cmp     oct,3
        jnz     @@Ynot3
        neg     CosWorldAngleY
        jmp     @@AngleOKY
@@Ynot3:cmp     oct,2
        jnz     @@AngleOKY
        neg     SinWorldAngleY
        neg     CosWorldAngleY
@@AngleOKY:


        jmp     @@calcOK

@@ZeroZ:mov     SinWorldAngleZ,0
        mov     CosWorldAngleZ,10000h
        jmp     @@calcX
@@ZeroX:mov     SinWorldAngleX,0
        mov     CosWorldAngleX,10000h
        jmp     @@calcY
@@ZeroY:mov     SinWorldAngleY,0
        mov     CosWorldAngleY,10000h

@@calcOK:

        ; * Calculate length from Camera to Viewpoint in 3d space *
        mov     eax,Xdiff
        mul     eax             ; Xdiff^2
        mov     ebx,eax
        mov     eax,Ydiff
        mul     eax             ; Ydiff^2
        add     ebx,eax
        mov     eax,Zdiff
        mul     eax             ; Zdiff^2
        add     ebx,eax

        mov     Cam2VPLen,eax

        fild    Cam2VPLen       ; Load coprocessor
        fsqrt
        fistp   Distance

@@ut:
        popad
        ret
        endp


;-------------------------------------------------------------------------------
;                           -+*+- Draw Screen -+*+-
;-------------------------------------------------------------------------------
DrawScreen proc near
        pushad
        cmp     Blur,0
        jnz     @@blurpic
        cmp     ScreenPic,0
        jnz     @@putpic

        move    edi,0a0000h
        mov     esi,ZbufferPtr
        add     esi,2                   ; Point at first colour

        ; Put pixels on screen and clear buffer at the same time
        xor     bx,bx
        mov     dx,ScreenZ
        mov     ecx,320*200
@@nxtpixel:
        mov     ax,[esi]                ; Get colour
        mov     [esi],bx                ; Clear colour
        mov     -2[esi],dx
        add     esi,4
        mov     [edi],al
        inc     edi
        dec     ecx
        jnz     @@nxtpixel
        jmp     @@snut

        ; Blur pic
@@blurpic:
        move    edi,0a0000h
        mov     esi,ZbufferPtr
        add     esi,2                   ; Point at first colour

        ; Put pixels on screen and clear buffer at the same time
        xor     bx,bx
        mov     dx,ScreenZ
        mov     ecx,320*200
@@nxtpixel3:
        mov     ax,[esi]                ; Get colour
        cmp     ax,8
        jle     @@noblur
        sub     w[esi],8
        jmp     @@blurOK
@@noblur:xor    ax,ax
@@blurOK:
        mov     -2[esi],dx
        add     esi,4
        mov     [edi],al
        inc     edi
        dec     ecx
        jnz     @@nxtpixel3
        jmp     @@snut

@@putpic:
        move    edi,0a0000h
        mov     esi,ZbufferPtr
        add     esi,2                   ; Point at first colour
        mov     ebp,ScreenPic

        ; Put pixels on screen and put screen pic at the same time
        xor     bx,bx
        mov     dx,ScreenZ
        mov     ecx,320*200
@@nxtpixel2:
        mov     ax,[esi]                ; Get colour
        mov     bl,[ebp]
        mov     [esi],bx                ; Set pixel from screenpic
        mov     -2[esi],dx
        add     esi,4
        inc     ebp
        mov     [edi],al
        inc     edi
        dec     ecx
        jnz     @@nxtpixel2

@@snut:
        popad
        ret
        endp

; Pointer to screen bitmap or zero
ScreenPic       dd      0
ScreenZ         dw      00000h  ; 7fff = No clipping
Blur            dw      1

; GENERATE SINE & COSINE LOOKUP-TABLE USING TAYLOR'S APPROXIMATION
; - fixed point integer math: 02b.30b

SINETAB_LENGTH  equ 16384          ;number of DWords sinetab will consist of
;----------------------------------

GENERATE_TAYLOR_SINETAB proc      ;GENERATE SINETABLE
        mov ebp,40000000h          ;ebp = 1.0
        xor esi,esi                ;variable x
        xor ecx,ecx                  ;index for destination in table

@@01:   push ecx                   ;calculate taylor's approximation for both
        mov sinvalue,esi          ;sines and cosines
        mov cosvalue,ebp
        xor edi,edi
        inc edi
@@02:   call @@sub
        sub cosvalue,eax
        call @@sub
        sub sinvalue,eax
        call @@sub
        add cosvalue,eax
        call @@sub
        add sinvalue,eax
        cmp edi,13
        jne @@02
        pop ecx

        mov eax,sinvalue          ;convert to *256
        sar eax,22
        mov ebx,cosvalue
        sar ebx,22
;        lea di,sinetab
        mov     edi,sintab
        add edi,ecx
        mov [edi]+(sinetab_length/4*0)*4,eax
        mov [edi]+(sinetab_length/4*1)*4,ebx
        mov [edi]+(sinetab_length/4*4)*4,eax
        sub edi,ecx
        sub edi,ecx
        mov [edi]+(sinetab_length/4*2)*4,eax
        mov [edi]+(sinetab_length/4*1)*4,ebx
        mov [edi]+(sinetab_length/4*5)*4,ebx
        neg eax
        neg ebx
        mov [edi]+(sinetab_length/4*4)*4,eax
        mov [edi]+(sinetab_length/4*3)*4,ebx
        add edi,ecx
        add edi,ecx
        mov [edi]+(sinetab_length/4*2)*4,eax
        mov [edi]+(sinetab_length/4*3)*4,ebx

;        add esi,1921f6h           ;next x value (pi/(sintab_length/8*4)*2^30)
        add     esi,6487fh
        add ecx,4
        cmp ecx,(sinetab_length/8)*4
        jbe @@01
        ret

@@sub:  inc edi                    ;EAX <- x ^ (++count) / (count!)
        mov eax,ebp
        xor ebx,ebx
        inc bx
        mov ecx,edi
@@sub@1:imul esi
        shrd eax,edx,30
        imul ebx,ecx
        loop @@sub@1
        cdq
        idiv ebx
        ret
GENERATE_TAYLOR_SINETAB endp

; GENERATE SINE & COSINE LOOKUP-TABLE USING TAYLOR'S APPROXIMATION
; - fixed point integer math: 02b.30b

SINETAB_LENGTH2 equ 4096           ;number of DWords sinetab will consist of
;----------------------------------

GENERATE_TAYLOR_SINETAB2 proc      ;GENERATE SINETABLE
        mov ebp,40000000h          ;ebp = 1.0
        xor esi,esi                ;variable x
        xor ecx,ecx                  ;index for destination in table

@@01:   push ecx                   ;calculate taylor's approximation for both
        mov sinvalue,esi          ;sines and cosines
        mov cosvalue,ebp
        xor edi,edi
        inc edi
@@02:   call @@sub
        sub cosvalue,eax
        call @@sub
        sub sinvalue,eax
        call @@sub
        add cosvalue,eax
        call @@sub
        add sinvalue,eax
        cmp edi,13
        jne @@02
        pop ecx

        mov eax,sinvalue          ;convert to 65536
        sar eax,14
        mov ebx,cosvalue
        sar ebx,14
;        lea di,sinetab2
        mov     edi,sintab2
        add edi,ecx
        mov [edi]+(sinetab_length2/4*0)*4,eax
        mov [edi]+(sinetab_length2/4*1)*4,ebx
        mov [edi]+(sinetab_length2/4*4)*4,eax
        sub edi,ecx
        sub edi,ecx
        mov [edi]+(sinetab_length2/4*2)*4,eax
        mov [edi]+(sinetab_length2/4*1)*4,ebx
        mov [edi]+(sinetab_length2/4*5)*4,ebx
        neg eax
        neg ebx
        mov [edi]+(sinetab_length2/4*4)*4,eax
        mov [edi]+(sinetab_length2/4*3)*4,ebx
        add edi,ecx
        add edi,ecx
        mov [edi]+(sinetab_length2/4*2)*4,eax
        mov [edi]+(sinetab_length2/4*3)*4,ebx

        add esi,1921f6h           ;next x value (pi/(sintab_length/8*4)*2^30)
;        add     esi,6487fh
        add ecx,4
        cmp ecx,(sinetab_length2/8)*4
        jbe @@01
        ret

@@sub:  inc edi                    ;EAX <- x ^ (++count) / (count!)
        mov eax,ebp
        xor ebx,ebx
        inc bx
        mov ecx,edi
@@sub@1:imul esi
        shrd eax,edx,30
        imul ebx,ecx
        loop @@sub@1
        cdq
        idiv ebx
        ret
GENERATE_TAYLOR_SINETAB2 endp

if DebugStuff eq 1
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.
;-------------------------------------------------------------------------------
; ***************************** DEBUGGING TOOLS *******************************
;-------------------------------------------------------------------------------
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.

; Convert number in a register to decimal value...
; Put number in register EAX.
ConvNr  proc    near
        pushad

        lea     edi,AsciiNr

        mov     b [edi],'('
        inc     edi

        cmp     eax,0
        jge     @@notneg
        neg     eax
        mov     b [edi],'-'
        inc     edi
@@notneg:
        mov     ebx,1000000000
        mov     ecx,10
@@conv:
        push    eax
        cdq
        div     ebx
        add     al,'0'
        stosb
        sub     al,'0'
        mul     ebx
        mov     ebp,eax
        mov     eax,ebx
        cdq
        div     ecx
        mov     ebx,eax
        pop     eax
        sub     eax,ebp
        cmp     ebx,0
        jnz     @@conv

        mov     b [edi],')'
        mov     b [edi+1],'$'

        popad
        ret
        endp

; Convert number in a register to hexdeciaml value...
; Put number in register EAX.
HexNr   proc    near
        pushad
        lea     edi,AsciiNr
        mov     b [edi],'('
        inc     edi

        mov     ebx,10000000h
        mov     ecx,10h
@@conv:
        push    eax
        xor     edx,edx
        div     ebx
        cmp     al,0ah
        jge     @@hexletter

        add     al,'0'
        stosb
        sub     al,'0'
        jmp     @@hexOK
@@hexletter:
        add     al,'A'-10
        stosb
        sub     al,'A'-10

@@hexOK:
        mul     ebx
        mov     ebp,eax
        mov     eax,ebx
        cdq
        div     ecx
        mov     ebx,eax
        pop     eax
        sub     eax,ebp
        cmp     ebx,0
        jnz     @@conv

        mov     b [edi],'H'
        mov     b [edi+1],')'
        mov     b [edi+2],'$'

        popad
        ret
        endp

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;Locates the cursor
;Calls: Dh=Row, Dl=Column
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Locate  Proc    Near
        Pusha
        mov     v86r_bx,0
        mov     v86r_dx,dx
        mov     v86r_ah,2
        mov     al,10h
        int     33h
        Popa
        Ret
Locate  Endp

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;Prints a text in textmode
;Calls: ESI = Offset to  text
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;PrintText       Proc    Near
;        Pushad
;        mov     edx,esi
;        add     edx,_code32a
;        ror     edx,4
;        mov     V86R_DS,dx
;        shr     edx,28
;        mov     V86R_DX,dx
;        mov     V86R_AH,9
;        mov     al,21h
;        int     33h
;        Popad
;        Ret
;PrintText       EndP

AsciiNr db      40       dup(0)         ; 40 chars should be enough

; ************************** End of Debugging Tools ***************************
endif


;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                           -+*+- Variables -+*+-                             บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

HiddenFaceOn    dw      0
SpecularFlag    dw      0

DebugFlag       dw      0

Syncspast       dd      1       ; Should be updated by the timer

; * Pointers *
SinTab          dd      0               ; Points at sinus table
CosTab          dd      0               ; And this is the cosinus table
ZBufferPtr      dd      0               ; Points at the Z buffer
CurrentCamera   dd      Cam             ; Points at the current active camera
LensSize        dd      8               ; 2^LensSize is the depth
PolygonBuffer   dd      0

SinValue        dd      0
CosValue        dd      0

Cam2VPlen       dd      0
Xdiff           dd      0
Ydiff           dd      0
Zdiff           dd      0
Oct             dw      0

PolygonCol      dw      0
NrOfRuns        dw      0

; Clipping coords
ClipLeft        dd      1
ClipRight       dd      318
ClipUp          dd      1
ClipDown        dd      198
LeftSkip        dd      0
UpSkip          dd      0
LineWidth       dd      0
LineHeight      dd      0

SinWorldAngleX  dd      0       ; Sinus for World Angles
SinWorldAngleY  dd      0
SinWorldAngleZ  dd      0
CosWorldAngleX  dd      0       ; Cosinus for World Angles
CosWorldAngleY  dd      0
CosWorldAngleZ  dd      0

Distance        dd      0       ; Distance from Camera to Viewpoint

ScreenWidth     dw      320
ScreenHeight    dw      200

Object2ptr      dd      0

LightTempX      dd      0
LightTempY      dd      0
LightTempZ      dd      0
LightVecLen     dd      0

NrOfLights      dd      1       ; Used for loop counter

WorldStructure  dd      WS      ; Internal Pointer to current World Structure
LightStructure  dd      Lght    ; Internal Pointer to a lightsource list
ObjectListPtr   dd      ObjList ; Internal Pointer to the list of objects

CurrNormal      dd      0
;NormalFlipsPtr  dd      NormalFlips
TempNormalX     dd      0
TempNormalY     dd      0
TempNormalZ     dd      0
AmountCounter   dd      0

Palette label
        db      256*3   dup(0)  ; Place for palette

        ;       *** WORLD STRUCTURE ***

WS      dd      1               ; Nr of cameras

        ;       *** Camera structure ***

Cam     dd      Lght            ; Pointer to next camera, light or object
        dd      0               ; Attach camera
        dd      0               ; Attach viewpoint
        dd      0               ; Camera pos X
        dd      0               ; Camera pos Y
        dd      -800            ; Camera pos Z
        dd      0               ; Viewpoint pos X
        dd      0               ; Viewpoint pos Y
        dd      0               ; Viewpoint pos Z

        ;       *** Camera struc end ***

        dd      1             ; Nr of lights (Must be stored in NrOfLights too)

        ;       *** Light structure ***
Lght    dd      Object1         ; Pointer to next light, or object
        dd      0               ; Attach light
        dd      0               ; Attach hotspot
        dd      0               ; Position X
        dd      0               ; Position Y
        dd      -100            ; Position Z
        dd      0               ; Hotspot X
        dd      0               ; Hotspot Y
        dd      0               ; Hotspot Z
        dw      0               ; Light group
        dw      Omni            ; Light flags

        ;       *** Light struc end ***

        dd      1               ; Nr of objects

        ;       *** Object structure ***

Object1 label
        include torus.inc
Object1end:

        ;       *** Material structure ***
Material1 dd    0               ; Size of the material struc (only for loading)
        dw      256             ; Width
        dw      200             ; Height
        db      0               ; Ambience
        db      63              ; Reflection (Max 63)
        db      0               ; BaseColour
        db      128             ; ShadingLevels
        dw      0               ; LevelSize (2^Levelsize=NrOfColours in bitmap)
        dd      Bitmap+768      ; Pointer to raw bitmap
shadpt  dd      0               ; Pointer to a shading table


;                           -+*+- Object List -+*+-

; This linked list will be created in the initialization process, and is used
; when sorting objects.

ObjList:
        dd      0              ; Pointer to next object in the list
        dd      0               ; Pointer to previous object in the list
        dd      Object1         ; Pointer to object
        dd      0               ; Minimum Z in object (not used now)

o1      dd      0               ; Pointer to next object in the list
        dd      0               ; Pointer to previous object in the list
        dd      0               ; Pointer to object
        dd      0               ; Minimum Z in object (not used now)

Bitmap  label
;        db      0,0,0           ; 3 bytes for gouraud colour
;        include Bitmap.inc
        include amber.inc


