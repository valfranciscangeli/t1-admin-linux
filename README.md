[Versión en expañol](#cómo-jugar)

---

# How to Play

1. Give execution permission to the main script:

   ```bash
   chmod +x game.sh
   ```

2. Then run it with:

   ```bash
   ./game.sh
   ```

3. **Follow the on-screen instructions** to interact with the game.

---

## ⚙️ Design Decisions

### 🗂️ Folder Naming Scheme

- Folders are named using the format `dir_xy`, where `x` is the depth level and `y` is the folder number within that level, to make them easy to identify and organize.

### 📄 File Generation

- Files are named `file_x.txt`, where `x` is a consecutive number based on their creation order from left to right in the folder tree.
- For instance, in a tree with depth 2, width 3, and 4 files per folder, the last file will be `file_32.txt` because \( x = 2^3  imes 4 \).
- File contents vary depending on the mode:
  - `name`: all files contain the string `"abcd"`.
  - `content` and `checksum`: filled with a random string.
  - `encrypted` and `signed`: contain a random line from the song **“Osito Gominola (2007)”**, extracted from `gominola.txt`, so **do not delete this file**.

### 💾 State Persistence

- The game state is saved in plain text files within `/tmp`.
- All temporary files are deleted when the game ends, **except** `/tmp/root_dir_name.txt`, which is retained for internal cleanup logic.

### 🎮 Game Considerations

- The number of treasure-hunt attempts is unlimited, making the game potentially infinite. However, the user is prompted after each round to decide whether to continue.
- Candidate paths must be fully specified, starting with `./board_root/...`.
- In `encrypted` mode, the path must point to the encrypted file, since the original `.txt` is deleted during treasure placement.
- In `signed` mode, the `.pem` files generated for key creation are removed after use, as they are not needed for gameplay. The public key is stored temporarily to validate candidate files later on.

---

# ¿Cómo jugar?

1. Da permisos de ejecución al archivo principal:

   ```bash
   chmod +x game.sh
   ```

2. Luego ejecuta el script:

   ```bash
   ./game.sh
   ```

3. **Sigue las instrucciones en pantalla** para interactuar con el juego.

---

## ⚙️ Decisiones de Diseño

### 🗂️ Nombramiento de Carpetas

- Las carpetas siguen el formato `dir_xy`, donde `x` representa el nivel de profundidad (depth) y `y` el número de carpeta (width) dentro de ese nivel. Esto facilita su identificación y organización jerárquica.

### 📄 Generación de Archivos

- Los archivos se nombran como `file_x.txt`, donde `x` es un número consecutivo que representa el orden de creación de izquierda a derecha en el árbol de carpetas.
- Por ejemplo, en un árbol de profundidad 2, ancho 3 y 4 archivos por carpeta, el último archivo será `file_32.txt`, ya que \( x = 2^3\cdot4 \).
- El contenido de los archivos varía según el modo:
  - `name`: todos contienen el texto `"abcd"`.
  - `content` y `checksum`: contienen una cadena aleatoria.
  - `encrypted` y `signed`: contienen una línea aleatoria de la canción **“Osito Gominola (2007)”**, extraída desde `gominola.txt`. Por eso, **no debe eliminarse este archivo**.

### 💾 Persistencia del Estado

- El estado del juego se guarda en archivos de texto dentro de `/tmp`.
- Todos estos archivos se eliminan al finalizar, **excepto** `/tmp/root_dir_name.txt`, que se conserva para permitir el borrado correcto del resto de archivos.

### 🎮 Consideraciones del Juego

- No se limitó la cantidad de intentos para encontrar el tesoro, permitiendo que el juego sea potencialmente infinito. Sin embargo, después de cada intento se le consulta al jugador si desea continuar.
- Las rutas candidatas deben ingresarse completas, comenzando con `./board_root/...`.
- En el modo `encrypted`, se debe ingresar la ruta del archivo encriptado, ya que los archivos originales `.txt` son eliminados al esconder el tesoro.
- En el modo `signed`, los archivos `.pem` generados durante la creación de llaves se eliminan automáticamente tras su uso, ya que no son necesarios para la lógica posterior. La llave pública se almacena temporalmente para realizar las validaciones.

---
⬆️ [Volver al inicio](#how-to-play)
