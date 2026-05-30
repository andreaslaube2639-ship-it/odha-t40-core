`timescale 1ps / 1ps

module odha_core_tb;

    reg [7:0]  data_in;
    reg [31:0] simulated_delay_ps;
    reg [31:0] thermal_delta;
    reg [31:0] erf_value;

    wire [7:0] data_out;
    wire       power_good;

    odha_core_top uut (
        .data_in(data_in),
        .simulated_delay_ps(simulated_delay_ps),
        .thermal_delta(thermal_delta),
        .erf_value(erf_value),
        .data_out(data_out),
        .power_good(power_good)
    );

    integer test_id;

    initial begin
        $display("--- Start RTL-Verification fuer ODHA-T40 ---");
        
        // TEST 1: In-Budget (L=200um)
        test_id = 1;
        data_in = 8'hA5;
        simulated_delay_ps = 10;
        thermal_delta = 65;
        erf_value = 180;
        #50;
        if (power_good === 1'b1 && data_out === 8'h22)
            $display("[PASS] Test %0d: Deterministischer Abschluss. Output: 0x%h, SNR = Inf", test_id, data_out);
        else
            $display("[FAIL] Test %0d: Defekt im Pfad.", test_id);

        // TEST 2: Timing-Violation (L=800um -> ZLDA)
        test_id = 2;
        data_in = 8'hA5;
        simulated_delay_ps = 25;
        thermal_delta = 65;
        erf_value = 180;
        #50;
        if (power_good === 1'b0 && data_out === 8'bzzzzzzzz)
            $display("[PASS] Test %0d: ZLDA aktiv. Signal erfolgreich amputiert.", test_id);
        else
            $display("[FAIL] Test %0d: Amputation blockiert.", test_id);

        // TEST 3: ERF-Sweep Abbruchkante
        test_id = 3;
        simulated_delay_ps = 10;
        thermal_delta = 65;
        
        erf_value = 176;
        #50;
        $display("[SWEEP] Evaluiere ERF = 1.76 -> Power_Good = %b (Erwartet: 0)", power_good);

        erf_value = 177;
        #50;
        $display("[SWEEP] Evaluiere ERF = 1.77 -> Power_Good = %b (Erwartet: 1), Output = 0x%h", power_good, data_out);

        $display("--- RTL-Verification abgeschlossen ---");
        $finish;
    end

endmodule
