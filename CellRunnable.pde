class CellRunnable implements Runnable {
  int x, n_cols;
  boolean discoverFull, computedFull;
  CountDownLatch latch;
  Queue<Cell> discover;
  Queue<Cell> computed;

  CellRunnable(int _x, CountDownLatch _latch, int _n_cols) {
    discover = new LinkedList<Cell>();
    computed = new LinkedList<Cell>();
    discoverFull = false;
    computedFull = false;
    latch = _latch;
    x = _x;
    n_cols = _n_cols;
  }

  boolean computed() {
    return computedFull;
  }

  boolean discoverFull() {
    return discoverFull;
  }

  void fillQueue() {
    for (int i = 0; i < n_cols; i++) {
      for (int y = 0; y < height; y++) {
        discover.add(c.cells[x+i][y]);
        computedFull = false;
        discoverFull = true;
      }
    }
  }

  void computeQueue() {
    while (discover.peek() != null) {
      Cell foo = discover.remove();
      // I create these floats here for the possibility of modifying
      // rates with other data (noise, x/y)
      float a_ = foo.A;
      float b_ = foo.B;
      int x = (int)foo.pos.x;
      int y = (int)foo.pos.y;
      foo.A = a_ + (c.da*sum(x, y, 'A')) - (a_*b_*b_) + (fill_rate*(1-a_));
      foo.B = b_ + (c.db*sum(x, y, 'B')) + (a_*b_*b_) - ((kill_rate+fill_rate)*b_);
      computed.add(foo);
      discoverFull = false;
      computedFull = true;
    }
  }

  void setArray() {
    while (computed.peek() != null) {
      Cell foo = computed.remove();
      c.cells[(int)foo.pos.x][(int)foo.pos.y].A = foo.A;
      c.cells[(int)foo.pos.x][(int)foo.pos.y].B = foo.B;
      computedFull = false;
    }
  }

  float sum(int _x, int _y, char _c) {
    float sum = 0;
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        //if (_x+x < 0 || _x+x > c.w-1) return 0;
        //if (_y+y < 0 || _y+y > c.h-1) return 0;
        if (_c == 'B') sum += (c.cells[(_x+x+width/size)%(width/size)][(_y+y+height/size)%(height/size)].B * c.convolution[x+1][y+1]);
        else sum += (c.cells[(_x+x+width/size)%(width/size)][(_y+y+height/size)%(height/size)].A * c.convolution[x+1][y+1]);
        //if (_c == 'B') sum += (c.cells[_x+x][_y+y].B * c.convolution[x+1][y+1]);
        //else sum += (c.cells[_x+x][_y+y].A * c.convolution[x+1][y+1]);
      }
    }
    return sum;
  }

  void run() {
    while (true) {
      while (!discoverFull()) fillQueue();
      while (!computed()) computeQueue();
      while (computed()) setArray();
      try {
        // This has to be here for some reason
        // I think it's an issue with Processing's PGraphics

        Thread.sleep(0);
        latch.countDown();
      } 
      catch (InterruptedException e) {
        println("Thread @ " + x + " threw exception");
      }
    }
  }
}