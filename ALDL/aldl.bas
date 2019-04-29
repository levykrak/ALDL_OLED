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

$regfile = "m32def.dat"
$crystal = 16000000
$hwstack = 32
$swstack = 8
$framesize = 50
$baud = 8192

'first compile and run this program with the line below remarked
Config Serialin = Buffered , Size = 66
Open "coma.0:9600,8,n,1" For Output As #1

'Dim Nm As String * 1
Dim Aldl_recv(66) As Byte
Dim Suma_kontrolna As Byte , I As Byte , R As Byte , Odp As Bit
Declare Sub Aldl_message(byval Message As Byte)
'Dim I As Byte


Const Aldl_size = 66                                        'wielkosc dla mode 0
'Const Aldl_bodysize_1 = 67                                  'wielkosc dla mode 0


'the enabling of interrupts is not needed for the normal serial mode
'So the line below must be remarked to for the first test
Enable Interrupts

Ucsrb.txen = 1                                              'wlaczamy wysylanie
Ucsrb.rxen = 0                                              'wylaczamy odbieranie


Wait 3
Print #1 , "Start"


Do

   Waitms 100


   Call Aldl_message(0)

   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
      Print #1 , "mode 0: ";

      For R = 3 To 66 Step 1                                'Aldl_size
         'Incr R
         Print #1 , Hex(aldl_recv(r)) ; " ";
         Waitms 10
      Next
'      Print "checksum: " ; Suma_kontrolna
      Print #1 , " ok "
   End If


   Call Aldl_message(1)

   If Aldl_recv(3) = &HF4 And Suma_kontrolna = 0 Then       'And Aldl_recv(66) = Suma_kontrolna Then
'      Suma_kontrolna = Suma_kontrolna - 256
      Print #1 , "mode 1: ";

      For R = 3 To 52 Step 1                                'Aldl_size
         'Incr R
         Print #1 , Hex(aldl_recv(r)) ; " ";
         Waitms 10
      Next

      Print #1 , " ok "
   End If





Loop



Sub Aldl_message(byval Message As Byte)
   Local Aldl_message_size As Byte , I As Byte

   Printbin &HF4 ; &H56 ; &H08 ; &HAE;                      'wylaczamy standardowa komunikacje
   If Message = 0 Then                                      'wylaczamy standardowa komunikacje
      Printbin &HF4 ; &H57 ; &H01 ; &H00 ; &HB4;            'page 0
      Aldl_message_size = 66                                'ilosc danych + 2
   Elseif Message = 1 Then
      Printbin &HF4 ; &H57 ; &H01 ; &H01 ; &HB3;            'page 1
      Aldl_message_size = 52                                'ilosc danych + 2
   End If

   Ucsrb.txen = 0                                           ' wylaczamy nadawanie
   Ucsrb.rxen = 1                                           'wlaczamy odbieranie
   Clear Serialin
   Suma_kontrolna = 0
   For I = 1 To Aldl_message_size                           ' Aldl_size
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
   Ucsrb.txen = 1                                           'wlaczamy wysylanie
   Ucsrb.rxen = 0                                           'wylaczamy odbieranie
End Sub

'Add2checksum:
'   Suma_kontrolna = Suma_kontrolna + Aldl_recv(i)
'Return