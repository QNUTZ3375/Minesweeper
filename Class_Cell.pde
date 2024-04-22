class Cell{
  int x, y;
  PImage img;
  boolean showCell = false;
  int num = 0;
  boolean showFlag;
  
  Cell(int _x, int _y, PImage curr){
    x = _x;
    y = _y;
    img = curr;
  }
  
  void reset(){
    img = tile;
    showCell = false;
    num = 0;
    showFlag = false;
  }
  
  void show(){
    fill(180);
    noStroke();
    square(xStartPos + x * cellSize - 1, yStartPos + y * cellSize - 1, cellSize);
    if(showFlag){
      if(hasHitBomb && img == bomb){
        image(flagWBomb, xStartPos + x * cellSize, yStartPos + y * cellSize);
        return;
      }
      image(flag, xStartPos + x * cellSize, yStartPos + y * cellSize);
    }else if(!showCell){
      image(tile, xStartPos + x * cellSize, yStartPos + y * cellSize);
    }else{
      if(img != tile){
        image(img, xStartPos + x * cellSize, yStartPos + y * cellSize);
      }
      if(num > 0){
        fill(numColors[num - 1]);
        text(num, xStartPos + x * cellSize + cellSize/2, yStartPos + y * cellSize + cellSize/2);
      }
    }
    noFill();
    strokeWeight(1);
    stroke(0);
    square(xStartPos + x * cellSize - 1, yStartPos + y * cellSize - 1, cellSize);
  }
}
