# memory_monitor_overlay

A simple Flutter overlay to monitor memory usage in real-time

## Features

- Draggable overlay widget
- Customizable colors and text
- Easily add to any screen

## Getting started

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  memory_monitor_overlay: ^0.0.1
```

## Usage

```dart
import 'package:memory_monitor_overlay/memory_monitor_overlay.dart';

Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Monitor Demo'), elevation: 2),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Memory Monitor Overlay',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Add memory monitory overlay
          const MemoryMonitorOverlay(
            updateInterval: Duration(milliseconds: 500),
            initialX: 20,
            initialY: 100,
          ),
        ],
      ),
    );
  }
```
