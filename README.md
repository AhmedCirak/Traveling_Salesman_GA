# Genetic Algorithm for the Traveling Salesman Problem (TSP) — MATLAB

A MATLAB implementation of a Genetic Algorithm (GA) that solves a delivery-routing variant of the Traveling Salesman Problem: finding the shortest route from a start point, through a set of delivery points, to a fixed destination.

## Problem Description

- A **start point** and a **goal/destination point** are fixed.
- **20 delivery points** are randomly generated inside a bounded area.
- The goal is to find the order in which to visit all delivery points that **minimizes the total travel distance** from start → deliveries → goal.

## How It Works

The script implements a standard GA pipeline:

1. **Initialization** — a population of random permutations (routes) of the delivery points.
2. **Fitness function** — total Euclidean distance of the full path (start → deliveries in chromosome order → goal).
3. **Selection** — tournament selection (tournament size = 5).
4. **Crossover** — Order Crossover (OX), preserving a valid permutation of delivery points.
5. **Mutation** — swap mutation (randomly swaps two points in the route).
6. **Elitism** — the best individual of each generation is carried over unchanged.
7. **Multiple runs** — the whole GA is run several times (independent runs) to compare convergence and to keep the overall best solution found.

## GA Parameters

All parameters are configurable in the code.

| Parameter | Value |
|---|---|
| Population size | 50 |
| Generations | 100 |
| Crossover probability | 0.8 |
| Mutation probability | 0.1 |
| Tournament size | 5 |
| Independent runs | 3 |

## Output

Running the script produces a figure with three subplots:

1. **All possible connections** between start, delivery points, and goal (visualizes the search space).
2. **Fitness over generations** for each independent run, showing convergence behavior.
3. **Final optimal route** found, with directional arrows and the best total distance in the title.

## Requirements

- MATLAB (no additional toolboxes required — uses only base MATLAB functions).

## Usage

```matlab
GA_Dostava_20_Tacaka
```

Running the function will generate the delivery points (seeded for reproducibility via `rng(1)`), execute the GA across 3 runs, and display the results figure described above.

## Results

Example output figures are saved in the [`results/`](./results) folder.

## Project Structure

```
GA_TSP_MATLAB/
├── GA_Dostava_20_Tacaka.m   # Main GA script
├── results/                 # Output figures / screenshots
└── README.md
```

## Notes

- Internal variable and function names are in Bosnian (the language the project was originally written in); this README documents the project in English for portfolio/GitHub purposes.
- The random seed for delivery-point generation is fixed (`rng(1)`) for reproducibility, while the GA's stochastic operators (selection, crossover, mutation) use a shuffled seed (`rng('shuffle')`) so each run explores different solutions.
