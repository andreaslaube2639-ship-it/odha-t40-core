`timescale 1ps / 1ps

module odha_core_top (
    input  wire [7:0]  data_in,
    input  wire [31:0] simulated_delay_ps,
    input  wire [31:0] thermal_delta,
    input  wire [31:0] erf_value,
    
    output wire [7:0]  data_out,
    output wire        power_good,
    output wire        error_flag
);

    localparam [31:0] T_PATH_BUDGET     = 40;  
    localparam [31:0] T_STATIC_LOGIC    = 26;  
    localparam [31:0] MIN_THERMAL_DELTA = 60;  
    localparam [31:0] MIN_ERF           = 177; 

    wire [7:0] diffused_data;
    wire       constraints_valid;

    mds_diffusion mds_inst (
        .data_in(data_in),
        .data_out(diffused_data)
    );

    assign constraints_valid = ((T_STATIC_LOGIC + simulated_delay_ps) <= T_PATH_BUDGET) &&
                               (thermal_delta >= MIN_THERMAL_DELTA) &&
                               (erf_value >= MIN_ERF);

    assign data_out    = constraints_valid ? diffused_data : 8'h00;
    assign power_good  = constraints_valid;
    assign error_flag  = ~constraints_valid;

endmodule
