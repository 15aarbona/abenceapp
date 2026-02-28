import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Importamos el provider que ya tiene a todos los miembros cargados
import '../../../members/data/providers/members_provider.dart';

part 'export_census_provider.g.dart';

@riverpod
class ExportCensusController extends _$ExportCensusController {
  @override
  FutureOr<void> build() {}

  Future<void> exportToExcel() async {
    state = const AsyncLoading();
    try {
      // 1. Obtenemos la lista de miembros actualizada
      final members = await ref.read(allMembersProvider.future);

      // 2. Creamos el archivo Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Cens'];
      excel.setDefaultSheet('Cens');

      // 3. Escribimos la cabecera (Primera fila)
      sheetObject.appendRow([
        TextCellValue('Nom'),
        TextCellValue('Cognoms'),
        TextCellValue('Quota'),
        TextCellValue('DNI'),
        TextCellValue('Correu Electrònic'),
        TextCellValue('Data Naixement'),
        TextCellValue('Excedència'),
      ]);

      // 4. Rellenamos con los datos de cada miembro
      for (var member in members) {
        sheetObject.appendRow([
          TextCellValue(member.nombre),
          TextCellValue(member.apellidos),
          TextCellValue(member.tipoCuota.toUpperCase()),
          TextCellValue(member.dni ?? 'Sense DNI'), // Si no tiene DNI, ponemos esto
          TextCellValue(member.email ?? 'Sense correu'),
          TextCellValue(member.fechaNacimiento != null 
              ? DateFormat('dd/MM/yyyy').format(member.fechaNacimiento!) 
              : 'Sense data'),
          TextCellValue(member.excedencia ? 'Sí' : 'No'), // Convertimos el true/false en Sí/No
        ]);
      }

      // 5. Guardamos el archivo en el dispositivo
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
        final filePath = '${directory.path}/Cens_Fila_$dateStr.xlsx';
        
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // 6. Abrimos el menú de compartir nativo del móvil
        await Share.shareXFiles([XFile(filePath)], text: 'Cens complet de la Filà');
      }

      state = const AsyncData(null);
    } catch (e, stack) {
      print('Error a l\'exportar: $e');
      state = AsyncError(e, stack);
      throw Exception('No s\'ha pogut generar l\'Excel');
    }
  }
}