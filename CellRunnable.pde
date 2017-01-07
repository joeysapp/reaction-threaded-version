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
      for (int y = 1; y < height-1; y++) {
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
      int x = (int) foo.pos.x;
      int y = (int) foo.pos.y;
      float asum = 0.05 * (c.cells[x-1][y-1].A + c.cells[x-1][y+1].A + 
                           c.cells[x+1][y-1].A + c.cells[x+1][y+1].A) + 
                   0.20 * (c.cells[x-1][y].A + c.cells[x+1][y].A + 
                           c.cells[x][y+1].A + c.cells[x][y-1].A)
                   - a_;
      float bsum = 0.05 * (c.cells[x-1][y-1].B + c.cells[x-1][y+1].B + 
                           c.cells[x+1][y-1].B + c.cells[x+1][y+1].B) + 
                   0.20 * (c.cells[x-1][y].B + c.cells[x+1][y].B + 
                           c.cells[x][y+1].B + c.cells[x][y-1].B)
                   - b_;
      float abb = a_*b_*b_;
      foo.A = a_ + (c.da*asum) - (abb) + (fill_rate*(1-a_));
      foo.B = b_ + (c.db*bsum) + (abb) - ((kill_rate+fill_rate)*b_);
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