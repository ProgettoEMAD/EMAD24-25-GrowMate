import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

import 'package:growmate/common/colors.dart';
import 'package:growmate/common/const.dart';

class LottoDetailPage extends StatefulWidget {
  final Map<String, dynamic> lotto;

  const LottoDetailPage({required this.lotto});

  @override
  State<LottoDetailPage> createState() => _LottoDetailPageState();
}

class _LottoDetailPageState extends State<LottoDetailPage> {
  File? _image; // Per salvare l'immagine scattata
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      print("Errore durante lo scatto della foto: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      appBar: AppBar(
        title: const Text("Dettaglio Lotto"),
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: kBrownAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: SvgPicture.asset(
                      'assets/illustration4.svg',
                      semanticsLabel: 'Illustrazione di una porta',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Coltura: ${widget.lotto['coltura'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Lotto: ${widget.lotto['id_lotto']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Fallanza: ${widget.lotto['fallanza'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Data semina: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(widget.lotto['data_semina'] as int))}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Data consegna: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(widget.lotto['data_consegna'] as int))}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_image != null)
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Immagine scattata:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              Center(
                child: ElevatedButton(
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
                    "Nuova scansione",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_cameraController == null)
              const Center(
                child: Text(
                  "Nessuna fotocamera trovata",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            if (_cameraController != null &&
                !_cameraController!.value.isInitialized)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
