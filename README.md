## Setup

```
install-ubuntu.sh
```
I had to build the gtest package [discribed here](https://stackoverflow.com/questions/24295876/cmake-cannot-find-googletest-required-library-in-ubuntu) even though I installed through apt.

## Run

I am using different version of cuda than the workspace environment, so SDL_VIDEODRIVER=offscreen does not work. In addition, opengl is no longer supported for my version of Unreal Engine so Vulkan is used. So for my environment I omit those options:

* `./CarlaUE4.sh`

In another window, I compile and run the code:
```
cmake .
make
./run_main.sh
```

## Behavior Planner

Lookahead is easy, just find the distance needed to come to a full stop. I chose a deceleration of -0.5.

Goal behind stopping point:
This one is a bit trickier. Cant figure out how to add the stop line buffer, because the buffer is -1.0 and the output of cos or sin will be less than or equal to 1. I did make sure the angle is negative so that it is pointing away from where the vehicle will be directed.

Goal speed at stopping point is easy, we want the vehicle to stop they are all set to 0.0.

Goal speed in nominal state is also easy, just maintain speed limit.

Maintain same goal when in DECEL_TO_STOP state is easy. After every iteration the current goal is saved in _goal which is the past goal. Just make the current goal the same as the previous one.

Calculate distance and use distance rather than speed:
Because there is no speed controller, the speed defaults to 0 each iteration so speed cannot be used to compare, instead distance is used. When the distance to the goal is below a threshold, it is assumed that the vehicle has stopped, so we set the active maneuver to stopped. 

Move to STOPPED state then move to FOLLOW_LANE state:
On the next iteration the vehicle will be in a stopped state so the goal is set the same as the previous goal. When the light turns green, then the state will be changed to FOLLOW_LANE.

## Cost Functions / Trajectory Selection

Circle Placement:
In an ideal world, the vehcile can be represented as a full mesh model of itself. In the real world, that takes too much computation, so a few simple shapes are used, in this case, 3 circles centered at different points in the car are used to represent the space vehicles take up. For each circle, the center is calculated given an offeset and the position of the vehicle.

Distance from circle to objects:
For every other vehicle or object in the frame, the circles around it are also generated. A distance between each circle in each obsticle and each circle in the ego vehicle is generated and if the distance is smaller than the radius of each circle then the objects have collided.

Distance between last point on spiral and main goal:
Find the distance between the last point on the generated spiral and the given goal point. The cost will be greater if they are farther from each other.

## Motion Planner

Perpendicular Direction:
The direction of the offset goal points is the goal yaw plus pi / 2. This provides a 90 degree offset.

Offset Goal Location:
Now the x and y of each offset goal must be calculated. To do this, the offset (calculated previously) is multiplied by either the cos or sin of the yaw calculated before.

## Velocity Profile Generator / Trajectory Generation

Calculate Distance:
Using one of the kinematic formulas, the distance needed to change velocities given the initial velocity, the velocity to change to, and a constant acceleration, is found.

Calculate Final Speed:
Using another kinematic formula, the final velocity is calculated given an initial velocity, the total distance traveled, and a constant acceleration.


## Planning Params

Number of paths:
I chose a reasonable 7 goal lines. I believe a smaller amount doesn't provide enough options, and a larger amount is not necessary. 

Number of points:
I experimented with 8, 16, 24, and 100 points per line (ppl). I noticed that 8 ppl produced strange visual timing issues where despite the speed being low, the vehicle would seem to accelerate to a stop then all of a sudden stop.

![8 ppl cannot navigate around obstacle](Images/Planning_spiral_8_points.gif)

Doubling the ppm eliminates the visual stopping issue. 

![16 ppl is able to navigate around the first obstacle](Images/Planning_spiral_16_points.gif)

I cant see a difference between 16 ppm and 24 ppm. There does not seem to be a large difference in performance either. Because of this I think 24 is a good ppm. 

![24 ppl is not able to navigate around obstacle](Images/Planning_spiral_24_points.gif)

The 24 ppm test hanles the stop light very well also.

![24 ppl stop light](Images/Planning_spiral_24_point_light.gif)
 
Just for fun, I increased the lookahead max value to 50m and the speed limit to 11m/s with the 24 ppm. Of course the code was not designed for these speeds so the ego vehicle's path to avoid other cars is very jerky, and it seems like the distance to stop is the same so the deceleration is very high.

![High speeds](Images/High_speeds.gif)

I also attempted a ppm of 100 with the increased speeds and did notice a decrease in performance. Similar to the 24 ppl high speed test, the vehicle's path is jerky and the deceleration is high. In the middle of the intersection, the path gets messed up.

![100 ppl high speed](Images/Planning_spiral_100.gif)

I included a summary of the metrics below.

|              | Avg Server fps | Avg Client fps | Visual issues | Jerky Path |
| ------------ | -------------- | -------------- | ------------- | ---------- |
| 8 ppl        | 49             | 61             | Yes           | No         | 
| 16 ppl       | 48             | 61             | No            | No         | 
| 24 ppl       | 45             | 58             | No            | No         | 
| 24 ppl Fast  | 46             | 59             | No            | Yes        | 
| 100 ppl Fast | 42             | 42             | Yes           | Yes        | 
