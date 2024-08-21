import 'package:flutter/material.dart' as m;
import 'package:glassmorphism/glassmorphism.dart' as gm;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart' as url;

const double maxRadius = 512.0;
const double _fontSize = 100.0;
const int numBoids = 96;
const double borderRadius = 12.0;
const double padding = 16.0;

const m.Color glassColor = m.Colors.white10;
const m.Color glassBorderColor = m.Colors.black;

m.Widget buttonBuilder({
  required m.Widget child,
  required double left,
  required double top,
  required double right,
  required double bottom,
  required void Function() onPressed,
}) {
  return gm.GlassmorphicFlexContainer(
    padding: m.EdgeInsets.fromLTRB(left, top, right, bottom),
    borderRadius: borderRadius,
    border: 1.0,
    blur: 8.0,
    borderGradient:
        const m.LinearGradient(colors: [glassColor, glassBorderColor]),
    linearGradient: const m.LinearGradient(colors: [glassColor, glassColor]),
    child: m.MouseRegion(
      cursor: m.SystemMouseCursors.click,
      child: m.GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    ),
  );
}

m.Widget projectButtonBuilder({
  required m.Widget child,
  required void Function() onPressed,
}) {
  return gm.GlassmorphicFlexContainer(
    padding: const m.EdgeInsets.all(16.0).r,
    borderRadius: borderRadius,
    border: 1.0,
    blur: 20.0,
    borderGradient:
        const m.LinearGradient(colors: [glassBorderColor, glassBorderColor]),
    linearGradient: const m.LinearGradient(colors: [glassColor, glassColor]),
    child: m.MouseRegion(
      cursor: m.SystemMouseCursors.click,
      child: m.GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    ),
  );
}

m.Widget projectButton({
  required String title,
  required String githubUrl,
  String? demoUrl,
  String? docsUrl,
  required double fontSize,
}) {
  return projectButtonBuilder(
    onPressed: () async {
      if (!await url.launchUrl(Uri.parse(githubUrl))) {
        throw 'Failed to launch email URL';
      }
    },
    child: m.Row(
      children: [
        m.Expanded(
          child: m.GestureDetector(
            onTap: () async {
              if (!await url.launchUrl(Uri.parse(githubUrl))) {
                throw 'Failed to launch github URL';
              }
            },
            child: m.Center(
              child: m.Text(
                title,
                style: m.TextStyle(
                  color: m.Colors.black,
                  fontSize: 64.0.r,
                  fontWeight: m.FontWeight.bold,
                  fontFamily: 'PorticoFilled',
                  shadows: const [
                    m.Shadow(
                      color: m.Colors.white,
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        m.Flexible(
          child: m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              if (demoUrl != null)
                m.Expanded(
                  child: m.GestureDetector(
                    onTap: () async {
                      if (!await url.launchUrl(Uri.parse(demoUrl))) {
                        throw 'Failed to launch demo URL';
                      }
                    },
                    child: m.Center(
                      child: m.Text(
                        'Demo',
                        style: m.TextStyle(
                          color: m.Colors.black,
                          fontSize: 64.0.r,
                          fontWeight: m.FontWeight.bold,
                          fontFamily: 'PorticoFilled',
                          shadows: const [
                            m.Shadow(
                              color: m.Colors.white,
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (demoUrl == null) const m.Spacer(),
              if (docsUrl != null)
                m.Expanded(
                  child: m.GestureDetector(
                    onTap: () async {
                      if (!await url.launchUrl(Uri.parse(docsUrl))) {
                        throw 'Failed to launch documentation URL';
                      }
                    },
                    child: m.Center(
                      child: m.Text(
                        'Docs',
                        style: m.TextStyle(
                          color: m.Colors.black,
                          fontSize: 64.0.r,
                          fontWeight: m.FontWeight.bold,
                          fontFamily: 'PorticoFilled',
                          shadows: const [
                            m.Shadow(
                              color: m.Colors.white,
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

m.Widget emailButton(
  double fontSize,
) {
  return buttonBuilder(
    left: 0.0,
    top: padding,
    right: padding,
    bottom: padding,
    onPressed: () async {
      if (!await url.launchUrl(Uri.parse('mailto:conradtyler0@gmail.com'))) {
        throw 'Failed to launch email URL';
      }
    },
    child: m.Center(
      child: m.Text(
        'Email',
        style: m.TextStyle(
          color: m.Colors.black,
          fontSize: fontSize,
          fontFamily: 'PorticoFilled',
          shadows: const [
            m.Shadow(
              color: m.Colors.white,
              blurRadius: 8.0,
            ),
          ],
        ),
      ),
    ),
  );
}

m.Widget gitHubButton(
  double fontSize,
) {
  return buttonBuilder(
    left: padding,
    top: padding,
    right: padding,
    bottom: padding,
    onPressed: () async {
      if (!await url.launchUrl(Uri.parse('https://github.com/tyler-conrad'))) {
        throw 'Failed to launch github link';
      }
    },
    child: m.Center(
      child: m.SizedBox(
        height: fontSize * 1.3,
        child: m.Image.asset('assets/github.png'),
      ),
    ),
  );
}

m.Widget resumeButton(
  double fontSize,
) {
  return buttonBuilder(
    left: padding,
    top: padding,
    right: 0.0,
    bottom: padding,
    onPressed: () async {
      if (!await url.launchUrl(Uri.parse('tyler_conrad_resume.pdf'))) {
        throw 'Failed to launch resume url';
      }
    },
    child: m.Center(
      child: m.Text(
        'Resume',
        style: m.TextStyle(
          color: m.Colors.black,
          fontSize: fontSize,
          fontFamily: 'PorticoFilled',
          shadows: const [
            m.Shadow(
              color: m.Colors.white,
              blurRadius: 8.0,
            ),
          ],
        ),
      ),
    ),
  );
}

class Project {
  const Project({
    required this.title,
    required this.githubUrl,
    this.demoUrl,
    this.docsUrl,
  });

  final String title;
  final String githubUrl;
  final String? demoUrl;
  final String? docsUrl;
}

const projects = [
  Project(
    title: 'Floss',
    githubUrl: 'https://github.com/tyler-conrad/floss',
    demoUrl: 'floss',
    docsUrl: 'doc/floss',
  ),
  Project(
    title: 'Charts Mockup',
    githubUrl: 'https://github.com/tyler-conrad/flutter_charts_mockup',
    demoUrl: 'charts_mockup',
    docsUrl: 'doc/flutter_charts_mockup',
  ),
  Project(
    title: 'NASA APOD',
    githubUrl: 'https://github.com/tyler-conrad/apod',
    docsUrl: 'doc/apod',
  ),
  Project(
    title: 'GPU Noise',
    githubUrl: 'https://github.com/tyler-conrad/gpu_noise',
    docsUrl: 'doc/gpu_noise',
  ),
  Project(
    title: 'Ray Tracer',
    githubUrl: 'https://github.com/tyler-conrad/ray_tracer',
    docsUrl: 'doc/ray_tracer',
  ),
  Project(
    title: 'DeviantArt',
    githubUrl: 'https://github.com/tyler-conrad/deviantart_client',
    docsUrl: 'doc/deviantart_client',
  ),
  Project(
    title: 'Exercism',
    githubUrl: 'https://github.com/tyler-conrad/dart_exercism',
  ),
];

class _Resume extends m.StatefulWidget {
  const _Resume();

  @override
  _ResumeState createState() => _ResumeState();
}

class _ResumeState extends m.State<_Resume> with m.TickerProviderStateMixin {
  late final m.AnimationController fadeInController;
  late final m.Animation<double> fadeInAnimation;

  late final m.AnimationController fadeOutController;
  late final m.Animation<double> fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    fadeInController = m.AnimationController(
      duration: const Duration(
        seconds: 4,
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
    final size = m.MediaQuery.of(context).size;
    return m.FadeTransition(
      opacity: fadeInAnimation,
      child: m.Stack(
        children: [
          m.Positioned(
            left: 0.0,
            top: 0.0,
            width: size.width,
            height: size.height,
            child: m.Image.asset(
              'assets/moog.png',
              fit: m.BoxFit.fill,
            ),
          ),
          m.Padding(
            padding: const m.EdgeInsets.all(128.0).r,
            child: m.Column(
              mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: m.CrossAxisAlignment.stretch,
              children: [
                gm.GlassmorphicFlexContainer(
                  flex: 1,
                  borderRadius: borderRadius,
                  border: 1.0,
                  blur: 8.0,
                  borderGradient: const m.LinearGradient(
                      colors: [glassBorderColor, glassBorderColor]),
                  linearGradient:
                      const m.LinearGradient(colors: [glassColor, glassColor]),
                  child: m.Center(
                    child: m.Text(
                      'Tyler Conrad',
                      style: m.TextStyle(
                        color: m.Colors.black,
                        fontSize: 160.0.r,
                        fontFamily: 'PorticoFilled',
                        shadows: const [
                          m.Shadow(
                            color: m.Colors.white,
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                m.Expanded(
                  flex: 1,
                  child: m.Row(
                    mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
                    children: [
                      emailButton(
                        _fontSize.r,
                      ),
                      gitHubButton(
                        _fontSize.r,
                      ),
                      resumeButton(
                        _fontSize.r,
                      ),
                    ],
                  ),
                ),
                m.Expanded(
                  flex: 4,
                  child: m.Column(
                    mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
                    children: [
                      for (final project in projects)
                        projectButton(
                          title: project.title,
                          githubUrl: project.githubUrl,
                          demoUrl: project.demoUrl,
                          docsUrl: project.docsUrl,
                          fontSize: 100.0.r,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResumeApp extends m.StatefulWidget {
  const ResumeApp({super.key});

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
    return ScreenUtilInit(
      designSize: const m.Size(1080, 1920),
      builder: (_, child) {
        return m.MaterialApp(
          theme: m.ThemeData(scaffoldBackgroundColor: m.Colors.white),
          home: const m.Scaffold(
            body: _Resume(),
          ),
        );
      },
    );
  }
}

void main() async {
  m.runApp(const ResumeApp());
}
