class Pathogen {
    PVector position;
    float speed;
    boolean isAlive;

    Pathogen(PVector p, float s) {
        this.position = p;
        this.speed = s;
        this.isAlive = true;
    }
    
    void draw() {
      if (this.isAlive == false) return;

      fill(0, 120, 40); // Darker green
      strokeWeight(2);
      stroke(0, 210, 0); // Lighter green
      
      // Create a rectangle with maximum roundness
      rect(this.position.x, this.position.y, PATHOGEN_LENGTH, PATHOGEN_WIDTH, 999);
      
      this.position.x -= this.speed;
      
      if (this.position.x < 500) {
        for (BodyCell bodyCell: battlefield.bodyCells) {
          if (bodyCell.isAlive && dist(this.position.x, this.position.y, bodyCell.position.x, bodyCell.position.y) < 35) {
            this.isAlive = false;
            bodyCell.reduceHealth(PATHOGEN_DAMAGE);
          }
        }
      }
      
      // The pathogen has successfully penetrated the wall of cells. Although it is still alive, for the purposes of the model, it is dead.
      if (this.position.x < -100) {
        this.isAlive = false;
      }
    }
}
