import 'package:flutter/material.dart';
import 'package:memory_monitor_overlay/memory_monitor_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Monitor Demo',
      theme: ThemeData.dark(),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final List<String> _items = [];

  void _allocateMemory() {
    setState(() {
      // 메모리 사용량을 늘리기 위한 더미 데이터 생성
      for (int i = 0; i < 10000; i++) {
        _items.add('Item ${_items.length}: ${'X' * 100}');
      }
    });
  }

  void _clearMemory() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Monitor Demo'), elevation: 2),
      body: Stack(
        children: [
          // 메인 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.memory, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Memory Monitor Overlay',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_items.length} items in memory',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _allocateMemory,
                  icon: const Icon(Icons.add),
                  label: const Text('Allocate Memory'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _clearMemory,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Memory'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withAlpha(20)),
                  ),
                  child: const Text(
                    '💡 You can drag the overlay above to move it to your desired location',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // 메모리 모니터 오버레이
          const MemoryMonitorOverlay(
            updateInterval: Duration(milliseconds: 500),
            initialX: 20,
            initialY: 100,
          ),
        ],
      ),
    );
  }
}
