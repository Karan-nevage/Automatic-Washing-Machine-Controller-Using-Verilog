// Module: Testbench for Automatic Washing Machine
// Description: This testbench simulates the washing machine controller by providing a sequence of inputs
// to test the FSM's behavior through all states.

//=====================================================================================================
//--------------------------------------- Test-Bench Module -------------------------------------------
//=====================================================================================================

module top_tb;
    //----> Testbench signals
    reg clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
    wire door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash;
    // Internal signal for state monitoring
    wire [2:0] current_state;

    //----> Instantiate the washing machine module
    automatic_washing_machine machine1 (
        .clk(clk),
        .reset(reset),
        .door_close(door_close),
        .start(start),
        .filled(filled),
        .detergent_added(detergent_added),
        .cycle_timeout(cycle_timeout),
        .drained(drained),
        .spin_timeout(spin_timeout),
        .door_lock(door_lock),
        .motor_on(motor_on),
        .fill_value_on(fill_value_on),
        .drain_value_on(drain_value_on),
        .done(done),
        .soap_wash(soap_wash),
        .water_wash(water_wash)
    );

    //-----> Expose internal state for waveform viewing
    assign current_state = machine1.current_state;

    //-----> Clock generation: Toggle clock every 5 time units (10ns = 10,000 ps period)
    always begin
        #5 clk = ~clk;
    end

    //----> Test stimulus: Sequence of inputs to test various scenarios
    initial begin
        //----> Initialize all signals
        clk = 0;              // Start with clock low
        reset = 1;            // Assert reset
        start = 0;            // Start off
        door_close = 0;       // Door open
        filled = 0;           // Tank not filled
        drained = 0;          // Tank not drained
        detergent_added = 0;  // Detergent not added
        cycle_timeout = 0;    // Cycle not complete
        spin_timeout = 0;     // Spin not complete

        // Test Case 1: Normal operation with rinse and delays (done = 1 at 1,350,000 ps = 135 units)=================
        #5 reset = 0;                   // Deassert reset (t=5, 50,000 ps)
        #15 start = 1; door_close = 1;  // Start machine and close door (t=20, 200,000 ps)
        #20 filled = 1;                 // Tank filled (t=40, 400,000 ps)
        #20 detergent_added = 1;        // Detergent added (t=60, 600,000 ps)
        #20 cycle_timeout = 1;          // Washing cycle complete (t=80, 800,000 ps)
        #15 drained = 1;                // Water drained (t=95, 950,000 ps)
        #15 filled = 1;                 // Tank refilled for rinse (t=110, 1,100,000 ps)
        #15 cycle_timeout = 1;          // Rinse cycle complete (t=125, 1,250,000 ps)
        #10 drained = 1;                // Water drained (t=135, 1,350,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete, done = 1 (t=145, 1,450,000 ps)

      // Test Case 2: Start without door closed (door_close = 1 at 1,750,000 ps = 175 units) =========================
        #10 reset = 1;                  // Reset to start fresh (t=155, 1,550,000 ps)
        #5 reset = 0;                   // Deassert reset (t=160, 1,600,000 ps)
        #10 start = 1; door_close = 0;  // Start with door open (t=170, 1,700,000 ps)
        #5 door_close = 0;             // Keep door open to test CHECK_DOOR (t=175, 1,750,000 ps)
        #5 door_close = 1;             // Close door to proceed (t=180, 1,800,000 ps)
        #10 filled = 1;                 // Tank filled (t=190, 1,900,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=200, 2,000,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=210, 2,100,000 ps)
        #10 drained = 1;                // Water drained (t=220, 2,200,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=230, 2,300,000 ps)

        // Test Case 3: Detergent not added
      #10 reset = 1;                  // Reset to start fresh (t=240, 2,400,000 ps) =================================
        #5 reset = 0;                   // Deassert reset (t=245, 2,450,000 ps)
        #5 start = 1; door_close = 1;   // Start machine (t=250, 2,500,000 ps)
        #10 filled = 1;                 // Tank filled (t=260, 2,600,000 ps)
        #20 detergent_added = 0;        // Detergent not added, stay in ADD_DETERGENT (t=280, 2,800,000 ps)
        #10 detergent_added = 1;        // Add detergent to proceed (t=290, 2,900,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=300, 3,000,000 ps)
        #10 drained = 1;                // Water drained (t=310, 3,100,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=320, 3,200,000 ps)

        // Test Case 4: Incomplete fill
      #10 reset = 1;                  // Reset to start fresh (t=330, 3,300,000 ps) ==============================
        #5 reset = 0;                   // Deassert reset (t=335, 3,350,000 ps)
        #5 start = 1; door_close = 1;   // Start machine (t=340, 3,400,000 ps)
        #20 filled = 0;                 // Tank not filled, stay in FILL_WATER (t=360, 3,600,000 ps)
        #10 filled = 1;                 // Tank filled to proceed (t=370, 3,700,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=380, 3,800,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=390, 3,900,000 ps)
        #10 drained = 1;                // Water drained (t=400, 4,000,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=410, 4,100,000 ps)

        // Test Case 5: Premature cycle timeout
      #10 reset = 1;                  // Reset to start fresh (t=420, 4,200,000 ps) ==============================
        #5 reset = 0;                   // Deassert reset (t=425, 4,250,000 ps)
        #5 start = 1; door_close = 1;   // Start machine (t=430, 4,300,000 ps)
        #10 filled = 1;                 // Tank filled (t=440, 4,400,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=450, 4,500,000 ps)
        #5 cycle_timeout = 1;           // Premature cycle timeout (t=455, 4,550,000 ps)
        #10 drained = 1;                // Water drained (t=465, 4,650,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=475, 4,750,000 ps)

        // Test Case 6: Reset in CYCLE state ====================================================================
        #10 reset = 1;                  // Reset to start fresh (t=485, 4,850,000 ps)
        #5 reset = 0;                   // Deassert reset (t=490, 4,900,000 ps)
        #5 start = 1; door_close = 1;   // Start machine (t=495, 4,950,000 ps)
        #10 filled = 1;                 // Tank filled (t=505, 5,050,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=515, 5,150,000 ps)
        #5 reset = 1;                   // Reset during CYCLE state (t=520, 5,200,000 ps)
        #5 reset = 0;                   // Deassert reset (t=525, 5,250,000 ps)
        #5 start = 1; door_close = 1;   // Restart machine (t=530, 5,300,000 ps)
        #10 filled = 1;                 // Tank filled (t=540, 5,400,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=550, 5,500,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=560, 5,600,000 ps)
        #10 drained = 1;                // Water drained (t=570, 5,700,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=580, 5,800,000 ps)

        // Test Case 7: Reset in DRAIN_WATER state =============================================================
        #10 reset = 1;                  // Reset to start fresh (t=590, 5,900,000 ps)
        #5 reset = 0;                   // Deassert reset (t=595, 5,950,000 ps)
        #5 start = 1; door_close = 1;   // Start machine (t=600, 6,000,000 ps)
        #10 filled = 1;                 // Tank filled (t=610, 6,100,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=620, 6,200,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=630, 6,300,000 ps)
        #5 reset = 1;                   // Reset during DRAIN_WATER (t=635, 6,350,000 ps)
        #5 reset = 0;                   // Deassert reset (t=640, 6,400,000 ps)
        #5 start = 1; door_close = 1;   // Restart machine (t=645, 6,450,000 ps)
        #10 filled = 1;                 // Tank filled (t=655, 6,550,000 ps)
        #10 detergent_added = 1;        // Detergent added (t=665, 6,650,000 ps)
        #10 cycle_timeout = 1;          // Washing cycle complete (t=675, 6,750,000 ps)
        #10 drained = 1;                // Water drained (t=685, 6,850,000 ps)
        #10 spin_timeout = 1;           // Spin cycle complete (t=695, 6,950,000 ps)

        // Test Case 8: Multiple cycles ======================================================================
        #10 reset = 1;                  // Reset to start fresh (t=705, 7,050,000 ps)
        #5 reset = 0;                   // Deassert reset (t=710, 7,100,000 ps)
        #5 start = 1; door_close = 1;   // Start first cycle (t=715, 7,150,000 ps)
        #15 filled = 1;                 // Tank filled (t=730, 7,300,000 ps)
        #15 detergent_added = 1;        // Detergent added (t=745, 7,450,000 ps)
        #15 cycle_timeout = 1;          // Washing cycle complete (t=760, 7,600,000 ps)
        #10 drained = 1;                // Water drained (t=770, 7,700,000 ps)
        #15 filled = 1;                 // Tank refilled for rinse (t=785, 7,850,000 ps)
        #15 cycle_timeout = 1;          // Rinse cycle complete (t=800, 8,000,000 ps)
        #10 drained = 1;                // Water drained (t=810, 8,100,000 ps)
        #15 spin_timeout = 1;           // Spin cycle complete (t=825, 8,250,000 ps)
        #10 reset = 1;                  // Reset for second cycle (t=835, 8,350,000 ps)
        #5 reset = 0;                   // Deassert reset (t=840, 8,400,000 ps)
        #5 start = 1; door_close = 1;   // Start second cycle (t=845, 8,450,000 ps)
        #15 filled = 1;                 // Tank filled (t=860, 8,600,000 ps)
        #15 detergent_added = 1;        // Detergent added (t=875, 8,750,000 ps)
        #15 cycle_timeout = 1;          // Washing cycle complete (t=890, 8,900,000 ps)
        #10 drained = 1;                // Water drained (t=900, 9,000,000 ps)
        #15 spin_timeout = 1;           // Spin cycle complete (t=915, 9,150,000 ps)
      
      	//===================================================================================================

        #10 $finish;                    // End simulation
    end

  				//************************************************************
  
    // VCD dump: Generate waveform file for debugging
    initial begin
        $dumpfile("dump.vcd");          // Specify the VCD file name
        $dumpvars(0, top_tb);          // Dump all signals in the testbench
    end
  
  				//*************************************************************

    // Monitor: Display signal values at each time step for debugging
    initial begin
        $monitor("Time=%0t, Clock=%b, Reset=%b, Start=%b, Door_close=%b, Filled=%b, Detergent_added=%b, Cycle_timeout=%b, Drained=%b, Spin_timeout=%b, Door_lock=%b, Motor_on=%b, Fill_valve_on=%b, Drain_valve_on=%b, Soap_wash=%b, Water_wash=%b, Done=%b, Current_state=%b",
                 $time, clk, reset, start, door_close, filled, detergent_added, cycle_timeout, drained, spin_timeout,
                 door_lock, motor_on, fill_value_on, drain_value_on, soap_wash, water_wash, done, current_state);
    end

endmodule
          
//============================================ END ==================================================
