import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketsystem/layout/market_controller.dart';
import 'package:marketsystem/layout/market_layout.dart';
import 'package:marketsystem/models/product.dart';
import 'package:marketsystem/screens/add_product/add_product_controller.dart';
import 'package:marketsystem/screens/manage_products/manage_products.dart';
import 'package:marketsystem/shared/bindings/market_layout_binding.dart';
import 'package:marketsystem/shared/components/default_button.dart';
import 'package:marketsystem/shared/components/default_text_form.dart';
import 'package:marketsystem/shared/constant.dart';
import 'package:marketsystem/shared/styles.dart';
import 'package:marketsystem/shared/toast_message.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewcontroller;
  Barcode? barCode = null;

  var productbarcodeController_text = TextEditingController();
  var productNameController_text = TextEditingController();
  var productPriceController_text = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  var marketController_needed = Get.put(MarketController());

  @override
  void dispose() {
    // TODO: implement dispose
    this.qrViewcontroller?.dispose();
    super.dispose();
  }

  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await qrViewcontroller?.pauseCamera();
    }
    qrViewcontroller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildQr(context),
          Positioned(
            bottom: 10,
            child: _buildResult(),
          ),
          Positioned(
            top: 10,
            child: _buildControlButton(),
          ),
          if (barCode != null)
            Align(
                alignment: Alignment.center,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _build_Form(),
                      SizedBox(
                        height: 15,
                      ),
                      _buildSubmitRow(),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  _buildResult() => GestureDetector(
        onTap: () {
          setState(() {
            this.barCode = Barcode(''.trim(), BarcodeFormat.codabar, []);
          });
        },
        child: Container(
          decoration: BoxDecoration(color: defaultColor),
          padding: EdgeInsets.all(15),
          child: Text(
            "Continue Without Scan",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      );

  _buildQr(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreatedCallback,
        overlay: QrScannerOverlayShape(
            borderColor: defaultColor,
            borderWidth: 7,
            borderLength: 20,
            borderRadius: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.7),
      );

  void onQRViewCreatedCallback(QRViewController controller) {
    setState(() {
      this.qrViewcontroller = controller;
    });

    qrViewcontroller?.scannedDataStream.listen((barcode) => setState(() {
          this.barCode = barcode;
          qrViewcontroller?.pauseCamera();
        }));
  }

  _build_Form() => SingleChildScrollView(
        child: Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "barcode must not be empty";
                      }
                    },
                    initialValue: barCode!.code,
                    enabled: barCode == '' ? false : true,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(hintText: "Barcode..."),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  defaultTextFormField(
                      onvalidate: (value) {
                        if (value!.isEmpty) {
                          return "Name must not be empty";
                        }
                      },
                      inputtype: TextInputType.name,
                      border: UnderlineInputBorder(),
                      hinttext: "Name...",
                      controller: productNameController_text),
                  SizedBox(
                    height: 5,
                  ),
                  defaultTextFormField(
                      onvalidate: (value) {
                        if (value!.isEmpty) {
                          return "Price must not be empty";
                        }
                      },
                      inputtype: TextInputType.phone,
                      border: UnderlineInputBorder(),
                      hinttext: "Price...",
                      controller: productPriceController_text),
                ],
              ),
            )),
      );

  _buildSubmitRow() => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: defaultButton(
                width: MediaQuery.of(context).size.width * 0.4,
                text: "Save",
                onpress: () {
                  if (_formkey.currentState!.validate()) {
                    print("valid");

                    marketController_needed
                        .insertProductByModel(
                            model: ProductModel(
                                barcode: barCode!.code.toString(),
                                name: productNameController_text.text,
                                price: productPriceController_text.text))
                        .then((value) {
                      if (marketController_needed.statusInsertMessage.value ==
                          ToastStatus.Error) {
                        showToast(
                            message: marketController_needed
                                .statusInsertBodyMessage
                                .toString(),
                            status: marketController_needed
                                .statusInsertMessage.value);
                      } else {
                        productNameController_text.clear();
                        productPriceController_text.clear();
                        marketController_needed.onchangeIndex(0);

                        Get.off(MarketLayout());
                        showToast(
                            message: marketController_needed
                                .statusInsertBodyMessage
                                .toString(),
                            status: marketController_needed
                                .statusInsertMessage.value);
                      }
                    });
                  } else {
                    print("invalid");
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: defaultButton(
                width: MediaQuery.of(context).size.width * 0.4,
                text: "Rescan",
                onpress: () {
                  productNameController_text.clear();
                  productPriceController_text.clear();
                  qrViewcontroller!.resumeCamera();
                  setState(() {
                    barCode = null;
                  });
                }),
          ),
        ],
      );

  _buildControlButton() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                qrViewcontroller!.toggleFlash();
              },
              icon: Icon(
                Icons.flash_on,
                color: defaultColor,
              ))
        ],
      );
}