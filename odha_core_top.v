`timescale 1ps / 1ps

module odha_core_top (
    input  wire [7:0] data_in,
    input  wire [31:0] simulated_delay_ps,
    input  wire [31:0] thermal_delta,
    input  wire [31:0] erf_value,
    output wire [7:0] data_out,
    output wire        power_good
);

    // Hardgecodete normative Constraints (Spezifikation v0.1)
    localparam [31:0] T_PATH_BUDGET     = 40;  // 40.0 ps
    localparam [31:0] T_STATIC_LOGIC    = 26;  // 26.0 ps
    localparam [31:0] MIN_THERMAL_DELTA = 60;  // Stabilitätsgrenze
    localparam [31:0] MIN_ERF           = 177; // 1.77 skaliert (ERF * 100)

    wire [7:0] diffused_data;
    wire        constraints_valid;

    mds_diffusion mds_inst (
        .data_in(data_in),
        .data_out(diffused_data)
    );

    // Asynchroner Invarianten-Prüfblock (Reine Kombinatorik)
    assign constraints_valid = ((T_STATIC_LOGIC + simulated_delay_ps) <= T_PATH_BUDGET) &&
                               (thermal_delta >= MIN_THERMAL_DELTA) &&
                               (erf_value >= MIN_ERF);

    // ZLDA-Verhalten: Tristate-Amputation bei Invariantenbruch
    assign data_out = constraints_valid ? diffused_data : 8'bzzzzzzzz;
    assign power_good = constraints_valid;

endmodule
