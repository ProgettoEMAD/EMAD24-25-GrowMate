import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:growmate/screen/view_data.dart';

class LottoDetailPage extends StatefulWidget {
  final Map<String, dynamic> lotto;

  const LottoDetailPage({required this.lotto});

  @override
  State<LottoDetailPage> createState() => _LottoDetailPageState();
}

class _LottoDetailPageState extends State<LottoDetailPage> {
  List<File?> _image = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dettaglio Lotto"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lotto: ${widget.lotto['id_lotto']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Coltura: ${widget.lotto['coltura'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Data Semina: ${widget.lotto['data_semina'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Data Consegna: ${widget.lotto['data_consegna'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Fallanza: ${widget.lotto['fallanza'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (_image.isNotEmpty)
              SizedBox(
                height: 250,
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Immagini scattate:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          itemCount: _image.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final image = _image[index];
                            return image != null
                                ? Image.file(
                                    image,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return CameraPreviewWidget(
                          pictureCallback: (XFile image) {
                            setState(() {
                              _image.add(File(image.path));
                            });
                          },
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Nuova scansione",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_image.isNotEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ViewData();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Analizza foto",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CameraPreviewWidget extends StatefulWidget {
  final Function pictureCallback;

  const CameraPreviewWidget({super.key, required this.pictureCallback});

  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  bool _isFlashOn = false;
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {});
      } else {
        throw Exception("No cameras found");
      }
    } catch (e) {
      print("Errore durante l'inizializzazione della fotocamera: $e");
      setState(() {
        _cameraController = null; // Assicura che la fotocamera non venga usata
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      widget.pictureCallback(image);
    } catch (e) {
      print("Errore durante lo scatto della foto: $e");
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_cameraController != null && _cameraController!.value.isInitialized)
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: CameraPreview(
                  _cameraController!,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Placeholder(),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _takePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Scatta Foto",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _toggleFlash,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFlashOn ? Colors.yellow : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  _isFlashOn ? "Disabilita Flash" : "Abilita Flash",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
