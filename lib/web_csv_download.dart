// Only imported on web
import 'dart:html' as html;

void downloadCsvWeb(String csv, String filename) {
  final bytes = html.Blob([csv], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
