#AngelBike Firmware

##AngelHack 2016 @ São Paulo


* Dependências
  * U8glib (https://github.com/olikraus/u8glib)

* Executando e carregando o código.
  * Todo o procedimento pode ser executado através da Arduino IDE
  * Instalar a U8glib (https://www.arduino.cc/en/Guide/Libraries)
  * Abrir o sketch firmware.ino
  * Usar a Arduino IDE para compilar e gravar

* Referência

| COMANDO  | DESCRIÇÃO |
| ------------- | ------------- |
| DIR+UP  | Desenha uma seta para frente no display.  |
| DIR+LEFT  | Desenha uma seta para a esquerda e aciona o LED auxiliar esquerdo  |
| DIR+RIGHT  | Desenha uma seta para a direita e aciona o LED auxiliar direito  |
| NOT+(1-5)  | Emite um aviso sonoro de duração proporcional ao parâmetro inserido  |
| HOLE  | Desenha o símbolo de Buraco Reportado  |
| RISK  | Desenha o símbolo Perido Reportado |

| COMANDO  | DESCRIÇÃO |
| ------------- | ------------- |
| ALT+N  | Usuário reportou situação usando o botão N  |
| TEMP=T  | A temperatura do ambiente em graus Celsius  |
