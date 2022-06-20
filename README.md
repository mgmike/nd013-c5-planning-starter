# Purpose of This Repo

This repository contains the starter code to launch in the SDC Planning course workspace. 

## Behavior Planner

Lookahead is easy, just find the distance needed to come to a full stop. I chose a decleration of -0.5.

Goal behind stopping point:
This one is a bit trickier. Cant figure out how to add the stop line buffer, because the buffer is -1.0 and the output of cos or sin will be less than or equal to 1. I did make sure the angle is negative so that it is pointing away from where the vehicle will be directed.

Goal speed at stopping point is easy, we want the vehicle to stop they are all set to 0.0.

Goal speed in nominal state is also easy, just maintain speed limit.

Maintain same goal when in DECEL_TO_STOP state is easy. After every iteration the current goal is saved in _goal which is the past goal. Just make the current goal the same as the previous one.

Calculate distance and use distance rather than speed:
Because there is no speed controller, the speed defaults to 0 each iteration so speed cannot be used to compare, instead distance is used. When the distance to the goal is below a threshold, it is assumed that the vehicle has stopped, so we set the active maneuver to stopped. 

Move to STOPPED state then move to FOLLOW_LANE state:
On the next iteration the vehicle will be in a stopped state so the goal is set the same as the previous goal. When the light turns green, then the state will be changed to FOLLOW_LANE.

## Cost Functions

Circle Placement:
In an ideal world, the vehcile can be represented as a full mesh model of itself. In the real world, that takes too much computation, so a few simple shapes are used, in this case, 3 circles centered at different points in the car are used to represent the space vehicles take up. For each circle, the center is calculated given an offeset and the position of the vehicle.

Distance from circle to objects:
For every other vehicle or object in the frame, the circles around it are also generated. A distance between each circle in each obsticle and each circle in the ego vehicle is generated and if the distance is smaller than the radius of each circle then the objects have collided.

Distance between last point on spiral and main goal:
Find the distance between the last point on the generated spiral and the given goal point. The cost will be greater if they are farther from each other.