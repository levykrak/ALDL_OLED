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

$regfile = "m328pdef.dat"
$crystal = 10000000
$hwstack = 32
$swstack = 8
$framesize = 50
$baud = 8192

'first compile and run this program with the line below remarked
Config Serialin = Buffered , Size = 66
Open "comb.1:9600,8,n,1" For Output As #1

'Dim Nm As String * 1
Dim Aldl_recv(66) As Byte
'Dim Aldl_recv As Byte ,
Dim Aldl_state As Byte
Dim Suma_kontrolna As Byte , I As Byte , R As Byte , Odp As Bit
'Dim I As Byte


Const Aldl_size = 66                                        'wielkosc dla mode 0
'Const Aldl_bodysize_1 = 67                                  'wielkosc dla mode 0


'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

Ucsr0b.txen0 = 1                                            'wlaczamy wysylanie
Ucsr0b.rxen0 = 0                                            'wylaczamy odbieranie

I = 1
Wait 5
Print #1 , "Start"


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
   Print Chr(&Hf4) ; Chr(&H57) ; Chr(&H01) ; Chr(&H00) ; Chr(&Hb4) ;       'mode 0
  'Clear Serialin
   'Waitms 4
'   If Isch

   Ucsr0b.txen0 = 0                                         ' wylaczamy nadawanie
   Ucsr0b.rxen0 = 1                                         'wlaczamy odbieranie
   Clear Serialin
   For I = 1 To 66                                          ' Aldl_size
      'Incr I
      While Ischarwaiting() = 0

      Wend
      'If Ischarwaiting(0) <> 0 Then                         'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
      Aldl_recv(i) = Waitkey()
      'Print #1 , Aldl_recv(i)
     ' Gosub Add2checksum
   '    Print #1 , " " ; I ; ": " ; Hex(aldl_recv(i));
   '    Waitms 2
      If I > 2 Then
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
     '                Print Suma_kontrolna
      End If
     ' End If
   Next

   Ucsr0b.txen0 = 1                                         'wlaczamy wysylanie
   Ucsr0b.rxen0 = 0                                         'wylaczamy odbieranie


   'Print "1: " ; Aldl_recv
   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
'      Suma_kontrolna = Suma_kontrolna - 256
      Print #1 , "mode 0: ";
      For R = 3 To 66 Step 1                                'Aldl_size
         'Incr R
         Print #1 , Hex(aldl_recv(r)) ; " ";

         Waitms 10
      Next
'      Print "checksum: " ; Suma_kontrolna

      Print #1 , " ok "
   End If


   'Print #1 , "checksum: " ; Hex(suma_kontrolna) ; "  " ; Hex(aldl_recv(66))
   Aldl_recv(3) = 0

'##################################mode 1 ##########################

   Print Chr(&Hf4) ; Chr(&H56) ; Chr(&H08) ; Chr(&Hae);
   Waitms 100


   Print Chr(&Hf4) ; Chr(&H57) ; Chr(&H01) ; Chr(&H01) ; Chr(&Hb3) ;       'mode 1
   Ucsr0b.txen0 = 0                                         ' wylaczamy nadawanie
   Ucsr0b.rxen0 = 1                                         'wlaczamy odbieranie
   Clear Serialin
   Suma_kontrolna = 0
   For I = 1 To 52                                          ' Aldl_size
      'Incr I
      While Ischarwaiting() = 0
      Wend
      'If Ischarwaiting(0) <> 0 Then                         'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
      Aldl_recv(i) = Waitkey()
      'Print #1 , Aldl_recv(i)
     ' Gosub Add2checksum
   '    Print #1 , " " ; I ; ": " ; Hex(aldl_recv(i));
   '    Waitms 2
      If I > 2 Then
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
     '                Print Suma_kontrolna
      End If
     ' End If
   Next

   Ucsr0b.txen0 = 1                                         'wlaczamy wysylanie
   Ucsr0b.rxen0 = 0                                         'wylaczamy odbieranie


   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
'      Suma_kontrolna = Suma_kontrolna - 256
      Print #1 , "mode 1: ";
      For R = 3 To 52 Step 1                                'Aldl_size
         'Incr R
         Print #1 , Hex(aldl_recv(r)) ; " ";
         Waitms 10
      Next
'      Print "checksum: " ; Suma_kontrolna
      Print #1 , " ok "
   End If

   Aldl_recv(3) = 0

                                           'wait 1 second


'##################################mode 2 ##########################
   Print Chr(&Hf4) ; Chr(&H56) ; Chr(&H08) ; Chr(&Hae);
   Waitms 100
   
   Print Chr(&Hf4) ; Chr(&H57) ; Chr(&H01) ; Chr(&H02) ; Chr(&Hb2) ;       'mode 1
   Ucsr0b.txen0 = 0                                         ' wylaczamy nadawanie
   Ucsr0b.rxen0 = 1                                         'wlaczamy odbieranie
   Clear Serialin
   Suma_kontrolna = 0
   For I = 1 To 59                                          ' Aldl_size
      'Incr I
      While Ischarwaiting() = 0
      Wend
      'If Ischarwaiting(0) <> 0 Then                         'tu wstrzymujemy petle for po to aby poczekac na reszte znakow
      Aldl_recv(i) = Waitkey()
      'Print #1 , Aldl_recv(i)
     ' Gosub Add2checksum
   '    Print #1 , " " ; I ; ": " ; Hex(aldl_recv(i));
   '    Waitms 2
      If I > 2 Then
         Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
     '                Print Suma_kontrolna
      End If
     ' End If
   Next
   Ucsr0b.txen0 = 1                                         'wlaczamy wysylanie
   Ucsr0b.rxen0 = 0                                         'wylaczamy odbieranie

   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
'      Suma_kontrolna = Suma_kontrolna - 256
      Print #1 , "mode 2: ";
      For R = 3 To 59 Step 1                                'Aldl_size
         'Incr R
         Print #1 , Hex(aldl_recv(r)) ; " ";
         Waitms 10
      Next
'      Print "checksum: " ; Suma_kontrolna
      Print #1 , " ok "
   End If
   Aldl_recv(3) = 0
Loop


Add2checksum:
   Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
Return