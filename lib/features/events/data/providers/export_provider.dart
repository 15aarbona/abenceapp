import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/event_model.dart';

part 'export_provider.g.dart';

@riverpod
class ExportEventController extends _$ExportEventController {
  @override
  FutureOr<void> build() {}

  Future<void> exportToExcel(EventModel event, List<dynamic> attendees) async {
    state = const AsyncLoading();
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Assistents'];
      excel.setDefaultSheet('Assistents');

      // 1. Cabeceras principales (Le hemos quitado el const)
      sheetObject.appendRow([
        TextCellValue('Nom i Cognoms'),
        TextCellValue('Tipus'),
        TextCellValue('Menú Triat'),
      ]);

      // Preparativos para contar
      Map<String, int> menuCounts = {};
      int totalAttendees = attendees.length;

      // 2. Rellenamos la lista y contamos los menús a la vez
      for (var attendee in attendees) {
        final isGuest = attendee['guest_name'] != null;
        final profileInfo = attendee['profiles'] ?? {};
        
        final String fullName = isGuest 
            ? '${attendee['guest_name']}'
            : '${profileInfo['nombre'] ?? 'Anònim'} ${profileInfo['apellidos'] ?? ''}';
        
        final tipo = isGuest ? 'Convidat' : 'Membre';
        final menu = attendee['menu_option']?.toString() ?? 'Sense menú';

        // Sumar al contador este menú concreto
        menuCounts[menu] = (menuCounts[menu] ?? 0) + 1;

        sheetObject.appendRow([
          TextCellValue(fullName),
          TextCellValue(tipo),
          TextCellValue(menu),
        ]);
      }

      // 3. --- SECCIÓN DE RESUMEN (Al final del Excel) ---
      sheetObject.appendRow([TextCellValue('')]); // Dejamos filas en blanco (sin const)
      sheetObject.appendRow([TextCellValue('')]); 
      
      sheetObject.appendRow([
        TextCellValue('RESUM DE MENÚS'),
        TextCellValue('Quantitat')
      ]);

      // Escribimos cada menú y cuántos hay
      menuCounts.forEach((menuName, count) {
        sheetObject.appendRow([
          TextCellValue(menuName),
          IntCellValue(count),
        ]);
      });

      sheetObject.appendRow([TextCellValue('')]); // Fila en blanco
      sheetObject.appendRow([
        TextCellValue('TOTAL ASSISTENTS'),
        IntCellValue(totalAttendees),
      ]);

      // 4. Guardar y compartir el archivo
      var fileBytes = excel.save();
      var directory = await getTemporaryDirectory();
      
      final safeTitle = event.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      File file = File('${directory.path}/Assistents_$safeTitle.xlsx');
      
      await file.writeAsBytes(fileBytes!);

      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Llista d\'assistents i resum - ${event.title}',
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Error a l\'exportar: $e', stack);
    }
  }
}