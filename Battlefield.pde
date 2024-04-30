// The overarching class that contains the entire model. Also holds configuration variables.

class Battlefield {
    // Status information
    int timeElapsed = 0;
    int percentageHealth = 100;

    BodyCell[] bodyCells;
    ArrayList<Pathogen> pathogens;
    ArrayList<Macrophage> macrophages;
    ArrayList<Neutrophil> neutrophils;
    
    String simulationStatus = "in progress";
    
    
    // Constructor: called once without parameters to run the program
    Battlefield() {
      initBodyCells();
      
      // Initialize lists
      this.pathogens = new ArrayList();
      this.macrophages = new ArrayList();
      this.neutrophils = new ArrayList();
    }

    void initBodyCells() {
      int rows = 11;
      int columns = 10;
      
      // Init body cell array with total number of body cells. Note that it is not 2D.
      this.bodyCells = new BodyCell[rows * columns];
      
      int index = 0; // Keep track of index

      // Loop over column, then each row, and then create a new body cell
      for (int column = 0; column < columns; column++) {
        float columnVerticalOffset = int(random(0, 25));
        for (int row = 0; row < rows; row++) {
          // As the rectMode is set to center, add 25 (half of cell size) to the x value to make the cell spawn right at the edge of the screen.
          PVector position = new PVector(25 + column * 50, row * 50 + columnVerticalOffset);
          this.bodyCells[index] = new BodyCell(position, index, BODY_CELL_STARTING_HEALTH);
          // Increase index
          index += 1;
        }
      }
    }
    
    // Spawns a pathogen, if the conditions are right.
    void spawnPathogen() {
      
      // The pathogens continuously spawn.
      boolean continuousCondition = PATHOGEN_SPAWN_TYPE == "continuous" && random(1) < PATHOGEN_SPAWN_RATE;
      
      // Waves come every 1000 frames, lasting for 500 frames
      boolean wavesCondition = PATHOGEN_SPAWN_TYPE == "waves" && frameCount % 1000 < 500 && random(1) < PATHOGEN_SPAWN_RATE;
      
      // Ripples come every 200 frames, lasting for 50 frames (basically shorter waves)
      boolean ripplesCondition = PATHOGEN_SPAWN_TYPE == "ripples" && frameCount % 200 < 50 && random(1) < PATHOGEN_SPAWN_RATE;
      
      // Check if one of the conditions is true to spawn a pathogen
      if (continuousCondition || wavesCondition || ripplesCondition) {
        // Generate a random y-value from the screen
        float y = int(random(0, 500));
        
        // Random speed boost to make the pathogens have different speeds
        float randomSpeedBoost = random(PATHOGEN_RANDOM_SPEED_BOOST);
        
        // Add pathogen to list of pathogens, with parameters
        this.pathogens.add(new Pathogen(new PVector(width + 100, y), PATHOGEN_SPEED + randomSpeedBoost ));
      }
    }
    
    // Checks whether the immune system has won or lost the battle. Also calculates percentage health.
    void updateStatus() {
       // Check if the invasion has ended and if there are no more pathogens: the immune system has won!
      if (frameCount > INVASION_END_FRAME) {
        boolean isPathogensLeft = false;
        for (Pathogen pathogen: this.pathogens) {
          if (pathogen.isAlive) isPathogensLeft = true;
        }
        
        if (!isPathogensLeft) {
          noLoop();
          this.simulationStatus = "won";
        }
      }
      
      // Check if there are no more body cells: if so, the immune system has lost...
      int numAliveBodyCells = 0;
      for (BodyCell bodyCell: this.bodyCells) {
        if (bodyCell.isAlive) numAliveBodyCells++;
      }
      
      this.percentageHealth = int(float(numAliveBodyCells) / this.bodyCells.length * 100);
      
      if (numAliveBodyCells == 0) {
        noLoop();
        this.simulationStatus = "lost";
      }
    }
    
    // Draws the status text at the bottom left corner of screen
    void drawStatus() {
        // Black with slight transparency
        fill(0, 0, 0, 200);
        noStroke();
        rectMode(CORNERS);
        rect(15, height - 80, 160, height - 10, 25);
        rectMode(CENTER);
        
        fill(255);
        textSize(20);
        
        text( String.format("Time: %d / %d", this.timeElapsed, int(INVASION_END_FRAME / 50)), 35, height - 50);
        
        if (this.simulationStatus == "won") {
          text("The immune system has won!", 35, height - 25);
        }
        else if (this.simulationStatus == "lost") {
          text("The immune system has lost...", 35, height - 25);
        }
        else {
          text("Health: " + Integer.toString(this.percentageHealth) + "%", 35, height - 25);
        };
    }
    
    void draw() {
      background(#1E0B34); // Dark purple background
      
      updateStatus();
      
      // Set the time elapsed to the frameCount, but less
      this.timeElapsed = int(frameCount / 50);

      // Spawn pathogen if the invasion has not ended
      if (frameCount < INVASION_END_FRAME) {
        this.spawnPathogen();
      }
   
      
      // Loop over objects and draw them
      // Pathogens are in the back, and neutrophils are in the front (due to their explosions)
      for (Pathogen pathogen: this.pathogens) {
        pathogen.draw();
      }
      for (BodyCell bodyCell: this.bodyCells) {
         bodyCell.draw();
      }
      for (Macrophage macrophage: this.macrophages) {
        macrophage.draw();
      }
      for (Neutrophil neutrophil: this.neutrophils) {
        neutrophil.draw();
      }
      
      
      // Spawn macrophages
      if (frameCount % MACROPHAGE_CONSTANT_SPAWN_RATE == 0 || random(1) < MACROPHAGE_RANDOM_SPAWN_RATE) {
        macrophages.add(new Macrophage(new PVector(-100, random(50, 500)), 100, MACROPHAGE_SPEED));
      }
      
      // Spawn neutrophils, but not before 1000 frames
      if (frameCount >= 1000 && (frameCount % NEUTROPHIL_CONSTANT_SPAWN_RATE == 0 || random(1) < NEUTROPHIL_RANDOM_SPAWN_RATE)) {
        neutrophils.add(new Neutrophil(new PVector(-100, random(50, 500)), NEUTROPHIL_SPEED));
      }
      
      drawStatus();
   }
}
