`timescale 10ns / 1ps

// Module: Automatic Washing Machine Controller
// Description: This module implements a finite state machine (FSM) to control an automatic washing machine.
// It manages the washing process through states like checking the door, filling water, adding detergent, cycling,
// draining water, and spinning, based on input signals and a clock.

//=====================================================================================================
//--------------------------------------- Design Module -----------------------------------------------
//=====================================================================================================

module automatic_washing_machine (
    input clk,                    // Clock signal for synchronous operation
    input reset,                  // Active-high reset to initialize the FSM
    input door_close,             // Indicates if the door is closed
    input start,                  // Start signal to begin the washing process
    input filled,                 // Indicates if the water tank is filled
    input detergent_added,        // Indicates if detergent has been added
    input cycle_timeout,          // Indicates if the washing cycle has completed
    input drained,                // Indicates if water has been drained
    input spin_timeout,           // Indicates if the spin cycle has completed
    output reg door_lock,         // Controls the door lock mechanism
    output reg motor_on,          // Controls the washing machine motor
    output reg fill_value_on,     // Controls the water fill valve
    output reg drain_value_on,    // Controls the water drain valve
    output reg done,              // Indicates if the washing process is complete
    output reg soap_wash,         // Indicates if the soap wash cycle is active
    output reg water_wash         // Indicates if the water rinse cycle is active
);

    // State encoding: Defines the states of the washing machine FSM using 3-bit parameters
    parameter CHECK_DOOR     = 3'b000; 	 // Initial state: Check if door is closed and start is pressed
    parameter FILL_WATER     = 3'b001; 	 // Fill the tank with water
    parameter ADD_DETERGENT  = 3'b010; 	 // Add detergent for soap wash
    parameter CYCLE          = 3'b011; 	 // Run the washing cycle
    parameter DRAIN_WATER    = 3'b100; 	 // Drain water from the tank
    parameter SPIN           = 3'b101; 	 // Spin cycle to dry clothes

    reg [2:0] current_state, next_state; // Registers to store current and next FSM states

    // Combinational logic block: Determines the next state and output signals based on current state and inputs
    always @(current_state or start or door_close or filled or detergent_added or drained or cycle_timeout or spin_timeout) begin
        case (current_state)
            CHECK_DOOR: begin
                // Check if the washing machine can start
                if (start == 1 && door_close == 1) begin
                    next_state = FILL_WATER;  // Move to filling water if start is pressed and door is closed
                    door_lock = 1;            // Lock the door
                    motor_on = 0;             // Motor off
                    fill_value_on = 0;        // Fill valve off
                    drain_value_on = 0;       // Drain valve off
                    soap_wash = 0;            // Soap wash not started
                    water_wash = 0;           // Water wash not started
                    done = 0;                 // Process not complete
                end 
              	else begin
                    next_state = current_state; // Stay in CHECK_DOOR if conditions not met
                    door_lock = 0;              // Door remains unlocked
                    motor_on = 0;               // Motor off
                    fill_value_on = 0;          // Fill valve off
                    drain_value_on = 0;         // Drain valve off
                    soap_wash = 0;              // Soap wash off
                    water_wash = 0;             // Water wash off
                    done = 0;                   // Process not complete
                end
            end

          				//******************************************
          
            FILL_WATER: begin
                // Control water filling process
                if (filled == 1) begin
                    	if (soap_wash == 0) begin
                    	    next_state = ADD_DETERGENT; // Move to adding detergent for soap wash
                    	    door_lock = 1;            	// Keep door locked
                    	    motor_on = 0;             	// Motor off
                    	    fill_value_on = 0;        	// Fill valve off (tank is full)
                    	    drain_value_on = 0;       	// Drain valve off
                    	    soap_wash = 1;            	// Enable soap wash
                    	    water_wash = 0;           	// Water wash not started
                    	    done = 0;                 	// Process not complete
                    	end 
                  		else begin
                    	    next_state = CYCLE;       	// Move to washing cycle for rinse
                    	    door_lock = 1;            	// Keep door locked
                    	    motor_on = 0;             	// Motor off
                    	    fill_value_on = 0;        	// Fill valve off
                    	    drain_value_on = 0;       	// Drain valve off
                    	    soap_wash = 1;            	// Keep soap wash active
                    	    water_wash = 1;           	// Enable water wash (rinse)
                    	    done = 0;                 	// Process not complete
                    	end
                end 
              	else begin
                    next_state = current_state; // Stay in FILL_WATER until tank is full
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 1;        	// Open fill valve
                    drain_value_on = 0;       	// Drain valve off
                    done = 0;                 	// Process not complete
                end
            end

          				//******************************************
          
            ADD_DETERGENT: begin
                // Wait for detergent to be added
                if (detergent_added == 1) begin
                    next_state = CYCLE;       	// Move to washing cycle
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 0;       	// Drain valve off
                    soap_wash = 1;            	// Keep soap wash active
                    done = 0;                 	// Process not complete
                end 
              	else begin
                    next_state = current_state; // Stay in ADD_DETERGENT until detergent is added
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 0;       	// Drain valve off
                    soap_wash = 1;            	// Keep soap wash active
                    water_wash = 0;           	// Water wash off
                    done = 0;                 	// Process not complete
                end
            end

          				//******************************************
          
            CYCLE: begin
                // Run the washing cycle
                if (cycle_timeout == 1) begin	
                    next_state = DRAIN_WATER; 	// Move to draining water when cycle completes
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 0;       	// Drain valve off
                    done = 0;                 	// Process not complete
                end 
              	else begin
                    next_state = current_state; // Stay in CYCLE until timeout
                    door_lock = 1;            	// Keep door locked
                    motor_on = 1;             	// Motor on for washing
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 0;       	// Drain valve off
                    done = 0;                 	// Process not complete
                end
            end
          
          				//******************************************

            DRAIN_WATER: begin
                // Drain water from the tank
                if (drained == 1) begin
                    if (water_wash == 0) begin
                        next_state = FILL_WATER;  // Refill for rinse cycle
                        door_lock = 1;            // Keep door locked
                        motor_on = 0;             // Motor off
                        fill_value_on = 0;        // Fill valve off
                        drain_value_on = 0;       // Drain valve off
                        soap_wash = 1;            // Keep soap wash active
                        done = 0;                 // Process not complete
                    end 
                  	else begin
                        next_state = SPIN;        // Move to spin cycle
                        door_lock = 1;            // Keep door locked
                        motor_on = 0;             // Motor off
                        fill_value_on = 0;        // Fill valve off
                        drain_value_on = 0;       // Drain valve off
                        soap_wash = 1;            // Keep soap wash active
                        water_wash = 1;           // Keep water wash active
                        done = 0;                 // Process not complete
                    end
                end else begin
                    next_state = current_state;   // Stay in DRAIN_WATER until drained
                    door_lock = 1;            	  // Keep door locked
                    motor_on = 0;             	  // Motor off
                    fill_value_on = 0;        	  // Fill valve off
                    drain_value_on = 1;       	  // Open drain valve
                    soap_wash = 1;            	  // Keep soap wash active
                    done = 0;                 	  // Process not complete
                end
            end

          				//******************************************
          
            SPIN: begin
                // Run the spin cycle
                if (spin_timeout == 1) begin
                    next_state = CHECK_DOOR;  	// Return to initial state
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 0;       	// Drain valve off
                    soap_wash = 1;            	// Keep soap wash active
                    water_wash = 1;           	// Keep water wash active
                    done = 1;                 	// Signal process completion
                end 
              	else begin
                    next_state = current_state; // Stay in SPIN until timeout
                    door_lock = 1;            	// Keep door locked
                    motor_on = 0;             	// Motor off
                    fill_value_on = 0;        	// Fill valve off
                    drain_value_on = 1;       	// Keep drain valve open
                    soap_wash = 1;            	// Keep soap wash active
                    water_wash = 1;           	// Keep water wash active
                    done = 0;                 	// Process not complete
                end
            end

          				//******************************************
          
            default: begin
                next_state = CHECK_DOOR;  // Default to CHECK_DOOR for safety
            end
          
        endcase
    end

    // Sequential logic: Updates the current state on clock edge or reset
    always @(posedge clk or negedge reset) begin
        if (reset) begin
            current_state <= CHECK_DOOR; // Reset to initial state
        end else begin
            current_state <= next_state; // Update state to next state on clock edge
        end
    end

endmodule

//============================================ END ==================================================
