import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ModalPdfViewer extends StatefulWidget {
  final List<int> pdfBytes;
  final String nomeArquivo;

  const ModalPdfViewer({
    super.key,
    required this.pdfBytes,
    required this.nomeArquivo,
  });

  @override
  State<ModalPdfViewer> createState() => _ModalPdfViewerState();
}

class _ModalPdfViewerState extends State<ModalPdfViewer> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _createPdfFile();
  }

  Future<void> _createPdfFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp_${widget.nomeArquivo}.pdf');
      await file.writeAsBytes(widget.pdfBytes);

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    try {
      // Solicita permissão de armazenamento
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text('Permissão de armazenamento negada'),
            //     backgroundColor: Colors.red,
            //   ),
            // );
          }
          return;
        }
      }

      // Para Android 10+ (API 29+), usar diretório público de Downloads
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Não foi possível acessar o diretório de downloads');
      }

      final file = File('${directory.path}/${widget.nomeArquivo}.pdf');
      await file.writeAsBytes(widget.pdfBytes);

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('PDF salvo em: ${file.path}'),
        //     backgroundColor: Colors.green,
        //     duration: const Duration(seconds: 4),
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Erro ao salvar PDF: $e'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2E35),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.nomeArquivo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Boomer',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // PDF Viewer
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/loading-screen-spinner.gif',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Carregando PDF...',
                            style: TextStyle(
                              fontFamily: 'Boomer',
                              fontSize: 16,
                              color: Color(0xFF2C2E35),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontFamily: 'Boomer',
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : _localPath != null
                          ? Stack(
                              children: [
                                PDFView(
                                  filePath: _localPath!,
                                  enableSwipe: true,
                                  swipeHorizontal: false,
                                  autoSpacing: true,
                                  pageFling: true,
                                  pageSnap: true,
                                  onRender: (pages) {
                                    setState(() {
                                      _totalPages = pages ?? 0;
                                    });
                                  },
                                  onPageChanged: (page, total) {
                                    setState(() {
                                      _currentPage = page ?? 0;
                                    });
                                  },
                                  onError: (error) {
                                    setState(() {
                                      _errorMessage = 'Erro ao renderizar PDF: $error';
                                    });
                                  },
                                ),
                                // Indicador de página
                                if (_totalPages > 0)
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '${_currentPage + 1} / $_totalPages',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Boomer',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: Text('Erro ao carregar PDF'),
                            ),
            ),

            // Footer com botões
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontFamily: 'Boomer',
                        fontSize: 14,
                        color: Color(0xFF2C2E35),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _downloadPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2E35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Download PDF',
                      style: TextStyle(
                        fontFamily: 'Boomer',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpa o arquivo temporário
    if (_localPath != null) {
      try {
        File(_localPath!).deleteSync();
      } catch (e) {
        print('Erro ao deletar arquivo temporário: $e');
      }
    }
    super.dispose();
  }
}