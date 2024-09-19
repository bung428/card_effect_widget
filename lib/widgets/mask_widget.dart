import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MaskWidget extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final bool isTest;
  final bool isOnHover;
  final BlendMode mode;
  final Widget child;

  const MaskWidget({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    required this.mode,
    required this.child,
    required this.isOnHover,
    this.isTest = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: convertImage(AssetImage(image)),
      builder: (context, snapshot) {
        if (!isOnHover || !snapshot.hasData) {
          return child;
        } else {
          if (isTest) {
            return Container();
          } else {
            return ShaderMask(
              shaderCallback: (Rect bounds) {
                final ui.Image image = snapshot.data!;
                final double scaleX = width / image.width;
                final double scaleY = height / image.height;
                final matrix = Matrix4.identity()
                  ..scale(scaleX, scaleY)
                  ..translate((width - image.width * scaleX) / 2, (height - image.height * scaleY) / 2);
                return ImageShader(
                  snapshot.data!,
                  TileMode.clamp,
                  TileMode.clamp,
                  matrix.storage,
                );
              },
              blendMode: mode,
              child: child,
            );
          }
        }
      }
    );
  }

  Future<ui.Image> convertImage(AssetImage assetImage) {
    final Image image = Image(image: assetImage);
    final Completer<ui.Image> completer = Completer();

    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
        })
    );
    return completer.future;
  }
}
