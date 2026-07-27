import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../logic/calculator_bloc/calculator_bloc.dart';
import '../../logic/calculator_bloc/calculator_event.dart';
import '../../logic/calculator_bloc/calculator_state.dart';
import '../widgets/display_area.dart';

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
            onPressed: () => _showHistoryBottomSheet(context),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: const DisplayArea(),
            ),

            Expanded(
              flex: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double totalHeight = constraints.maxHeight;
                  double totalWidth = constraints.maxWidth;
                  double ratio = (totalWidth / 4) / (totalHeight / 5);

                  return GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: ratio,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _buildButtons(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final bloc = BlocProvider.of<CalculatorBloc>(context);

    final buttons = [
      {'text': 'AC', 'bg': Colors.grey[700]!, 'textC': Colors.white, 'action': () => bloc.add(ClearPressed())},
      {'text': '⌫', 'bg': Colors.grey[700]!, 'textC': Colors.white, 'action': () => bloc.add(DeletePressed())},
      {'text': '%', 'bg': Colors.grey[700]!, 'textC': Colors.white, 'action': () => bloc.add(OperatorPressed('%'))},
      {'text': '÷', 'bg': Colors.orange, 'textC': Colors.white, 'action': () => bloc.add(OperatorPressed('÷'))},

      {'text': '7', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('7'))},
      {'text': '8', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('8'))},
      {'text': '9', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('9'))},
      {'text': 'x', 'bg': Colors.orange, 'textC': Colors.white, 'action': () => bloc.add(OperatorPressed('x'))},

      {'text': '4', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('4'))},
      {'text': '5', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('5'))},
      {'text': '6', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('6'))},
      {'text': '-', 'bg': Colors.orange, 'textC': Colors.white, 'action': () => bloc.add(OperatorPressed('-'))},

      {'text': '1', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('1'))},
      {'text': '2', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('2'))},
      {'text': '3', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('3'))},
      {'text': '+', 'bg': Colors.orange, 'textC': Colors.white, 'action': () => bloc.add(OperatorPressed('+'))},

      {'text': '00', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('00'))},
      {'text': '0', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('0'))},
      {'text': '.', 'bg': Colors.grey[900]!, 'textC': Colors.white, 'action': () => bloc.add(NumberPressed('.'))},
      {'text': '=', 'bg': Colors.orange, 'textC': Colors.white, 'action': () => bloc.add(CalculatePressed())},
    ];

    return buttons.map((b) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: b['bg'] as Color,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: b['action'] as VoidCallback, 
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

  void _showHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<String>('calculator_history').listenable(),
          builder: (context, Box<String> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat', style: TextStyle(color: Colors.white54)),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Riwayat Perhitungan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => box.clear(),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final history = box.getAt(box.length - 1 - index);
                      return ListTile(
                        title: Text(history ?? '', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}