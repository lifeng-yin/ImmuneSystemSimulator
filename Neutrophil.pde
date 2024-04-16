// The general of the immune system's army, neutrophils are homing missibles that self-destruct to destroy pathogens. 

class Neutrophil {
    PVector position;
    float timeLeft = NEUTROPHIL_LIFESPAN;
    float speed;
    boolean isAlive = true;
    float directionAngle = 0; // The angle that the neutrophil is going towards (in radians)
    float rotationAngle = 0; // The angle that the neutrophil's spikes are rotating at.
    float blastRadius = NEUTROPHIL_BLAST_RADIUS;
    boolean isSelfDestructing;
    // The argument that is passed into the easing function that calculates the blast radius. Increases linearly with the amount of frames that 
    // have passed since the start of the blast.
    float blastEaseFactor = 0;
    Pathogen nearestPathogen;

    Neutrophil(PVector p, float s) {
        this.position = p;
        this.speed = s;
    }
    
    void draw() {
      if (this.isAlive == false) return;
      
      // Rotate the spikes by this.rotationAngle, using the same technique as the macrophage rotation.
      pushMatrix();
      translate(this.position.x, this.position.y);
      rotate(this.rotationAngle);
      translate(-this.position.x, -this.position.y);
      
      // Draw 7 evenly-spaced spikes on the perimeter
      for (int i = 0; i < 8; i++) {
        // Rotation using the same method as the macrophage rotation.
        translate(this.position.x, this.position.y);
        rotate(radians(360 / 8));
        translate(-this.position.x, -this.position.y);
        
        stroke(#D62A2A);
        strokeWeight(7);
        noFill();
        strokeJoin(ROUND);
        triangle(this.position.x + 35, this.position.y, this.position.x + 15, this.position.y - 5, this.position.x + 20, this.position.y + 5);
      }
      
      popMatrix();
      
      
      strokeWeight(5);
      stroke(#D62A2A); // Lighter red
      fill(#701010); // Dark red
      // Draw neutrophil body.
      circle(this.position.x, this.position.y, 50);
      
      // Make the circles in the neutrophil face towards the direction of the pathogen, using the same rotation method.
      pushMatrix();
      translate(this.position.x, this.position.y);
      rotate(this.directionAngle);
      translate(-this.position.x, -this.position.y);
      
      noStroke();
      fill(#33DDEE); // Cyan
      
      circle(this.position.x + 10, this.position.y, 15); // Larger, front circle
      circle(this.position.x - 6, this.position.y - 10, 12); // Smaller, top circle
      circle(this.position.x - 6, this.position.y + 10, 12); // Smaller, bottom circle
      
      popMatrix();
      
     
      // Constant rotation of 1 degree per frame
      this.rotationAngle += radians(1);
      
      // Reduce the time left
      this.timeLeft -= 1;
      
      if (this.isSelfDestructing) {
        this.blastEaseFactor += 0.05;
        
        // Easing function obtained from https://gizma.com/easing/#easeInOutQuad
        float currentBlastRadius = (1 - pow(1 - blastEaseFactor, 2)) * 100;
        
        fill(255);
        noStroke();
        circle(this.position.x, this.position.y, currentBlastRadius);
        
        // The blast radius has grown to the max blast radius, so damage nearby objects and stop drawing
        if (currentBlastRadius >= this.blastRadius) {
          damageObjectsInBlast();
          this.isAlive = false;
        }
      }
      else {
        
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
        
        // Calculate distance to nearest pathogen.
        float distance = dist(this.position.x, this.position.y, this.nearestPathogen.position.x, this.nearestPathogen.position.y);
        
        // Self destruct if close to pathogen or its lifespan has ended.
        if (distance <= 10 || this.timeLeft <= 0) {
          this.isSelfDestructing = true;
        }
        else {
            headTowardsPathogen();
            move();
        }
      }
    }
    
    // Set this.nearestPathogen to the nearest alive pathogen.
    // Does not do anything if there are no alive pathogens.
    void setNearestPathogen() {
      float minDist = 1000;
      
      // Loop over each alive pathogen
      for (Pathogen pathogen: battlefield.pathogens) {
        if (pathogen.isAlive) {
          // Calculate distance
          float distance = dist(this.position.x, this.position.y, pathogen.position.x, pathogen.position.y);
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
      // Find the displacement vector by subtracting the pathogen's position by the neutrophil's position.
      PVector displacement = PVector.sub(this.nearestPathogen.position, this.position);
      // Calculate the angle (in radians) using Processing's handy heading() method.
      this.directionAngle = displacement.heading();
    }
    
    // Move the neutrophil towards the nearest pathogen.
    void move() {
      // Find unit vector with an angle of this.angle.
      PVector direction = PVector.fromAngle(this.directionAngle);
      // Find velocity by multiplying the unit vector with this.speed.
      PVector velocity = direction.mult(this.speed);
      // Change the position by adding the velocity.
      this.position.add(velocity);
    }
    
    // Damange the objects (bodyCells and pathogens) within the blast radius. To be called once only.
    void damageObjectsInBlast() {
      // Loop over each alive pathogen
      for (Pathogen pathogen: battlefield.pathogens) {
        if (pathogen.isAlive) {
          
          // If distance between the neutrophil and pathogen is less than 50, kill the pathogen.
          if (dist(this.position.x, this.position.y, pathogen.position.x, pathogen.position.y) <= this.blastRadius) {
            pathogen.isAlive = false;
          }
        }
      }
      
      // Also loop over each body cell
      for (BodyCell bodyCell: battlefield.bodyCells) {
        if (bodyCell.isAlive) {
          // If distance between the neutrophil and bodyCell is less than 50, reduce the bodyCell's health by  the pathogen.
          float distance = dist(this.position.x, this.position.y, bodyCell.position.x, bodyCell.position.y);
          if (distance <= this.blastRadius) {
            // Reduces the health of the bodyCell by 5 + (blastRadius - distance) / 5
            // For example (with blastRadius 100): a cell on the edge of the blast radius would take 5 dmg
            //                                    a cell at the very center of the blast would take 20 dmg
            bodyCell.reduceHealth(3 + (blastRadius - distance) / 10);
          }
        }
      }
      
      // Also loop over each macrophage
      for (Macrophage macrophage: battlefield.macrophages) {
        if (macrophage.isAlive) {
          float distance = dist(this.position.x, this.position.y, macrophage.position.x, macrophage.position.y);
          if (distance <= this.blastRadius) {
            // As macrophages have more health, reduce it more: 10 + (blastRadius - distance) / 2
            macrophage.reduceHealth(10 + (blastRadius - distance) / 2);
          }
        }
      }
      
      // Also loop over each other neutrophil
      for (Neutrophil neutrophil: battlefield.neutrophils) {
        if (neutrophil.isAlive && neutrophil != this) {
          float distance = dist(this.position.x, this.position.y, neutrophil.position.x, neutrophil.position.y);
          if (distance <= this.blastRadius) {
            neutrophil.isSelfDestructing = true;
          }
        }
      }
    }
}
