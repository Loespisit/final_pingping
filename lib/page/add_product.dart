import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_pingping/page/model/product_type.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductModal extends StatefulWidget {
  const AddProductModal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductModalState createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  String? userToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<ListProductType> dropdownItems = ListProductType.getListProductType();
  late List<DropdownMenuItem<ListProductType>> dropdownMenuItems;
  int? selectedProductType;

  @override
  void initState() {
    super.initState();
    getUserToken();
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> addProductToApi() async {
    final productname = productNameController.text;
    final producttype = selectedProductType;
    double? price = double.tryParse(priceController.text);
    // String productname = "เทส"
    // int producttype = 1;
    // int price = 500;

    print("------------------------------------");
    print("product_name: $productname");
    print("product_type: $producttype");
    print("price: $price");
    print("userToken: $userToken");
    print("-----------------------------------");

    http.Response? response;

    try {
      response = await http.post(
        Uri.parse('https://642021155.pungpingcoding.online/api/product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          "product_name": productname,
          "product_type": producttype,
          "price": price,
        }),
      );

      if (response.statusCode == 200) {
        print("เพิ่มดอกไม้สำเร็จ");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'เพิ่มดอกไม้สำเร็จ!',
          confirmBtnText: 'กลับ',
          showConfirmBtn: false,
          autoCloseDuration: const Duration(seconds: 3),
        ).then((value) async {
          // Close the modal
          Navigator.of(context).pop();
        });
      } else {
        final responseData = json.decode(response.body);
        print(response.statusCode);
        print(
            responseData['message'] ?? 'เพิ่มดอกไม้ไม่ได้ ลองใหม่อีกครั้งไหม?');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'เพิ่มดอกไม้ไม่ได้ ลองใหม่อีกครั้งไหม?',
          confirmBtnText: 'เพิ่มเลย!',
          showConfirmBtn: false,
          autoCloseDuration: const Duration(seconds: 3),
        ).then((value) async {
          // Close the modal
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      print('Error during add product: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'ช่วยกรอกให้ถูกต้องหน่อย',
        confirmBtnText: 'เพิ่มเลย',
        showConfirmBtn: false,
        autoCloseDuration: const Duration(seconds: 3),
      ).then((value) async {
        // Close the modal
        Navigator.of(context).pop();
      });
    } finally {
      // Cleanup code, if necessary
      if (response != null) {
        print('HTTP status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          // Do nothing when tapped outside the modal
        },
        child: AlertDialog(
          title: const Text('เพิ่มดอกไม้ในคลัง'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  TextFormField(
                    controller: productNameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.filter_vintage_sharp),
                      labelText: 'ชื่อดอกไม้',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ช่วยกรอกชื่อดอกไม้ก่อน';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.monetization_on_outlined),
                      labelText: 'ราคา',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ช่วยกรอกราคาก่อน';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedProductType,
                    items:
                        ListProductType.getListProductType().map((productType) {
                      return DropdownMenuItem<int>(
                        value: productType.value,
                        child: Text(productType.name!),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedProductType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.emergency_outlined),
                      labelText: 'ประเภทดอกไม้',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'ช่วยเลือกประเภทดอกไม้ก่อน';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 254, 100, 100)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'กลับ',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 95, 255, 100)),
              ),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  addProductToApi();
                } else {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'ช่วยกรอกข้อมูลให้ครบก่อน!!',
                    confirmBtnText: 'กลับ',
                    showConfirmBtn: true,
                  );
                }
              },
              child: const Text(
                'เก็บไว้ในคลัง',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
