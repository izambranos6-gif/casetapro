# CASETAPRO — Control de Balanceado (Flutter)

## Rediseño elegante v1.1

Se modernizó únicamente la interfaz de Flutter: paleta azul petróleo/turquesa/verde, tarjetas con sombras discretas, selección de zona, menú, formulario y opciones de reporte. En Flutter Web se centra la interfaz a un ancho cómodo para probarla en navegador. No modifica el catálogo de 46 piscinas ni el almacenamiento ni el contenido de los reportes exportados. El reporte sigue completamente neutro.

**Actualización desde la versión anterior:** sube el ZIP a la raíz de tu repositorio *casetapro*, descomprímelo con `unzip -o CasetaPro_Rediseno_Elegante_Flutter.zip`, ejecuta `flutter pub get` y `flutter analyze`; luego arranca `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`. Detén primero cualquier servidor que ya ocupe el puerto 8080. La modificación visual no garantiza resolver posibles errores de carga previos de Flutter Web; si aparece una pantalla blanca, consulta la consola del navegador.


Proyecto **Flutter para Android y Web**, independiente del sistema web AQUAPRO. No lo modifica.

## Pantallas

1. Seleccionar zona (primera pantalla al abrir).
2. Menú principal: Nuevo Registro, Registros del Día, Generar Reporte, Consultas por Fecha.
3. Nuevo Registro por fecha/piscina: cuatro cantidades manuales.
4. Registros del Día: todas las piscinas, editar/eliminar, totales.
5. Generar Reporte: fecha + formato PNG/PDF.
6. Vista previa del reporte.
7. Compartir Reporte: WhatsApp vía menú compartir, galería, PDF, otras apps.

**Zona 1**: 24 piscinas. **Zona 2**: 22 piscinas. Los listados están en `lib/core/pools.dart`.

El reporte **no lleva** CASETAPRO, AQUAPRO, camarón, nombre del técnico ni marcas. Solo título descriptivo, zona, fecha, tabla y totales. La plantilla única está en `lib/widgets/report_table.dart`.

**Importante:** el campo «Sacos caseta» se ingresa manualmente, sin cálculo automático, para respetar los valores operativos recibidos. Solo es obligatorio ingresar números enteros no negativos en los cuatro campos; se admite 0.

## Crear y ejecutar el proyecto en GitHub Codespaces

Este paquete contiene el **código fuente** (`lib`, `test`, `pubspec.yaml`), no carpetas generadas del SDK Flutter. En un repositorio NUEVO, crea un Codespace con Flutter instalado y coloca allí los archivos de este paquete. Después, en la raíz:

```bash
flutter create . --project-name casetapro --platforms android,web
flutter pub get
flutter test
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Luego abre el puerto 8080 desde la pestaña **Puertos** de Codespaces.

En navegador, el almacenamiento es local al navegador. El archivo PNG/PDF se comparte/descarga según las capacidades del navegador; la galería nativa y WhatsApp están pensados para Android.

Para comprobar errores, ejecuta `flutter analyze` y `flutter test` después de extraer los archivos.


Para compilar APK:

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

> No ejecutes `flutter create` dentro de tu repositorio web AQUAPRO. CasetaPro usa su propio repositorio.

### Requisito para Android antiguo (solo API 29 o inferior)

Si quieres guardar imágenes en la galería de teléfonos Android antiguos, añade justo bajo `<manifest ...>` en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" />
```

En Android moderno, `gal` gestiona el guardado de imágenes. Para iOS, agrega las claves `NSPhotoLibraryAddUsageDescription` y `NSPhotoLibraryUsageDescription` en `ios/Runner/Info.plist` según las instrucciones del plugin `gal`.

### Sobre WhatsApp

La opción «Compartir por WhatsApp» abre el menú nativo para compartir; el técnico selecciona WhatsApp. No se envía automáticamente ni se elige un destinatario sin intervención del usuario.

## Persistencia

En Android los datos se guardan como JSON en almacenamiento privado del dispositivo, usando `path_provider`. En Web se guardan en el almacenamiento local del navegador con `shared_preferences`. Se mantienen al cerrar y volver a abrir salvo que borres los datos locales. **No se sincronizan entre celulares** ni existe base de datos en nube en esta primera versión. Desinstalar la aplicación puede borrar la información local. Antes de desinstalar, conserva los reportes compartidos.

## Estructura

- `lib/core`: zonas, fechas y diseño.
- `lib/models`: modelo `FeedRecord`, independiente de Flutter.
- `lib/data`: persistencia mediante interfaz `FeedRepository` y JSON local.
- `lib/state`: controlador observable para registros.
- `lib/pages`: pantallas de interfaz.
- `lib/widgets`: componentes comunes y reporte neutro.
- `lib/services`: crear PNG, PDF, galería y compartir.
- `test`: pruebas del catálogo de piscinas y datos.

## Integración futura con la web AQUAPRO

No está implementada ni se ha tocado la web. Si después decides integrarlo, se puede construir un repositorio remoto que implemente `FeedRepository`, un endpoint y autenticación conforme a las necesidades de la empresa. El modelo está separado de las pantallas para facilitarlo.

## Limitaciones

- Flutter no está instalado en el entorno donde se generó este código; debes ejecutar `flutter pub get`, `flutter test` y `flutter run` en tu Codespace para validarlo antes de distribuirlo a los técnicos.
- El reporte PDF se construye a partir de la imagen PNG del mismo reporte neutro; por ello su contenido es una imagen y no texto editable.
