/*

  ***************************
  Immune System Simulator
  Created by: Li Feng Yin
  ***************************
  
  This program is meant to model a simple battle between the human body's immune system and invading pathogens.
  
  Note: this program is not meant to be scientifically accurate! The immune system is the second-most complex organ system in the human body,
  besides the nervous system. As such, this program only depicts a small, 2D, close-up battle in the innate immune system, with only 2 types of
  immune cells. It does not show the immune system's ultimate weapon: the adaptive immune system, which is far more complex. This program also 
  omits details such as: immune cell and pathogen duplication, collision detection, and pathogens infecting cells (rather than destroying).
*/

// CONFIGURATION

// The frame at which the pathogens stop spawning and end their invasion.
int INVASION_END_FRAME = 1500;

// Starting health of a body cell
float BODY_CELL_STARTING_HEALTH = 5;
// The probability, per frame, that a cell duplicates to regenerate its neighbours. Value from 0 - 1.
float BODY_CELL_REGENERATION_RATE = 0.01;
 
// Starting health of a macrophage
float MACROPHAGE_STARTING_HEALTH = 10000;
// Every x number of frames, a macrophage spawns.
float MACROPHAGE_CONSTANT_SPAWN_RATE = 500;
// Every frame, there is an x% chance a macrophage spawns. Value from 0 - 1.
float MACROPHAGE_RANDOM_SPAWN_RATE = 0.001;
// Macrophage speed, in pixels.
float MACROPHAGE_SPEED = 5;

// Every x number of frames, a neutrophil spawns.
float NEUTROPHIL_CONSTANT_SPAWN_RATE = 500;
// The probability, per frame, that a random neutrophil spawns. Value from 0 - 1.
float NEUTROPHIL_RANDOM_SPAWN_RATE = 0.005;
// Macrophage speed, in pixels.
float NEUTROPHIL_SPEED = 3;
// The amount of damage neutrophils do to body cells at the center of the blast. (Body cells take less damage away from the blast). 
float NEUTROPHIL_BODY_CELL_DAMAGE = 20;
// Time left of neutrophils before they explode automatically, in frames.
int NEUTROPHIL_LIFESPAN = 300;
// Blast radius of neutrophils.
float NEUTROPHIL_BLAST_RADIUS = 100;

// How the pathogen invasion is spread out. 
String PATHOGEN_SPAWN_TYPE = "continuous"; // "continuous", "waves", "ripples"
// The probability, per frame, that a pathogen spawns. Value from 0 - 1.
float PATHOGEN_SPAWN_RATE = 1;
// Pathogen speed, in pixels.
float PATHOGEN_SPEED = 2;
// Random number from 0 to this number to be added to pathogen speed
float PATHOGEN_RANDOM_SPEED_BOOST = 0.5;
// Pathogen damage to body cells and macrophages.
float PATHOGEN_DAMAGE = 2;
// Pathogen length in pixels.
float PATHOGEN_LENGTH = 20;
// Pathogen width in pixels.
float PATHOGEN_WIDTH = 8;

Battlefield battlefield;

void setup() {
    // Set the resolution of the screen higher. This is to make rounded corners not look pixelated (although it comes with a cost of reduced performance).
    pixelDensity(displayDensity());
    
    // Set the size of the screen to be a little wider than typical processing programs.
    size(1000, 500);
    
    // Set frame rate.
    frameRate(30);
    
    // Set rectangles to be drawn with the specificed position point being the center instead of the top-left corner.
    // This provides consistency across the program (with circles and ellipses).
    rectMode(CENTER);

    battlefield = new Battlefield(); 
}

void draw() {
    battlefield.draw();
}
