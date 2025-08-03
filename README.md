# Automatic Washing Machine Controller Using Verilog

## Overview
This repository contains a Verilog implementation of a finite state machine (FSM) to control an automatic washing machine. The design simulates the operation of a washing machine through states such as checking the door, filling water, adding detergent, washing, draining, and spinning. The project includes a comprehensive testbench to verify the FSM's behavior under various scenarios, with waveform generation for debugging.

## Access Project at EDAPlayground
 Visit the [EDA Playground link](https://www.edaplayground.com/x/GMvz) to directly access the code.
 
## Project Structure
- **Design File**: `automatic_washing_machine.v`
  - Contains the main module `automatic_washing_machine`, which implements the FSM.
- **Testbench File**: `top_tb.v`
  - Contains the testbench module `top_tb`, which tests the design under multiple scenarios and generates a VCD file for waveform viewing.
- **Timescale**: ``timescale 10ns / 1ps`
  - Time unit: 10 ns (10,000 ps), precision: 1 ps.

## Module Description
### `automatic_washing_machine`
- **Purpose**: Controls an automatic washing machine using an FSM.
- **Inputs**:
  | Signal            | Description                                      |
  |-------------------|--------------------------------------------------|
  | `clk`             | Clock signal for synchronous operation           |
  | `reset`           | Active-high reset to initialize the FSM         |
  | `door_close`      | Indicates if the door is closed                 |
  | `start`           | Starts the washing process                      |
  | `filled`          | Indicates if the water tank is filled           |
  | `detergent_added` | Indicates if detergent has been added           |
  | `cycle_timeout`   | Indicates if the washing cycle has completed    |
  | `drained`         | Indicates if water has been drained             |
  | `spin_timeout`    | Indicates if the spin cycle has completed       |

- **Outputs**:
  | Signal            | Description                                      |
  |-------------------|--------------------------------------------------|
  | `door_lock`       | Controls the door lock mechanism                |
  | `motor_on`        | Controls the washing machine motor              |
  | `fill_value_on`   | Controls the water fill valve                   |
  | `drain_value_on`  | Controls the water drain valve                  |
  | `done`            | Indicates if the washing process is complete    |
  | `soap_wash`       | Indicates if the soap wash cycle is active      |
  | `water_wash`      | Indicates if the water rinse cycle is active    |

- **States**:
  | State             | Code   | Description                                      |
  |-------------------|--------|--------------------------------------------------|
  | `CHECK_DOOR`      | 3'b000 | Checks if the door is closed and start is pressed|
  | `FILL_WATER`      | 3'b001 | Fills the tank with water                       |
  | `ADD_DETERGENT`   | 3'b010 | Adds detergent for soap wash                    |
  | `CYCLE`           | 3'b011 | Runs the washing cycle                          |
  | `DRAIN_WATER`     | 3'b100 | Drains water from the tank                      |
  | `SPIN`            | 3'b101 | Spins to dry clothes                            |

### `top_tb`
- **Purpose**: Tests the `automatic_washing_machine` module under various scenarios.
- **Features**:
  - Generates a VCD file (`dump.vcd`) for waveform viewing.
  - Monitors internal state (`current_state`) and all inputs/outputs.
  - Tests multiple scenarios, including normal operation, error cases, and edge cases.
- **Test Cases**:
  1. **Normal Operation with Rinse and Delays**: Full cycle with rinse, `done = 1` at 1,350,000 ps (135 units).
  2. **Start Without Door Closed**: Stays in `CHECK_DOOR` until `door_close = 1` at 1,750,000 ps (175 units).
  3. **Detergent Not Added**: Stalls in `ADD_DETERGENT` from 2,600,000 ps to 2,800,000 ps.
  4. **Incomplete Fill**: Stalls in `FILL_WATER` from 3,400,000 ps to 3,600,000 ps.
  5. **Premature Cycle Timeout**: Early `cycle_timeout` at 4,550,000 ps.
  6. **Reset in CYCLE State**: Reset at 5,200,000 ps, returns to `CHECK_DOOR`.
  7. **Reset in DRAIN_WATER State**: Reset at 6,350,000 ps, returns to `CHECK_DOOR`.
  8. **Multiple Cycles**: Two consecutive cycles, `done = 1` at 8,250,000 ps and 9,150,000 ps.

## Waveform
The following is a reference waveform generated from the `top_tb` testbench using Siemens QuestaSim on EDA Playground. It shows the behavior of all signals and the internal state (`current_state`) across the test cases.

![Waveform Reference](https://raw.githubusercontent.com/Karan-nevage/Automatic-Washing-Machine-Controller-Using-Verilog/refs/heads/main/Output%20Waveform.png)

## Analyze Waveforms
   - Verify key events:
     - **Test Case 1**: `done = 1` at 1,350,000 ps (135 units).
     - **Test Case 2**: `current_state = 000` until `door_close = 1` at 1,750,000 ps (175 units).
     - **Test Case 3**: `current_state = 010` from 2,600,000 ps to 2,800,000 ps.
     - **Test Case 4**: `current_state = 001` from 3,400,000 ps to 3,600,000 ps.
     - **Test Case 5**: Early `cycle_timeout` at 4,550,000 ps, transitions to `DRAIN_WATER`.
     - **Test Case 6**: Reset at 5,200,000 ps, `current_state = 000`.
     - **Test Case 7**: Reset at 6,350,000 ps, `current_state = 000`.
     - **Test Case 8**: `done = 1` at 8,250,000 ps and 9,150,000 ps.
   - Use EPWave’s time axis (set to ps) to zoom into specific events.

## Usage
- Clone or download this repository.
- Open EDA Playground via the provided [link](https://www.edaplayground.com/x/GMvz) or upload the Verilog files.
- Follow the simulation steps above to run and analyze the testbench.
- Use the waveform viewer to debug state transitions and output behavior.

## Notes
- The design assumes a 10 ns clock period (5 ns high, 5 ns low).
- The testbench is designed to be comprehensive, covering normal operation, error conditions (e.g., door open, no detergent), and edge cases (e.g., premature timeout, resets).
- For further customization, modify the testbench delays or add new test cases in `top_tb`.

## Contributing
Feel free to submit issues or pull requests for improvements, such as additional test cases or design optimizations. Contact the author via [email](mailto:karanpr9423@gmail.com) for collaboration.

## Author
- **Name**: Karankumar Nevage
- **LinkedIn**: [https://www.linkedin.com/in/karankumar-nevage/](https://www.linkedin.com/in/karankumar-nevage/)
- **Email**: [karanpr9423@gmail.com](mailto:karanpr9423@gmail.com)

## License
This project is licensed under the [Appache 2.0](LICENSE). See the [LICENSE](LICENSE) file for details.

