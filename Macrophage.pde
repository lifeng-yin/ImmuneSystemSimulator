// The first-responder to the scene, macrophages are large white blood cells that swallow up enemy pathogens.

class Macrophage {
    PVector position;
    float health;
    float speed;
    boolean isAlive = true;
    float angle = 0; // The angle of the macrophage, in radians
    Pathogen nearestPathogen;

    Macrophage(PVector p, float h, float s) {
        this.position = p;
        this.health = h;
        this.speed = s;
    }
    
    void draw() {
      if (this.isAlive == false) return;
      
      // These next few lines uses Processing's transformation matrices to rotate the macrophage.
      // For a reference, see https://processing.org/tutorials/transform2d/#rotating-the-correct-way
      
      // Start a new transformation matrix.
      pushMatrix();
      
      // Move the coordinate system to the pivot point, the macrophage's position .
      translate(this.position.x, this.position.y);
      // Rotate the coordinate system by the angle (in radians).
      rotate(this.angle);
      //scale(0.8 + this.health / 500);
      // Move the coordinate system back to the origin, and begin drawing.
      translate(-this.position.x, -this.position.y);
      
      
      
      
      strokeWeight(3);
      stroke(#F6C718); // Brighter yorange (yellow-orange)
      fill(#E1A60E); // Darker yorange
      
      // Draw the macrophage body. A real-life macrophage has arms and a sophisticated shape, but here it is simplified.
      // (unfortunately it resembles an egg-shaped Amogus blob)
      ellipse(this.position.x, this.position.y, 100, 85);
      
      // Draw nucleus
      stroke(#1F60ED); // Darker blue
      fill(#4C85FF); // Lighter blue
      rect(this.position.x + 30, this.position.y, 25, 30, 30); // Rounded rectangle
      
      // As drawing has finished, end the transformation matrix.
      popMatrix();
      
      // Check if nearest pathogen is null or is dead.
      // If so, try to find a new pathogen.
      // Although they contain the same content, the if-statements have been separated due to Processing throwing an error.
      if (this.nearestPathogen == null ) {
          setNearestPathogen();
          if (this.nearestPathogen == null) return;
      }
      else if (this.nearestPathogen.isAlive == false) {
          // Remove the current (dead) nearest pathogen first.
          this.nearestPathogen = null;
          setNearestPathogen();
          if (this.nearestPathogen == null) return;
      }
      
      // As there is a nearest pathogen, head and move towards it, and swallow pathogens.
      headTowardsPathogen();
      move();
      swallowPathogens();
    }
    
    // Set this.nearestPathogen to the nearest alive pathogen.
    // Does not do anything if there are no alive pathogens.
    void setNearestPathogen() {
      float minDist = 1000;
      
      // Calculate position of mouth
      PVector mouthPosition = PVector.add(this.position, PVector.fromAngle(this.angle).mult(15));
      
      // Loop over each alive pathogen
      for (Pathogen pathogen: battlefield.pathogens) {
        if (pathogen.isAlive) {
          
          // Calculate distance
          float distance = dist(mouthPosition.x, mouthPosition.y, pathogen.position.x, pathogen.position.y);
          // If a new distance has been found, then replace it and set the (current) nearest pathogen.
          if (distance < minDist) {
            minDist = distance;
            this.nearestPathogen = pathogen;
          }
        }
      }
    }
    
    // Sets this.angle to be in the direction of the nearest pathogen.
    void headTowardsPathogen() {
      // Find the displacement vector by subtracting the pathogen's position by the macrophage's position.
      PVector displacement = PVector.sub(this.nearestPathogen.position, this.position);
      // Calculate the angle (in radians) using Processing's handy heading() method.
      this.angle = displacement.heading();
    }
    
    // Move the macrophage towards the nearest pathogen.
    void move() {
      // Find unit vector with an angle of this.angle.
      PVector direction = PVector.fromAngle(this.angle);
      // Find velocity by multiplying the unit vector with this.speed.
      PVector velocity = direction.mult(this.speed);
      // Change the position by adding the velocity.
      this.position.add(velocity);
    }
    
    // Swallow (and kill) pathogens.
    void swallowPathogens() {
      
      // Loop over each alive pathogen
      for (Pathogen pathogen: battlefield.pathogens) {
        if (pathogen.isAlive) {
          // Find the position of the "mouth" of the macrophage by adding 15 in the direction of the pathogen
          PVector mouthPosition = PVector.add(this.position, PVector.fromAngle(this.angle).mult(15));
          
          // If distance between the mouth and pathogen is less than 50, then the macrophage can eat the pathogen. The macrophage's health also decreases by 1.
          if (dist(mouthPosition.x, mouthPosition.y, pathogen.position.x, pathogen.position.y) < 50) {
            pathogen.isAlive = false;
            this.reduceHealth(PATHOGEN_DAMAGE);
          }
        }
      }
    }
    
    void reduceHealth(float dmg) {
      this.health -= dmg;
      if (this.health <= 0) {
        this.isAlive = false;
      }
    }
}
