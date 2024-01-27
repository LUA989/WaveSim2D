int w = 64, h = 64;
float[][] pixHeight = new float[w][h];
float[][] pixVel = new float[w][h];
float[][] pixMass = new float[w][h];

float[][] accumLight = new float[w][h];
static final float ACCUM_EXPOSURE = 0.0125;
boolean drawAccum = false;

PGraphics pg;

int targetX, targetY;

float brightness = 1.0;

int frame = 0;
float time = 0.0;

int tool = 1;
boolean drawHud = true;

void setup() {
  noSmooth();
  surface.setResizable(false);
  size(800, 800);
  pg = createGraphics(w, h);
  init();
  textAlign(LEFT, TOP);
}

void draw() {
  pg.beginDraw();
  for(int j = 0; j < h; j++) {
    for(int i = 0; i < w; i++) {
      pixHeight[i][j] += pixVel[i][j];
      accumLight[i][j] += abs(pixHeight[i][j]) * ACCUM_EXPOSURE;
      color lightColor = drawAccum ? color(accumLight[i][j] * 255) : color(abs(pixHeight[i][j]) * brightness * 255); // Absolute light coloring
      if(pixMass[i][j] < 1.0) {
        pg.stroke(red(lightColor) + 50, green(lightColor) + 60, blue(lightColor) + 70); // Glass 
      } else {
        if(pixMass[i][j] == Float.POSITIVE_INFINITY) {
          pg.stroke(63);
        } else {
          if(pixMass[i][j] > 1.0 && pixMass[i][j] < Float.POSITIVE_INFINITY) {
            pg.stroke(red(lightColor), green(lightColor), blue(lightColor) + 95);
          } else {
            pg.stroke(lightColor);
          }
        }
      }
      pg.point(i, j);
      if(drawHud) {
        pg.stroke(255, 0, 0);
        pg.point(targetX, targetY);
      }
    }
  }
  
  for(int j = 0; j < h; j++) {
    for(int i = 0; i < w; i++) {
      float force = pixHeight[min(i + 1, w - 1)][j] + pixHeight[i][max(j - 1, 0)] + pixHeight[max(i - 1, 0)][j] + pixHeight[i][min(j + 1, h - 1)];
      pixVel[i][j] += (force / 4 - pixHeight[i][j]) / pixMass[i][j];
    }
  }
  pg.endDraw();
  frame++;
  time += 1.0 / frameRate;
  //pixHeight[w / 4][h / 2] = sin(time * 0.8 * TWO_PI) * 12;
  if(mousePressed) {
    if(mouseButton == LEFT) {
      switch(tool) {
        case 0:
        pixMass[targetX][targetY] = 1.0;
        break;
        case 1:
        pixHeight[targetX][targetY] = 1.0;
        break;
        case 2:
        pixHeight[targetX][targetY] = 0.0;
        pixVel[targetX][targetY] = 0.0;
        pixMass[targetX][targetY] = Float.POSITIVE_INFINITY;
        break;
        case 3:
        pixMass[targetX][targetY] = 0.5;
        break;
        case 4:
        pixMass[targetX][targetY] = 2;
        break;
      }
    }
  }
  //pixHeight[w / 4][h / 4] = sin(time * TWO_PI);
  image(pg, 0, 0, width, height);
  targetX = clamp(round(map(mouseX, 0, width - 1, 0, w - 1)), 0, w - 1);
  targetY = clamp(round(map(mouseY, 0, height - 1, 0, h - 1)), 0, h - 1);
  if(drawHud) {
    text("Light Simulator\nFPS: " + frameRate + "\nTime: " + time + "\nFrame: " + frame + "\nBrightness: x" + brightness, 5, 5);
    text("PixHeight: " + pixHeight[targetX][targetY] + "\nPixVel: " + pixVel[targetX][targetY] + "\nPixMass: " + pixMass[targetX][targetY] + "\nAccumulated Light: " + accumLight[targetX][targetY], mouseX + 5, mouseY + 5);
  }
}

void keyPressed() {
  switch(key) {
    case 'c':
    for(int j = 0; j < h; j++) {
      for(int i = 0; i < w; i++) {
        pixHeight[i][j] = 0.0;
        pixVel[i][j] = 0.0;
        accumLight[i][j] = 0.0;
      }
    }
    break;
    case 'r':
    init();
    break;
    case '0':
    tool = 0;
    break;
    case '1':
    tool = 1;
    break;
    case '2':
    tool = 2;
    break;
    case '3':
    tool = 3;
    break;
    case '4':
    tool = 4;
    break;
    case '+':
    brightness *= 2;
    break;
    case '-':
    brightness /= 2;
    break;
    case 'a':
    drawAccum = !drawAccum;
    break;
    case 'h':
    drawHud = !drawHud;
    break;
  }
}

void init() {
  frame = 0;
  time = 0.0;
  for(int j = 0; j < h; j++) {
    for(int i = 0; i < w; i++) {
      pixHeight[i][j] = 0.0;
      pixVel[i][j] = 0.0;
      accumLight[i][j] = 0.0;
      //pixMass[i][j] = 1.0;
      pixMass[i][j] = (i == 0 || i == w - 1 || j == 0 || j == h - 1) ? Float.POSITIVE_INFINITY : 1.0;
      //if(sqrt(sq(i - w / 2) + sq(j - h / 2)) < 12) pixMass[i][j] = 2;
    }
  }
}
