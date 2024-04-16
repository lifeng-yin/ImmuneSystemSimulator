// Represents a civilian cell of the body.

class BodyCell {
    PVector position;
    // The index in the bodyCells ArrayList, used for getting neighbouring cells
    int index;
    PVector nucleusPosition;
    float health;
    boolean isAlive = true;

    BodyCell(PVector p, int i, float h) {
        this.position = p;
        this.health = h;
        this.index = i;
        
        // Randomly generate a position for the nucleus through a random offset of the position.
        PVector nucleusPositionOffset = new PVector(int(random(-10, 10)), int(random(-10, 10)));
        this.nucleusPosition = PVector.add(this.position, nucleusPositionOffset);
    }
    
    void draw() {
      if (this.isAlive == false) return;

      fill(#473063); // Translucent pink to represent cytoplasm
      stroke(#D43CCF); // Bright pink
      strokeWeight(3);
      
      // Create rounded square with cells with damaged cells being slightly smaller.
      // rect() is needed as Processing does not allow rounded edges for square().
      
      float size = 45 - (BODY_CELL_STARTING_HEALTH - this.health) * 10 / BODY_CELL_STARTING_HEALTH;
      rect(this.position.x, this.position.y, size, size, 15);
      
      // Create a small, bright pink circle to represent the nucleus. 
      fill(#D43CCF); 
      circle(this.nucleusPosition.x, this.nucleusPosition.y, 6);
      
      regenerateNeighbouringCells();
    }
    
    // Cell undergoes mitosis (duplication) to fill up holes and repair the tissue
    // Chance of regenerating the cell next to them in the array
    void regenerateNeighbouringCells() {
      // 1 in 100 chance of regenerating (if possible) per frame
      if (random(1) < BODY_CELL_REGENERATION_RATE) {
        
        // Check if cell is close to any pathogens. If so, don't regenerate.
        for (Pathogen pathogen: battlefield.pathogens) {
          if (pathogen.isAlive && dist(this.position.x, this.position.y, pathogen.position.x, pathogen.position.y) < 200) {
            return;
          }
        }
        
        // Regenerate the previous cell in the array
        if (this.index > 0) {
          BodyCell prevCell = battlefield.bodyCells[this.index - 1];
          if (prevCell.isAlive == false) {
            prevCell.isAlive = true;
            prevCell.health = BODY_CELL_STARTING_HEALTH;
          }
        }
        
        // Regenerate the next cell in the array
        if (this.index < battlefield.bodyCells.length - 1) {
          BodyCell nextCell = battlefield.bodyCells[this.index + 1];
          if (nextCell.isAlive == false) {
            nextCell.isAlive = true;
            nextCell.health = BODY_CELL_STARTING_HEALTH;
          }
        }
      }
    }
    
    // Reduces the health of the cell, checking if the cell is alive or not.
    // To be called by other classes.
    void reduceHealth(float dmg) {
        this.health -= dmg;
        
        // Check if cell is dead
        if (this.health <= 0) {
          this.isAlive = false;
        }    
    }
}
