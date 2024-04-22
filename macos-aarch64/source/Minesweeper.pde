import java.util.Arrays;
int cols = 18;
int rows = 12;
int cellSize = 51;
int xStartPos = 40;
int yHeaderPos = 80;
int headerHeight = 80;
int yStartPos = 200;
int margin = 4;
int currX = 0;
int currY = 0;
int bombLimit = 31;
int flagCount = bombLimit;
int timer = 0;
Cell[][] board = new Cell[cols][rows];
color[] numColors = {color(0, 0, 255), color(0, 255, 0), color(255, 0, 0), color(0, 0, 150), 
                     color(150, 0, 0), color(0, 150, 150), color(0, 0, 0), color(150, 150, 0)};
PFont f;
PFont metrics;
PFont s;
PImage tile;
PImage bomb;
PImage bomb_red;
PImage flag;
PImage flagWBomb;
PImage flagIcon;
color yellow = color(250, 200, 120);
color cream = color(255, 225, 175);
color orange = color(255, 180, 55);
boolean hasHitBomb = false;
boolean flagMode = false;
boolean isPlaying = false;
int boardState = 0;
int level = 5; //default level
String difficulty = "MD";
int[][] difficulties = {{3, 6, 10, 17, 25, 33, 40, 56, 70, 88},
                        {4, 8, 13, 22, 31, 46, 68, 71, 91, 100},
                        {5, 10, 18, 27, 40, 53, 82, 87, 105, 114}, 
                        {6, 13, 22, 37, 48, 67, 90, 101, 121, 136}};
int[][] neighbors = {{-1,-1}, {0, -1}, {1, -1},
                     {-1, 0},          {1, 0} ,
                     {-1, 1}, {0, 1},  {1, 1} };
boolean keyHeldDown = false;
boolean mouseHeldDown = false;

void resetBoard(){
  hasHitBomb = false;
  isPlaying = false;
  flagMode = false;
  boardState = 0;
  flagCount = bombLimit;
  timer = 0;
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j].reset();
    }
  }
  makeBombs();
  findNeighbors();
}

void loadImages(){
  tile = loadImage("tile.png");
  bomb = loadImage("bomb.png");
  bomb_red = loadImage("bomb_red.png");
  flag = loadImage("flag.png");
  flagWBomb = loadImage("flag_with_bomb.png");
  tile.resize(cellSize, cellSize);
  bomb.resize(cellSize, cellSize);
  bomb_red.resize(cellSize, cellSize);
  flag.resize(cellSize, cellSize);
  flagWBomb.resize(cellSize, cellSize);
}

void generateNewBoard(){
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j] = new Cell(i, j, tile);
    }
  }
}

boolean checkWinCondition(){
  int checkSum = 0;
  //checks if the current board has all of the digits uncovered
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[i][j].img != bomb && board[i][j].showCell && !board[i][j].showFlag){
        checkSum++;
      }
    }
  }
  return checkSum == (cols * rows) - bombLimit;
}

void showValidNeighbors(int i, int j){
  if(board[i][j].img == flag){
    return;
  }
  board[i][j].showCell = true;
  if(board[i][j].img == bomb){
    return;
  }
  //Basically just do *iterative* DFS (iterative BFS tanks the FPS counter (basically way too damn slow))
  Cell[] lst = {board[i][j]};
  
  while(lst.length > 0){
    Cell curr = lst[lst.length - 1];
    lst = Arrays.copyOf(lst, lst.length - 1);
    
    curr.showCell = true;
    
    if(curr.num > 0){
      continue;
    }
    
    for(int idx = 0; idx < neighbors.length; idx++){
      if(curr.x + neighbors[idx][0] < 0 || curr.y + neighbors[idx][1] < 0 || 
         curr.x + neighbors[idx][0] >= cols || curr.y + neighbors[idx][1] >= rows){
           continue;
      }
      if(board[curr.x + neighbors[idx][0]][curr.y + neighbors[idx][1]].img == bomb){
        continue;
      }
      if(board[curr.x + neighbors[idx][0]][curr.y + neighbors[idx][1]].showCell){
        continue;
      }
      lst = Arrays.copyOf(lst, lst.length + 1);
      lst[lst.length - 1] = board[curr.x + neighbors[idx][0]][curr.y + neighbors[idx][1]];
    }
  }
}

void findNeighbors(){
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      for(int k = 0; k < neighbors.length; k++){
        if(board[i][j].img == bomb){
          continue;
        }
        if(i + neighbors[k][0] < 0 || j + neighbors[k][1] < 0 || 
           i + neighbors[k][0] >= cols || j + neighbors[k][1] >= rows){
             continue;
        }
        if(board[i + neighbors[k][0]][j + neighbors[k][1]].img == bomb){
          board[i][j].num++;
        }
      }
    }
  }
}

void makeBombs(){
  int temp = 0;
  while(temp < bombLimit){
    int c = int(random(cols));
    int r = int(random(rows));
    if (board[c][r].img != bomb){
      board[c][r].img = bomb;
      board[c][r].num = 0;
      temp++;
    }
  }
}

void drawHeaderOutline(){
  noStroke();
  fill(orange);
  //TL triangle
  triangle(xStartPos - margin, yHeaderPos - margin, //TL
           xStartPos - margin, yHeaderPos + headerHeight + margin, //TR
           xStartPos + headerHeight + margin, yHeaderPos - margin); //B
  //TR triangle
  triangle(xStartPos + cols * cellSize - headerHeight, yHeaderPos - margin, //TL
           xStartPos + cols * cellSize + margin, yHeaderPos - margin, //TR
           xStartPos + cols * cellSize - headerHeight, yHeaderPos + headerHeight); //B
  //Top rectangle
  rect(xStartPos - margin, yHeaderPos - margin, cols * cellSize - margin, margin * 2);
  
  fill(cream);
  //BL triangle
  triangle(xStartPos - margin, yHeaderPos + headerHeight + margin, //BL
           xStartPos + headerHeight, yHeaderPos + headerHeight + margin, //BR
           xStartPos + headerHeight, yHeaderPos); //T
  //BR triangle
  triangle(xStartPos + cols * cellSize - headerHeight - margin, yHeaderPos + headerHeight + margin, //BL
           xStartPos + cols * cellSize + margin, yHeaderPos + headerHeight + margin, //BR
           xStartPos + cols * cellSize + margin, yHeaderPos - margin); //T
  //Bottom rectangle
  rect(xStartPos + margin * 2, yHeaderPos + headerHeight - margin, cols * cellSize - margin, margin * 2);
  
  switch(boardState){
    case 1:
      fill(0, 255, 0);
      break;
    case -1:
      fill(185, 0, 0);
      break;
    case 0:
      fill(yellow);
      break;
    default:
      fill(0);
  }
  //main Center rectangle
  rect(xStartPos, yHeaderPos, cols * cellSize, headerHeight);
}

void drawMainBoardOutline(){
  noStroke();
  fill(orange);
  //TL triangle
  triangle(xStartPos - margin, yStartPos - margin, //TL
           xStartPos - margin, yStartPos + rows * cellSize + margin, //TR
           xStartPos + rows * cellSize + margin, yStartPos - margin); //B
  //TR triangle
  triangle(xStartPos + rows * cellSize, yStartPos - margin, //TL
           xStartPos + cols * cellSize + margin, yStartPos - margin, //TR
           xStartPos + rows * cellSize, yStartPos + (cols - rows) * cellSize); //B
  
  fill(cream);
  //BL triangle
  triangle(xStartPos - margin, yStartPos + rows * cellSize + margin, //BL
           xStartPos + (cols - rows) * cellSize, yStartPos + rows * cellSize + margin, //BR
           xStartPos + (cols - rows) * cellSize, yStartPos + (cols - rows) * cellSize); //T
  //BR triangle
  triangle(xStartPos + (cols - rows) * cellSize - margin, yStartPos + rows * cellSize + margin, //BL
           xStartPos + cols * cellSize + margin, yStartPos + rows * cellSize + margin, //BR
           xStartPos + cols * cellSize + margin, yStartPos - margin); //T
  
  //rectangle
  fill(yellow);
  rect(xStartPos, yStartPos, cols * cellSize, rows * cellSize);
}

void setup(){
  size(1000, 850);
  f = createFont("AlBayan", cellSize * 0.7, true);
  metrics = createFont("Helvetica", 60, true);
  s = createFont("Zapfino", 40, true);
  flagIcon = loadImage("flag.png");
  flagIcon.resize(40, 40);
  loadImages();
  generateNewBoard();
  makeBombs();
  findNeighbors();
}

void draw(){
  background(yellow); 
  drawMainBoardOutline();
  drawHeaderOutline();
  
  if(isPlaying){
    timer++;
  }
  
  textAlign(LEFT);
  textFont(metrics, 40);
  fill(0);
  text("Level: " + level + "-" + difficulty, xStartPos + headerHeight/4, yHeaderPos + 55);
  text("Flags Left: " + flagCount, xStartPos + headerHeight/4 + 260, yHeaderPos + 55);
  text("Timer: " + timer/60 + 's', xStartPos + headerHeight/4 + 550, yHeaderPos + 55);
  textFont(s, 12);
  text("Made By: Jozka N. T. in 10 hours", xStartPos + headerHeight/4, 50);

  if(flagMode){
    image(flagIcon, xStartPos + cols * cellSize - headerHeight * 0.75, yHeaderPos + headerHeight/4);
  }
  
  textAlign(CENTER, CENTER);
  textFont(f, cellSize * 0.7); 
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j].show();
    }
  }
  
  if(checkWinCondition() && boardState == 0){
    boardState = 1;
    for(int i = 0; i < cols; i++){
      for(int j = 0; j < rows; j++){
        board[i][j].showCell = true;
      }
    }
    isPlaying = false;
  }
}

void mousePressed(){
  if(mouseHeldDown || keyHeldDown){
    return;
  }
  mouseHeldDown = true;
  //prevents out of bounds clicks and only allows the player to click if they haven't hit a bomb yet
  if(mouseX <= xStartPos || mouseY <= yStartPos || 
     mouseX >= xStartPos + cols * cellSize || mouseY >= yStartPos + rows * cellSize || hasHitBomb){
    return;
  }
  isPlaying = true;
  currX = (mouseX - xStartPos) / cellSize;
  currY = (mouseY - yStartPos) / cellSize;
  
  if(flagMode && !board[currX][currY].showCell){
    //flips the showFlag boolean value
    board[currX][currY].showFlag = !board[currX][currY].showFlag;
    if(board[currX][currY].showFlag){
      flagCount--;
    } else{
      flagCount++;
    }
    return;
  }
  
  showValidNeighbors(currX, currY);
  //checks if the cell clicked is not a flag and is a bomb
  if(board[currX][currY].img == bomb && !board[currX][currY].showFlag){
    board[currX][currY].img = bomb_red;
    hasHitBomb = true;
    isPlaying = false;
    boardState = -1;
    for(int i = 0; i < cols; i++){
      for(int j = 0; j < rows; j++){
        if(board[i][j].img == bomb){
          board[i][j].showCell = true;
        }
      }
    }
  }
}

void mouseReleased(){
  mouseHeldDown = false;
}

void keyPressed(){
  //if(key == ENTER){
  //  for(int i = 0; i < cols; i++){
  //    for(int j = 0; j < rows; j++){
  //      board[i][j].showCell = !board[i][j].showCell;
  //    }
  //  }
  //}
  if(keyHeldDown || mouseHeldDown){
    return;
  }
  keyHeldDown = true;
  
  if(key == 'r'){
    resetBoard();
    return;
  }
  if(key == 'f' && !hasHitBomb){
    flagMode = !flagMode;
    return;
  }
  if((int) key >= 48 && (int) key <= 57){
    level = (int) key - 48;
    if((int) key == 48){
      level = 10;
    }
    cols = 6 + (level - 1) * 3;
    rows = cols * 2/3;
    cellSize = (width - 2*xStartPos) / cols;
    difficulty = "MD";
    bombLimit = difficulties[1][level - 1];
    board = new Cell[cols][rows];
    loadImages();
    generateNewBoard();
    resetBoard();
  }
  if(key == 'e'){
    difficulty = "EZ";
    bombLimit = difficulties[0][level - 1];
    generateNewBoard();
    resetBoard();
  }
  if(key == 'm'){
    difficulty = "MD";
    bombLimit = difficulties[1][level - 1];
    generateNewBoard();
    resetBoard();
  }
  if(key == 'h'){
    difficulty = "HD";
    bombLimit = difficulties[2][level - 1];
    generateNewBoard();
    resetBoard();
  }
  if(key == 'x'){
    difficulty = "EX";
    bombLimit = difficulties[3][level - 1];
    generateNewBoard();
    resetBoard();
  }
}

void keyReleased(){
  keyHeldDown = false;
}

/*
Notes:
- 16 Jan 1:00PM - 3:30PM, 4:30PM - 6:30PM: designed the UI and the sprites (4.5 hrs) 
- 16 Jan 7:50PM - 11:20PM: added the colors yellow, cream and orange, added all of the logic for the game, (3.5 hrs)
fixed a bug where having too few bombs tanks the FPS due to iterative BFS, 
switched to iterative DFS (removes the for loop that shifts all elements), 
finished the UI, added level selection (1-9, 0 being a bonus 10th level), 
fixed a bug where the top shows green even though
a bomb was clicked on (reproducible by flagging one cell then blowing up), 
made the window larger, added difficulties (e, m, h, i)

- 17 Jan 9:20AM - 10:20AM: tweaked the difficulty and the bomb counts (1hr)
- 17 Jan: 1:30PM - 2:30PM: tweaked the findValidNeighbors function so now it includes diagonal cells, 
adjusted some UI elements (1 hr)

- 18 Jan: checks if the key is released (prevents flag bug)

THIS PROJECT IS NOW FINISHED (Might add some more features in the future)
*/
