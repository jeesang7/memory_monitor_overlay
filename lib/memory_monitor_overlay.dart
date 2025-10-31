import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 실시간 메모리 사용량을 표시하는 드래그 가능한 오버레이 위젯
class MemoryMonitorOverlay extends StatefulWidget {
  /// 메모리 정보 업데이트 주기
  final Duration updateInterval;

  /// 초기 위치 X 좌표
  final double initialX;

  /// 초기 위치 Y 좌표
  final double initialY;

  /// 배경색
  final Color backgroundColor;

  /// 텍스트 색상
  final Color textColor;

  const MemoryMonitorOverlay({
    super.key,
    this.updateInterval = const Duration(milliseconds: 500),
    this.initialX = 20,
    this.initialY = 100,
    this.backgroundColor = const Color(0xDD000000),
    this.textColor = Colors.white,
  });

  @override
  State<MemoryMonitorOverlay> createState() => _MemoryMonitorOverlayState();
}

class _MemoryMonitorOverlayState extends State<MemoryMonitorOverlay> {
  Timer? _timer;
  double _x = 0;
  double _y = 0;

  // 메모리 정보
  int _currentRss = 0; // 현재 메모리 (MB)
  int _peakRss = 0; // 최대 메모리 (MB)

  // 메모리 히스토리 (차트용)
  final List<double> _memoryHistory = [];
  static const int _maxHistoryLength = 30;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _updateMemory();
    _timer = Timer.periodic(widget.updateInterval, (_) => _updateMemory());
  }

  void _updateMemory() {
    if (!mounted) return;

    setState(() {
      // 현재 메모리 사용량 (바이트 → MB)
      _currentRss = ProcessInfo.currentRss ~/ 1024 ~/ 1024;

      // 최대 메모리 사용량 (바이트 → MB)
      _peakRss = ProcessInfo.maxRss ~/ 1024 ~/ 1024;

      // 히스토리에 추가
      _memoryHistory.add(_currentRss.toDouble());
      if (_memoryHistory.length > _maxHistoryLength) {
        _memoryHistory.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _x,
          top: _y,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _x += details.delta.dx;
                _y += details.delta.dy;

                // 화면 밖으로 나가지 않도록 제한
                final size = MediaQuery.of(context).size;
                _x = _x.clamp(0, size.width - 200);
                _y = _y.clamp(0, size.height - 150);
              });
            },
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.textColor.withAlpha(100),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Icon(Icons.memory, color: widget.textColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Memory',
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 현재 메모리
                  _buildInfoRow('Current:', '$_currentRss MB', Colors.blue),
                  const SizedBox(height: 6),

                  // 최대 메모리
                  _buildInfoRow('Peak:', '$_peakRss MB', Colors.red),
                  const SizedBox(height: 10),

                  // 미니 차트
                  SizedBox(
                    height: 40,
                    child: CustomPaint(
                      painter: _MemoryChartPainter(
                        data: _memoryHistory,
                        color: Colors.blue,
                        maxValue: _peakRss > 0 ? _peakRss.toDouble() : 100,
                      ),
                      size: Size(176, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: widget.textColor.withAlpha(200),
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: [ui.FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// 메모리 히스토리를 그리는 커스텀 페인터
class _MemoryChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double maxValue;

  _MemoryChartPainter({
    required this.data,
    required this.color,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withAlpha(100)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final linePath = Path();

    final stepX = size.width / (data.length - 1).clamp(1, double.infinity);

    // 첫 점 시작
    final firstY = size.height - (data[0] / maxValue * size.height);
    path.moveTo(0, size.height);
    path.lineTo(0, firstY);
    linePath.moveTo(0, firstY);

    // 나머지 점들 연결
    for (int i = 1; i < data.length; i++) {
      final x = i * stepX;
      final y =
          size.height -
          (data[i] / maxValue * size.height).clamp(0, size.height);

      path.lineTo(x, y);
      linePath.lineTo(x, y);
    }

    // 영역 채우기 (닫기)
    path.lineTo(size.width, size.height);
    path.close();

    // 그리기
    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);

    // 그리드 라인
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_MemoryChartPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}
