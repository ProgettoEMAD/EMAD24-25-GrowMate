import 'package:flutter/material.dart';

class DettaglioLottoScreen extends StatelessWidget {
  final Map<String, dynamic> lotto;

  const DettaglioLottoScreen({super.key, required this.lotto});

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
              "Lotto: ${lotto['id_lotto']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Coltura: ${lotto['coltura'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Data Semina: ${lotto['data_semina'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Data Consegna: ${lotto['data_consegna'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fallanza: ${lotto['fallanza'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}