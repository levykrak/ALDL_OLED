'-----------------------------------------------------------------------------------------
'name                     : rs232buffer.bas
'copyright                : (c) 1995-2005, MCS Electronics
'purpose                  : example shows the difference between normal and buffered
'                           serial INPUT
'micro                    : Mega48
'suited for demo          : yes
'commercial addon needed  : no
'-----------------------------------------------------------------------------------------

$regfile = "m32def.dat"                                     ' specify the used micro
$crystal = 16000000                                         ' used crystal frequency
$baud = 9600                                                ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space

'first compile and run this program with the line below remarked
Config Serialin = Buffered , Size = 64


'Dim Nm As String * 1
Dim Aldl_recv(64) As Byte
'Dim Aldl_recv As Byte ,
Dim Aldl_state As Byte
Dim Suma_kontrolna As Byte , I As Byte , R As Byte , Odp As Bit
'Dim I As Byte


Const Aldl_size = 64                                        'wielkosc dla mode 0
'Const Aldl_bodysize_1 = 67                                  'wielkosc dla mode 0


'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

I = 1
Wait 2
Print "Start"
Do
   'get a char from the UART
   'For I = 0 To 70
   'Wait 1
   Wait 1

   'wyslac zapytanie o mode

   Suma_kontrolna = 0

   For I = 1 To Aldl_size
      If Ischarwaiting() <> 0 Then                          'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
         Aldl_recv(i) = Waitkey()
         Gosub Add2checksum
         'Incr I

      'Print "tu " ; Aldl_recv(1)                            'print it
      '  Print "z"
      End If
   Next

'   Wend
   'I = 0



   'Print "1: " ; Aldl_recv
   If Aldl_recv(1) = &HF4 Then
   Suma_kontrolna = Suma_kontrolna - 256
      'For R = 1 To 64
      '   Print Hex(aldl_recv(r)) ; " ";
      'Next R
      Print "checksum: " ; Suma_kontrolna
   End If

   Aldl_recv(1) = 0

   'If Ucsra.rxc = 1 Then
   '   Print "lala"
   'End If
   'Print "3: " ; Aldl_recv(2)
   'Next I

   'Suma_kontrolna = Suma_kontrolna + Nm
      'Print Suma_kontrolna

   '
   'Print "suma: " ; Suma_kontrolna

   '(

   While Ischarwaiting() <> 0                               'as long as there is data in the buffer
   Aldl_recv = Waitkey()                                  'get a char

   If Aldl_state = 0 Then                                   ' nothing received yet
   If Aldl_recv = &HF4 Then                           ' slave addressed
   Aldl_state = 1                                  '  go to next state

           'Mbruncount = 0                                  ' reset the counter
   Gosub Add2checksum                              ' add the received byte to checksum
   Print "1:" ; Suma_kontrolna
   Else
   Aldl_state = 99
   End If
   Elseif Aldl_state = 1 Then                            ' dlugosc w bajtach
   Gosub Add2checksum                                  ' add it
   Print "2:" ; Suma_kontrolna
   Aldl_state = 2                                     ' next state

        'Select Case Mbfunc                                  ' determine the function
          ' Case 3 : Mbfunc = 3                              ' read register
          ' Case 6 : Mbfunc = 6                              ' write register
          ' Case 16 : Mbfunc = 16                            ' write multiple registers
        '   Case Else                                        'the function is not supported
        '     Mberr = 1 : Gosub Mberror : Exit While         'report error
        'End Select
   Elseif Aldl_state = 2 Then                            ' get starting address
   Gosub Add2checksum
   Print "3:" ; Suma_kontrolna
   Aldl_state = 3
   Elseif Aldl_state = 3 Then
   Gosub Add2checksum
   Aldl_state = 99
   End If
   Wend

')
   'Aldl_state = 0
   'Print "suma: " ; Suma_kontrolna
   'Wait 5                                                   'wait 1 second

Loop


Add2checksum:
   Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
Return
