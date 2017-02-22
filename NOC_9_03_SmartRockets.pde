int lifetime;  // How long should each generation live //<>// //<>//

Population population;  // Population

int lifecycle;          // Timer for cycle of generation
int recordtime;         // Fastest time to target

Obstacle target;        // Target position

ArrayList<Obstacle> obstacles;  //an array list to keep track of all the obstacles!

float d = 25;

int[][] grid;
Cell[][] graph;



//boolean[][] walls = new boolean[h][w];


void setup() {
  size(600, 400);
  // The number of cycles we will allow a generation to live
  lifetime = 600;

  // Initialize variables
  lifecycle = 0;
  recordtime = lifetime;

  target = new Obstacle(width/2-12, 24, 24, 24);

  // Create the obstacle course  
  obstacles = new ArrayList<Obstacle>();
  obstacles.add(new Obstacle(width/2-50, height/1.5, 200, 10));
  obstacles.add(new Obstacle(width/3-100, height/3, 200, 10));
  obstacles.add(new Obstacle(width -500, height/4, 10, 200));
  obstacles.add(new Obstacle(width -500, height/5, 10, 500));

  grid = new int[40][60];
  for (int r = 0; r != 40; r++) {
    for (int c = 0; c != 60; c++) {
      grid[r][c] = isObstacle(c, r);
    }
  }
  for (int r = 0; r != 40; r++) {
    for (int c = 0; c != 60; c++) {
      print(" " + grid[r][c]);
    }
    println();
  }
  // Create a population with a mutation rate, and population max
  float mutationRate = 0.1;
  population = new Population(mutationRate, 50, grid);

  //graph = new Cell[40][60];
  //for (int i = 0; i != 40; i++) {
  //  for (int j = 0; j != 60; j++) {
  //    graph[i][j] = new Cell();
  //  }
  //}
  //for (int i = 0; i != 40; i++) {
  //  for (int j = 0; j != 60; j++) {
  //    if (grid[i][j] == 0) {
  //      // top
  //      if (i == 0) {
  //        graph[i][j].top = null;
  //      } else if (grid[i-1][j] == 1) {
  //        graph[i][j].top = null;
  //      } else if (grid[i-1][j] == 0) {
  //        graph[i][j].top = graph[i-1][j];
  //      }
  //      // right
  //      if (j == 59) {
  //        graph[i][j].right = null;
  //      } else if (grid[i][j+1] == 1) {
  //        graph[i][j].right = null;
  //      } else if (grid[i][j+1] == 0) {
  //        graph[i][j].right = graph[i][j+1];
  //      }
  //      // bottom
  //      if (i == 39) {
  //        graph[i][j].bottom = null;
  //      } else if (grid[i+1][j] == 1) {
  //        graph[i][j].bottom = null;
  //      } else if (grid[i+1][j] == 0) {
  //        graph[i][j].bottom = graph[i+1][j];
  //      }
  //      // left
  //      if (j == 0) {
  //        graph[i][j].left = null;
  //      } else if (grid[i][j-1] == 1) {
  //        graph[i][j].left = null;
  //      } else if (grid[i][j-1] == 0) {
  //        graph[i][j].left = graph[i][j-1];
  //      }
  //    }
  //  }
  //}
  println("done");
  //bfs();
}

int isObstacle(int c, int r) {
  int x = c * 10 + 5;
  int y = r * 10 + 5;

  for (Obstacle o : obstacles) {
    if (o.contains(x, y)) {
      return 1;
    }
  }

  return 0;
}

void draw() {
  background(255);

  // Draw the start and target positions
  target.display();


  // If the generation hasn't ended yet
  if (lifecycle < lifetime) {
    population.live(obstacles);
    if ((population.targetReached()) && (lifecycle < recordtime)) {
      recordtime = lifecycle;
    }
    lifecycle++;
    // Otherwise a new generation
  } else {
    lifecycle = 0;
    population.fitness();
    population.selection();
    population.reproduction();
  }

  // Draw the obstacles
  for (Obstacle obs : obstacles) {
    obs.display();
  }

  // Display some info
  fill(0);
  text("Generation #: " + population.getGenerations(), 10, 18);
  text("Cycles left: " + (lifetime-lifecycle), 10, 36);
  text("Record cycles: " + recordtime, 10, 54);
}

// Move the target if the mouse is pressed
// System will adapt to new target
void mousePressed() {
  target.position.x = mouseX;
  target.position.y = mouseY;
  recordtime = lifetime;
}