// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:serial/serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _inputController = TextEditingController();
  SerialPort? _port;
  final _received = <String>[];
  //final _inputController = TextEditingController();

  Future<void> _openPort() async {
    final port = await window.navigator.serial.requestPort();
    await port.open(baudRate: 9600);

    _port = port;
  }

  Future<void> _writeToPort(String data) async {
    if (_port == null) {
      return;
    }

    final writer = _port!.writable.writer;

    await writer.ready;
    await writer.write(Uint8List.fromList(data.codeUnits));

    await writer.ready;
    await writer.close();
  }

  Future<void> _readFromPort() async {
    if (_port == null) {
      return;
    }

    final reader = _port!.readable.reader;

    while (true) {
      final result = await reader.read();
      final text = String.fromCharCodes(result.value);

      _received.add(text);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Serial'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                //上下左右各添加8像素补白
                padding: const EdgeInsets.all(8),
                children: _received.map((e) => Text(e)).toList(),
              ),
            ),
            ElevatedButton(
              child: const Text('Open Port'),
              onPressed: () {
                _openPort();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "请输入要传递的信息",
              ),
            ),


            OutlinedButton(
              child: const Text('Send'),
              onPressed: () {
                final inputText = _inputController.text;
                _writeToPort(inputText);
              },
              style: ElevatedButton.styleFrom(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Receive'),
              onPressed: () {
                _readFromPort();
              },
            ),
          ],
        ),
      ),
    );
  }
}