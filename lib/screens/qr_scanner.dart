import 'dart:convert';
import 'dart:io';

import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:demo_app/constants/razor_credentials.dart' as razorCredentials;

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final razorpay = Razorpay();
  String scanBarcode = '';
  List<String> barcodes = [];
  TextEditingController barcodeArrayController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();

  // Future<void> startBarcodeScanStream() async {
  //   FlutterBarcodeScanner.getBarcodeStreamReceiver(
  //           '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
  //       .listen((barcode) {
  //     setState(() {
  //       barcodes.add(barcode);
  //       barcodeArrayController.text = barcodes.toString();
  //       print("barcode:  $barcode");
  //     });
  //   });
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    });
    super.initState();
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("QR Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                color: Colors.red,
                icon: const Icon(Icons.qr_code_scanner),
                iconSize: 100,
                alignment: Alignment.center,
                splashColor: Colors.red.shade100,
                onPressed: () async {
                  await scanQR();
                }),
            // ElevatedButton(
            //   onPressed: () async => await startBarcodeScanStream(),
            //   child: const Text('Start barcode scan stream'),
            // ),
            Text(
              (scanBarcode == '-1') ? '' : scanBarcode,
              style: const TextStyle(fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                readOnly: true,
                controller: barcodeController,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () => onMakePayment(barcodeController),
              child: const Text("Make Payment"),
            )
            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: TextField(
            //     decoration: const InputDecoration(
            //       border: OutlineInputBorder(
            //         borderSide: BorderSide(color: Colors.black, width: 1),
            //       ),
            //     ),
            //     enabled: false,
            //     controller: barcodeArrayController,
            //     style: const TextStyle(fontSize: 20),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      barcodeController.text = barcodeScanRes;
    });
  }

  onMakePayment(barcodeController) async {
    if (barcodeController.text == null) {
      customSnackbar(width: 150, title: "Please scan QR first");
    } else {}
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response);
    ScaffoldMessenger.of(context).showSnackBar(
      customSnackbar(width: 200, title: response.toString()),
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    print(response);
    ScaffoldMessenger.of(context).showSnackBar(
      customSnackbar(width: 200, title: response.toString()),
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    print(response);
    ScaffoldMessenger.of(context).showSnackBar(
      customSnackbar(width: 200, title: response.toString()),
    );
  }

  void createOrder() async {
    String userName = razorCredentials.keyId;
    String password = razorCredentials.keySecret;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$userName:$password'))}';
    Map<String, dynamic> body = {
      "amount": 1000, //100 = Rs.1
      "currency": "INR",
      "receipt": "${DateTime.now()}"
    };

    var res = await http.post(
      Uri.https("api.razorpay.com", "v1/orders"),
      headers: <String, String>{
        "content-type": "application/json",
        'authorization': basicAuth,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      openGateway(jsonDecode(res.body)['id']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          width: 100,
          title: jsonDecode(res.body),
        ),
      );
    }
  }

  openGateway(String orderId) {
    var options = {
      'key': razorCredentials.keyId,
      'amount': 100, //in the smallest currency sub-unit.
      'name': 'Acme Corp.',
      'order_id': orderId, // Generate order_id using Orders API
      'description': 'Fine T-Shirt',
      'timeout': 60 * 5, // in seconds // 5 minutes
      'prefill': {
        'contact': '9123456789',
        'email': 'ary@example.com',
      }
    };
    razorpay.open(options);
  }

  verifySignature({
    String? signature,
    String? paymentId,
    String? orderId,
  }) async {
    Map<String, dynamic> body = {
      'razorpay_signature': signature,
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
    };
    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "10.0.2.2", // my ip address , localhost
        "razorpay_signature_verify.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          title: res.body.toString(),
          width: 200,
        ),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
