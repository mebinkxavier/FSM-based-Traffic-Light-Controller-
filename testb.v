`timescale 1ns / 1ps

module test_tb;


// DUT I/Os

reg clock;
reg clear;
reg X;
wire [1:0] hwy;
wire [1:0] cntry;


// Instantiate DUT

TLC uut (
    .hwy(hwy),
    .cntry(cntry),
    .X(X),
    .clock(clock),
    .clear(clear)
);


// Clock Generator (10ns period)

always #5 clock = ~clock;  // 100MHz clock

// Test Sequence with setup margin

initial begin
    $display("🚦 Starting Traffic Light FSM Test...");

    clock = 0;
    clear = 1;
    X = 0;
    #20;

    clear = 0;
    X = 0;
    #50;

    //  Simulate car on country road (apply X slightly before clock edge)
    #45;    // At 115ns total time
    X = 1;  // Becomes 1 at 115ns (before 120ns clock edge)
    $display(" Car detected at Time = %0t", $time);
    #55;

    // Keep car present during country GREEN
    #100;

    // Car has passed
    #45;
    X = 0;
    $display(" Car left at Time = %0t", $time);
    #55;

    // Repeat test again to observe second cycle
    #100;
    #45;
    X = 1;
    $display(" Car detected again at Time = %0t", $time);
    #55;
    #100;
    #45;
    X = 0;
    $display("Car left again at Time = %0t", $time);
    #55;

    $display(" Simulation completed.");
    $finish;
end


// Output Monitor

initial begin
    $monitor("⏱ Time=%0t | X=%b | HWY=%b | CNTRY=%b | STATE=%0d | DELAY=%0d", 
             $time, X, hwy, cntry, uut.state, uut.delay_counter);
end


// VCD Dump for GTKWave

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, test_tb);
end

endmodule