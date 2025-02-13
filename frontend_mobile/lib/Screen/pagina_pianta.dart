import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

import 'package:growmate/common/colors.dart';
import 'package:growmate/common/const.dart';
import 'package:growmate/service/api_wrapper.dart';

class LottoDetailPage extends StatefulWidget {
  final Map<String, dynamic> lotto;

  const LottoDetailPage({required this.lotto});

  @override
  State<LottoDetailPage> createState() => _LottoDetailPageState();
}

class _LottoDetailPageState extends State<LottoDetailPage> {
  List<File> images = [];
  List<int> results = [];

  num? campionePiante;
  num? percentuale;
  num? sommaPianteVassoiScansionati;
  num? numeroVassoiScansionati;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      appBar: AppBar(
        title: const Text("Dettaglio Lotto"),
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const Padding(
                padding: EdgeInsets.only(top: 16),
              ),
              if (images.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Non ci sono ancora scansioni registrate",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        List<File>? images =
                            await Navigator.of(context).push<List<File>>(
                          MaterialPageRoute(builder: (_) => const CameraView()),
                        );

                        if (images != null) {
                          setState(() {
                            this.images = images;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Nuova scansione",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (images.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Hai effettuato ${images.length} foto, pronte per la scansione.",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kGreenDark,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 16),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.file(
                              images[index],
                              width: 200,
                              fit: BoxFit.fitWidth,
                            ),
                            if (results.isNotEmpty) ...[
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 40,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: kGreenDark.withAlpha(150),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      results[index].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                  ),
                ),
              ],
              if (images.isNotEmpty && results.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        var wrapper = ApiWrapper();
                        int i = 0;
                        results = List.filled(images.length, 0);
                        for (File image in images) {
                          Map<String, dynamic> result = await wrapper.analyze(
                            image,
                            widget.lotto['id_lotto'] as int,
                          );

                          results[i] = result['result'] as int;
                          i++;
                        }

                        var piante = widget.lotto['piante'];
                        var vassoi = widget.lotto['vassoi'];

                        var piantePerVassoio = piante / vassoi;
                        numeroVassoiScansionati = results.length;

                        sommaPianteVassoiScansionati = results.fold<int>(
                            0,
                            (previousValue, element) =>
                                previousValue + element);

                        campionePiante =
                            numeroVassoiScansionati! * piantePerVassoio;

                        percentuale = (sommaPianteVassoiScansionati! * 100) /
                            campionePiante!;

                        var prospettivaPianteCresciuteTotale =
                            (sommaPianteVassoiScansionati! * piante) /
                                campionePiante!;

                        var percentualeTotale =
                            (prospettivaPianteCresciuteTotale * 100) / piante;
                        print(
                          "piante: $piante, vassoi $vassoi, piantePerVassoio: $piantePerVassoio, numeroVassoiScansionati: $numeroVassoiScansionati, sommaPianteVassoiScansionati: $sommaPianteVassoiScansionati, campionePiante: $campionePiante, percentuale: $percentuale, prospettivaPianteCresciuteTotale: $prospettivaPianteCresciuteTotale, percentualeTotale: $percentualeTotale",
                        );

                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Invia per la scansione",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (percentuale != null && campionePiante != null) ...analysis
              /*if (_image != null)
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
                ),*/
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get analysis {
    var piantePerVassoio = widget.lotto['piante'] / widget.lotto['vassoi'];

    return [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Risultati analisi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Percentuale di piante nate: ${percentuale!.toStringAsFixed(2)}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Vassoi scansionati: $numeroVassoiScansionati su ${widget.lotto['vassoi']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  color: kGreen,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                ),
                const Text(
                  "Piante nate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  color: kGreenDark,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                ),
                const Text(
                  "Piante non nate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {},
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: kGreen,
                value: sommaPianteVassoiScansionati!.toDouble(),
                title: '$sommaPianteVassoiScansionati',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kBrownAccent,
                ),
              ),
              PieChartSectionData(
                color: kGreenDark,
                value: (widget.lotto['piante']! - sommaPianteVassoiScansionati)
                    .toDouble(),
                title:
                    '${((piantePerVassoio * numeroVassoiScansionati!) - sommaPianteVassoiScansionati as double).toInt()}',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kBrownAccent,
                ),
              )
            ],
          ),
        ),
      ),
    ];
  }
}

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  List<File> takenPictures = [];

  Offset? _focusPoint;
  bool _showFocusIcon = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        takenPictures.add(File(image.path));
      });
    } catch (e) {
      print("Errore durante lo scatto della foto: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _onTapToFocus(BuildContext context, TapDownDetails details) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final Size size = renderBox.size;

    final Offset focusPoint = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    _cameraController!.setFocusPoint(focusPoint);

    // Mostra l'icona di focus nel punto toccato
    setState(() {
      _focusPoint = localPosition;
      _showFocusIcon = true;
    });

    // Nascondi l'icona dopo 1 secondo
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showFocusIcon = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? GestureDetector(
              onTapDown: (details) => _onTapToFocus(context, details),
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  ),
                  if (takenPictures.isNotEmpty) ...[
                    Positioned(
                      top: 64,
                      left: 16,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: kBrownLight,
                                  iconColor: kGreenDark,
                                  title: const Text(
                                    "Foto scattate",
                                    style: TextStyle(
                                      color: kGreenDark,
                                    ),
                                  ),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: takenPictures.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        kBrownLight,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: InkWell(
                                                      onTap: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          12,
                                                        ),
                                                        child: Image.file(
                                                          takenPictures[index],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Image.file(
                                              takenPictures[index],
                                            ),
                                          ),
                                        );
                                      },
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Stack(
                          children: [
                            for (int i = 0; i < takenPictures.length; i++)
                              Transform.rotate(
                                angle: i * 0.1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: kBrownLight,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    takenPictures[i],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 64,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(takenPictures);
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_showFocusIcon && _focusPoint != null)
                    Positioned(
                      top: _focusPoint!.dy - 20,
                      left: _focusPoint!.dx - 20,
                      child: const Icon(
                        Icons.filter_center_focus_rounded,
                        color: kBrownLight,
                        size: 40,
                      ),
                    ),
                  Positioned.fill(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 64,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _takePicture(),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                // Blurred background
                                BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: kGreenDark,
                                    ),
                                  ),
                                ),

                                Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      margin: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: kBrownLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.eco,
                                        color: kGreenDark,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .6,
                                      child: const Text(
                                        "Clicca qui per scattare la foto!",
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.clip,
                                          fontSize: 18,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
