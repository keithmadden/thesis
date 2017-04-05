class Rocket {

  // All of our physics stuff
  PVector position;
  PVector velocity;
  PVector acceleration;

  // Size
  float r;

  // How close did it get to the target
  float recordDist;

  // Fitness and DNA
  float fitness;
  DNA dna;
  // To count which force we're on in the genes
  int geneCounter = 0;

  boolean hitObstacle = false;    // Am I stuck on an obstacle?
  boolean hitTarget = false;   // Did I reach the target
  int finishTime;              // What was my finish time?
  
  float maxspeed;
  float maxforce;
  float obTop;
  float obRight;
  float obBottom;
  float obLeft;
  
  int[][] grid;
  int cols = 600;
  int rows = 400;
  
  //int w;   //int h;
  int[][] distance;
  //int maxDist = -1;

  //int startr;
  //int startc;

  //constructor
  Rocket(PVector l, DNA dna_, int totalRockets, int[][] g, int[][] d) {
    acceleration = new PVector();
    velocity = new PVector();
    position = l.get();
    r = 4;
    dna = dna_;
    finishTime = 0;          // We're going to count how long it takes to reach target
    recordDist = 10000;      // Some high number that will be beat instantly
    maxspeed = 2.5;
    maxforce = 0.15;
    
    //w = width/10;
    //h = height/10;
    distance = d;
    grid = g;
  }

  // FITNESS FUNCTION 
  // distance = distance from target
  // finish = what order did i finish (first, second, etc. . .)
  // f(distance,finish) =   (1.0f / finish^1.5) * (1.0f / distance^6);
  // a lower finish is rewarded (exponentially) and/or shorter distance to target (exponetially)
  void fitness() {
    if (recordDist < 1) recordDist = 1;

    // Reward finishing faster and getting close
    fitness = (1/(finishTime*recordDist));

    // Make the function exponential
    fitness = pow(fitness, 4);

    if (hitObstacle) fitness *= 0.1; // lose 90% of fitness hitting an obstacle
    if (hitTarget) fitness *= 2; // twice the fitness for finishing!
    //bfs();
    //println("current fitness level " + getMaxDist());
  }
  
  

  // Run in relation to all the obstacles
  // If I'm stuck, don't bother updating or checking for intersection
  void run(ArrayList<Obstacle> os) {
    
    boundaries(os);
    
    if (!hitObstacle && !hitTarget) {
      applyForce(dna.genes[geneCounter]);
      geneCounter = (geneCounter + 1) % dna.genes.length;
      update();
      // If I hit an edge or an obstacle
      obstacles(os);
    }
    // Draw me!
    //if (!hitObstacle) {
      display();
    //}
  }
  
  void boundaries(ArrayList<Obstacle> obList) {
    
    for (Obstacle obstacles : obList) {
        
      obTop = obstacles.position.y;
      obRight = obstacles.position.x + obstacles.w;
      obBottom = obstacles.position.y + obstacles.h;
      obLeft = obstacles.position.x;
      
      //println("top = " + obTop + " right = " + obRight + " bottom = " + obBottom + " left = " + obLeft + " d2 = " + d2);
      //println("x = " + location.x + " y = " + location.y);
  
      PVector desired = null;
  
      if (position.x < d) {
        desired = new PVector(maxspeed, velocity.y);
        //println("Hit wall left");
      } 
      else if (position.x > width -d) {
        desired = new PVector(-maxspeed, velocity.y);
        //println("Hit wall right");
      } 
  
      if (position.y < d) {
        desired = new PVector(velocity.x, maxspeed);
        //println("Hit wall top");
      } 
      else if (position.y > height-d) {
        desired = new PVector(velocity.x, -maxspeed);
        //println("Hit wall bottom");
      } 
      
      if (position.x > obRight && position.x < obRight + d && position.y > obTop - d && position.y < obBottom + d) {
        desired = new PVector(maxspeed, velocity.y);
        //println("Hit obstacle right");
      } 
      else if (position.x > obLeft - d && position.x < obLeft && position.y > obTop - d && position.y < obBottom + d) {
        desired = new PVector(-maxspeed, velocity.y);
        //println("Hit obstacle left");
      } 
  
      if (position.y > obBottom && position.y < obBottom + d && position.x > obLeft - d && position.x < obRight + d) {
        desired = new PVector(velocity.x, maxspeed);
        //println("Hit obstacle bottom");
      } 
      else if (position.y > obTop - d && position.y < obTop && position.x > obLeft - d && position.x < obRight + d) {
        desired = new PVector(velocity.x, -maxspeed);
        //println("Hit obstacle top");
      } 
  
      if (desired != null) {
        desired.normalize();
        desired.mult(maxspeed);
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxforce);
        applyForce(steer);
      }
    }
  }

  // Did I make it to the target?
  void checkTarget() {
    //float d = dist(position.x, position.y, target.position.x, target.position.y);
    int r = ((int)position.y)/10;
    int c = ((int)position.x)/10;
    if (r > 39) r = 39;
    if (c > 59) c = 59;
    float d = distance[r][c];
    d = d * 10;
    println(d);
    if (d < recordDist) recordDist = d;

    if (target.contains(position) && !hitTarget) {
      hitTarget = true;
    } 
    else if (!hitTarget) {
      finishTime++;
    }
  }

  // Did I hit an obstacle?
  void obstacles(ArrayList<Obstacle> os) {
    for (Obstacle obs : os) {
      if (obs.contains(position)) {
        hitObstacle = true;
      }
    }
  }

  void applyForce(PVector f) {
    acceleration.add(f);
  }


  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    //background(255,0,0);
    float theta = velocity.heading2D() + PI/2;
    fill(200, 100);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);

    // Thrusters
    rectMode(CENTER);
    fill(0);
    rect(-r/2, r*2, r/2, r);
    rect(r/2, r*2, r/2, r);

    // Rocket body
    fill(175);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();

    popMatrix();
  }

  float getFitness() {
    return fitness;
  }

  DNA getDNA() {
    return dna;
  }

  boolean stopped() {
    return hitObstacle;
  }
  
  //void grid() {
  //  grid = new Cell[cols][rows];
  //  for ( int i = 0; i < cols / 10; i ++) {
  //    for ( int j = 0; j < rows / 10; j ++) {
  //    }
  //  }
  //}
}