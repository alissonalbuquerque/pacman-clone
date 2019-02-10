import java.util.ArrayList; //<>//

int x = 0;
int y = 0;
int largura = 30;
float mov = 3;
float angInicio = radians(0);
float angFim = radians(360);
float angMod = radians(3);

int CANTO_SUP_ESQ = 0;
int CANTO_SUP_DIR = 1;
int CANTO_INF_ESQ = 2;
int CANTO_INF_DIR = 3;
int PAREDE_HORIZ = 4;
int PAREDE_VERT = 5;

int POSICAO_LIVRE = 6;
int BOLINHA = 7;

int Pontos_Bolinhas = 0;
int Pontos_Fantasmas = 0;

//int cor = #18CB18; //Cor Verde
//int cor = #1890C6; //Cor Azul
//int cor = #6E0CAD; //Cor Roxa
int cor = #EA1834; //Cor Vermelha
//int cor = #EACB18; //Cor Amarela

boolean up, left, down, right;
int tecla;

int incrementoGrid = 20;
int linhasMapa = 25;
int colunasMapa = 26;
int[][] mapa = new int[linhasMapa][colunasMapa]; // Linhas e Coluna

PImage[][] fantasma = new PImage[1][8];

int C = -1;
int count = 1;

void setup() {
  
  fantasma[0][0] = loadImage("sprites/up_01.png");
  fantasma[0][1] = loadImage("sprites/up_02.png");
  
  fantasma[0][2] = loadImage("sprites/down_01.png");
  fantasma[0][3] = loadImage("sprites/down_02.png");
  
  fantasma[0][4] = loadImage("sprites/left_01.png");
  fantasma[0][5] = loadImage("sprites/left_02.png");
  
  fantasma[0][6] = loadImage("sprites/right_01.png");
  fantasma[0][7] = loadImage("sprites/right_02.png");

  size(500,500);
  x = 240;
  y = 240;
  right = true;
  
  //___________________________________Mapa_______________________________________

  for (int i = 0; i < mapa.length; i++) {
    for (int j = 0; j < mapa[i].length; j++) {
      mapa[i][j] = POSICAO_LIVRE;
    }
  }

  // LER ARQUIVO (LER MAPA)
  try {
    BufferedReader reader = createReader("mapas/mapa_01.map");
    String linha = null;
    linha = reader.readLine();
    int i = 0;
    while (linha != null) {
      for (int j = 0; j < linha.length(); j++) {
        if (linha.charAt(j) == '|') {
          mapa[i][j] = PAREDE_VERT;
        } else if (linha.charAt(j) == '=') {
          mapa[i][j] = PAREDE_HORIZ;
        } else if (linha.charAt(j) == 'e') {
          mapa[i][j] = CANTO_SUP_ESQ;
        } else if (linha.charAt(j) == 'd') {
          mapa[i][j] = CANTO_INF_ESQ;
        } else if (linha.charAt(j) == 'r') {
          mapa[i][j] = CANTO_SUP_DIR;
        } else if (linha.charAt(j) == 'f') {
          mapa[i][j] = CANTO_INF_DIR;
        } else if (linha.charAt(j) == '°') {
          mapa[i][j] = BOLINHA;
          //alimento.add(new PVector(j*20, i*20, 1));
        } else if (linha.charAt(i) == ' ') {
          mapa[i][j] = POSICAO_LIVRE;
        }
      }
      linha = reader.readLine();
      i++;
    }
  } 
  catch (IOException e) {
    println(e);
  }
}

void draw() {
  background(0);
  noStroke();
  fill(255);
  imageMode(CENTER);

  if (angInicio > radians(45) || angInicio < 0) { // Abrir e fechar boca do Pac_Man
    angMod *= -1;
  }
  angInicio += angMod;
  angFim -= angMod;

  movimentacao(); // Função de direção e lógica de direção
  fantasmas(); // Função para manipulação dos inimigos "fantasmas"
  mapa(); //Função para carregar o mapa;

  if (x >= width) { //Condições para "Atravessar" bordas
    x = 0;
  }
  if (x < 0) {
    x = width;
  }
  if (y >= height) {
    y = 0;
  }
  if (y < 0) {
    y = height;
  }
}

void keyPressed() { // Teclas de direção.
  if (key == CODED) {
    if (keyCode == UP || keyCode == LEFT || keyCode == DOWN || keyCode == RIGHT) {
      tecla = keyCode;
    }
  }
  
  if(key == ENTER){ // Troca valor de cor.
    C += count;
  }
  if (C > 4){
    C = 0;
  }
}

void movimentacao() { // Função de direção (velocidade e direção) e Lógica de direção Pac_Man
  fill(#F5D311); //Cor do Pac_Man
  //fill(cor); //Cores Alternatvas

  //________________________________________ Lógica __________________________________________
  
  int linha = 0;
  int coluna = 0;
  
  if (tecla == UP || tecla == LEFT){
    coluna = ceil(float(x) / float(incrementoGrid));  
    linha = ceil(float(y) / float(incrementoGrid));
  } else if (tecla == DOWN || tecla == RIGHT){
    coluna = floor(float(x) / float(incrementoGrid));  
    linha = floor(float(y) / float(incrementoGrid));
    
    if(coluna < 0){
      coluna = 0;
    }
  }

  if (x % incrementoGrid == 0 && y % incrementoGrid == 0) { // Lógica     //<>//
    if (tecla == UP && (mapa[linha-1][coluna] == BOLINHA || mapa[linha-1][coluna] == POSICAO_LIVRE)) {
      up = true;
      left = false;
      down = false;
      right = false;
    } 
    if (tecla == LEFT && (mapa[linha][coluna-1] == BOLINHA || mapa[linha][coluna-1] == POSICAO_LIVRE)) {
      up = false;
      left = true;
      down = false;
      right = false;
    } 
    if (tecla == DOWN && (mapa[linha+1][coluna] == BOLINHA || mapa[linha+1][coluna] == POSICAO_LIVRE)) {
      up = false;
      left = false;
      down = true;
      right = false;
    } 
    if (tecla == RIGHT && (mapa[linha][coluna+1] == BOLINHA || mapa[linha][coluna+1] == POSICAO_LIVRE)) {
      up = false;
      left = false;
      down = false;
      right = true;
    }
  }

  //_______________________ Velocidade e Direção __________________________
  
  float angInicioSoma = angInicio;
  float angFimSoma = angFim;
  
  if (up == true) { // Velociade e direção
    if (linha - 1 < 0) {
      linha = linhasMapa;
    }
    if (mapa[linha-1][coluna] == BOLINHA || mapa[linha-1][coluna] == POSICAO_LIVRE) {
      y -= mov; // CIMA
      angInicioSoma = angInicio+radians(270);
      angFimSoma = angFim+radians(270);
      mapa[linha][coluna] = POSICAO_LIVRE;
    }
  }
  
  if (left == true) {
    if (coluna - 1 < 0) {
      coluna = colunasMapa;
    }
    if (mapa[linha][coluna-1] == BOLINHA || mapa[linha][coluna-1] == POSICAO_LIVRE) {
      x -= mov; // ESQUERDA
      angInicioSoma = angInicio+radians(180);
      angFimSoma = angFim+radians(180);
      mapa[linha][coluna] = POSICAO_LIVRE;
    }
  }
  
  if (down == true) {
    int linhaAnterior = linha;
    if (linha + 1 >= linhasMapa) {
      linha = -1;
    }
    if (mapa[linha+1][coluna] == BOLINHA || mapa[linha+1][coluna] == POSICAO_LIVRE) {
      y += mov; // BAIXO
      angInicioSoma = angInicio+radians(90);
      angFimSoma = angFim+radians(90);
      mapa[linhaAnterior][coluna] = POSICAO_LIVRE;
    }
  }
  
  if (right == true) {
    int colunaAnterior = coluna;
    if (coluna + 1 >= colunasMapa) {
      coluna = -1;
    }
  if (mapa[linha][coluna+1] == BOLINHA || mapa[linha][coluna+1] == POSICAO_LIVRE) {
      x += mov; // DIREITA
      angInicioSoma = angInicio;
      angFimSoma = angFim;
      mapa[linha][colunaAnterior] = POSICAO_LIVRE;
    }
  }
  
  arc(x+10, y+10, largura, largura, angInicioSoma, angFimSoma);
}

void fantasmas() {
  image(fantasma[0][0], width/2, 370);
}

//_________________________________Mapa________________________________

void mapa() { // Cores, Linhas


  int Px, Py;
  Px = 0;
  Py = 10;

  for (int i = 0; i < mapa.length; i++) {
    Px = 10;
    for (int j = 0; j < mapa[i].length; j++) {
      
      stroke(cor);
      strokeWeight(5);
      strokeCap(PROJECT);
      
      if (mapa[i][j] == CANTO_SUP_ESQ) {
        line(Px, Py, Px+10, Py);
        line(Px, Py, Px, Py+10);
      }
      if (mapa[i][j] == CANTO_SUP_DIR) {
        line(Px, Py, Px-10, Py);
        line(Px, Py, Px, Py+10);
      }
      if (mapa[i][j] == CANTO_INF_DIR) {
        line(Px, Py, Px, Py-10);
        line(Px, Py, Px-10, Py);
      }
      if (mapa[i][j] == CANTO_INF_ESQ) {
        line(Px, Py, Px, Py-10);
        line(Px, Py, Px+10, Py);
      }
      if (mapa[i][j] == PAREDE_VERT) {
        line(Px, Py-10, Px, Py+10);
      }
      if (mapa[i][j] == PAREDE_HORIZ) {
        line(Px-10, Py, Px+10, Py);
      }
      if (mapa[i][j] == BOLINHA) {
        strokeWeight(0);
        fill(255);
        stroke(255);
        ellipse(Px, Py, 5, 5);
      }
      Px+=20;
    }
    Py+=20;
  }
  
  if (C == 0){
    cor = #18CB18; //Cor Verde
  }else if (C == 1){
    cor = #1890C6; //Cor Azul
  }else if (C == 2){
    cor = #6E0CAD; //Cor Roxa
  }else if (C == 3){
    cor = #EA1834; //Cor Vermelha
  }else if (C == 4){
    cor = #EACB18; //Cor Amarela
  }
}
