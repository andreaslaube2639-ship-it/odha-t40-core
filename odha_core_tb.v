`timescale 1ps / 1ps

module odha_core_tb;

    reg [7:0]  data_in;
    reg [31:0] simulated_delay_ps;
    reg [31:0] thermal_delta;
    reg [31:0] erf_value;

    wire [7:0] data_out;
    wire       power_good;
    wire       error_flag;

    odha_core_top uut (
        .data_in(data_in),
        .simulated_delay_ps(simulated_delay_ps),
        .thermal_delta(thermal_delta),
        .erf_value(erf_value),
        .data_out(data_out),
        .power_good(power_good),
        .error_flag(error_flag)
    );

    initial begin
        $display("--- Start RTL-Verification v0.3 (Error-Flag Validation) ---");

        // Test: Amputation bei Invariantenbruch
        data_in = 8'hA5;
        simulated_delay_ps = 30; // 30+26 = 56 > 40
        thermal_delta = 65;
        erf_value = 180;
        #10;

        if (error_flag === 1'b1 && data_out === 8'h00 && power_good === 1'b0)
            $display("[PASS] ZLDA-HARTUNG: Korrekte Amputation mit Error-Flag.");
        else
            $display("[FAIL] ZLDA-HARTUNG: Inkonsistenter Fehlerzustand.");

        $display("--- RTL-Verification v0.3 erfolgreich abgeschlossen ---");
        $finish;
    end
endmodule
