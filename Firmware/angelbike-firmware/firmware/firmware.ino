#include <U8glib.h>
#include "right.h"
#include "right_line.h"
#include "left.h"
#include "left_line.h"
#include "up.h"
#include "up_line.h"
#include "risco.h"
#include "buraco.h"
#include "logo.h"

#include <SoftwareSerial.h>

#define BLE_RX  5
#define BLE_TX  6
#define BLE_EN 7
#define BUZZER 9
#define ALERT1 2
#define ALERT2 3
#define TEMPERATURE A0
#define RIGHT_LED 10
#define LEFT_LED 11

#define NOTIF_FREQ 3000

#define DIR_RIGHT_CMD 1
#define DIR_LEFT_CMD 2
#define NOT_CMD 3
#define HOLE_CMD 8
#define DIR_UP_CMD 9
#define RISK_CMD 10

int cmdCode = 0, flip = 0, notif = 0, oldCmdCode, doPost = 1, doSplash = 0;
volatile int sendAlert1 = 0, sendAlert2 = 0;

SoftwareSerial BLE (BLE_RX, BLE_TX); // RX, TX
U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

void POST(void) {
  BLE.println("AT");
  delay(500);
  if ( BLE.find("OK") ) u8g.drawStr(0, 20, "BLE: OK!");
  else u8g.drawStr(0, 20, "BLE failed!");
}

void Splash(void) {
  u8g.drawXBMP(0, 0, logo_width, logo_height, logo_bits);
}

void drawRightArrow() {
  if (flip) u8g.drawXBMP(0, 0, right_width, right_height, right_bits);
  else u8g.drawXBMP(0, 0, right_line_width, right_line_height, right_line_bits);
}

void drawLeftArrow() {
  if (flip) u8g.drawXBMP(0, 0, left_width, left_height, left_bits);
  else u8g.drawXBMP(0, 0, left_line_width, left_line_height, left_line_bits);
}

void drawUpArrow() {
  if (flip) u8g.drawXBMP(50 , 0, up_width, up_height, up_bits);
  else u8g.drawXBMP(50, 0, up_line_width, up_line_height, up_line_bits);
}

void drawRisk() {
  u8g.drawXBMP(0, 0, risco_width, risco_height, risco_bits);
}

void drawBuraco() {
  u8g.drawXBMP(0, 0, buraco_width, buraco_height, buraco_bits);
}

void notify(int code) {
  if (!notif) return;
  notif = 0;
  tone(BUZZER, NOTIF_FREQ);
  delay(200 * (code - NOT_CMD + 1));
  noTone(BUZZER);
  delay(200 * (code - NOT_CMD + 1));
  for (int i = 0; i < code - NOT_CMD; i++) {
    tone(BUZZER, NOTIF_FREQ);
    delay(200 * (code - NOT_CMD + 1 + i));
    noTone(BUZZER);
    delay(200 * (code - NOT_CMD + 1 - i));
  }
}

void isrAlert1 () {
  sendAlert1 = 1;
}

void isrAlert2 () {
  sendAlert2 = 1;
}



void setup(void) {

  Serial.begin(9600);
  BLE.begin(9600);
  u8g.setFont(u8g_font_unifont);
  pinMode(BUZZER, OUTPUT);
  pinMode(ALERT1, INPUT_PULLUP);
  pinMode(ALERT2, INPUT_PULLUP);
  pinMode(BLE_EN, OUTPUT);
  pinMode(RIGHT_LED, OUTPUT);
  pinMode(LEFT_LED, OUTPUT);


  digitalWrite(BLE_EN, LOW);
  delay(2000);
  digitalWrite(BLE_EN, HIGH);
  delay(2000);

  attachInterrupt(digitalPinToInterrupt(ALERT1), isrAlert1, FALLING);
  attachInterrupt(digitalPinToInterrupt(ALERT2), isrAlert2, FALLING);

}

int mapCmd2Code(String cmd) {
  notif = NOTIF_FREQ;
  if (cmd.startsWith("DIR+RIGHT") ) return DIR_RIGHT_CMD;
  else if (cmd.startsWith("DIR+LEFT") ) {
    return DIR_LEFT_CMD;
  }
  else if (cmd.startsWith("NOT+1") ) {
    return NOT_CMD;
  }
  else if (cmd.startsWith("NOT+2") ) {
    return NOT_CMD + 1;
  }
  else if (cmd.startsWith("NOT+3") ) {
    return NOT_CMD + 2;
  }
  else if (cmd.startsWith("NOT+4") ) {
    return NOT_CMD + 3;
  }
  else if (cmd.startsWith("NOT+5") ) {
    return NOT_CMD + 4;
  }
  else if (cmd.startsWith("HOLE") ) {
    return HOLE_CMD;
  }
  else if (cmd.startsWith("DIR+UP") ) {
    return DIR_UP_CMD;
  }
  else if (cmd.startsWith("RISK") ) {
    return RISK_CMD;
  }
}

void loop(void) {

  //recebe comandos do BLE
  String cmd;
  int k;
  float temp;

  cmd = BLE.readStringUntil('\n');
  if (cmd.length() >= 3) {
    oldCmdCode = cmdCode;
    cmdCode = mapCmd2Code(cmd);
    if (cmdCode > DIR_LEFT_CMD && cmdCode <= NOT_CMD + 4) {
      notify(cmdCode);
      cmdCode = oldCmdCode;
    }
  }

  // picture loop
  u8g.firstPage();
  do {
    if (doPost == 1) POST();
    if (doSplash == 1 && cmdCode == 0) Splash();
    else if (cmdCode == DIR_RIGHT_CMD) drawRightArrow();
    else if (cmdCode == DIR_LEFT_CMD) drawLeftArrow();
    else if (cmdCode == DIR_UP_CMD) drawUpArrow();
    else if (cmdCode == RISK_CMD) drawRisk();
    else if (cmdCode == HOLE_CMD) drawBuraco();
  } while ( u8g.nextPage() );

  //led auxiliar
  if (cmdCode == DIR_RIGHT_CMD ) {
    digitalWrite(RIGHT_LED, flip);
  } else digitalWrite(RIGHT_LED, LOW);

  if (cmdCode == DIR_LEFT_CMD ) {
    digitalWrite(LEFT_LED, flip);
  } else digitalWrite(LEFT_LED, LOW);

  //animacao
  flip = !flip;

  if (doPost) {
    doPost = 0;
    doSplash = 1;
  }

  //alertas
  if (sendAlert1) {
    BLE.println("ALT+1");
    sendAlert1 = 0;
  }
  if (sendAlert2) {
    BLE.println("ALT+2");
    sendAlert2 = 0;
  }

  //temperatura
  temp = 0;
  for (k = 0; k < 10; k++) {
    temp = temp + analogRead(TEMPERATURE) * 100.0 * 5.0 / 1023.0;
    delay(5);
  }
  temp = temp / 10.0;
  BLE.print("TEMP=");
  BLE.println(temp);

  delay(50);
}

