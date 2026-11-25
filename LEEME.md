# 🐱 Reto 2: Generador de Memes de Gatos con Filtros

## Lo que pide el reto y dónde está en el código (lib/main.dart)
| Requisito | Cómo se cumple |
|---|---|
| Consumir la API de Cataas | `Image.network` con URLs de https://cataas.com |
| Gatos aleatorios | Cada "Generar" pide `/cat` o `/cat/says/...` y llega un gato distinto |
| Campo de texto con una frase | `TextField` con `TextEditingController` |
| La frase aparece sobre la foto (por URL) | `_construirUrl()` arma `/cat/says/<frase>?fontSize=..&fontColor=..` |
| Filtros | `?filter=mono / negate / blur` con `ChoiceChip` |
| Manejo de estados | `setState` en un `StatefulWidget`; al cambiar filtro/color la imagen cambia al instante |
| Ver cómo la URL cambia la respuesta | Caja "URL que se va a pedir", se actualiza en vivo |

## Cómo ejecutarlo (solo la primera vez)
Abre esta carpeta en VS Code y en la terminal (Ctrl + ñ) corre:

    flutter create .
    flutter pub get
    flutter run -d chrome

`flutter create .` agrega lo que falta (Android, Windows, etc.) sin tocar `lib/main.dart`.
Después de eso ya puedes usar F5.

Otras opciones: `flutter run -d windows` o con un emulador de Android abierto `flutter run`.

## Si algo falla
- "Failed to connect/initialize debugger": no se había corrido `flutter pub get`; corre los 3 comandos de arriba.
- Sale el gato triste 😿 en Chrome: prueba `flutter run -d windows` o en Android; revisa tu internet.
- Requiere Flutter 3.22+ (`flutter --version`, actualiza con `flutter upgrade`).
