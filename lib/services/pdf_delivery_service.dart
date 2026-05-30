import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

class PdfDeliveryService {
  /// Entrega o PDF gerado de acordo com a plataforma ativa.
  /// 
  /// - **Web**: Abre a janela de visualização do próprio pacote `printing`.
  /// - **Celular (Android/iOS)**: Salva em pasta temporária e compartilha usando `share_plus`.
  /// - **Desktop (Windows/Linux/macOS)**: Salva em pasta temporária e abre usando o leitor padrão via `open_file`.
  static Future<void> entregarPdf(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: fileName,
      );
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);

      // Compartilha no celular usando Share.shareXFiles
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Relatório PDF',
        text: 'Aqui está o relatório de abastecimento gerado.',
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);

      // Abre no leitor padrão do sistema desktop
      await OpenFile.open(file.path);
    } else {
      // Fallback para outros sistemas não mapeados
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: fileName,
      );
    }
  }
}
