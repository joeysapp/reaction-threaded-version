class Cell {
  PVector pos;
  int size;
  float A, B, f;

  Cell(float x, float y, int _size) {
    pos = new PVector(x, y);
    size = _size;
    A = 1;
    B = 0;
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    fill(A*512, (A+B)*255, 255);
    rect(0, 0, size, size);
    popMatrix();
  }
}

/* ToxicLibs color theory stuff 
 TColor c;
 c = TColor.newHSV(0.5*A, (A*B)*10, 100);
 c = c.getRotatedRYB(QUARTER_PI/2);
 c.complement();
 c.saturate(0.3);
 fill(c.toARGB());*/