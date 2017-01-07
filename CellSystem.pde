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
    cells = new Cell[w+2][h+2];
    for (int x = 0; x < w+2; x++) {
      for (int y = 0; y < h+2; y++) {
        cells[x][y] = new Cell(x*size, y*size, size);
      }
    }
    pool = Executors.newFixedThreadPool((int)width/n_cols);      
    latch = new CountDownLatch((int)width/n_cols);
    tasks = new LinkedList<CellRunnable>();
    for (int i = 1; i < width-1; i += n_cols) {
      tasks.add(new CellRunnable(i, latch, n_cols));
    }
  }

  void clearGrid() {
    for (int x = 0; x < (width/size + 2); x++) {
      for (int y = 0; y < (height/size + 2); y++) {
        cells[x][y].A = 1;
        cells[x][y].B = 0;
      }
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
    for (int x = 1; x < w-1; x++) {
      for (int y = 1; y < h-1; y++) {
        cells[x][y].display();
      }
    }
  }

  void setBorder() {
    // ALSO corners should technically go to the opposite corner but who cares
    /* MIRRORING instead 
     for (int y = 0; y < h+2; y++){
     cells[0][y].A = cells[1][y].A;
     cells[0][y].B = cells[1][y].B;
     cells[w+1][y].A = cells[w][y].A;
     cells[w+1][y].B = cells[w][y].B;
     }
     for (int x = 0; x < w+2; x++){
     cells[x][0].A = cells[x][1].A;
     cells[x][0].B = cells[x][1].B;
     cells[x][w+1].A = cells[x][w].A;
     cells[x][w+1].B = cells[x][w].B;
     }
     */
    for (int y = 0; y < h+2; y++) {
      cells[0][y].A = cells[w][y].A;
      cells[0][y].B = cells[w][y].B;
      cells[w+1][y].A = cells[1][y].A;
      cells[w+1][y].B = cells[1][y].B;
    }
    for (int x = 0; x < w+2; x++) {
      cells[x][0].A = cells[x][h].A;
      cells[x][0].B = cells[x][h].B;
      cells[x][w+1].A = cells[x][1].A;
      cells[x][w+1].B = cells[x][1].B;
    }
  }

  void run() {
    try {
      setBorder();
      //println(cells[0][100].A + " " + cells[0][201].A);
      for (int i = 0; i < (width/n_cols); i++) {
        pool.execute(tasks.get(i));
      }
      latch.await();
    } 
    catch (InterruptedException e) {
      pool.shutdown();
    }
  }
}