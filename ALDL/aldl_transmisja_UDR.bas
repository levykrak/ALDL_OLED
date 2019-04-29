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
' nie dziala
'do sprawdzenia z wylaczonym buforem
' no nie robi


$regfile = "m8def.dat"
$crystal = 10000000
$hwstack = 32
$swstack = 8
$framesize = 50
$baud = 8192

'first compile and run this program with the line below remarked
'Config Serialin = Buffered , Size = 66
Open "comc.0:9600,8,n,1" For Output As #1

'Dim Nm As String * 1
Dim Aldl_recv(64) As Byte
'Dim Aldl_recv As Byte ,
Dim Aldl_state As Byte
Dim Suma_kontrolna As Byte , I As Byte , R As Byte , Odp As Bit
'Dim I As Byte
Dim Temp As Byte

'Const Aldl_size = 64                                        'wielkosc dla mode 0
'Const Aldl_bodysize_1 = 67                                  'wielkosc dla mode 0
Ucsrb.rxcie = 1
On Urxc Uart_rx
Disable Urxc
'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

I = 1
Wait 5
Print #1 , "Start"

Ucsrb.txen = 1                                              'wlaczamy wysylanie
Ucsrb.rxen = 0                                              'wylaczamy odbieranie

Do
   'get a char from the UART
   'For I = 0 To 70
  ' Wait 1
   'Print #1 , "slij"
   Suma_kontrolna = 0
   'Wait 2

   'Waitms 50
   Print Chr(&Hf4) ; Chr(&H56) ; Chr(&H08) ; Chr(&Hae);
   Waitms 100

   'wyslac zapytanie o mode
   Print Chr(&Hf4) ; Chr(&H57) ; Chr(&H01) ; Chr(&H00) ; Chr(&Hb4) ;

   Udr = 0
  'Clear Serialin
   'Waitms 4
'   If Isch

   'While Ucsra.txc = 0                                      ' czekamy az wysle sie
   'Wend


   'Temp = Udr


   Ucsrb.txen = 0


   Ucsrb.rxen = 1                                           'wlaczamy odbieranie
   Enable Urxc

'(
   For I = 1 To 64                                          ' Aldl_size
      'Incr I
   While Ischarwaiting() = 0

   Wend
      'If Ischarwaiting(0) <> 0 Then                         'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
   Aldl_recv(i) = Waitkey()
      'Print #1 , Aldl_recv(i)
     ' Gosub Add2checksum
   '    Print #1 , " " ; I ; ": " ; Hex(aldl_recv(i));
   '    Waitms 2
'      If I > 2 Then
   Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
     '                Print Suma_kontrolna
 '     End If
     ' End If
   Next
')

   Print #1 , Udr ; " i=" ; I
   While I < 67
   Wend
   Disable Urxc


   Ucsrb.txen = 1                                           'wlaczamy wysylanie
   Ucsrb.rxen = 0                                           'wylaczamy odbieranie
   I = 0

   'Print "1: " ; Aldl_recv
   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
'      Suma_kontrolna = Suma_kontrolna - 256

   For R = 3 To 66 Step 1                                   'Aldl_size
         'Incr R
      Print #1 , Hex(aldl_recv(r)) ; " ";

      Waitms 10
   Next
'      Print "checksum: " ; Suma_kontrolna

   Print #1 , " ok "
   End If


   'Print #1 , "checksum: " ; Hex(suma_kontrolna) ; "  " ; Hex(aldl_recv(66))
   Aldl_recv(1) = 0




Loop


Add2checksum:
   Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
Return

Uart_rx:

'For I = 1 To 64                                             ' Aldl_size
      'If I > 2 Then
'      While Ischarwaiting() = 0
'      Wend
      'If Ischarwaiting(0) <> 0 Then                         'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
   Aldl_recv(i) = Udr
   If I > 2 Then
      Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
   End If
   Incr I
      'Print #1 , Aldl_recv(i)
     ' Gosub Add2checksum
   '    Print #1 , " " ; I ; ": " ; Hex(aldl_recv(i));
   '    Waitms 2
'      If I > 2 Then

     '                Print Suma_kontrolna
 '     End If
     ' End If
 '  Next
Return