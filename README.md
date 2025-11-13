# memory_monitor_overlay

[![Pub Version](https://img.shields.io/pub/v/memory_monitor_overlay)](https://pub.dev/packages/memory_monitor_overlay)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/memory_monitor_overlay)
[![codecov](https://codecov.io/gh/jeesang7/memory_monitor_overlay/graph/badge.svg?token=ZNHOOVWZI0)](https://codecov.io/gh/jeesang7/memory_monitor_overlay)

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

## Screenshot

![](https://github.com/jeesang7/memory_monitor_overlay/blob/main/screenshots/memory_monitor_demo.GIF)
