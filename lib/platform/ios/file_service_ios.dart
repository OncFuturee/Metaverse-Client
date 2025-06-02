import 'package:metaverse_client/platform/base/file_service.dart';

class IosFileServiceImpl implements FileService {
  @override
  Future<List<int>?> readFile(String path) async {
    // Web平台的文件读取实现
    // 这里可以使用dart:html的File API或其他方式读取文件
    throw UnimplementedError('Web file reading not implemented');
  }

  @override
  Future<String?> saveFile(String path, List<int> contents) async {
    // Web平台的文件保存实现
    throw UnimplementedError('Web file saving not implemented');
  }

  @override
  Future<bool> fileExists(String path) async {
    // Web平台的文件存在性检查实现
    throw UnimplementedError('Web file exists check not implemented');
  }

  @override
  Future<bool> deleteFile(String path) async {
    // Web平台的文件删除实现
    throw UnimplementedError('Web file deletion not implemented');
  }
}
