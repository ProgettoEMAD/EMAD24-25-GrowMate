import 'package:flutter/material.dart';

class VivaioScreen extends StatelessWidget {
  const VivaioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Placeholder(
                    color: Colors.blue,
                  ),
                ),
                Text("Vivai"),
                Spacer(),
                Text("Prove"),
                Container(
                  child: Placeholder(
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Placeholder(),
          )
        ],
      ),
    );
  }
}
