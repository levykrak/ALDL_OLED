'-----------------------------------------------------------------------------------------
'name                     : rs232buffer.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : example shows the difference between normal and buffered
'                           serial INPUT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

'$sim
'dziala

$regfile = "m328def.dat"
$crystal = 16000000
$hwstack = 80
$swstack = 90
$framesize = 100
$baud = 8192

'first compile and run this program with the line below remarked
'Config Serialin = Buffered , Size = 66
Open "coma.0:9600,8,n,1" For Output As #1

$lib "i2c_twi.lbx"                                          'Hardware I2C
Config Scl = Portc.0                                        ' used i2c pins
Config Sda = Portc.1
Config Twi = 400000                                         ' i2c speed
I2cinit
'*******************************************************************************
'
'
Config Portc.2 = Output                                     'DISPLAY_Reset
Lcd_rst Alias Portc.2
'*******************************************************************************
'Declare Subs
Declare Sub Lcd_init()
Declare Sub Lcd_comm_out(byval Comm As Byte)
Declare Sub Lcd_clear(byval Colo As Byte)
Declare Sub Lcd_show()
Declare Sub Lcd_text(byval S As String , Byval Xoffset As Byte , Byval Yoffset As Byte , Byval Fontset As Byte)
Declare Sub Lcd_set_pixel(byval Xp As Byte , Byval Yp As Byte , Byval Colo As Byte)
Declare Sub Lcd_fill_circle(byval X0 As Byte , Byval Y0 As Byte , Byval Radius As Byte , Byval Color1 As Byte )
Declare Sub Lcd_line(byval X1 As Byte , Byval Y1 As Byte , Byval X2 As Byte , Byval Y2 As Byte , Byval Pen_width As Byte , Byval Color As Byte)
Declare Sub Lcd_show_bgf(byval Xs As Byte , Byval Ys As Byte)
Const White = &HFF
Const Black = &H00
Const Dlugosc_wskazowki_gruba = 45
Const Dlugosc_wskazowki_cienka = 10
'Const Dlugosc_wskazowki_cienka = Dlugosc_wskazowki_gruba + Dlugosc_wskazowki_gruba
Dim Ddata(1024) As Byte                                     'Display Data Buffer
'*******************************************************************************
'Init Display -- SSD1306 oder Treiber IC SH1106 wird häufig als Ersatz geliefert.
Const Driver_typ = 1                                        'SSD1306 =1   SH1106 =0
Call Lcd_init()                                             'Init Display
'*******************************************************************************
'*******************************************************************************

Dim Zab As Single
Dim X As Byte
Dim X_cienka As Byte
Dim X_1 As Byte , X_2 As Byte
Dim Y As Byte
Dim Y_cienka As Byte
Dim Y_1 As Byte , Y_2 As Byte
Dim X_single As Single
Dim Y_single As Single
Dim Rad As Single
Dim Text11 As String * 20

Dim Aldl_recv(66) As Byte
Dim Suma_kontrolna As Byte , I As Byte , R As Byte
Dim Zezwolenie As Byte

Const Aldl_size_page0 = 65                                  'wielkosc pakietu dla page 0 +1
Const Aldl_size_page1 = 51                                  'wielkosc pakietu dla page 1 +1
On Urxc Uart_rx
Enable Interrupts


Ucsrb.txen = 1                                              'wlaczamy wysylanie
Ucsrb.rxen = 0                                              'wylaczamy odbieranie


Wait 3
Print #1 , "Start"
Zezwolenie = 10


Do

   Waitms 100
   If Zezwolenie = 10 Then
      Disable Urxc
      Ucsrb.txen = 1                                           'wlaczamy wysylanie
      Ucsrb.rxen = 0                                        'wylaczamy odbieranie
      Printbin &HF4 ; &H56 ; &H08 ; &HAE;                      'wylaczamy standardowa komunikacje
      Printbin &HF4 ; &H57 ; &H01 ; &H00 ; &HB4;               'page 0
      Ucsrb.txen = 0                                           'wlaczamy wysylanie
      Ucsrb.rxen = 1                                           'wylaczamy odbieranie
      I = 0
      Enable Urxc
      Zezwolenie = Aldl_size_page0
   Elseif Zezwolenie = 0 Then
      Suma_kontrolna = 0
      For R = 2 To Aldl_size_page0                          'Aldl_size
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(r)
         'Print #1 , Hex(aldl_recv(r)) ; " ";
         'Waitms 10
      Next
      If Aldl_recv(2) = &HF4 And Suma_kontrolna = 0 Then    'And Aldl_recv(66) = Suma_kontrolna Then
         Print #1 , "mode 0: ";
         For R = 2 To 65                                       'Aldl_size
         'Incr R
            Print #1 , Hex(aldl_recv(r)) ; " ";
            Waitms 10
         Next
         Print #1 , "suma:" ; Suma_kontrolna
      End If
      Zezwolenie = 11

   Elseif Zezwolenie = 11 Then

      Disable Urxc
      Ucsrb.txen = 1                                           'wlaczamy wysylanie
      Ucsrb.rxen = 0                                        'wylaczamy odbieranie
      Printbin &HF4 ; &H56 ; &H08 ; &HAE;                   'wylaczamy standardowa komunikacje
      Printbin &HF4 ; &H57 ; &H01 ; &H01 ; &HB3;            'page 0
      Ucsrb.txen = 0                                        'wlaczamy wysylanie
      Ucsrb.rxen = 1                                        'wylaczamy odbieranie
      I = 0
      Enable Urxc
      Zezwolenie = Aldl_size_page1

   Elseif Zezwolenie = 1 Then
      Suma_kontrolna = 0
      For R = 2 To Aldl_size_page1                          'Aldl_size
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(r)
         'Print #1 , Hex(aldl_recv(r)) ; " ";
         'Waitms 10
      Next
      If Aldl_recv(2) = &HF4 And Suma_kontrolna = 0 Then      'And Aldl_recv(66) = Suma_kontrolna Then
         Print #1 , "mode 1: ";
         For R = 2 To 51                                       'Aldl_size
         'Incr R
            Print #1 , Hex(aldl_recv(r)) ; " ";
            Waitms 10
         Next
         Print #1 , "suma:" ; Suma_kontrolna
      End If
      Zezwolenie = 10

   End If




Loop




Uart_rx:

   Aldl_recv(i) = Udr
   If Zezwolenie = Aldl_size_page0 And I = Zezwolenie Then
      Zezwolenie = 0
      Disable Urxc
   Elseif Zezwolenie = Aldl_size_page1 And I = Zezwolenie Then
      Zezwolenie = 1
      Disable Urxc
   End If

   Incr I
Return

'*******************************************************************************
'*******************************************************************************
'include used fonts
'$include "My6_8.font"
'$include "My12_16.font"
'$include "Digital20x32.font"                                'Font nur Zahlen Punkt und Komma
'include used BGF
'$inc Pic , Nosize , "BGF\abc.bgf"                           '32x32 pixel
'$inc Pic1 , Nosize , "BGF\time.bgf"                         '32x32 Pixel
'$inc Pic2 , Nosize , "BGF\music.bgf"                        '32x32 Pixel
'$inc Wskaznik , Nosize , "BGF\wskaznik.bgf"                 '32x32 Pixel
'$inc Test , Nosize , "BGF\test.bgf"                         '32x32 Pixel
'Routines
'*******************************************************************************
' Show BASCOM Graphic Files (BGF)
' use the Graphic converter in Uncompressed Mode
' The Sub do not support RLE compression
' Set Xs=Start Xpoint  Ys=Start Ypoint
'*******************************************************************************
Sub Lcd_show_bgf(byval Xs As Byte , Byval Ys As Byte)
   Dbg
   Local Xz As Byte , Yz As Byte , Col As Byte
   Local Bnr As Byte , Xdum As Byte , Xend As Byte , Yend As Byte
   Read Yend                                                'Read Height
   Read Xend                                                'Read Width
   Yend = Yend + Ys                                         'Set end point
   Xend = Xend + Xs                                         'Set end point
   Decr Xend
   Decr Yend
   For Yz = Ys To Yend                                      'Ystart to Yend
      For Xz = Xs To Xend Step 8                            'Step 8 Pixel for one Byte
         Read Col                                           'Read BGF file 1Byte = 8 Pixel
         Xdum = Xz                                          'X Start Point
         For Bnr = 7 To 0 Step -1                           'MSB first Set 8Bit
            If Col.bnr = 1 Then                             'Read pixel
               Call Lcd_set_pixel(xdum , Yz , White)        'Set Pixel
            Else
               Call Lcd_set_pixel(xdum , Yz , Black)        'Clear Pixel
            End If
            Incr Xdum                                       'Incr X pointer
         Next
      Next
   Next
End Sub
'*******************************************************************************
' Set or Clear a Pixel to X-Y Position  White= Set Pixel  Black= Clear Pixel
' and write Data to Display-Array
'*******************************************************************************
Sub Lcd_set_pixel(byval Xp As Byte , Byval Yp As Byte , Byval Colo As Byte)
   Dbg
   Local B1 As Byte , Zeiger As Word , Bitnr As Byte
   Decr Yp
   B1 = Yp / 8
   Zeiger = B1 * 128
   Zeiger = Zeiger + Xp
   Bitnr = Yp Mod 8
   If Colo = Black Then
      Ddata(zeiger).bitnr = 0
   Else
      Ddata(zeiger).bitnr = 1
   End If
End Sub
'*******************************************************************************
' Updated the Display whith Display-Array
'*******************************************************************************
Sub Lcd_show()
   Dbg
   Local Page As Byte , Zab1 As Byte , Zab2 As Byte
   Local Point As Word
   Point = 1
   Page = &HB0                                              'Page Address + 0xB0
   Call Lcd_comm_out(&H40)                                  'Display start address + 0x40
   For Zab1 = 0 To 7
      Call Lcd_comm_out(page)                               'send page address
      Call Lcd_comm_out(&H10)                               'column address upper 4 bits + 0x10
      #if Driver_typ = 1
         Call Lcd_comm_out(&H00)                            'column address lower 4 bits + 0x00    H02 for SH1106
      #else
         Call Lcd_comm_out(&H02)
      #endif
      I2cstart                                              'start condition
      I2cwbyte &H78                                         'slave address
      I2cwbyte &H40
      For Zab2 = 1 To 128                                   '128 columns wide
         I2cwbyte Ddata(point)
         Incr Point
      Next
      I2cstop
      Incr Page                                             'after 128 columns, go to next page
   Next
End Sub
'*******************************************************************************
' Clear Display and Display-Array
'*******************************************************************************
Sub Lcd_clear(byval Colo As Byte)
   Dbg
   Local Page As Byte , Zab1 As Byte , Zab2 As Word
   Page = &HB0                                              'Page Address + 0xB0
   Call Lcd_comm_out(&H40)                                  'Display start address + 0x40
   For Zab1 = 0 To 7
      Call Lcd_comm_out(page)                               'send page address
      Call Lcd_comm_out(&H10)                               'column address upper 4 bits + 0x10
      #if Driver_typ = 1
         Call Lcd_comm_out(&H00)                            'column address lower 4 bits + 0x00 H02 for SH1106
      #else
         Call Lcd_comm_out(&H02)
      #endif
      I2cstart                                              'start condition
      I2cwbyte &H78                                         'slave address
      I2cwbyte &H40
      For Zab2 = 1 To 128                                   '128 columns wide
         I2cwbyte Colo
      Next
      I2cstop
      Incr Page                                             'after 128 columns, go to next page
   Next
   For Zab2 = 1 To 1024
      Ddata(zab2) = 0                                       'Clear Display Data Buffer
   Next
End Sub
'*******************************************************************************
' Send Command to SSD1306
'*******************************************************************************
Sub Lcd_comm_out(byval Comm As Byte)
   Dbg
   I2cstart                                                 'start condition
   I2cwbyte &H78                                            'slave address
   I2cwbyte &H00
   I2cwbyte Comm
   I2cstop
End Sub
'*******************************************************************************
' Init the Driver SSD1306
'*******************************************************************************
Sub Lcd_init()
   Dbg
   Lcd_rst = 0
   Waitms 100                                               'Reset Display
   Lcd_rst = 1
   Waitms 100
   Call Lcd_comm_out(&Hae)                                  'DISPLAYOFF
   Call Lcd_comm_out(&Hd5)                                  'SETDISPLAYCLOCKDIV
   Call Lcd_comm_out(&H80)                                  'ratio 0x80
   Call Lcd_comm_out(&Ha8)                                  'SETMULTIPLEX
   Call Lcd_comm_out(&H3f)                                  '  1f 128x32
   Call Lcd_comm_out(&Hd3)                                  'SETDISPLAYOFFSET
   Call Lcd_comm_out(&H00)
 '  Call Lcd_comm_out(&H40)                                  'SETSTARTLINE
   Call Lcd_comm_out(&H8d)                                  'CHARGEPUMP
   Call Lcd_comm_out(&H14)                                  'vccstate 14
   Call Lcd_comm_out(&H20)                                  'MEMORYMODE
   Call Lcd_comm_out(&H00)                                  '
   Call Lcd_comm_out(&Ha1)                                  'SEGREMAP  a0
   Call Lcd_comm_out(&Hc8)                                  'COMSCANDEC
   Call Lcd_comm_out(&Hda)                                  'SETCOMPINS
   Call Lcd_comm_out(&H12)                                  ' 02 128x32  12
   Call Lcd_comm_out(&H81)                                  'SETCONTRAST
   Call Lcd_comm_out(255)                                   'value 1-->256
   Call Lcd_comm_out(&Hd9)                                  'SETPRECHARGE
   Call Lcd_comm_out(&Hf1)                                  'vccstate  f1
   Call Lcd_comm_out(&Hdb)                                  'SETVCOMDETECT
 '  Call Lcd_comm_out(&H40)                                  '
   Call Lcd_comm_out(&Ha4)                                  'DISPLAYALLON_RESUME
   Call Lcd_comm_out(&Ha6)                                  'NORMALDISPLAY
   Call Lcd_comm_out(&Haf)
   Waitms 100
End Sub
'*******************************************************************************
'LCD_Text  String -- X -- Y Start -- Font
'*******************************************************************************
Sub Lcd_text(byval S As String , Xoffset As Byte , Yoffset As Byte , Fontset As Byte)
   Dbg
   Local Tempstring As String * 1 , Temp As Word
   Local Pixels As Byte , Count As Byte , Carcount As Byte
   Local Row As Byte , Block As Byte , Byteseach As Byte , Blocksize As Byte
   Local Colums As Byte , Columcount As Byte , Rowcount As Byte , Stringsize As Byte
   Local Xpos As Byte , Ypos As Byte , Pixel As Byte , Pixelcount As Byte
   Local Offset As Word
   Stringsize = Len(s) - 1                                  'Size of the text string -1 because we must start with 0
   Select Case Fontset
      Case 1 :
         Block = Lookup(0 , My6_8)                          'Add or remove here fontset's that you need or not,
         Byteseach = Lookup(1 , My6_8)
         Blocksize = Lookup(2 , My6_8)
         Pixel = Lookup(3 , My6_8)
      Case 2 :
         Block = Lookup(0 , My12_16)
         Byteseach = Lookup(1 , My12_16)
         Blocksize = Lookup(2 , My12_16)
         Pixel = Lookup(3 , My12_16)
      Case 3 :
         Block = Lookup(0 , Digital20x32)
         Byteseach = Lookup(1 , Digital20x32)
         Blocksize = Lookup(2 , Digital20x32)
         Pixel = Lookup(3 , Digital20x32)
   End Select
   Colums = Blocksize / Block                               'Calculate the numbers of colums
   Row = Block * 8                                          'Row is always 8 pixels high = 1 byte, so working with row in steps of 8.
   Row = Row - 1                                            'Want to start with row=0 instead of 1
   Colums = Colums - 1                                      'Same for the colums
   For Carcount = 0 To Stringsize                           'Loop for the numbers of caracters that must be displayed
      Temp = Carcount + 1                                   'Cut the text string in seperate caracters
      Tempstring = Mid(s , Temp , 1)
      Offset = Asc(tempstring) - 32                         'Font files start with caracter 32
      Offset = Offset * Blocksize
      Offset = Offset + 4
      Temp = Carcount * Byteseach
      Temp = Temp + Xoffset
      For Rowcount = 0 To Row Step 8                        'Loop for numbers of rows
         Xpos = Temp
         For Columcount = 0 To Colums                       'Loop for numbers of Colums
            Select Case Fontset
               Case 1 : Pixels = Lookup(offset , My6_8)
               Case 2 : Pixels = Lookup(offset , My12_16)
               Case 3 : Pixels = Lookup(offset , Digital20x32)
            End Select
            Ypos = Rowcount + Yoffset
            For Pixelcount = 0 To 7                         'Loop for 8 pixels to be set or not
               Pixel = Pixels.0                             'Set the pixel (or not)
               If Pixel = 1 Then
                  Call Lcd_set_pixel(xpos , Ypos , White)
               Else
                  Call Lcd_set_pixel(xpos , Ypos , Black)
               End If
               Shift Pixels , Right                         'Shift the byte 1 bit to the right so the next pixel comes availible
               Incr Ypos                                    'Each pixel on his own spot
            Next Pixelcount
            Incr Offset
            Incr Xpos                                       'Do some calculation to get the caracter on the correct Xposition
         Next Columcount
      Next Rowcount
   Next Carcount
End Sub

'*******************************************************************************
' Draw Fill Circle  X-Y Center - Radius - Color=1 set Pixel  Color=Black - White
'*******************************************************************************
Sub Lcd_fill_circle(byval X0 As Byte , Byval Y0 As Byte , Byval Radius As Byte , Byval Color1 As Byte )
   Dbg
   Local F As Integer
   Local Ddf_x As Integer
   Local Ddf_y As Integer
   Local X As Integer
   Local Y As Integer
   F = 1 - Radius
   Ddf_x = 0
   Ddf_y = -2 * Radius
   X = 0
   Y = Radius
   Call Lcd_line(x0 , Y0 + Radius , X0 , Y0 - Radius , 1 , Color1)
   While X < Y
      If F >= 0 Then
         Decr Y
         Ddf_y = Ddf_y + 2
         F = F + Ddf_y
      End If
      Incr X
      Ddf_x = Ddf_x + 2
      F = F + Ddf_x
      Incr F
      Call Lcd_line(x0 + Y , Y0 + X , X0 + Y , Y0 - X , 1 , Color1)
      Call Lcd_line(x0 - Y , Y0 + X , X0 - Y , Y0 - X , 1 , Color1)
      Call Lcd_line(x0 + X , Y0 + Y , X0 + X , Y0 - Y , 1 , Color1)
      Call Lcd_line(x0 - X , Y0 + Y , X0 - X , Y0 - Y , 1 , Color1)
   Wend
End Sub
'*******************************************************************************
' Draw line X - Y Start to X - Y End - Pen Width - Color= Black - White
'*******************************************************************************
Sub Lcd_line(byval X1 As Byte , Byval Y1 As Byte , Byval X2 As Byte , Byval Y2 As Byte , Byval Pen_width As Byte , Byval Color As Byte)
   Dbg
   Local Y As Byte , X As Byte , X_diff As Single , Y_diff As Single , Pos As Byte
   Local X_factor As Single , X_pos As Byte , Y_pos As Byte , Base As Byte , Pen_count As Byte

   Y_diff = Y2 - Y1
   X_diff = X2 - X1
   Pos = 0
   X_factor = Abs(y_diff)
   Y = X_factor
   X_factor = Abs(x_diff)
   X = X_factor
   If Y > X Then
      X_factor = X_diff / Y_diff
      If Y1 > Y2 Then
         Swap Y1 , Y2
         Base = X2
      Else
         Base = X1
      End If
      For Y = Y1 To Y2
         X_diff = Pos * X_factor
         X_pos = X_diff
         X_pos = X_pos + Base
         For Pen_count = 1 To Pen_width
            Call Lcd_set_pixel(x_pos , Y , Color)
            Incr X_pos
         Next Pen_count
         Incr Pos
      Next Y
   Else
      X_factor = Y_diff / X_diff
      If X1 > X2 Then
         Swap X1 , X2
         Base = Y2
      Else
         Base = Y1
      End If
      For X = X1 To X2
         Y_diff = Pos * X_factor
         Y_pos = Y_diff
         Y_pos = Y_pos + Base
         For Pen_count = 1 To Pen_width
            Call Lcd_set_pixel(x , Y_pos , Color)
            Incr Y_pos
         Next Pen_count
         Incr Pos
      Next X
   End If
End Sub