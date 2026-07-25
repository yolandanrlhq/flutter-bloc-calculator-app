import 'package:flutter/material.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Kalkulator', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.orange),
            onPressed: () {
              // hive
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [            
            Expanded(
              flex: 2, 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                alignment: Alignment.bottomRight,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '12 + 5',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    FittedBox( 
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '17',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              flex: 4, 
              child: Container(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 1.3, 
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _buildButtons(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildButtons() {
    final buttons = [
      {'text': 'AC', 'bg': Colors.grey[700]!, 'textC': Colors.white},
      {'text': '⌫', 'bg': Colors.grey[700]!, 'textC': Colors.white},
      {'text': '%', 'bg': Colors.grey[700]!, 'textC': Colors.white},
      {'text': '/', 'bg': Colors.orange, 'textC': Colors.white},
      
      {'text': '7', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '8', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '9', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '*', 'bg': Colors.orange, 'textC': Colors.white},
      
      {'text': '4', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '5', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '6', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '-', 'bg': Colors.orange, 'textC': Colors.white},
      
      {'text': '1', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '2', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '3', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '+', 'bg': Colors.orange, 'textC': Colors.white},
      
      {'text': '00', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '0', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '.', 'bg': Colors.grey[900]!, 'textC': Colors.white},
      {'text': '=', 'bg': Colors.orange, 'textC': Colors.white},
    ];

    return buttons.map((b) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: b['bg'] as Color,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // tombol bloc
            },
            child: Center(
              child: Text(
                b['text'] as String,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: b['textC'] as Color,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}