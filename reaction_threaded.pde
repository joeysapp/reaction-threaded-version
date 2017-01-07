import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.CountDownLatch;
import java.util.Queue;
import java.util.LinkedList;
import java.util.List;

//import toxi.color.*;
//import toxi.color.theory.*;

CellSystem c;

int size = 1;

float fill_rate = 0.004;
float kill_rate = 0.029;
float a_rate = 1;
float b_rate = 0.5;

boolean animated = true;
boolean framerate = false;

// Change of fill and kill rates during animation 
float d_fr = 0.000005;
float d_kr = 0.000010;

void setup() {
  size(200, 200);
  noStroke();
  //colorMode(HSB);
  c = new CellSystem(50, size, fill_rate, kill_rate, a_rate, b_rate);
  
  //c.randomPopulate(50);
  //c.quadPlace();
  c.centralPlacement();
}

void draw() {
  c.run();
  c.display();
  if (framerate) println(frameRate);
  if (animated) {
    fill_rate += d_fr;
    kill_rate += d_kr;
    // Curve up at k = 0.61
    if (fill_rate > 0.02) {
      if (d_fr < 5) {
        d_fr += (0.1*d_fr);
      }
      d_kr = 0;
    }
  }
}

void mouseDragged() {
  int x = (int)mouseX/size;
  int y = (int)mouseY/size;
  c.cells[x%(width*size)][y%(height*size)].B = 1;
}

void mouseClicked() {
  int x = (int)mouseX/size;
  int y = (int)mouseY/size;
  // Places a +
  c.cells[x+1][y].B = 1;
  c.cells[x-1][y].B = 1;
  c.cells[x][y+1].B = 1;
  c.cells[x][y-1].B = 1;
}

void keyPressed() {
  println("f: " + fill_rate + ", k: " + kill_rate);
  if (key == 's') {
    println("saved");
    String parameters = "(f-"+c.f+",k-"+c.k+")";
    String date = str(month())+'-'+str(day())+'-'+str(year())+'-'+str(second());
    String name = parameters+"-"+date+'-'+(int)random(1000);
    saveFrame(name+".png");
  } else if (key == 'a'){
    c.randomPopulate(5);
  } else if (key == 'c'){
    c.clearGrid();
  }
}