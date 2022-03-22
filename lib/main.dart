import 'dart:ui' as ui;

import 'package:flutter/material.dart' as m;
import 'package:flutter_neumorphic/flutter_neumorphic.dart' as neu;
import 'package:url_launcher/url_launcher.dart' as url;

void main() {
  m.runApp(
    m.MaterialApp(
      theme: m.ThemeData.dark(),
      home: const m.Material(
        child: Resume(),
      ),
    ),
  );
}

const double frameEdgeInset = 64.0;
const double fontFrameWidth = 768.0;
const double fontFrameHeight = 128.0;

const glassColor = m.Color.fromARGB(
  64,
  192,
  192,
  255,
);

class FrameClip extends m.CustomClipper<m.Path> {
  @override
  ui.Path getClip(ui.Size size) {
    final path = m.Path();
    path.addRRect(
      m.RRect.fromRectAndRadius(
        m.Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height,
        ),
        const m.Radius.circular(
          16.0,
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
        const m.Radius.circular(
          16.0,
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

class Resume extends m.StatefulWidget {
  const Resume({m.Key? key}) : super(key: key);

  @override
  _ResumeState createState() => _ResumeState();
}

m.Widget button({
  required double scaleFactor,
  required m.Widget child,
  required void Function() onPressed,
  required m.Animation<double> fadeInAnimation,
}) {
  return m.ClipRRect(
    borderRadius: const m.BorderRadius.all(
      m.Radius.circular(
        16.0,
      ),
    ),
    child: neu.Neumorphic(
      style: const neu.NeumorphicStyle(
        color: glassColor,
      ),
      child: m.BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 32.0,
          sigmaY: 32.0,
        ),
        child: m.IconButton(
          iconSize: 500.0 * scaleFactor,
          color: m.Colors.black,
          icon: m.FadeTransition(
            opacity: fadeInAnimation,
            child: child,
          ),
          onPressed: onPressed,
        ),
      ),
    ),
    // width: 256.0,
    // height: 256.0,
  );
}

class _ResumeState extends m.State<Resume> with m.TickerProviderStateMixin {
  late final m.AnimationController scaleController;
  late final m.Animation<double> scaleAnimation;

  late final m.AnimationController whiteFadeOutController;
  late final m.Animation<double> whiteFadeOutAnimation;

  late final m.AnimationController fadeInController;
  late final m.Animation<double> fadeInAnimation;

  late final m.AnimationController fadeOutController;
  late final m.Animation<double> fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    scaleController = m.AnimationController(
      duration: const Duration(
        seconds: 60,
      ),
      vsync: this,
    );

    scaleAnimation = m.Tween<double>(
      begin: 2.0,
      end: 3.0,
    ).animate(
      m.CurvedAnimation(
        parent: scaleController,
        curve: m.Curves.easeInOut,
      ),
    );

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

    scaleController.repeat(reverse: true);
    whiteFadeOutController.forward();
    fadeInController.forward();
  }

  @override
  void dispose() {
    fadeInController.dispose();
    whiteFadeOutController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    final screenSize = m.MediaQuery.of(context).size;
    final scaleFactor = (screenSize.width / 1080.0) / 3.0;
    final fontSize = 64.0 * scaleFactor;
    return m.Stack(
      children: [
        m.Center(
          child: m.ScaleTransition(
            scale: scaleAnimation,
            child: m.Image.asset(
              'assets/moog.png',
              fit: m.BoxFit.cover,
            ),
          ),
        ),
        m.Positioned(
          left: 0,
          top: 0,
          width: screenSize.width,
          height: screenSize.height,
          child: m.FadeTransition(
            opacity: whiteFadeOutAnimation,
            child: m.Container(
              color: m.Colors.white,
            ),
          ),
        ),
        m.Positioned(
          left: frameEdgeInset * 4.0,
          top: frameEdgeInset * 5.0,
          child: m.SizedBox(
            width: screenSize.width - frameEdgeInset * 8.0,
            height: screenSize.height - frameEdgeInset * 9.0,
            child: m.Row(
              mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
              children: [
                button(
                  scaleFactor: scaleFactor,
                  child: neu.NeumorphicText(
                    'Email',
                    style: const neu.NeumorphicStyle(
                      color: m.Colors.black,
                    ),
                    textStyle: neu.NeumorphicTextStyle(
                        // color: m.Colors.black,
                        fontSize: fontSize,
                        fontFamily: 'PorticoFilled'),
                  ),
                  onPressed: () async {
                    if (!await url.launch('mailto:conradtyler0@gmail.com')) {
                      throw 'Failed to launch email URL';
                    }
                  },
                  fadeInAnimation: fadeInAnimation,
                ),
                button(
                  scaleFactor: scaleFactor,
                  child: m.Image.asset('assets/github.png'),
                  onPressed: () async {
                    if (!await url.launch('https://github.com/tyler-conrad')) {
                      throw 'Failed to launch github link';
                    }
                  },
                  fadeInAnimation: fadeInAnimation,
                ),
                button(
                  scaleFactor: scaleFactor,
                  onPressed: () async {
                    if (!await url.launch(
                        'https://tyler-conrad.github.io/tyler-conrad-resume.pdf')) {
                      throw 'Failed to launch resume url';
                    }
                  },
                  fadeInAnimation: fadeInAnimation,
                  child: neu.NeumorphicText(
                    'Resume',
                    style: const neu.NeumorphicStyle(
                      color: m.Colors.black,
                    ),
                    textStyle: neu.NeumorphicTextStyle(
                        // color: m.Colors.black,
                        fontSize: fontSize,
                        fontFamily: 'PorticoFilled'),
                  ),
                ),
              ],
            ),
          ),
        ),
        m.Positioned(
          left: frameEdgeInset,
          top: frameEdgeInset,
          width: screenSize.width - frameEdgeInset * 2.0,
          height: screenSize.height - frameEdgeInset * 2.0,
          child: m.ClipPath(
            clipper: FrameClip(),
            child: neu.Neumorphic(
              style: const neu.NeumorphicStyle(
                color: glassColor,
              ),
              child: m.BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 32.0,
                  sigmaY: 32.0,
                ),
                child: const m.ClipRRect(
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
        m.Positioned(
          left: frameEdgeInset * 1.5,
          top: frameEdgeInset * 1.5,
          child: m.SizedBox(
            width: fontFrameWidth,
            height: fontFrameHeight,
            child: m.FadeTransition(
              opacity: fadeInAnimation,
              child: neu.NeumorphicText(
                'Tyler Conrad',
                textStyle: neu.NeumorphicTextStyle(
                  fontSize: 96.0,
                  fontFamily: 'PorticoOutlined',
                ),
                style: const neu.NeumorphicStyle(
                  color: m.Colors.black,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
