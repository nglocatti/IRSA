VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CliSiTef"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Event OnCliSiTef(ByVal Command As Integer, ByVal FieldID As Integer, ByVal MinLength As Integer, ByVal MaxLength As Integer, ByVal InputData As String, ByRef OutputData As String, ByRef Continue As Integer)

' Funciones de clisitef32
Private Declare Function ConfiguraIntSiTefInterativoEx Lib "CliSitef32I.dll" (ByVal pEnderecoIP As String, ByVal pCodigoLoja As String, ByVal pNumeroTerminal As String, ByVal ConfiguraResultado As Integer, ByVal pParamAdic As String) As Long
Private Declare Function EnviaInformacoesSiTef Lib "CliSitef32I.dll" (ByVal data2send As String, ByVal pParamAdic As String) As Long

Private CurrentFiscalDoc As String
Private CurrentFiscalDate As String
Private CurrentFiscalTime As String


' Función para remover NULL al final de un char* recibido de la Dll
Private Function ntrim(ByVal theString As String) As String
  Dim iPos As Long
  iPos = InStr(theString, Chr$(0))
  If iPos > 0 Then
    ntrim = Left$(theString, iPos - 1)
  Else
    ntrim = theString
  End If
End Function

Public Function Configure(ByVal SiTefIP As String, ByVal StoreID As String, ByVal TerminalID As String, Optional ByVal AdditionalParameters As String = "") As Integer
  CurrentFiscalDoc = ""
  CurrentFiscalDate = ""
  CurrentFiscalTime = ""
  Configure = CInt(ConfiguraIntSiTefInterativoEx(SiTefIP, StoreID, TerminalID, 0, AdditionalParameters))
End Function

Public Function StartTransaction(ByVal FunctionId As Integer, ByVal TrnAmount As String, ByVal TaxInvoiceNumber As String, ByVal TaxInvoiceDate As String, ByVal TaxInvoiceTime As String, ByVal CashierOperator As String, Optional ByVal AdditionalParameters As String) As String
  Dim Sts As Integer
  Dim jsonString As String
  
  Dim json As String
  'jsonString = "002000111234567890100400013002020011077700500008202302270060000607082500900001N013000079999999901400001E02500016EF28042023070825ANF01029{'SEVersion':{'Number':'2'},'Merchant':{'SiTefCode':'ARGAGS00','DocumentMerchant':'20200065620','DocumentMerchantType':'CUIT'},'SaleTicketType':'SALE','merchantId':'20200065620','Terminal':'AR000001','Invoice':[{'InvoiceNumber':{'Type':'B','FiscalPointSaleNumber':'00005','Number':'00003434','InvoiceDeliveryMethod':'FISCAL_PRINTER','documentType':'EFACTURA'},'Date':'20230428','Time':'042525','PriceList':'Publico','Customer':"
  'jsonString = jsonString & "{'Name':'','FiscalSituation':'','DocumentType':'','Number':''},'Products':[{'ProductSKU':'4929495720','ProductDescription':'Testes Fiserv','Quantity':'1','Price':'121.00','DiscountPercentage':'0','DiscountAmount':'0','Amount':'121.00'}],'PaymentValues':[{'PaymentCode':'P','PaymentDescription':'Peso','CardBrand':'','Date':'20230428','Time':'042525','Type':'Efectivo','Symbol':'$','Amount':'121.00','NSUSitef':'','PaymentID':'EF27022023070825'}],'SubTotal':'100.00','DiscountPercentage':'0','DiscountAmount':'0','IVA':[{'Percentage':'21','Amount':'21.00'}],'OtherTaxes':'0','AmountTotal':'121.00'}]}"
  
    'Primero se envian los tags y sus valores
    json = "002000111234567890100400013002020011077700500008202302270060000607082500900001N013000079999999901400001E02500016EF28042023070825ANF01163" & _
        "{" & Chr(34) & "SEVersion" & Chr(34) & ":{"
    'Datos del comercio
    json = json & Chr(34) & "Number" & Chr(34) & ":" & Chr(34) & "2" & Chr(34) & "},"
    json = json & Chr(34) & "Merchant" & Chr(34) & ":{"
    json = json & Chr(34) & "SiTefCode" & Chr(34) & ":" & Chr(34) & "ARGAGS00" & Chr(34) & ","
    json = json & Chr(34) & "DocumentMerchant" & Chr(34) & ":" & Chr(34) & "20200065620" & Chr(34) & ","
    json = json & Chr(34) & "DocumentMerchantType" & Chr(34) & ":" & Chr(34) & "CUIT" & Chr(34) & "},"
    json = json & Chr(34) & "SaleTicketType" & Chr(34) & ":" & Chr(34) & "SALE" & Chr(34) & ","
    json = json & Chr(34) & "merchantId" & Chr(34) & ":" & Chr(34) & "20200065620" & Chr(34) & ","
    json = json & Chr(34) & "Terminal" & Chr(34) & ":" & Chr(34) & "AR000001" & Chr(34) & ","
    'Datos de la factura
    json = json & Chr(34) & "Invoice" & Chr(34) & ":[{"
    json = json & Chr(34) & "InvoiceNumber" & Chr(34) & ":{"
    json = json & Chr(34) & "Type" & Chr(34) & ":" & Chr(34) & "B" & Chr(34) & ","
    json = json & Chr(34) & "FiscalPointSaleNumber" & Chr(34) & ":" & Chr(34) & "00005" & Chr(34) & ","
    json = json & Chr(34) & "Number" & Chr(34) & ":" & Chr(34) & "00003434" & Chr(34) & ","
    json = json & Chr(34) & "InvoiceDeliveryMethod" & Chr(34) & ":" & Chr(34) & "FISCAL_PRINTER" & Chr(34) & ","
    json = json & Chr(34) & "documentType" & Chr(34) & ":" & Chr(34) & "EFACTURA" & Chr(34) & "},"
    json = json & Chr(34) & "Date" & Chr(34) & ":" & Chr(34) & "20230428" & Chr(34) & ","
    json = json & Chr(34) & "Time" & Chr(34) & ":" & Chr(34) & "042525" & Chr(34) & ","
    json = json & Chr(34) & "PriceList" & Chr(34) & ":" & Chr(34) & "Publico" & Chr(34) & ","
    json = json & Chr(34) & "Customer" & Chr(34) & ":{"
    json = json & Chr(34) & "Name" & Chr(34) & ":" & Chr(34) & "" & Chr(34) & ","
    json = json & Chr(34) & "FiscalSituation" & Chr(34) & ":" & Chr(34) & "" & Chr(34) & ","
    json = json & Chr(34) & "DocumentType" & Chr(34) & ":" & Chr(34) & "" & Chr(34) & ","
    json = json & Chr(34) & "Number" & Chr(34) & ":" & Chr(34) & "" & Chr(34)
    json = json & "},"
    'Datos de los productos
    json = json & Chr(34) & "Products" & Chr(34) & ":[{"
    json = json & Chr(34) & "ProductSKU" & Chr(34) & ":" & Chr(34) & "4929495720" & Chr(34) & ","
    json = json & Chr(34) & "ProductDescription" & Chr(34) & ":" & Chr(34) & "Testes Fiserv" & Chr(34) & ","
    json = json & Chr(34) & "Quantity" & Chr(34) & ":" & Chr(34) & "1" & Chr(34) & ","
    json = json & Chr(34) & "Price" & Chr(34) & ":" & Chr(34) & "121.00" & Chr(34) & ","
    json = json & Chr(34) & "DiscountPercentage" & Chr(34) & ":" & Chr(34) & "0" & Chr(34) & ","
    json = json & Chr(34) & "DiscountAmount" & Chr(34) & ":" & Chr(34) & "0" & Chr(34) & ","
    json = json & Chr(34) & "Amount" & Chr(34) & ":" & Chr(34) & "121.00" & Chr(34)
    json = json & "}],"
    'Datos del pago (pueden ser varios pagos)
    json = json & Chr(34) & "PaymentValues" & Chr(34) & ":[{"
    json = json & Chr(34) & "PaymentCode" & Chr(34) & ":" & Chr(34) & "P" & Chr(34) & ","
    json = json & Chr(34) & "PaymentDescription" & Chr(34) & ":" & Chr(34) & "Peso" & Chr(34) & ","
    json = json & Chr(34) & "CardBrand" & Chr(34) & ":" & Chr(34) & "" & Chr(34) & ","
    json = json & Chr(34) & "Date" & Chr(34) & ":" & Chr(34) & "20230428" & Chr(34) & ","
    json = json & Chr(34) & "Time" & Chr(34) & ":" & Chr(34) & "042525" & Chr(34) & ","
    json = json & Chr(34) & "Type" & Chr(34) & ":" & Chr(34) & "Efectivo" & Chr(34) & ","
    json = json & Chr(34) & "Symbol" & Chr(34) & ":" & Chr(34) & "$" & Chr(34) & ","
    json = json & Chr(34) & "Amount" & Chr(34) & ":" & Chr(34) & "121.00" & Chr(34) & ","
    json = json & Chr(34) & "NSUSitef" & Chr(34) & ":" & Chr(34) & "" & Chr(34) & ","
    json = json & Chr(34) & "PaymentID" & Chr(34) & ":" & Chr(34) & "EF27022023070825" & Chr(34) & "}"
    json = json & "],"
    'Montos de la factura
    json = json & Chr(34) & "SubTotal" & Chr(34) & ":" & Chr(34) & "100.00" & Chr(34) & ","
    json = json & Chr(34) & "DiscountPercentage" & Chr(34) & ":" & Chr(34) & "0" & Chr(34) & ","
    json = json & Chr(34) & "DiscountAmount" & Chr(34) & ":" & Chr(34) & "0" & Chr(34) & ","
    json = json & Chr(34) & "IVA" & Chr(34) & ":[" & _
            "{" & Chr(34) & "Percentage" & Chr(34) & ":" & Chr(34) & "21" & Chr(34) & "," & Chr(34) & "Amount" & Chr(34) & ":" & Chr(34) & "21.00" & Chr(34) & "}" & _
            "],"
    json = json & Chr(34) & "OtherTaxes" & Chr(34) & ":" & Chr(34) & "0" & Chr(34) & ","
    json = json & Chr(34) & "AmountTotal" & Chr(34) & ":" & Chr(34) & "121.00" & Chr(34) & "}"
    json = json & "]}"


'Envio de toda la información
  Sts = EnviaInformacoesSiTef(json, "")

  If (Sts = 10000) Then
    CurrentFiscalDoc = TaxInvoiceNumber
    CurrentFiscalDate = TaxInvoiceDate
    CurrentFiscalTime = TaxInvoiceTime
  End If
  StartTransaction = Sts
End Function


