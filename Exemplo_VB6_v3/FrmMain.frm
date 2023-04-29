VERSION 5.00
Begin VB.Form FrmSiTef 
   Caption         =   "Exemplo"
   ClientHeight    =   7080
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7230
   LinkTopic       =   "Form1"
   ScaleHeight     =   7080
   ScaleWidth      =   7230
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox tdLog 
      Height          =   5175
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   3
      Top             =   1560
      Width           =   6735
   End
   Begin VB.TextBox tdHeader 
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   570
      Left            =   240
      TabIndex        =   2
      Text            =   "Display"
      Top             =   840
      Width           =   6735
   End
   Begin VB.CommandButton BtnPagamento 
      Caption         =   "Efetua Pagamento"
      Height          =   495
      Left            =   2160
      TabIndex        =   1
      Top             =   120
      Width           =   1815
   End
   Begin VB.CommandButton BtnConfigura 
      Caption         =   "Configura"
      Height          =   495
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   1695
   End
End
Attribute VB_Name = "FrmSiTef"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim WithEvents clisitef As clisitef
Attribute clisitef.VB_VarHelpID = -1

Private MenuTitle As String
Private ComprovanteCliente As String
Private ComprovanteLoja As String

Private Sub AddLog(ByVal line As String)
  tdLog.Text = tdLog.Text & line & vbNewLine
  tdLog.SelStart = Len(tdLog.Text)
End Sub

Private Sub BtnConfigura_Click()
  Dim Retorno        As Integer
  AddLog ("Configurando")
  Screen.MousePointer = vbHourglass
  Retorno = clisitef.Configure("52.67.141.229:10289", "ARGAGS00", "AR000001", "[CUIT=20200065620;CUITISV=20200065620;]")
  Screen.MousePointer = vbDefault

  If (Retorno = 0) Then
    AddLog ("Conexión Ok!")
  Else
    AddLog ("Conexión con error " & CStr(Retorno))
    MsgBox "Error: Retorno " & CStr(Retorno)
  End If

  
End Sub

Private Sub BtnPagamento_Click()
  Dim Opt As Integer
  Dim Retorno As Integer
  AddLog ("Iniciando Transacción")
  ComprovanteCliente = ""
  ComprovanteLoja = ""
  
  'La función no está utilizando los datos que se envían, está todo a modo de placeholder. Dentro de la función están todos los datos hardcodeados.
  Retorno = clisitef.StartTransaction(0, "1,00", "12345", "20011022", "091800", "Operador", "20200065620")
  
  If (Retorno = 0) Then
    AddLog ("Transacción aprobada!")
  Else
    AddLog ("Transacción negada con error " & CStr(Retorno))
    MsgBox "Error: Retorno " & CStr(Retorno)
  End If
End Sub

Private Sub clisitef_OnCliSiTef(ByVal Command As Integer, ByVal FieldID As Integer, ByVal MinLength As Integer, ByVal MaxLength As Integer, ByVal InputData As String, ByRef OutputData As String, Continue As Integer)
  Dim str As String
  Dim Opt As Integer
  str = ""
  str = "ProximoComando = " & CStr(Command) & "; TipoCampo=" & CStr(FieldID) & "; min=" & CStr(MinLength) & "; max=" & CStr(MaxLength) & "; input=[" & InputData & "]"
  AddLog (str)
  Select Case Command
    Case CMD_RESULT_DATA
      Select Case FieldID
        Case 121: ' Via cliente
          ComprovanteCliente = ComprovanteCliente & InputData & vbNewLine
          
        Case 122: ' Via lojista
          ComprovanteLoja = ComprovanteLoja & InputData & vbNewLine
      End Select
      
    Case CMD_SHOW_MENU_TITLE
      MenuTitle = InputData
      
    Case CMD_CLEAR_MENU_TITLE
      MenuTitle = ""
      
    Case CMD_CLEAR_MSG_CASHIER, CMD_CLEAR_MSG_CUSTOMER, CMD_CLEAR_MSG_CASHIER_CUSTOMER, CMD_CLEAR_HEADER
      tdHeader.Text = ""
      
    Case CMD_SHOW_MSG_CASHIER, CMD_SHOW_MSG_CUSTOMER, CMD_SHOW_MSG_CASHIER_CUSTOMER, CMD_SHOW_HEADER
      tdHeader.Text = InputData
      
    Case CMD_CONFIRMATION
      Opt = MsgBox(InputData, vbYesNoCancel + vbQuestion)
      If Opt = vbYes Then
        OutputData = "0"
      ElseIf Opt = vbNo Then
        OutputData = "1"
      Else
        Continue = -1
      End If
      
    Case CMD_GET_FIELD
      str = InputBox(InputData, "")
      If StrPtr(str) = 0 Then
        Continue = -1
      Else
        OutputData = str
      End If
    
    Case CMD_GET_MENU_OPTION
      str = InputBox(Replace(InputData, ";", vbNewLine), MenuTitle)
      If StrPtr(str) = 0 Then
        Continue = -1
      Else
        OutputData = str
      End If
    
    Case CMD_PRESS_ANY_KEY
      MsgBox (InputData)
  End Select
  DoEvents
End Sub

Private Sub Form_Initialize()
  Set clisitef = New clisitef
  tdHeader.Text = ""
  tdLog.Text = ""
End Sub

