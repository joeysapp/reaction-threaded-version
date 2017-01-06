class CellSystem implements Runnable { 
  ExecutorService pool;
  CountDownLatch latch;
  List<CellRunnable> tasks;
  Cell[][] cells;
  int w, h, n_cols;
  float f, k, da, db; 
  float[][] convolution = {{0.05, 0.2, 0.05}, 
                           {0.2, -1, 0.2}, 
                           {0.05, 0.2, 0.05}};

  CellSystem(int _n_cols, int size, float _f, float _k, float _da, float _db) {
    n_cols = _n_cols;
    da = _da;
    db = _db;
    f = _f;
    k = _k;
    w = (int)width/size;
    h = (int)height/size;
    cells = new Cell[w][h];
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        cells[x][y] = new Cell(x*size, y*size, size);
      }
    }
    pool = Executors.newFixedThreadPool((int)width/n_cols);      
    latch = new CountDownLatch((int)width/n_cols);
    tasks = new LinkedList<CellRunnable>();
    for (int i = 0; i < width; i += n_cols) {
      tasks.add(new CellRunnable(i, latch, n_cols));
    }
  }

  void randomPopulate(int num) {
    for (int i = 0; i < num; i++) {
      int rx = (int) random(1, w-1);
      int ry = (int) random(1, h-1);
      placeAt(rx, ry);
    }
  }

  void quadPlace() {
    c.placeAt(width/4, height/4);
    c.placeAt(width/2 + width/4, height/4);
    c.placeAt(width/4, height/2 + height/4);
    c.placeAt(width/2 + width/4, height/2 + height/4);
  }

  void placeAt(int x, int y) {
    cells[x+1][y].B = 1;
    cells[x-1][y].B = 1;
    cells[x][y+1].B = 1;
    cells[x][y-1].B = 1;
  }

  void centralPlacement() {
    placeAt((int)width/2, (int)height/2);
  }

  void display() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        cells[x][y].display();
      }
    }
  }

  void run() {
    try {
      for (int i = 0; i < (width/n_cols); i++) {
        pool.execute(tasks.get(i));
      }
      latch.await();
    } catch (InterruptedException e) {
      pool.shutdown();
    }
  }
}