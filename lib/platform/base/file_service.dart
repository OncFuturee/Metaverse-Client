abstract class FileService {
  Future<String?> saveFile(String path, List<int> bytes);
  Future<List<int>?> readFile(String path);
  Future<bool> deleteFile(String path);
  Future<bool> fileExists(String path);
}
