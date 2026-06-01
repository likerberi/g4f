import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceVisualizer extends StatefulWidget {
  final bool isActive;
  final Color themeColor;

  const VoiceVisualizer({
    super.key,
    required this.isActive,
    required this.themeColor,
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heightMultipliers = [0.2, 0.5, 0.8, 0.4, 0.9, 0.6, 0.3, 0.7, 0.5, 0.8, 0.2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(
          '말하기 버튼을 누르고 말씀해 보세요 (오프라인 마이크 시뮬레이터)',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      height: 60,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_heightMultipliers.length, (index) {
              // Calculate wave animation
              final double wave = math.sin((_controller.value * 2 * math.pi) + (index * 0.4));
              final double animatedHeight = 15 + (35 * _heightMultipliers[index] * (wave.abs() + 0.1));

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 4,
                height: animatedHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      widget.themeColor,
                      const Color(0xFF00E5FF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.themeColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
