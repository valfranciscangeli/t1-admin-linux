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
- In `encrypted` mode, the path must point to the encrypted `.gpg` file, since the original `.txt` is deleted during treasure placement.
- In `signed` mode, the `.pem` files generated for key creation are stored in the `/tmp` folder as hidden files.

---
⬆️ [Go to top](#how-to-play)
