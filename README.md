# IRSA

## Diagrama de flujo:
Inicia Venta --> Detalle de cobranza --> Realizó conexión con ConfiguraIntSiTefInteractivo --> Espera OK --> Genera factura(Electronica, fiscal, etc) --> Envío a IRSA una vez la factura está emitida con EnviaInformacoesSiTef

## Funcionamiento básico del ejemplo:

### Conexión:
Primero que nada se debe realizar la conexión, se puede realizar una vez y luego enviar la cantidad de comprobantes que se necesiten, no se cierra la conexión. En caso de incorporarlo en el SIV o Sivimpresion se puede realizar la conexión al iniciar el sistema y listo, pero para evitar problemas realizaría la conexión en cada factura ya que se puede conectar aunque ya estés conectado. En el testeo está conexión se realiza con el botón configura.

### Envío de comprobante:
Con el otro botón se realiza el envío del comprobante, el cuál se realiza dentro de la función StartTransaction (los parámetros están a modo place holder, no sé están enviando los datos necesarios para el envío de una factura ya que deben cargarse por consulta)

#### Ejemplo de string final que se debe enviar TAG + JSON en la función de envío.

002000111234567890100400013002020011077700500008202302270060000607082500900001N013000079999999901400001E02500016EF28042023070825ANF01163{"SEVersion":{"Number":"2"},"Merchant":{"SiTefCode":"ARGAGS00","DocumentMerchant":"20200065620","DocumentMerchantType":"CUIT"},"SaleTicketType":"SALE","merchantId":"20200065620","Terminal":"AR000001","Invoice":[{"InvoiceNumber":{"Type":"B","FiscalPointSaleNumber":"00005","Number":"00003434","InvoiceDeliveryMethod":"FISCAL_PRINTER","documentType":"EFACTURA"},"Date":"20230428","Time":"042525","PriceList":"Publico","Customer":{"Name":"","FiscalSituation":"","DocumentType":"","Number":""},"Products":[{"ProductSKU":"4929495720","ProductDescription":"Testes Fiserv","Quantity":"1","Price":"121.00","DiscountPercentage":"0","DiscountAmount":"0","Amount":"121.00"}],"PaymentValues":[{"PaymentCode":"P","PaymentDescription":"Peso","CardBrand":"","Date":"20230428","Time":"042525","Type":"Efectivo","Symbol":"$","Amount":"121.00","NSUSitef":"","PaymentID":"EF27022023070825"}],"SubTotal":"100.00","DiscountPercentage":"0","DiscountAmount":"0","IVA":[{"Percentage":"21","Amount":"21.00"}],"OtherTaxes":"0","AmountTotal":"121.00"}]}


## Resumen de la documentación de la biblioteca

### Archivo Plan de Homologación CliSiTef_Envio de datos_1.7

Pasos del proceso de homologación (Pág 3):
Validar en SiTef Express si las transacciones están mostrándose correctamente.
Enviar archivos por email a DL-LAC-certificacion.latam@fiserv.com 

Archivos enviados para revisión de Software Express:
    • Los archivos 
    <Driver>:\CliSiTef\CliSiTef.AAAAMMDD.dmp del día en que las pruebas fueron ejecutadas.
    • Ejecutar las pruebas del plan todas en la misma fecha y enviar TXT con todas las TAGs y JSONs y el archivo trazas dmp.
    • Es necesario un manual de configuración de la interface de venta de su aplicación.

Consideraciones
Para situaciones en que hay más de un PDV apuntando al mismo servidor se debe establecer un solo IDTerminal para cada uno.
Recomendamos que se cambie el valor del campo CupomFiscal en cada nueva transacción (excepto en las transacciones con múltiples tarjetas).

Envio de CUIT  (Pág 6):
El CUIT es enviado en los parámetros adicionales de la función ConfiguraIntSiTefInterativoEx
ConfiguraIntSiTefInterativoEx (sitefIP, storeID, terminalID, reservado, additionalParameters);
Añadir al INI del SIV sitefIP(alfanumerico), storeID

Tipos de comprobante (Pág 8):
Sec. 1 – Transacción con Tarjeta de Crédito
Ejecución:
- Hacer una venta con Tarjeta de 
Crédito.
- Enviar los datos del pago.
- Enviar el Json con los datos de la 
factura.
Resultado Esperado:
Visualizar correctamente los informes de pagos y facturas, debe contener:
• En una venta, el número del comprobante fiscal debe aparecer y debe ser el mismo en el informe de la factura.
• El tipo de producto debe coincidir con la venta.
• El monto total pagado por el cliente y el número de cuotas.
• Y el número de identificación del pago (NSU Host) en el Reporte de Transacción tiene que ser correspondiente con el número de Identificación de Transacción 
que se presenta en el Reporte de Factura.
• Y la factura, además de esta información, debe contener el importe del impuesto.

Ejemplo de TAGs (TLV) y JSON de Factura enviados para esta secuencia de prueba:
TAGS: 002000113045465251300400013002020009532000500008202302020060000609532000700001C00900001N013000051210001400001T01500002VI020000011021000012022000011023000064916
190240000635254502500016TC02022023095320

JSON: ANF01133{"SEVersion": {"Number": "2"}, "Merchant": {"SiTefCode": "ARFISV01", "DocumentMerchant": "30454652513", "DocumentMerchantType": "CUIT"}, "SaleTicketType": "SALE", 
"merchantId": "30454652513", "Terminal": "AR000001", "Invoice": [{"InvoiceNumber": {"Type": "B", "FiscalPointSaleNumber": "00202", "Number": "00095320", "InvoiceDeliveryMethod": 
"FISCAL_PRINTER", "documentType": "EFACTURA"}, "Date": "20230202", "Time": "095320", "PriceList": "Publico", "Customer": {"Name": "", "FiscalSituation": "", "DocumentType": "", "Number": ""}, 
"Products": [{"ProductSKU": "4929495720", "ProductDescription": "Testes Fiserv", "Quantity": "1", "Price": "121.00", "DiscountPercentage": "0", "DiscountAmount": "0", "Amount": "121.00"}], 
"PaymentValues": [{"PaymentCode": "VI", "PaymentDescription": "Visa", "CardBrand": "VI", "Date": "20230202", "Time": "095320", "Type": "Tarjeta de Credito", "Symbol": "$", "Amount": "121.00", 
"NSUSitef": " ", "PaymentID": "TC02022023095320"}], "SubTotal": "100.00", "DiscountPercentage": "0", "DiscountAmount": "0", "IVA": [{"Percentage": "21", "Amount": "21.00"}], "OtherTaxes": "0", 
"AmountTotal": "121.00"}]}


Especificación envio de datos:

El flujo consiste en el envío de dos funciones, una para realizar la conexión con el servidor y otra para enviar los 
datos de pago y factura. 
ConfiguraIntSiTefInterativoEx (una vez al día o al activar la CliSiTef Plus)
EnviaInformacoesSiTef (al final de cada venta, informando los datos fiscales y de pago)

int EnviaInformacoesSiTef (char * data2send, char *ParamAdic)
El primer parámetro data2send se enviará en formato TLV, cuyo tag (T) tiene un tamaño de 3, la longitud 
(L) tiene un tamaño de 5 bytes y el valor (V) tiene un tamaño variable, según la L informada. Todos los 
campos deben estar en ASCII o UTF-8.
Comentarios:
• Las TAGS deben enviarse en orden consecutiva.
• Las TAGS y JSON de factura deben enviarse inmediatamente después de cada venta, no puede enviarse 
por lote.
• El segundo parámetro “paramAdic” está reservado para uso futuro.
Para los sistemas desarrollados para la integración de Envió de Datos a IRSA que necesitaren desconectarse 
de la DLL CiSiTef por requisitos de estructura y operación del sistema, es obligatorio añadir un controle 
de tiempo de 30 segundos luego después de cada envío de factura (TAG y JSON) que mantenga la DLL 
CLiSiTef cargada (emprendida) con sistema de transmisión de datos, o sea siempre después que la 
aplicación llamar la función EnviainformacacaoSiTef transmitir las TAGS y JSON de cada venta /nota de 
crédito y recibir de la DLL CliSiTef la respuesta “0” el sistema debe mantener la conexión abierta por 
mínimo 30 segundos con la librería CliSiTef para garantizar que la factura fue almacenada en el buffer de 
la DLL CliSiTef para transmisión al fondo (backgraund) al servidor SiTef.

### Archivo ESPECIFICACIÓN REDUCIDA DE DESARROLLO
CON CLISITEF PLUS: 

Lista de TAGS Pag 6
Lista de Tarjetas Pag 9
Lista de ejemplos  Pag 10 11
Lista de valores de retorno 11

#### Configuración de INI 
[Geral] 
DataEmAmbienteDeDesenvolvimento=AAAAMMDD
Donde AAAA=año, MM=mes y DD=día de las pruebas
[PinPadCompartilhado]
Porta=NENHUM


#### EJEMPLO DE DECLARACIÓN EN “C”
extern int (__stdcall ConfiguraIntSiTefInterativoEx) (char *pEnderecoIP, char *pCodigoLoja,
 char *pNumeroTerminal,
 short ConfiguraResultado,
 char *pParametrosAdicionais);
data2send = “TAGJSON”
extern int (__stdcall EnviaInformacoesSiTef) (char * data2send, char *ParamAdic);

## Archivo Adjunto A - CliSiTef Plus - Pagos-Facturas_1.09.pdf

#### QUÉ COMPROBANTES ESTÁN ALCANZADOS
Facturas y recibos clase A, A con la leyenda PAGO EN CBU INFORMADA y/o M.
Nota de crédito y débito clase A, A con la leyenda PAGO EN CBU INFORMADA y/o M.
Facturas y recibos clase B.
Nota de crédito y débito clase B.
Facturas y recibos clase C.
Nota de crédito y débito clase C.
Facturas y recibos clase E.
Notas de crédito y notas de débito clase E

#### DESCRIPCIÓN DE JSON DE FACTURAS (TABLA EN PAG 8)
{
"SEVersion": {
"Number": "2"
},
"Merchant": {
"SiTefCode": "CODELOJA",
"DocumentMerchant": "30123456784",
"DocumentMerchantType": "CUIT"
},
"SaleTicketType":"SALE",
"merchantId": "30123456784",
"Terminal": "AR000001",
"Invoice": [{
"InvoiceNumber": {
"Type": "B",
"FiscalPointSaleNumber": "00005",
"Number": "00003434",
"InvoiceDeliveryMethod": "ELECTRONIC_INVOICE",
 "documentType": "EFACTURA"
},
"Date": "20201001",
"Time": "113925",
"PriceList": "Publico",
"Customer": {
"Name": " ",
"FiscalSituation": "",
"DocumentType": "",
"Number": ""
},
"Products": [{
"ProductSKU": "Panta",
"ProductDescription": "Pantalon Cargo",
"Quantity": "4",
"Price": "3249.49",
"DiscountPercentage": "20.51",
"DiscountAmount": "666.47",
"Amount": "2583.02"
},
{
"ProductSKU": "RETYD",
"ProductDescription": "Remera manga corta",
"Quantity": "4",
"Price": "3249.49",
"DiscountPercentage": "20.51",
"DiscountAmount": "666.47",
"Amount": "2583.02"
}
],
"PaymentValues": [{
"PaymentCode": "VI3",
"PaymentDescription": "Visa 3 pagos",
"CardBrand": "VI",
CliSiTef Plus – Descripción del Formato de Facturas – Proyecto IRSA.docx 7 de 28
Copyright Software Express
Este documento contiene información CONFIDENCIAL y PRIVADA de Software Express y no puede publicarse ni distribuirse sin permiso. Se permiten copias 
y transmisiones solo para uso interno.
"Date": "20201102",
"Time": "113925",
"Type": "Tarjeta de Credito",
"Symbol ": "$",
"Amount": "4000.00",
"NSUSitef": "",
"PaymentID": "8765321"
},
{
"PaymentCode": "P",
"PaymentDescription": "Pesos",
"Date": "20201102",
"Time": "113925",
"Type": "Efectivo",
"Symbol ": "$",
"Amount": "1165.98",
"NSUSitef": "",
"PaymentID": "8765555"
}
],
"SubTotal": "4269.41",
"DiscountPercentage": "0",
"DiscountAmount": "0",
"IVA": [{
"Percentage": "21",
"Amount": "896.58"
}],
"OtherTaxes": "0",
"AmountTotal": "5165.98"
}]
}

#### Ejemplo de un comprobante de venta. (NC y demás, en pag 12 adelante)
{
"SEVersion": {
"Number": "2"
},
"Merchant": {
"SiTefCode": "CODELOJA",
"DocumentMerchant": "20358538463",
"DocumentMerchantType": "CUIT"
},
"SaleTicketType":"SALE",
"merchantId": "20358538463",
"Terminal": "AR000001",
"Invoice": [{
"InvoiceNumber": {
"Type": "B",
"FiscalPointSaleNumber": "00005",
"Number": "00003434",
"InvoiceDeliveryMethod": "ELECTRONIC_INVOICE",
 "documentType": "EFACTURA"
},
"Date": "20201006",
"Time": "163925",
"PriceList": "Publico",
"Customer": {
"Name": " ",
"FiscalSituation": " ",
"DocumentType": " ",
"Number": " "
},
"Products": [{
"ProductSKU": "Panta",
"ProductDescription": "Pantalon Cargo",
"Quantity": "4",
"Price": "3249.49",
"DiscountPercentage": "20.51",
"DiscountAmount": "666.47",
"Amount": "2583.02"
},
{
"ProductSKU": "RETYD",
"ProductDescription": "Remera manga corta",
"Quantity": "4",
"Price": "3249.49",
"DiscountPercentage": "20.51",
"DiscountAmount": "666.47",
"Amount": "2583.02
}
],
"PaymentValues": [{
"PaymentCode": "VI3",
CliSiTef Plus – Descripción del Formato de Facturas – Proyecto IRSA.docx 12 de 28
Copyright Software Express
Este documento contiene información CONFIDENCIAL y PRIVADA de Software Express y no puede publicarse ni distribuirse sin permiso. Se permiten copias 
y transmisiones solo para uso interno.
"PaymentDescription": "Visa 3 pagos",
"CardBrand": "VI",
"Date": "20201102",
"Time": "163925",
"Type": "Tarjeta de Credito",
"Symbol ": "$",
"Amount": "4000.00",
"NSUSitef": "",
"PaymentID": "8765327"
},
{
"PaymentCode": "P",
"PaymentDescription": "Pesos",
"Date": "20201102",
"Time": "163925",
"Type": "Efectivo",
"Symbol ": "$",
"Amount": "1165.98",
"NSUSitef": "",
"PaymentID": "8765557"
}
],
"SubTotal": "4269.40",
"DiscountPercentage": "0",
"DiscountAmount": "0",
"IVA": [{
"Percentage": "21",
"Amount": "896.58"
}],
"OtherTaxes": "0",
"AmountTotal": "5165.98"
}]
}

### Imagen explicativa de una venta y como se conforma el string
![image](https://user-images.githubusercontent.com/38087860/235285962-5ec40d9e-39cb-4bfb-983f-b3dbce1b438c.png)
