import processing.sound.*;

boolean cogumelofinal = false;
SoundFile soundFile;
Amplitude analyzer;

int numerogill = 450;
float maxangle = TWO_PI;
float raiobase = 40;
float raiomaximo = 100;
float growth = 0;
boolean blurring = true;
int ncogumelos = 10;
float shape, shape2;

PGraphics pg;
float lastAmp = 0;

Figure[] figures = new Figure[ncogumelos];
int activeIndex = 0;

Figure figurafinal;
boolean startfigurafinal= false;
int startTime;

void setup() {
  size(800, 700);
  pg = createGraphics(width, height);
  noFill();
  frameRate(100);

  soundFile = new SoundFile(this, "2.mp3");
  soundFile.loop();
  analyzer = new Amplitude(this);
  analyzer.input(soundFile);

  for (int i = 0; i < figures.length; i++) {
    float raiomaximo = random(40, 150);
    float x = random(raiomaximo, width - raiomaximo);
    float y = random(raiomaximo, height - raiomaximo);
    figures[i] = new Figure(x, y, raiomaximo, random(10, 80), round(random(100, 200)), random(0.8, 20));
  }

  figurafinal = new Figure(width/2, height/2, 500, 60, 800, 0);
  figurafinal.shapeAdd = 0.5;
  figurafinal.shapeAdd2 = 0.5;
  figurafinal.stop = false;

  startTime = millis();
}

void draw() {
    if (millis() - startTime >= 35000) {
    return; 
  }
  background(0);

  pg.beginDraw();
  pg.fill(0);

  for (int i = 0; i <= activeIndex; i++) {
    if (i < figures.length) {
      Figure f = figures[i];
      if (!f.stop) {
        f.update();
        f.shaping();
      }
      f.display(pg);
    }
  }

  if (activeIndex < figures.length) {
    Figure currentFigure = figures[activeIndex];
    if (currentFigure.stop) {
      activeIndex++;
    }
  }

  pg.endDraw();
  image(pg, 0, 0);

  // Verifica se passaram 20 segundos
  if (millis() - startTime >= 30000) {
    startfigurafinal = true;
  }

  // Desenha a figura final por cima de tudo
  if (startfigurafinal) {
    pg.beginDraw();
    figurafinal.update();
    figurafinal.shaping();
    figurafinal.display(pg);
    pg.endDraw();
    image(pg, 0, 0);
  }
}

class Figure {
  float x, y;
  float raiomaximo;
  float raiobase;
  float growth;
  boolean blurring = true;
  float maxangle = TWO_PI;
  int numerogill;
  float shape, shape2;
  float shapeAdd, shapeAdd2;
  boolean stop = false;
  float t;

  Figure(float x, float y, float raiomaximo, float raiobase, int numerogill, float growth) {
    this.x = x;
    this.y = y;
    this.raiomaximo = raiomaximo;
    this.raiobase = raiobase;
    this.numerogill = numerogill;
    this.growth = growth;
    this.t = random(1000);
    this.shape = 10;
    this.shape2 = -10;
    this.shapeAdd = random(0.1, 1);
    this.shapeAdd2 = random(0.1, 1);
  }

  void update() {
    if (!stop) {
      growth += 1.5;
      if (growth >= 100) {
        growth = 100;
      }
    }
  }

  void display(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(x, y);
    pg.fill(0);

    // Stroke dinâmico para finalFigure
    if (this == figurafinal) {
      float dynamicStroke = map(growth, 0, 100, 0.1, 1);
      pg.strokeWeight(dynamicStroke);
      pg.stroke(0);
    } else {
      pg.strokeWeight(0.1);
      pg.stroke(255);
    }

    if (blurring && frameCount % 1 == 0 ) {
      pg.filter(BLUR, 0.1);
    }

    float raiomaximoatual = raiomaximo * (growth / 100.0);

    for (int i = 0; i < numerogill; i++) {
      float norm = i / float(numerogill);
      float anglevariacao = sin(t + i * 0.1) * 0.1;
      float angle = map(norm, 0, 1, -maxangle / 2, maxangle / 2) + anglevariacao;

      float offsetraio = noise(i * 0.1, t) * 5;
      float raiofinal = raiomaximo + offsetraio;

      float baseX = cos(angle);
      float baseY = -sin(angle);

      pg.beginShape();

      for (float rStep = raiobase; rStep <= raiofinal; rStep += 5) {
        if (rStep <= raiomaximoatual) {
          float n = noise(i * 0.1, rStep * 0.01, t);
          float offset = map(n, 0, 1, shape, shape2);
          float xPos = baseX * rStep + offset * baseY;
          float yPos = baseY * rStep + offset * baseX;
          pg.vertex(xPos, yPos);
        }
      }
      pg.endShape();
    }

    pg.popMatrix();
  }

  void shaping() {
    if (!stop) {
      shape += shapeAdd;
      shape2 += shapeAdd2;

   
        float amp = analyzer.analyze();
        t += amp;
    }

      if (shape > 200 && shape2 > 200) {
        stop = true;
      }

      // trava finalFigure ao atingir tamanho máximo
      if (this == figurafinal && growth >= 100) {
        stop = true;
      }
    }
  
}
