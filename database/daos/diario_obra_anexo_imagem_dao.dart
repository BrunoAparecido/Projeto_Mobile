import 'package:drift/drift.dart';
import 'package:lotus_mobile/database/database.dart';
import 'dart:typed_data';
import 'package:lotus_mobile/database/tables/diario_obra_anexo_imagem_table.dart';

part 'diario_obra_anexo_imagem_dao.g.dart';

@DriftAccessor(tables: [DiarioObraAnexoImagem])
class DiarioObraAnexoImagemDao extends DatabaseAccessor<AppDatabase>
    with _$DiarioObraAnexoImagemDaoMixin {
  DiarioObraAnexoImagemDao(AppDatabase db) : super(db);

  Future<DiarioObraAnexoImagemData?> getByGuid(String guid) async {
    return await (select(diarioObraAnexoImagem)
          ..where((tbl) => tbl.guidControleUpload.equals(guid)))
        .getSingleOrNull();
  }

  Future<void> inserirImagem({
    required String guidControleUpload,
    required Uint8List imagemBytes,
  }) async {
    await into(diarioObraAnexoImagem).insert(
      DiarioObraAnexoImagemCompanion.insert(
        guidControleUpload: guidControleUpload,
        imagemBytes: imagemBytes,
        dataDownload: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deletarImagem(String guid) async {
    await (delete(diarioObraAnexoImagem)
          ..where((tbl) => tbl.guidControleUpload.equals(guid)))
        .go();
  }

  Future<List<DiarioObraAnexoImagemData>> listarTodas() async {
    return await select(diarioObraAnexoImagem).get();
  }
}