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




$prog &HFF , &HFF , &HD9 , &HFF                             ' generated. Take care that the chip supports all fuse bytes.

$regfile = "m328pdef.dat"
$crystal = 16000000
$hwstack = 120
$swstack = 120
$framesize = 120
$baud = 8192
Const Debag = 0                                             'printy i inne spowolnienia do debugowania

'first compile and run this program with the line below remarked
'Config Serialin = Buffered , Size = 66
#if Debag = 1
   Open "comb.1:9600,8,n,1" For Output As #1
#endif

$lib "i2c_twi.lbx"                                          'Hardware I2C
Config Scl = Portc.5                                        ' used i2c pins
Config Sda = Portc.4
Config Twi = 400000                                         ' i2c speed
I2cinit
'*******************************************************************************
'
'
Config Portc.3 = Output                                     'DISPLAY_Reset
Lcd_rst Alias Portc.3


Config Portc.0 = Output
Led Alias Portc.0


'Config Adc = Single , Prescaler = Auto , Reference = Avcc
''Start Adc
'Dim W As Word

'*******************************************************************************
'Declare Subs
Declare Sub Lcd_init()
Declare Sub Lcd_comm_out(byval Comm As Byte)
Declare Sub Lcd_clear(byval Colo As Byte)
Declare Sub Lcd_show()
Declare Sub Lcd_text(byval S As String , Byval Xoffset As Byte , Byval Yoffset As Byte , Byval Fontset As Byte)
Declare Sub Lcd_set_pixel(byval Xp As Byte , Byval Yp As Byte , Byval Colo As Byte)
'Declare Sub Lcd_fill_circle(byval X0 As Byte , Byval Y0 As Byte , Byval Radius As Byte , Byval Color1 As Byte )
Declare Sub Lcd_line(byval X1 As Byte , Byval Y1 As Byte , Byval X2 As Byte , Byval Y2 As Byte , Byval Pen_width As Byte , Byval Color As Byte)
Declare Sub Lcd_show_bgf(byval Xs As Byte , Byval Ys As Byte)
Const White = &HFF
Const Black = &H00
Const Dlugosc_wskazowki_gruba = 45

'Const Dlugosc_wskazowki_cienka = Dlugosc_wskazowki_gruba + Dlugosc_wskazowki_gruba
Dim Ddata(1024) As Byte                                     'Display Data Buffer
'*******************************************************************************
'Init Display -- SSD1306 oder Treiber IC SH1106 wird h�ufig als Ersatz geliefert.
Const Driver_typ = 1                                        'SSD1306 =1   SH1106 =0
Call Lcd_init()                                             'Init Display
'*******************************************************************************
'*******************************************************************************

Dim Zab As Single
Dim I_czysc As Single
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

Dim Aldl_recv(66) As Byte                                   'At &H0900 Overlay
Dim Suma_kontrolna As Byte , I As Byte , R As Byte
Dim Zezwolenie As Byte
Dim Temperatura_silnika As Integer , Temperatura_skrzyni As Integer
Dim Went_silnika As Bit , Went_skrzyni As Bit


Const Aldl_size_page0 = 65                                  'wielkosc pakietu dla page 0 +1
Const Aldl_size_page1 = 51                                  'wielkosc pakietu dla page 1 +1
On Urxc Uart_rx
Enable Interrupts


Ucsr0b.txen0 = 1                                            'wlaczamy wysylanie
Ucsr0b.rxen0 = 0                                            'wylaczamy odbieranie
Call Lcd_clear(black)
Restore Test
Call Lcd_show_bgf(1 , 1)                                    'write BGF to Buffer
Restore Went_off

Call Lcd_show_bgf(1 , 30)
Call Lcd_text( "???" , 1 , 50 , 2)
'Call Lcd_text( "engine" , 92 , 45 , 1)
Call Lcd_text( "???" , 90 , 49 , 2)
Call Lcd_text( "*" , 110 , 33 , 2)
Call Lcd_show()

X_1 = 64
Y_1 = 61

#if Debag = 1
   Wait 2
   Print #1 , "Start"
#endif

Zezwolenie = 10

Wait 2


Do
   Toggle Led
   #if Debag = 1
      Toggle Led
      Waitms 100
   #endif

   If Zezwolenie = 10 Then
      Disable Urxc
      Ucsr0b.txen0 = 1                                      'wlaczamy wysylanie
      Ucsr0b.rxen0 = 0                                      'wylaczamy odbieranie
      'Printbin &HF4 ; &H56 ; &H08 ; &HAE;                   'wylaczamy standardowa komunikacje
      'waitms 50
      Printbin &HF4 ; &H57 ; &H01 ; &H00 ; &HB4;            'page 0
      Ucsr0b.txen0 = 0                                      'wlaczamy wysylanie
      Ucsr0b.rxen0 = 1                                      'wylaczamy odbieranie
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
         #if Debag = 1
            Print #1 , "mode 0: ";
            For R = 2 To 65                                 'Aldl_size
         'Incr R
               Print #1 , Hex(aldl_recv(r)) ; " ";
               Waitms 10
            Next
            Print #1 , "suma:" ; Suma_kontrolna
            Print #1 , "went_silnika:" ; Aldl_recv(17).0
            Print #1 , "went_skrzyni:" ; Aldl_recv(17).1
         #endif
         Went_silnika = Aldl_recv(16).0
         Went_skrzyni = Aldl_recv(16).1
      End If
      Zezwolenie = 11

   Elseif Zezwolenie = 11 Then

      Disable Urxc
      Ucsr0b.txen0 = 1                                      'wlaczamy wysylanie
      Ucsr0b.rxen0 = 0                                      'wylaczamy odbieranie
      'Printbin &HF4 ; &H56 ; &H08 ; &HAE;                   'wylaczamy standardowa komunikacje
      'waitms 50
      Printbin &HF4 ; &H57 ; &H01 ; &H01 ; &HB3;            'page 0
      Ucsr0b.txen0 = 0                                      'wlaczamy wysylanie
      Ucsr0b.rxen0 = 1                                      'wylaczamy odbieranie
      I = 0
      Enable Urxc
      Zezwolenie = Aldl_size_page1

   Elseif Zezwolenie = 1 Then                               'page 1
      Suma_kontrolna = 0
      For R = 2 To Aldl_size_page1                          'Aldl_size
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(r)
         'Print #1 , Hex(aldl_recv(r)) ; " ";
         'Waitms 10
      Next
      If Aldl_recv(2) = &HF4 And Suma_kontrolna = 0 Then    'And Aldl_recv(66) = Suma_kontrolna Then
         #if Debag = 1
            Print #1 , "mode 1: ";
            For R = 2 To 51                                 'Aldl_size
               Incr R
               Print #1 , Hex(aldl_recv(r)) ; " ";
               Waitms 10
            Next
            Print #1 , "suma:" ; Suma_kontrolna
         #endif
         Temperatura_silnika = Aldl_recv(36)
         Temperatura_silnika = Temperatura_silnika * 75
         Temperatura_silnika = Temperatura_silnika - 4000
         Temperatura_silnika = Temperatura_silnika / 100

         Temperatura_skrzyni = Aldl_recv(37)
         Temperatura_skrzyni = Temperatura_skrzyni * 75
         Temperatura_skrzyni = Temperatura_skrzyni - 4000
         Temperatura_skrzyni = Temperatura_skrzyni / 100
      End If
      Zezwolenie = 10

   End If

 '############################ obsluga wyswietlacza ###################################
 '################ wazne aby nie przekroczyc rozdzielczosci wyswietlacza bo bedzie sypac bledami po pamieci uarta ###
'   Wait 4
 '(    For R = 2 To Aldl_size_page0                          'Aldl_size
   Suma_kontrolna = Suma_kontrolna + Aldl_recv(r)
         'Print #1 , Hex(aldl_recv(r)) ; " ";
         'Waitms 10
   Next
      'If Aldl_recv(2) = &HF4 And Suma_kontrolna = 0 Then    'And Aldl_recv(66) = Suma_kontrolna Then
   Print #1 , "mode 0: ";
   For R = 2 To 65                                    'Aldl_size
         'Incr R
   Print #1 , Hex(aldl_recv(r)) ; " ";
   Waitms 10
   Next
   Print #1 , "suma:" ; Suma_kontrolna
      'End If
')

'                  temp  dzialanie   stopnie
'   temperatura = 60     -180        = -120    (180 - 60) *-1
''   temperatura = 90     -180        = -90    (180 - 90) *-1
' temperatura   = 130                 = -50    (180 - 130) *-1

   'Call Lcd_clear(black)

   For I_czysc = -135 To - 44                               'do czyszczenia widma po wskazowce
       Rad = Deg2rad(i_czysc)
       X_single = Cos(rad)
       Y_single = Sin(rad)
       X = X_single * Dlugosc_wskazowki_gruba
      X = X + 64
      Y = Y_single * Dlugosc_wskazowki_gruba
      Y = Y + 61
      Call Lcd_line(64 , 61 , X , Y , 3 , Black)            'Line
   Next I_czysc


   If Temperatura_skrzyni >= 45 Then

      Zab = 180 - Temperatura_skrzyni                       '=135  dla 45   45 dla 135
      Zab = Zab * -1                                        '=-135 dla 45   -45 dla 135
      Rad = Deg2rad(zab)                                    'przeliczamy ze stopni na radiany
      X_single = Cos(rad)                                   'obliczamy wspolrzedna x i y dla konca lini
      Y_single = Sin(rad)
      X = X_single * Dlugosc_wskazowki_gruba
      X = X + 64
      Y = Y_single * Dlugosc_wskazowki_gruba
      Y = Y + 61

 '     Call Lcd_line(64 , 61 , X_1 , Y_1 , 3 , Black)        'Line
      Call Lcd_line(64 , 61 , X , Y , 3 , White)            'Line gruba
 '     X_1 = X
 '     Y_1 = Y

   Else
      Zab = 180 - 45
      Zab = Zab * -1
      Rad = Deg2rad(zab)                                    'inaczej wskazuj 45
      X_single = Cos(rad)                                   'obliczamy wspolrzedna x i y dla konca lini
      Y_single = Sin(rad)
      X = X_single * Dlugosc_wskazowki_gruba
      X = X + 64
      Y = Y_single * Dlugosc_wskazowki_gruba
      Y = Y + 61
  '    Call Lcd_line(64 , 61 , X_1 , Y_1 , 3 , Black)        'Line
      'Restore Oska
      'Call Lcd_show_bgf(60 , 57)
      Call Lcd_line(64 , 61 , X , Y , 3 , White)            'Line gruba
   '   X_1 = X
   '   Y_1 = Y
   End If

   If Went_skrzyni = 1 Then                                 'ikonka od wentylatora
      Restore Went_on
      Call Lcd_show_bgf(1 , 30)
   Else
      Restore Went_off
      Call Lcd_show_bgf(1 , 30)
   End If

   Text11 = Str(temperatura_skrzyni)                        ' info o temp skrzyni
   Text11 = Format(text11 , "000")
                                                            ' info o temp skrzyni
   Call Lcd_text(text11 , 1 , 50 , 2)                       ' info o temp skrzyni

   If Went_silnika = 1 Then                                 ' zmieniamy ikonke jak dziala wentylator na on

      Text11 = Str(temperatura_silnika)
      Text11 = Format(text11 , "000")
      Call Lcd_text(text11 , 90 , 49 , 2)
      Call Lcd_text( "*" , 110 , 30 , 2)

   Else

      Text11 = Str(temperatura_silnika)
      Text11 = Format(text11 , "000")
      Call Lcd_text(text11 , 90 , 49 , 2)
      Call Lcd_text( " " , 110 , 30 , 2)
   End If


   Call Lcd_show()

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
$include "My6_8.font"
$include "My12_16.font"
'$include "Digital20x32.font"                                'Font nur Zahlen Punkt und Komma
'include used BGF
'$inc Wskaznik , Nosize , "BGF\wskaznik.bgf"                 '32x32 Pixel
$inc Test , Nosize , "BGF\wskaznik_test.bgf"                '32x32 Pixel
$inc Oska , Nosize , "BGF\oska.bgf"
$inc Went_on , Nosize , "BGF\went.bgf"
$inc Went_off , Nosize , "BGF\went_off.bgf"
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
   '   Case 3 :
   '      Block = Lookup(0 , Digital20x32)
   '      Byteseach = Lookup(1 , Digital20x32)
   '      Blocksize = Lookup(2 , Digital20x32)
   '      Pixel = Lookup(3 , Digital20x32)
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
               'Case 3 : Pixels = Lookup(offset , Digital20x32)
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