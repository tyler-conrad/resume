import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart' as serv;
import 'package:flutter/material.dart' as m;
import 'package:flutter_neumorphic/flutter_neumorphic.dart' as neu;
import 'package:flutter/scheduler.dart' as s;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as url;

const double _maxRadius = 92.0;
const double _frameEdgeInset = 24.0;
const double _fontSize = 24.0;
const int _numBoids = 128;

const glassColor = m.Color.fromARGB(
  64,
  192,
  192,
  255,
);

double r(double size) {
  final widthFactor = 0.1.w;
  final heightFactor = 0.1.h;
  return widthFactor > heightFactor ? heightFactor * size : widthFactor * size;
}

class Boid {
  Boid({
    required this.x,
    required this.y,
    required this.velocity,
    required this.angle,
    required this.radius,
  });

  double x;
  double y;
  double velocity;
  double angle;
  double radius;
}

double distance(double x0, double y0, double x1, double y1) {
  return math.sqrt(
    math.pow((x1 - x0), 2) +
        math.pow(
          (y1 - y0),
          2,
        ),
  );
}

double dist(double x, double y) => math.sqrt(math.pow(x, 2) + math.pow(y, 2));

class Model {
  Model({
    required this.boids,
    required this.rand,
  });

  Iterable<Boid> boids;
  final math.Random rand;

  void update(
    double dt,
    m.Size screenSize,
  ) {
    for (final boid in boids) {
      final x = math.cos(boid.angle) * boid.velocity;
      final y = math.sin(boid.angle) * boid.velocity;

      boid.x = (boid.x + x);
      boid.y = (boid.y + y);

      if (boid.x <= 0.0) {
        boid.x = screenSize.width + boid.x % screenSize.width;
      }

      if (boid.y <= 0.0) {
        boid.y = screenSize.height + boid.y % screenSize.height;
      }

      if (boid.x > screenSize.width) {
        boid.x = boid.x % screenSize.width;
      }
      if (boid.y > screenSize.height) {
        boid.y = boid.y % screenSize.height;
      }
    }
  }
}

class Painter<T extends Model> extends m.CustomPainter {
  Painter({
    m.Listenable? repaint,
    required this.screenSize,
    required this.mousePos,
    required this.model,
    required this.dt,
    required this.image,
  }) : super(repaint: repaint);

  final m.Size screenSize;
  final m.Offset mousePos;
  final T model;
  final m.ValueNotifier<double> dt;
  final ui.Image? image;

  @override
  void paint(m.Canvas canvas, m.Size size) {
    final paint = m.Paint();
    canvas.drawRect(
      m.Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      paint..color = m.Colors.white,
    );

    for (final boid in model.boids) {
      canvas.drawCircle(
        m.Offset(boid.x, boid.y),
        (math.sin(dist(screenSize.width * 0.5 - boid.x,
                        screenSize.height * 0.5 - boid.y) *
                    0.01) *
                boid.radius)
            .abs(),
        paint..color = m.Colors.black,
      );
    }

    if (image != null) {
      m.Rect r = m.Offset.zero & size;

      m.Size inputSize =
          m.Size(image!.width.toDouble(), image!.height.toDouble());
      m.FittedSizes fs = m.applyBoxFit(m.BoxFit.cover, inputSize, size);

      m.Rect src = m.Offset.zero & fs.source;
      m.Rect dst = m.Alignment.center.inscribe(fs.destination, r);

      canvas.saveLayer(dst, paint);

      paint.blendMode = m.BlendMode.difference;
      canvas.restore();
      canvas.drawImageRect(
        image!,
        src,
        dst,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant m.CustomPainter oldDelegate) => true;
}

class Background extends m.StatefulWidget {
  const Background({m.Key? key}) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends m.State<Background>
    with m.SingleTickerProviderStateMixin {
  late m.Size screenSize;
  late m.Offset mousePos;
  late final s.Ticker ticker;

  final rand = math.Random();

  Duration lastTick = const Duration(
    seconds: 0,
  );

  m.ValueNotifier<double> dt = m.ValueNotifier(0.0);

  late Model model;

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _load('assets/moog.png');

    ticker = createTicker(
      (elapsed) {
        setState(
          () {
            dt.value =
                (elapsed - lastTick).inMicroseconds.toDouble() / 1000000.0;
            lastTick = elapsed;
            model.update(
              dt.value,
              screenSize,
            );
          },
        );
      },
    )..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = m.MediaQuery.of(context).size * 0.5;
    final halfScreenSize = screenSize * 0.5;
    mousePos = m.Offset(halfScreenSize.width, halfScreenSize.height);
    model = Model(
      rand: rand,
      boids: List.generate(
        _numBoids,
        (index) => Boid(
          x: screenSize.width * rand.nextDouble(),
          y: screenSize.height * rand.nextDouble(),
          velocity: rand.nextDouble() * 10.0,
          angle: rand.nextDouble() * math.pi * 2.0,
          radius: r(rand.nextDouble() * _maxRadius),
        ),
      ),
    );
  }

  ui.Image? image;

  void _load(String path) async {
    var bytes = await serv.rootBundle.load(path);
    image = await m.decodeImageFromList(bytes.buffer.asUint8List());
    setState(() {});
  }

  @override
  m.Widget build(m.BuildContext context) {
    screenSize = m.MediaQuery.of(context).size * 0.5;
    return m.Listener(
      onPointerHover: (e) {
        setState(() {
          mousePos = e.localPosition;
        });
      },
      child: m.ClipRect(
        child: m.CustomPaint(
          painter: Painter<Model>(
            screenSize: screenSize,
            mousePos: mousePos,
            model: model,
            repaint: dt,
            dt: dt,
            image: image,
          ),
        ),
      ),
    );
  }
}

class FrameClip extends m.CustomClipper<m.Path> {
  FrameClip({
    required this.frameEdgeInset,
  });

  final double frameEdgeInset;

  @override
  ui.Path getClip(
    ui.Size size,
  ) {
    final path = m.Path();
    path.addRRect(
      m.RRect.fromRectAndRadius(
        m.Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height,
        ),
        m.Radius.circular(
          r(24.0),
        ),
      ),
    );

    path.addRRect(
      m.RRect.fromRectAndRadius(
        m.Rect.fromLTWH(
          frameEdgeInset * 2.0,
          frameEdgeInset * 3.0,
          size.width - frameEdgeInset * 4.0,
          size.height - frameEdgeInset * 5.0,
        ),
        m.Radius.circular(
          r(24.0),
        ),
      ),
    );
    path.fillType = m.PathFillType.evenOdd;
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant m.CustomClipper<ui.Path> oldClipper) => true;
}

m.Widget button({
  required m.Widget child,
  required void Function() onPressed,
  required double frameEdgeInset,
  required m.Animation<double> fadeInAnimation,
  required ui.ImageFilter imageFilter,
  required m.BuildContext context,
}) {
  return m.SizedBox(
    child: m.ClipRRect(
      borderRadius: m.BorderRadius.all(
        m.Radius.circular(
          r(24.0),
        ),
      ),
      child: neu.Neumorphic(
        style: const neu.NeumorphicStyle(
          color: glassColor,
        ),
        child: m.BackdropFilter(
          filter: imageFilter,
          child: m.IconButton(
            iconSize: frameEdgeInset * 2.0,
            color: m.Colors.black,
            icon: m.FadeTransition(
              opacity: fadeInAnimation,
              child: child,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    ),
  );
}

m.Widget emailButton(
  ui.ImageFilter imageFilter,
  double fontSize,
  double frameEdgeInset,
  m.Animation<double> fadeInAnimation,
  m.BuildContext context,
) {
  return button(
    imageFilter: imageFilter,
    child: neu.NeumorphicText(
      'Email',
      style: const neu.NeumorphicStyle(
        color: m.Colors.black,
      ),
      textStyle: neu.NeumorphicTextStyle(
          fontSize: fontSize, fontFamily: 'PorticoFilled'),
    ),
    onPressed: () async {
      if (!await url.launch('mailto:conradtyler0@gmail.com')) {
        throw 'Failed to launch email URL';
      }
    },
    frameEdgeInset: frameEdgeInset,
    fadeInAnimation: fadeInAnimation,
    context: context,
  );
}

m.Widget gitHubButton(
  ui.ImageFilter imageFilter,
  double fontSize,
  double frameEdgeInset,
  m.Animation<double> fadeInAnimation,
  m.BuildContext context,
) {
  return button(
    imageFilter: imageFilter,
    child: m.Image.asset('assets/github.png'),
    onPressed: () async {
      if (!await url.launch('https://github.com/tyler-conrad')) {
        throw 'Failed to launch github link';
      }
    },
    frameEdgeInset: frameEdgeInset,
    fadeInAnimation: fadeInAnimation,
    context: context,
  );
}

m.Widget resumeButton(
  ui.ImageFilter imageFilter,
  double fontSize,
  double frameEdgeInset,
  m.Animation<double> fadeInAnimation,
  m.BuildContext context,
) {
  return button(
    imageFilter: imageFilter,
    onPressed: () async {
      if (!await url
          .launch('https://tyler-conrad.github.io/tyler-conrad-resume.pdf')) {
        throw 'Failed to launch resume url';
      }
    },
    frameEdgeInset: frameEdgeInset,
    fadeInAnimation: fadeInAnimation,
    child: neu.NeumorphicText(
      'Resume',
      style: const neu.NeumorphicStyle(
        color: m.Colors.black,
      ),
      textStyle: neu.NeumorphicTextStyle(
          fontSize: fontSize, fontFamily: 'PorticoFilled'),
    ),
    context: context,
  );
}

class Resume extends m.StatefulWidget {
  const Resume({m.Key? key}) : super(key: key);

  @override
  _ResumeState createState() => _ResumeState();
}

class _ResumeState extends m.State<Resume> with m.TickerProviderStateMixin {
  late final m.AnimationController fadeInController;
  late final m.Animation<double> fadeInAnimation;

  late final m.AnimationController fadeOutController;
  late final m.Animation<double> fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    fadeInController = m.AnimationController(
      duration: const Duration(
        seconds: 10,
      ),
      vsync: this,
    );

    fadeInAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: fadeInController,
        curve: m.Curves.easeInOut,
      ),
    );

    fadeOutController = m.AnimationController(
      duration: const Duration(
        seconds: 4,
      ),
      vsync: this,
    );

    fadeOutAnimation = m.Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      m.CurvedAnimation(
        parent: fadeInController,
        curve: m.Curves.easeInOut,
      ),
    );

    fadeInController.forward();
  }

  @override
  void dispose() {
    fadeOutController.dispose();
    fadeInController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    final imageFilter = ui.ImageFilter.blur(
      sigmaX: 32.0,
      sigmaY: 32.0,
    );
    final frameEdgeInset = r(_frameEdgeInset);
    final fontSize = r(_fontSize);
    final centerSize = m.MediaQuery.of(context).size * 0.5;
    return m.Stack(
      children: [
        m.Positioned(
          left: 0.0,
          top: 0.0,
          width: centerSize.width,
          height: centerSize.height,
          child: const Background(),
        ),
        m.Positioned(
          left: frameEdgeInset * 4.0,
          top: frameEdgeInset * 5.0,
          child: m.SizedBox(
            width: centerSize.width - frameEdgeInset * 8.0,
            height: centerSize.height - frameEdgeInset * 9.0,
            child: m.Center(
              child: m.Column(
                mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: m.CrossAxisAlignment.stretch,
                children: [
                  emailButton(
                    imageFilter,
                    fontSize,
                    frameEdgeInset,
                    fadeInAnimation,
                    context,
                  ),
                  gitHubButton(
                    imageFilter,
                    fontSize,
                    frameEdgeInset,
                    fadeInAnimation,
                    context,
                  ),
                  resumeButton(
                    imageFilter,
                    fontSize,
                    frameEdgeInset,
                    fadeInAnimation,
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
        m.Positioned(
          left: frameEdgeInset,
          top: frameEdgeInset,
          child: m.SizedBox(
            width: centerSize.width - frameEdgeInset * 2.0,
            height: centerSize.height - frameEdgeInset * 2.0,
            child: m.ClipPath(
              clipper: FrameClip(frameEdgeInset: frameEdgeInset),
              child: neu.Neumorphic(
                style: const neu.NeumorphicStyle(
                  color: glassColor,
                ),
                child: m.BackdropFilter(
                  filter: imageFilter,
                  child: m.ClipRRect(
                    borderRadius: m.BorderRadius.all(
                      m.Radius.circular(
                        frameEdgeInset,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        m.Positioned(
          left: frameEdgeInset * 1.7,
          top: frameEdgeInset * 1.5,
          child: m.FadeTransition(
            opacity: fadeInAnimation,
            child: neu.NeumorphicText(
              'Tyler Conrad',
              textStyle: neu.NeumorphicTextStyle(
                fontSize: fontSize,
              ),
              style: const neu.NeumorphicStyle(
                color: m.Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResumeApp extends m.StatefulWidget {
  const ResumeApp({m.Key? key}) : super(key: key);

  @override
  m.State<ResumeApp> createState() => _ResumeAppState();
}

class _ResumeAppState extends m.State<ResumeApp>
    with m.SingleTickerProviderStateMixin {
  late final m.AnimationController whiteFadeOutController;
  late final m.Animation<double> whiteFadeOutAnimation;

  @override
  void initState() {
    super.initState();

    whiteFadeOutController = m.AnimationController(
      duration: const Duration(
        seconds: 3,
      ),
      vsync: this,
    );

    whiteFadeOutAnimation = m.Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      m.CurvedAnimation(
        parent: whiteFadeOutController,
        curve: m.Curves.easeOut,
      ),
    );

    whiteFadeOutController.forward();
  }

  @override
  void dispose() {
    whiteFadeOutController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return m.MaterialApp(builder: (context, _widget) {
        final screenSize = m.MediaQuery.of(context).size;
        return m.Scaffold(
          body: m.Stack(
            children: [
              m.Positioned(
                left: 0.0,
                top: 0.0,
                width: screenSize.width,
                height: screenSize.height,
                child: m.FractionallySizedBox(
                  heightFactor: 0.5,
                  widthFactor: 0.5,
                  child: m.DecoratedBox(
                    decoration: m.BoxDecoration(
                      boxShadow: [
                        m.BoxShadow(
                          blurRadius: r(128.0),
                          color: m.Colors.black,
                          spreadRadius: r(128.0),
                        )
                      ],
                    ),
                    child: const Resume(),
                  ),
                ),
              ),
              m.Positioned(
                left: 0.0,
                top: 0.0,
                width: screenSize.width,
                height: screenSize.height,
                child: m.IgnorePointer(
                  child: m.FadeTransition(
                    opacity: whiteFadeOutAnimation,
                    child: m.Container(
                      color: m.Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    });
  }
}

void main() async {
  m.runApp(const ResumeApp());
}
