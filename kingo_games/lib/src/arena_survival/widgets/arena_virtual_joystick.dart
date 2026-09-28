import 'package:flutter/material.dart';

/// Flutter virtual joystick. Writes directly into the Flame player input
/// so drag events are not stolen by GameWidget / overlay hit-testing.
class ArenaVirtualJoystick extends StatefulWidget {
  const ArenaVirtualJoystick({
    super.key,
    required this.onChanged,
    this.size = 128,
    this.knobSize = 52,
  });

  final void Function(double x, double y) onChanged;
  final double size;
  final double knobSize;

  @override
  State<ArenaVirtualJoystick> createState() => _ArenaVirtualJoystickState();
}

class _ArenaVirtualJoystickState extends State<ArenaVirtualJoystick> {
  Offset _knob = Offset.zero;
  int? _pointer;

  double get _maxTravel => (widget.size - widget.knobSize) / 2;

  void _apply(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    var delta = local - center;
    final maxR = _maxTravel;
    final dist = delta.distance;
    if (dist > maxR && dist > 0) {
      delta = delta * (maxR / dist);
    }
    if (_knob != delta) {
      setState(() => _knob = delta);
    }
    final nx = (delta.dx / maxR).clamp(-1.0, 1.0);
    final ny = (delta.dy / maxR).clamp(-1.0, 1.0);
    widget.onChanged(nx, ny);
  }

  void _release() {
    _pointer = null;
    if (_knob != Offset.zero) {
      setState(() => _knob = Offset.zero);
    }
    widget.onChanged(0, 0);
  }

  @override
  void dispose() {
    widget.onChanged(0, 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final knobOffset = _knob;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (_pointer != null) return;
        _pointer = event.pointer;
        _apply(event.localPosition);
      },
      onPointerMove: (event) {
        if (_pointer != event.pointer) return;
        _apply(event.localPosition);
      },
      onPointerUp: (event) {
        if (_pointer != event.pointer) return;
        _release();
      },
      onPointerCancel: (event) {
        if (_pointer != event.pointer) return;
        _release();
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _JoystickPainter(
            knob: knobOffset,
            maxTravel: _maxTravel,
            knobRadius: widget.knobSize / 2,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  _JoystickPainter({
    required this.knob,
    required this.maxTravel,
    required this.knobRadius,
  });

  final Offset knob;
  final double maxTravel;
  final double knobRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      maxTravel + 8,
      Paint()..color = Colors.white.withAlpha(55),
    );
    canvas.drawCircle(
      center,
      maxTravel + 8,
      Paint()
        ..color = Colors.white.withAlpha(90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center + knob,
      knobRadius,
      Paint()..color = Colors.white.withAlpha(230),
    );
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.knob != knob;
  }
}