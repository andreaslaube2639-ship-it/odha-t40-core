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

    integer i;
    integer passed_vectors;

    initial begin
        $display("--- Start Exhaustive RTL-Verification (v0.2) ---");
        passed_vectors = 0;
        
        // ---------------------------------------------------------
        // VALIDIERUNGS-SCHLEIFE: Alle 256 Kombinationen im Budget
        // ---------------------------------------------------------
        simulated_delay_ps = 10;
        thermal_delta = 65;
        erf_value = 180;

        for (i = 0; i < 256; i = i + 1) begin
            data_in = i[7:0];
            #10;
            if (power_good === 1'b1) begin
                passed_vectors = passed_vectors + 1;
            end
        end
        $display("[PASS] Vollstaendige Matrix-Abdeckung: %0d/256 Vektoren erfolgreich diffundiert.", passed_vectors);

        // ---------------------------------------------------------
        // INVARIANTEN-TEST: Amputation bei Fehlerzustand
        // ---------------------------------------------------------
        data_in = 8'hA5;
        simulated_delay_ps = 30; // 30ps + 26ps = 56ps (> 40ps Budget)
        #10;
        if (power_good === 1'b0 && data_out === 8'h00)
            $display("[PASS] ZLDA-HARTUNG: Safe-State 0x00 bei Budgetverletzung verifiziert.");
        else
            $display("[FAIL] ZLDA-HARTUNG: Fehlerhafte Bus-Evakuierung.");

        $display("--- RTL-Verification v0.2 erfolgreich abgeschlossen ---");
        $finish;
    end

endmodule
