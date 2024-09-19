import 'dart:math';

import 'package:flutter/material.dart';

class FilterMatrix {
  static contrast({required List<double> matrix, required double value}) {
    double v = value;
    double b = (1.0 - value) * 0.5 * 255.0; // 0.5*255 => 127

    return multiplyMatrix5(matrix, <double>[
      v,
      0,
      0,
      0,
      b,
      0,
      v,
      0,
      0,
      b,
      0,
      0,
      v,
      0,
      b,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static grayscale({required List<double> matrix, required double value}) {
    double v = 1.0 - value;
    double lumR = 0.2126;
    double lumG = 0.7152;
    double lumB = 0.0722;

    return multiplyMatrix5(matrix, <double>[
      (lumR + (1 - lumR) * v),
      (lumG - lumG * v),
      (lumB - lumB * v),
      0,
      0,
      (lumR - lumR * v),
      (lumG + (1 - lumG) * v),
      (lumB - lumB * v),
      0,
      0,
      (lumR - lumR * v),
      (lumG - lumG * v),
      (lumB + (1 - lumB) * v),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static sepia({required List<double> matrix, required double value}) {
    double v = 1.0 - value;

    return multiplyMatrix5(matrix, <double>[
      (0.393 + 0.607 * v),
      (0.769 - 0.769 * v),
      (0.189 - 0.189 * v),
      0,
      0,
      (0.349 - 0.349 * v),
      (0.686 + 0.314 * v),
      (0.168 - 0.168 * v),
      0,
      0,
      (0.272 - 0.272 * v),
      (0.534 - 0.534 * v),
      (0.131 + 0.869 * v),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static invert({required List<double> matrix, required double value}) {
    // v * (255 - n) + (1 - v) * n => (1 - 2v) * n + 255 * v
    double v = value * 255.0;
    double k = 1.0 - 2.0 * value;

    // The fifth column n is 255.
    return multiplyMatrix5(matrix, <double>[
      k,
      0,
      0,
      0,
      v,
      0,
      k,
      0,
      0,
      v,
      0,
      0,
      k,
      0,
      v,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static hue({required List<double> matrix, required double value}) {
    double v = pi * (value / 180.0);
    double cosVal = cos(v);
    double sinVal = sin(v);
    double lumR = 0.213;
    double lumG = 0.715;
    double lumB = 0.072;

    return multiplyMatrix5(matrix, <double>[
      (lumR + (cosVal * (1 - lumR))) + (sinVal * (-lumR)),
      (lumG + (cosVal * (-lumG))) + (sinVal * (-lumG)),
      (lumB + (cosVal * (-lumB))) + (sinVal * (1 - lumB)),
      0,
      0,
      (lumR + (cosVal * (-lumR))) + (sinVal * 0.143),
      (lumG + (cosVal * (1 - lumG))) + (sinVal * 0.14),
      (lumB + (cosVal * (-lumB))) + (sinVal * (-0.283)),
      0,
      0,
      (lumR + (cosVal * (-lumR))) + (sinVal * (-(1 - lumR))),
      (lumG + (cosVal * (-lumG))) + (sinVal * lumG),
      (lumB + (cosVal * (1 - lumB))) + (sinVal * lumB),
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static brightness({required List<double> matrix, required double value}) {
    double v = value;

    return multiplyMatrix5(matrix, <double>[
      v,
      0,
      0,
      0,
      0,
      0,
      v,
      0,
      0,
      0,
      0,
      0,
      v,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }

  static saturate({required List<double> matrix, required double value}) {
    return FilterMatrix.grayscale(matrix: matrix, value: 1.0 - value);
  }

  static opacity({required List<double> matrix, required double value}) {
    return multiplyMatrix5(matrix, <double>[
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      value,
      0,
      0,
      0,
      0,
      0,
      1
    ]);
  }
}

List<double> baseMatrix() {
  return <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1
  ];
}

ColorFilter toColorFilterMatrix(List<double> matrix) {
  return ColorFilter.matrix(matrix.sublist(0, 20));
}

List<double> multiplyMatrix5(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw FlutterError('Matrix length should be same.');
  }

  if (a.length != 25) {
    throw FlutterError('Matrix5 size is not correct.');
  }

  var a00 = a[0];
  var a01 = a[1];
  var a02 = a[2];
  var a03 = a[3];
  var a04 = a[4];
  var a10 = a[5];
  var a11 = a[6];
  var a12 = a[7];
  var a13 = a[8];
  var a14 = a[9];
  var a20 = a[10];
  var a21 = a[11];
  var a22 = a[12];
  var a23 = a[13];
  var a24 = a[14];
  var a30 = a[15];
  var a31 = a[16];
  var a32 = a[17];
  var a33 = a[18];
  var a34 = a[19];
  var a40 = a[20];
  var a41 = a[21];
  var a42 = a[22];
  var a43 = a[23];
  var a44 = a[24];

  var b00 = b[0];
  var b01 = b[1];
  var b02 = b[2];
  var b03 = b[3];
  var b04 = b[4];
  var b10 = b[5];
  var b11 = b[6];
  var b12 = b[7];
  var b13 = b[8];
  var b14 = b[9];
  var b20 = b[10];
  var b21 = b[11];
  var b22 = b[12];
  var b23 = b[13];
  var b24 = b[14];
  var b30 = b[15];
  var b31 = b[16];
  var b32 = b[17];
  var b33 = b[18];
  var b34 = b[19];
  var b40 = b[20];
  var b41 = b[21];
  var b42 = b[22];
  var b43 = b[23];
  var b44 = b[24];

  return [
    a00 * b00 + a01 * b10 + a02 * b20 + a03 * b30 + a04 * b40,
    a00 * b01 + a01 * b11 + a02 * b21 + a03 * b31 + a04 * b41,
    a00 * b02 + a01 * b12 + a02 * b22 + a03 * b32 + a04 * b42,
    a00 * b03 + a01 * b13 + a02 * b23 + a03 * b33 + a04 * b43,
    a00 * b04 + a01 * b14 + a02 * b24 + a03 * b34 + a04 * b44,
    a10 * b00 + a11 * b10 + a12 * b20 + a13 * b30 + a14 * b40,
    a10 * b01 + a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41,
    a10 * b02 + a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42,
    a10 * b03 + a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43,
    a10 * b04 + a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44,
    a20 * b00 + a21 * b10 + a22 * b20 + a23 * b30 + a24 * b40,
    a20 * b01 + a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41,
    a20 * b02 + a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42,
    a20 * b03 + a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43,
    a20 * b04 + a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44,
    a30 * b00 + a31 * b10 + a32 * b20 + a33 * b30 + a34 * b40,
    a30 * b01 + a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41,
    a30 * b02 + a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42,
    a30 * b03 + a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43,
    a30 * b04 + a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44,
    a40 * b00 + a41 * b10 + a42 * b20 + a43 * b30 + a44 * b40,
    a40 * b01 + a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41,
    a40 * b02 + a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42,
    a40 * b03 + a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43,
    a40 * b04 + a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44,
  ];
}