
# ¿Cómo puedo jugar?

1.Para ejecutar los archivos debes dar permisos de ejecucion con 
chmod +x game.sh
2. luego ejecutar 
./game.sh
3. **Sigue las instrucciones en pantalla** para interactuar con el juego.

## Decisiones de Diseño

### Mecanismo de Nombramiento de Carpetas
- Las carpetas se nombran siguiendo el formato: `dir_xy`, con x el nivel en que se encuentra la carpeta e y el numero de carpeta dentro del nivel para poder identificarlas facilmente.

### Generación del Archivos
- El nombre de cada archivo original generado es en el formtao:  `file_x.txt`, donde x es el numero del archivo. El orden de estos numeros es consecutivo, de forma que si vemos el arbol de ejemplo, se enumeran de izquierda a derecha. Por ende, el archivo de la primera carpeta del primer nivel es file_1.txt, mientras que el ultimo archivo de un arbol de profundidad 2 y ancho 3, c on 4 archivos por carpeta es $x=2³*4$ `file_32.txt`.
- al rellenar los archivos en modo 'name' se rellenan todos con el strin "abcd", en modo 'content' y 'checksum' se rellenó con una cadena aleatoria y para los modos 'encrypted' y 'signed' se rellenó con una linea aleatoria de la cancion "Osito gominola -Osito gominola (2007)", extraida desde el archivo 'gominola.txt', por lo que es importante no borrar este archivo.

### Método de Persistencia de Estado
- El estado del juego se guarda en archivos de texto plano dentro de la carpeta "/tmp". Al terminar el juego estos archivos son borrados, excepto por el archivo '/tmp/root_dir_name.txt', ya que por logica del codigo se necesita mantener para poder borrar otros archivos. No se intentó mejorar esto ya que no es información sensible y está guardada en una carpeta temporal. 

### Consideraciones del juego
- pensé en limitar el loop para ingresar candidatos, pero me pareció más entretenido (y no se especifica) que el juego sea infinito, pero hay oportunidad de teminarlo luego de cada ronda, pues el juego consulta si el jugador desea continuar
- al ingresar una ruta candidata, se debe ingresar la ruta completa, empezando por './board_root/...' para que pueda ser valida
- al utilizar el modo encrypted se debe ingresar la ruta del archivo encriptado, pues el original es borrado al esconder el tesoro. el enunciado no especifica sobre esto, y como no afecta al juego, tomé la decision de remover todos los archvos txt originales al invocar a 'place_treasure'
- al utilizar el modo signed, los archivos .pem creados al crear las llaves en 'fill_board' y 'place_treasure' son eliminados luego de su uso, ya que no se necesitan para la logica del juego, pues la llave publica se guarda en un archivo temporal para poder comparar posteriormente a los archivos candidatos