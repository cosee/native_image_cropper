import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_example/pages/custom.dart';
import 'package:native_image_cropper_example/pages/default.dart';
import 'package:native_image_cropper_example/pages/native.dart';
import 'package:native_image_cropper_example/themes.dart';
import 'package:native_image_cropper_example/widgets/loading_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String imageName = 'sail-boat';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomThemes.theme(context),
      home: const _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  late final Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _getBytes();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Native Image Cropper Example',
          ),
          bottom: TabBar(
            indicatorColor: ColorScheme.of(context).secondary,
            tabs: const [
              Tab(
                text: 'Default',
              ),
              Tab(
                text: 'Custom',
              ),
              Tab(
                text: 'Native',
              ),
            ],
          ),
        ),
        body: FutureBuilder<Uint8List>(
          future: _bytesFuture,
          builder: (context, snapshot) => switch (snapshot.data) {
            null => const LoadingIndicator(),
            final bytes => TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DefaultPage(bytes: bytes),
                CustomPage(bytes: bytes),
                NativePage(bytes: bytes),
              ],
            ),
          },
        ),
      ),
    );
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/${MyApp.imageName}.png');
    return byteData.buffer.asUint8List();
  }
}
