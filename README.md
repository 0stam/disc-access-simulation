# Disk access algorithm simulation

A simulation/visualization of different HDD scheduling algorithms.

https://github.com/user-attachments/assets/49f24310-0890-4c1d-a8be-e0d42a74f57b

## Features

- FCFS, SSTF, SCAN, and C-SCAN algorithms
- Calculation of average request handling time
- Optional inclusion of priority real-time requests
- Shader-based visualization

The visualization demonstrates how these algorithms manage head movement across HDD tracks. Specific sector positions and rotational latency are not taken into account. The plate rotation is a visual effect only (a cool one though).

## Architecture

The code is split into logic and presentation layers.

- **`main/`**: Setup code that connects the simulation to the UI.
- **`runner/`**: Logic for generating and managing disk requests.
- **`strategies/`**: Implementation of the algorithms (FCFS, SSTF, etc).
- **`disk/`** & **`disk_circle/`**: Visuals for the hard drive and the shader for the spinning platter.
- **`ui/`**: Display for statistics and other UI controls.
