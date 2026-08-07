/*
 * Joystick Breakout Controller — прошивка для Arduino
 *
 * Считывает значения с аналогового 2-осевого джойстика (модуль KY-023 / HW-504)
 * и передаёт их по последовательному порту в формате "Y,X,reset\n"
 * для приёма скетчем Processing (см. ../../processing/breakout_game).
 *
 * Подключение:
 *   VRx -> A0
 *   VRy -> A1
 *   +5V -> 5V
 *   GND -> GND
 */

#define axisX A0 // Ось Х джойстика, отвечающая за движение вверх и вниз
#define axisY A1 // Ось Y джойстика, отвечающая за движение влево и вправо

void setup()
{
  // Обозначим оси как выходы
  pinMode(axisX, INPUT);
  pinMode(axisY, INPUT);

  // Установим соединение с Serial портом
  Serial.begin(9600);
}

void loop()
{
  // Переменные для передачи данных
  int Y = analogRead(axisY);
  int X = analogRead(axisX);

  // Протокол передачи данных
  Serial.print(Y);
  Serial.print(",");
  Serial.print(X);
  Serial.print(",");
  Serial.println(1);
}
