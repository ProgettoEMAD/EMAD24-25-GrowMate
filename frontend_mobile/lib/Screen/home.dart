import 'package:flutter/material.dart';
class home extends StatefulWidget {

  @override
  State<home> createState() => _home();
}

class _home extends State<home> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vivavio Bello srl'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riepilogo scannerizzazioni',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ScanCard(
              plantName: "Basilico",
              lotNumber: "n.12491245",
              seedLossPercentage: "13%",
              scansPerformed: 125,
            ),
            ScanCard(
              plantName: "Pomodoro",
              lotNumber: "n.12492245",
              seedLossPercentage: "1%",
              scansPerformed: 25,
            ),
            ScanCard(
              plantName: "Lattuga",
              lotNumber: "n.12391245",
              seedLossPercentage: "35%",
              scansPerformed: 1,
            ),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Azione da eseguire quando si preme il pulsante
                  print('Scannerizza vassoio premuto');
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Scannerizza vassoio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ScanCard extends StatelessWidget {
  final String plantName;
  final String lotNumber;
  final String seedLossPercentage;
  final int scansPerformed;

  const ScanCard({
    required this.plantName,
    required this.lotNumber,
    required this.seedLossPercentage,
    required this.scansPerformed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.eco,
                color: Colors.green,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Lotto $lotNumber"),
                  SizedBox(height: 8),
                  Text(
                    "Percentuale perdita semenza: $seedLossPercentage",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Nr scan. effettuati: $scansPerformed",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}