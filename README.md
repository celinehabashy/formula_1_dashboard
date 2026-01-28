# 🏎️ Formula 1 Dashboard
Auther/Developer: Celine Habashy

Interactive Shiny dashboard that provides insights into Formula 1 race results, driver performance, and circuit locations over different seasons. This dashboard allows F1 fans, analysts, and racing enthusiasts to explore historical data and visualize trends in a user-friendly interface.

## Motivation 

Formula 1 is a data-driven sport, and understanding race performance, driver trends, and circuit data is essential for fans and analysts. This dashboard provides an intuitive way to explore race data, identify key patterns, and analyze driver performance across different seasons. It helps users visualize race locations, compare driver results, and discover trends that influence race outcomes.

This dashboard is designed for:

- F1 enthusiasts who want to analyze past races and explore driver performance.
- Analysts seeking insights into performance trends over time.
- Casual fans interested in an interactive way to engage with race data.


## App Description 

![Demo](img/demo.gif)

The Formula 1 Race Dashboard is an interactive data visualization tool that provides insights into Formula 1 race results and driver performance across different seasons. It includes the following features:

🏁 Race Map
- Displays race circuits and locations for selected seasons.
- Allows users to explore F1 tracks across the world using an interactive Leaflet map.

📈 Driver Performance Analysis
- Visualizes driver finishing positions over a season.
- Helps identify performance trends and consistency.

🏆 Race Statistics
- Highlights key race metrics such as:
- Race winners
- Fastest lap holders
- Winning teams

Users can filter data by year, circuit, and driver, making it a powerful tool for analyzing Formula 1 history and performance patterns.

### Data Description

The dashboard utilizes multiple datasets related to Formula 1 racing, including:

**Circuits Data** - Information about race circuits, including names, locations, and geographic coordinates.

**Races Data** - Historical race details such as race name, year, and associated circuit.

**Drivers Data** - Information on F1 drivers, including names and nationalities.

**Results Data** - Individual race results, including driver placements, fastest laps, and constructor details.

**Constructors Data** - Information about teams participating in the races.

These datasets are integrated into the dashboard to allow for interactive exploration and visualization.

## Installation

To set up and run the dashboard locally, follow these steps:

### 1. Clone the  repository  
```bash
git clone https://github.ubc.ca/mds-2024-25/DSCI_532_individual-assignment_chabashy.git
cd DSCI_532_individual-assignment_chabashy.git
```
### 2. Create and activate a conda environment 
```bash
conda env create -f environment.yml
conda activate f1_dashboard_env
```
### 3. Run the Shiny app
```bash
Rscript -e 'shiny::runApp()'
```
