import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 图片主色调提取工具类
///
/// 功能：
/// - 提取图片中出现频率最高的颜色作为主色调
/// - 支持任意类型的 [ImageProvider]（如 NetworkImage、AssetImage、MemoryImage）
///
/// 核心流程：
/// 1. 通过 [ImageProvider] 加载图片为 [ui.Image] 获取像素数据
/// 2. 按步长采样像素，过滤透明像素
/// 3. 对颜色进行量化处理（合并相近颜色）
/// 4. 统计颜色出现频率，返回出现次数最多的颜色
class ColorExtractor {
  /// 提取图片主色调颜色
  ///
  /// [provider]：图片提供器（支持 NetworkImage、AssetImage、MemoryImage 等）
  /// [sampleStep]：采样步长，越大性能越好但精度降低（默认 10）
  /// [quantizeInterval]：颜色量化步长，用于降低颜色维度（默认 32）
  /// [defaultColor]：提取失败时返回的默认颜色
  /// [minAlpha]：最小 Alpha 值，低于该值视为透明像素（默认 128）
  static Future<Color> extractDominantColorFromProvider({
    required ImageProvider provider,
    int sampleStep = 10,
    int quantizeInterval = 32,
    Color defaultColor = const ui.Color(0xFF4F4F4F),
    int minAlpha = 128,
  }) async {
    try {
      // 1. 加载图片为 ui.Image
      final ui.Image image = await _loadImageFromProvider(provider);

      // 2. 获取图片宽高和像素数据（RGBA8888格式，每个像素4字节：R、G、B、A）
      final int width = image.width;
      final int height = image.height;
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba,);

      // 若无法获取像素数据，返回默认颜色
      if (byteData == null) return defaultColor;

      // 将字节数据转换为Uint8List，便于按索引访问像素
      final Uint8List pixels = byteData.buffer.asUint8List();

      // 每个像素占用4字节（R、G、B、A），计算单个像素的字节跨度
      const int pixelStride = 4;

      // 3. 统计颜色频率的Map：key为量化后的颜色，value为出现次数
      final Map<Color, int> colorCount = {};

      // 4. 遍历像素（按采样步长间隔遍历，减少计算量）
      for (int y = 0; y < height; y += sampleStep) {
        // 防止y超出图片高度导致数组越界
        if (y >= height) break;

        for (int x = 0; x < width; x += sampleStep) {
          // 防止x超出图片宽度导致数组越界
          if (x >= width) break;

          // 计算当前像素在pixels数组中的起始索引
          // 公式：(y * 图片宽度 + x) * 每个像素的字节数
          final int index = (y * width + x) * pixelStride;

          // 防止索引超出数组长度（极端情况：图片尺寸计算误差）
          if (index + 3 >= pixels.length) continue;

          // 提取RGBA通道值（0-255范围）
          final int r = pixels[index];
          final int g = pixels[index + 1];
          final int b = pixels[index + 2];
          final int a = pixels[index + 3];

          // 过滤透明度过高的像素（alpha < minAlpha视为透明，不参与统计）
          if (a < minAlpha) continue;

          // 5. 颜色量化：合并相似颜色（降低颜色维度，减少计算量）
          // 原理：将0-255的通道值按quantizeInterval分组，取每组第一个值作为代表
          // 例如：quantizeInterval=32时，100会被量化为96（32*3=96），120会被量化为128（32*4=128）
          final int quantR = (r ~/ quantizeInterval) * quantizeInterval;
          final int quantG = (g ~/ quantizeInterval) * quantizeInterval;
          final int quantB = (b ~/ quantizeInterval) * quantizeInterval;

          // 创建量化后的颜色（忽略原始alpha，统一使用不透明，避免透明影响主色调判断）
          final Color quantColor = Color.fromARGB(255, quantR, quantG, quantB);

          // 6. 统计该颜色出现的次数
          colorCount[quantColor] = (colorCount[quantColor] ?? 0) + 1;
        }
      }

      // 7. 找到出现次数最多的颜色（主色调）
      if (colorCount.isEmpty) return defaultColor;

      // 从Map中筛选出value（次数）最大的key（颜色）
      return colorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    } catch (e) {
      debugPrint('提取主色调失败: $e');
      return defaultColor;
    }
  }

  /// 使用 ImageProvider 加载图片并转换为 ui.Image
  static Future<ui.Image> _loadImageFromProvider(ImageProvider provider) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();

    provider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              completer.complete(info.image);
            },
            onError: (Object error, StackTrace? stackTrace) {
              completer.completeError(error, stackTrace);
            },
          ),
        );

    return completer.future;
  }
}
