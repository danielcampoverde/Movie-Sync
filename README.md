# MovieSync

## Design Goal

The goal of this project was to design a system that synchronizes smart lights to the content of a video stream. This is similar to products such as the Phillips HDMI SyncBox. Our solution should be adaptable to work with any brand of lights.

The smart lights react to the color and intensity of each video frame on the HDMI input. An HDMI output port allows the user to watch the original video stream or to apply a filter to each frame in real-time.

## Table of Contents

- [MovieSync](#moviesync)
  - [Design Goal](#design-goal)
  - [Table of Contents](#table-of-contents)
  - [Key Terms](#key-terms)
  - [Design Overview](#design-overview)
    - [Platform](#platform)
    - [Directory Structure](#directory-structure)
    - [Notes](#notes)
  - [Demo](#demo)
  - [Aditional Resources](#aditional-resources)
  - [About](#about)

## Key Terms

- HDMI in
- HDMI out
- HDMI stream
- Filter
- Ethernet
- WiFi
- Light control

## Design Overview

### Platform

This design was be implemented using a Digilient Nexys Video Artix-7 FPGA board that provides HDMI input and output ports.

The hardware parts of the project were implemented using Vivado 2018.1.

To program the project use SDK 2017.4.

### Directory Structure

- docs
  - documentation and resouces such as the final report and presentation slides.
- src
  - ...
- ip_repo
  - ...

### Notes

- All data streaming is **RBG** except for the `avg_col` read by the microblaze which is **RGB**.
- Average color can be read from `BASE_AVERAGER_ADDR + 0x0`
- Which filter to apply can be selected by writing to `BASE_FILTER_ADDR + 0xC`

| Filter Select | Filter       | Variation |
| :------------ | :----------- | :-------- |
| 0, 5, 8-15    | No Filter    |
| 1             | Greyscale    |
| 2, 3, 4, 6    | Vignette     | Slower dropoff (2,3), Faster dropoff (4,6). Fade to black (2,6), Fade to average color (3,4).
| 7             | Test Pattern |

## Demo

Here is a link to the [project demo](https://www.youtube.com/watch?v=-cMMUXW6eE8&feature=youtu.be).

## Aditional Resources

For more details, please see our [final report](docs/MovieSync_Final_Report.pdf).

Our final presentation slides can be found [here](docs/MovieSync_Final_Pres.pdf)

Greyscale

- Color ratios from [here](https://en.wikipedia.org/wiki/Grayscale)

Vignette

- The vignette dropoff fuction that we used was extended from [here](https://www.codeproject.com/Articles/182814/Vignettes-for-You-and-Me)
- They use `(1+cos(x))/2` as dropoff
- For the dropoff used in this project see the [final report - section 4.4](docs/MovieSync_Final_Report.pdf)

[Digilent HDMI tutorial](https://github.com/Digilent/Nexys-Video-HDMI)

The following are some of the **Xilinx IP docs** consulted in the creation of this project.

- Video In to AXI4-Stream
- Video Timing Controller
- AXI4-Stream to Video Out

## About

Authors:

- Isidor Brkic
- Rakib Ahmed
- Daniel Campoverde
- Luis Munoz

Course: ECE532

Location: University of Toronto

Date: Jan - April 2020
