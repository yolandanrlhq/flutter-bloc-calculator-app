import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/history_model.dart';
import '../../logic/calculator_bloc/calculator_bloc.dart';
import '../../logic/calculator_bloc/calculator_event.dart';
import '../widgets/calculator_button.dart';
import '../widgets/display_area.dart';
import 'package:intl/intl.dart';

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
            const Expanded(
              flex: 2,
              child: DisplayArea(),
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

    final List<CalculatorButtonSpec> buttons = [
      CalculatorButtonSpec(
          text: 'AC',
          backgroundColor: Colors.grey[700]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const ClearPressed())),
      CalculatorButtonSpec(
          text: '⌫',
          backgroundColor: Colors.grey[700]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const DeletePressed())),
      CalculatorButtonSpec(
          text: '%',
          backgroundColor: Colors.grey[700]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const OperatorPressed('%'))),
      CalculatorButtonSpec(
          text: '÷',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          onTap: () => bloc.add(const OperatorPressed('÷'))),
      CalculatorButtonSpec(
          text: '7',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('7'))),
      CalculatorButtonSpec(
          text: '8',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('8'))),
      CalculatorButtonSpec(
          text: '9',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('9'))),
      CalculatorButtonSpec(
          text: 'x',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          onTap: () => bloc.add(const OperatorPressed('x'))),
      CalculatorButtonSpec(
          text: '4',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('4'))),
      CalculatorButtonSpec(
          text: '5',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('5'))),
      CalculatorButtonSpec(
          text: '6',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('6'))),
      CalculatorButtonSpec(
          text: '-',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          onTap: () => bloc.add(const OperatorPressed('-'))),
      CalculatorButtonSpec(
          text: '1',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('1'))),
      CalculatorButtonSpec(
          text: '2',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('2'))),
      CalculatorButtonSpec(
          text: '3',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('3'))),
      CalculatorButtonSpec(
          text: '+',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          onTap: () => bloc.add(const OperatorPressed('+'))),
      CalculatorButtonSpec(
          text: '00',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('00'))),
      CalculatorButtonSpec(
          text: '0',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('0'))),
      CalculatorButtonSpec(
          text: '.',
          backgroundColor: Colors.grey[900]!,
          textColor: Colors.white,
          onTap: () => bloc.add(const NumberPressed('.'))),
      CalculatorButtonSpec(
          text: '=',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          onTap: () => bloc.add(const CalculatePressed())),
    ];

    return buttons.map((b) {
      return CalculatorButton(
        text: b.text,
        backgroundColor: b.backgroundColor,
        textColor: b.textColor,
        onTap: b.onTap,
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
          valueListenable:
              Hive.box<HistoryModel>('calculator_history').listenable(),
          builder: (context, Box<HistoryModel> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat',
                    style: TextStyle(color: Colors.white54)),
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
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmClearHistory(context, box),
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
                        title: Text(
                          history?.expression ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '= ${history?.result ?? ''}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              history != null
                                  ? DateFormat('dd/MM/yyyy HH:mm')
                                      .format(history.timestamp)
                                  : '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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

  void _confirmClearHistory(BuildContext context, Box<HistoryModel> box) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Seluruh riwayat perhitungan akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              box.clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}