/*
 * Breakout Game — графическая часть проекта (Processing 4)
 *
 * Принимает данные с Arduino по последовательному порту
 * (см. ../../arduino/joystick_controller) и управляет платформой
 * в аркадной игре "Breakout" при помощи аналогового джойстика.
 */

// Подключаем библиотеку для работы с Serial
import processing.serial.*;

Serial myPort;

// Переменные для значений, получаемых с датчика
int reset, axisX, axisY;

// Переменные движения платформы
int moveX, moveY;

// Переменные для изменения скорости платформы
int Xspeed = 3;
int Yspeed = 3;

// Переменные для определения положения и скорости шарика
int nowmove = 0;
int BallSpeedX = 2;
int BallSpeedY = 2;
int BallPosX, BallPosY;

// Переменные для "уничтожения" кирпичей
int[] destroy = new int[7];

// Положение первого кирпича
int brickX = 200;
int brickY = 370;

// Цвет и "округление" кирпича
color brcol = color(240, 248, 255);
int round = 20;

// Переменные для вывода счета
int[] ScoreCount = new int[7];
int score;
int printscore;
int fontSize = 36;

// Переменные для определения победы или поражения
int win;
int lives = 3;
int start = 0;

void setup()
{
  // Определение размера поля
  size(640, 450);

  // Протокол
  println("=== Доступные COM-порты ===");
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    println(i + ": " + ports[i]);
  }
  println("===========================");

  // Используем первый доступный порт
  if (ports.length > 0) {
    String portName = ports[0];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
    println("Успешно подключен к: " + portName);
  } else {
    println("ERROR: Нет доступных COM-портов!");
  }

  // Фигуры без рамки
  noStroke();

  // Начальное положение и скорость
  // платформы и мячика
  moveX = width / 2;
  moveY = 15;
  BallPosX = width / 2;
  BallPosY = 50;
  Xspeed = 0;
  Yspeed = 0;
  BallSpeedY = 0;
  BallSpeedX = 0;
}

// Протокол
void serialEvent(Serial myPort)
{
  String inputString = myPort.readStringUntil('\n');
  inputString = trim(inputString);
  int axises[] = int(split(inputString, ','));
  if (axises.length == 3)
  {
    axisY = axises[0];
    axisX = axises[1];
    reset = axises[2];
  }
}

// В этом методе вызываются методы игры
void draw()
{
  // Цвет фона в grb или html, по умолчанию - черный
  background(#000033);
  // Цвет заполнения в grb или html, по умолчанию - белый
  fill(#F0F8FF);

  // Код игры
  StartScreeen();
  if (start == 1)
  {
    Start();
    Score();
    Brick();
    Ball();
    Joystick();
    Reset();
    Win();
    Dead();
  }
  // Управление платформой с помощью джойстика
}

void Joystick()
{
  if (axisY > 1000)
  {
    if (moveX > 0)
    {
      moveX -= Xspeed;
    }
  } else if (axisY < 10)
  {
    if (moveX < 560)
    {
      moveX += Xspeed;
    }
  }

  if (axisX > 1000)
  {
    if (moveY < 50)
    {
      moveY += Yspeed;
    }
  } else if (axisX < 10)
  {
    if (moveY >= 5)
    {
      moveY -= Yspeed;
    }
  }

  rect(moveX, moveY, 80, 15, 10);
  // цвет платформы
  fill(#FF5733); // Оранжево-красный цвет
  rect(moveX, moveY, 80, 15, 10);
}

// Описание движения шарика при столкновении с краем, платформой
// вызов метода уничтожения кирпичей при касании
void Ball()
{
  if (BallPosX >= 630 || BallPosX <= 0)
  {
    BallSpeedX =- BallSpeedX;
  }
  if (BallPosY >= 440)
  {
    BallSpeedY =- BallSpeedY;
  }
  if (BallPosX >= moveX && BallPosX <= moveX + 80 && BallPosY >= moveY && BallPosY <= moveY + 15)
  {
    BallSpeedY =- BallSpeedY;
  }

  if (BallPosX >= brickX && BallPosX <= brickX + 30 && BallPosY >= brickY && BallPosY <= brickY + 30)
  {
    destroy[0] = 1;
  }
  if (BallPosX >= brickX + 60 && BallPosX <= brickX + 90 && BallPosY >= brickY && BallPosY <= brickY + 30)
  {
    destroy[1] = 1;
  }
  if (BallPosX >= brickX + 120 && BallPosX <= brickX + 150 && BallPosY >= brickY && BallPosY <= brickY + 30)
  {
    destroy[2] = 1;
  }
  if (BallPosX >= brickX + 175 && BallPosX <= brickX + 225 && BallPosY >= brickY && BallPosY - 5 <= brickY + 35)
  {
    destroy[3] = 1;
  }
  if (BallPosX >= brickX + 60 && BallPosX <= brickX + 90 && BallPosY >= brickY - 60 && BallPosY <= brickY - 30)
  {
    destroy[4] = 1;
  }
  if (BallPosX >= brickX + 120 && BallPosX <= brickX + 150 && BallPosY >= brickY - 120 && BallPosY <= brickY - 60)
  {
    destroy[5] = 1;
  }
  if (BallPosX >= brickX + 90 && BallPosX <= brickX + 120 && BallPosY >= brickY - 120 && BallPosY <= brickY - 60)
  {
    destroy[6] = 1;
  }

  BallPosX += BallSpeedX;
  BallPosY += BallSpeedY;

  // цвет шарика
  fill(#33FF57); // Зеленый цвет
  rect(BallPosX, BallPosY, 20, 20, 30);
  rect(BallPosX, BallPosY, 20, 20, 30);
}

// Описание кирпичей и уничтожение, при вызове
void Brick()
{
  // Массив цветов для каждого кирпича
  color[] brickColors = {
    #FF5733, // оранжевый
    #33FF57, // зеленый
    #3357FF, // синий
    #F333FF, // фиолетовый
    #FFFF33, // желтый
    #33FFFF, // бирюзовый
    #FF33F3  // розовый
  };

  for (int i = 0; i < 7; i++) {
    if (destroy[i] == 0) {
      fill(brickColors[i]);
      // Рисуем кирпич в зависимости от индекса
      switch(i) {
        case 0: rect(brickX, brickY, 30, 30, round); break;
        case 1: rect(brickX + 60, brickY, 30, 30, round); break;
        case 2: rect(brickX + 120, brickY, 30, 30, round); break;
        case 3: rect(brickX + 180, brickY, 30, 30, round); break;
        case 4: rect(brickX + 60, brickY - 60, 30, 30, round); break;
        case 5: rect(brickX + 120, brickY - 60, 30, 30, round); break;
        case 6: rect(brickX + 90, brickY - 120, 30, 30, round); break;
      }
    }
  }
  fill(#F0F8FF); // Возвращаем стандартный цвет
}

// Подсчет очков и вывод их на экран
void Score()
{
  PFont myFont = createFont(PFont.list()[6], fontSize);
  textFont(myFont);
  text(printscore, fontSize, fontSize);
  text(lives, width-fontSize, fontSize);
}

// Условия победы
void Win()
{
  if (score == 7)
  {
    win = 1;
    BallSpeedY = 0;
    BallSpeedX = 0;
    clear();
    background(#898383);
    text("You win!", 250, height / 2);
  }
}

// Рестарт игры в случае победы или поражения
void Reset()
{
  if ( reset == 0 && win == 1 || reset == 0 && lives == 0)
  {
    moveX = width / 2 - 60;
    moveY = 15;
    BallPosX = width / 2 - 40;
    BallPosY = 50;
    score = 0;
    printscore = 0;
    for (int val = 0; val < 7; val++)
    {
      ScoreCount[val] = 0;
      destroy[val] = 0;
    }
    BallSpeedY = 0;
    BallSpeedX = 0;
    Xspeed = 0;
    Yspeed = 0;
    win = 0;
    lives = 3;
    nowmove = 0;
    Start();
  }
}

// Определение смерти и отъема жизней
// или поражения, если жизни закончились
void Dead()
{
  if (BallPosY <= 0 && lives != 0)
  {
    lives -= 1;
    BallSpeedY = 0;
    BallSpeedX = 0;
    moveX = width / 2 - 60;
    moveY = 15;
    BallPosX = width / 2 - 40;
    BallPosY = 50;
    nowmove = 0;
    Start();
  }
  if (lives == 0)
  {
    clear();
    text("Game over!", 250, height / 2);
    BallPosX = width / 2 - 40;
    BallPosY = 50;
    Xspeed = 0;
    Yspeed = 0;
    BallSpeedY = 0;
    BallSpeedX = 0;
    Reset();
  }
}

// Старт игры по нажатию кнопки
void Start()
{
  if (reset == 0 && nowmove == 0)
  {
    BallSpeedY = 2;
    BallSpeedX = 2;
    Xspeed = 3;
    Yspeed = 1;
    nowmove = 1;
  }
}

// Стартовый экран
void StartScreeen()
{
  if (start == 0)
  {
    clear();
    PFont myFont = createFont(PFont.list()[6], fontSize);
    textFont(myFont);
    background(#898383);
    text("Press the button!", 210, height / 2);
    if (reset == 0)
    {
      background(#898383);
      start = 1;
    }
  }
}
