import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadBytes(Uint8List bytes, String fileName, String mimeType) {
  final jsArray = [bytes.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

void downloadText(String text, String fileName, String mimeType) {
  final bytes = Uint8List.fromList(utf8.encode(text));
  downloadBytes(bytes, fileName, mimeType);
}
