'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: AVR_HEATER_AND_TIMER_CONTROLLER_v1.0
'  date: 23/12/2006
'--------------------------------------------------------------

$regfile = "2313def.dat"
$crystal = 4000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024

Dim A As Byte , Lifesignal As Integer
Dim Doraapen As Integer , Pretimer As Integer
Dim Ovndiode As Integer , Posttimer As Integer
Dim Ovndiode2 As Integer , Servertimer As Integer

Lifesignal = 21
Doraapen = 0
Pretimer = 0
Posttimer = 0
Ovndiode = 0
Ovndiode2 = 0
Servertimer = 0

Portb = 0

For A = 1 To 20
    Portb.2 = Not Portb.2
    Portb.3 = Not Portb.3
    Waitms 200
Next A
Portb = 0

Waitms 1000

Start Watchdog
Portb.0 = 1

Main:
If Pind.1 = 1 Then

'sense if door is open/closed
If Pind.0 = 0 Then Doraapen = 21
If Doraapen > 0 Then Doraapen = Doraapen - 1

'activate pre delay
If Doraapen > 1 And Pretimer = 0 And Portb.0 = 1 Then Pretimer = 201
If Pretimer > 0 Then Decr Pretimer
If Doraapen = 0 And Pretimer <> 0 Then Pretimer = 0
If Pretimer > 5 And Ovndiode = 0 Then Ovndiode = 3

'turn off heater
If Pretimer = 1 And Doraapen > 1 Then
   Portb.0 = 0
   Pretimer = 0
   End If

'activate post delay
If Doraapen = 0 And Posttimer = 0 And Portb.0 = 0 Then Posttimer = 901
If Posttimer > 0 Then Decr Posttimer
If Doraapen > 0 And Ovndiode = 0 Then Ovndiode = 50
If Posttimer > 200 And Ovndiode = 0 Then Ovndiode = 15
If Posttimer < 200 And Posttimer > 0 And Ovndiode = 0 Then Ovndiode = 10

'turn on heater
If Posttimer = 1 Then Portb.0 = 1

'turn on LED
If Ovndiode > 0 Then Ovndiode = Ovndiode - 1
If Ovndiode = 10 Then
   Portb.2 = 1
   Portb.3 = 1
   End If
If Ovndiode = 2 Then
   Portb.2 = 1
   Portb.3 = 1
   End If
If Ovndiode = 1 Then
   Portb.2 = 0
   Portb.3 = 0
   End If

Else
Portb.0 = 0
Pretimer = 0
Posttimer = 100
Ovndiode = 0
Doraapen = 0
If Ovndiode2 = 0 Then Ovndiode2 = 50
End If

'local heater LED
If Ovndiode2 > 0 Then Ovndiode2 = Ovndiode2 - 1
If Ovndiode2 = 11 Then Portb.3 = 1
If Ovndiode2 = 1 Then Portb.3 = 0

'heater NC
Portb.1 = Not Portb.0

'timer signal
If Pind.2 = 0 And Servertimer = 0 Then Servertimer = 9000
If Pind.2 = 0 And Servertimer < 8975 Then Servertimer = 15

If Servertimer > 0 Then
   Decr Servertimer
   Portb.4 = 1
   End If
If Servertimer = 0 Then Portb.4 = 0

'Lifesignal
If Lifesignal > 0 Then Lifesignal = Lifesignal - 1
If Lifesignal = 6 Then Portb.5 = 1
If Lifesignal = 1 Then Portb.5 = 0
If Lifesignal = 0 Then Lifesignal = 21

'Loop cycle
Reset Watchdog
Waitms 100
Goto Main
End