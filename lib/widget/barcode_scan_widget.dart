import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanWidget extends StatelessWidget{
  const BarcodeScanWidget({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:const Color(0xFF000020),
      appBar: AppBar(
        title: const Text('バーコードをスキャン', style: TextStyle(color: Colors.white, fontSize: 18),),
        backgroundColor: Colors.green.withOpacity(0.9),
      ),
      body:MobileScanner(
        //バーコード読み取りでonDetectが起動
        onDetect: (capture){
          final List<Barcode> barcodes=capture.barcodes;//取得したバーコードをリストにする。(通常検出されるのは一つ)
          if(barcodes.isNotEmpty){
            final barcode=barcodes.first;
            if(barcode.rawValue!= null){
              Navigator.pop(context);
            }
          }
        },
      )
    );
  }
}