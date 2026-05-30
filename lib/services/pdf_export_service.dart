import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/services/veiculo_service.dart';

class PdfExportService {
  static Future<Uint8List> gerarRelatorioAbastecimentos({
    required Veiculo veiculo,
    required List<Abastecimento> abastecimentos,
    String? filtroTipoCombustivel,
    DateTime? filtroDataInicial,
    DateTime? filtroDataFinal,
  }) async {
    final pdf = pw.Document();

    // Carregar fonte com suporte a Unicode (acentos, R$, etc.)
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
      italic: fontItalic,
    );

    // Helper functions for formatting
    String formatarData(DateTime dt) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    String formatarMoeda(double valor) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    String formatarDecimal(double valor) {
      return valor.toStringAsFixed(2).replaceAll('.', ',');
    }

    // Calcular totais
    double totalLitros = 0.0;
    double totalGasto = 0.0;
    for (var a in abastecimentos) {
      totalLitros += a.quantidade;
      totalGasto += a.valorTotal;
    }

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório de Abastecimentos',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Veículo: ${veiculo.apelido} (${veiculo.marca} ${veiculo.modelo} - ${veiculo.ano})',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Placa: ${veiculo.placa}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Gerado em: ${formatarData(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Filtros Aplicados
          if (filtroTipoCombustivel != null ||
              filtroDataInicial != null ||
              filtroDataFinal != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Filtros Aplicados:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.SizedBox(height: 2),
                  if (filtroTipoCombustivel != null)
                    pw.Text('• Tipo de Combustível: $filtroTipoCombustivel', style: const pw.TextStyle(fontSize: 9)),
                  if (filtroDataInicial != null || filtroDataFinal != null)
                    pw.Text(
                      '• Período: ${filtroDataInicial != null ? formatarData(filtroDataInicial) : "Início"} até ${filtroDataFinal != null ? formatarData(filtroDataFinal) : "Fim"}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Tabela de Abastecimentos
          pw.TableHelper.fromTextArray(
            headers: [
              'Data',
              'Posto',
              'Combustível',
              'Qtd (L)',
              'Valor Total',
              'Odômetro (km)'
            ],
            data: abastecimentos.map((a) {
              return [
                formatarData(a.data),
                a.posto,
                a.tipoCombustivel,
                '${formatarDecimal(a.quantidade)} L',
                formatarMoeda(a.valorTotal),
                '${formatarDecimal(a.odometro)} km',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Resumo dos Totais
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 250,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey700, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Resumo Geral (Filtrado)',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blueGrey700,
                    ),
                  ),
                  pw.Divider(color: PdfColors.blueGrey700, thickness: 1),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Abastecimentos:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('${abastecimentos.length}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Litros:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('${formatarDecimal(totalLitros)} L', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Valor Total Gasto:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(formatarMoeda(totalGasto), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> gerarRelatorioVeiculos({
    required List<Veiculo> veiculos,
    String? busca,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
      italic: fontItalic,
    );

    String formatarData(DateTime dt) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    String formatarMoeda(double valor) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    String formatarDecimal(double valor) {
      return valor.toStringAsFixed(2).replaceAll('.', ',');
    }

    // Calcular totais
    final veiculoService = VeiculoService();
    double totalGastoGeral = 0.0;
    int totalAbastecimentosGeral = 0;
    for (var v in veiculos) {
      totalGastoGeral += veiculoService.calcularTotalGasto(v);
      totalAbastecimentosGeral += v.abastecimentos.length;
    }

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório Geral da Frota',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Controle de Veículos',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Gerado em: ${formatarData(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Filtros Aplicados
          if (busca != null && busca.trim().isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'Filtro de busca: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text('"$busca"', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Tabela de Veículos
          pw.TableHelper.fromTextArray(
            headers: [
              'Apelido',
              'Marca/Modelo/Ano',
              'Placa',
              'Qtd. Abast.',
              'Média Consumo',
              'Gasto Total'
            ],
            data: veiculos.map((v) {
              double mediaKmLitro = veiculoService.calcularUltimoConsumoSeguro(v);
              if (mediaKmLitro == 0) mediaKmLitro = veiculoService.calcularMediaGlobal(v);

              return [
                v.apelido,
                '${v.marca} ${v.modelo} (${v.ano})',
                v.placa,
                '${v.abastecimentos.length}',
                mediaKmLitro > 0 ? '${formatarDecimal(mediaKmLitro)} km/L' : 'N/A',
                formatarMoeda(veiculoService.calcularTotalGasto(v)),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Resumo dos Totais
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 250,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey700, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Resumo da Frota (Filtrado)',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blueGrey700,
                    ),
                  ),
                  pw.Divider(color: PdfColors.blueGrey700, thickness: 1),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Veículos:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('${veiculos.length}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Abastecimentos:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('$totalAbastecimentosGeral', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Gasto Geral Frota:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(formatarMoeda(totalGastoGeral), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
