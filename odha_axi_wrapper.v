`timescale 1ps / 1ps

module odha_axi_wrapper (
    // Synchrone AXI4-Stream Schnittstelle (Host-Seite)
    input  wire        aclk,
    input  wire        aresetn,
    
    // Slave Interface (Eingehende Daten vom XDP-DMA)
    input  wire [7:0]  s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    
    // Master Interface (Ausgehende Daten an die Validierungs-Stage)
    output wire [7:0]  m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,

    // Physische Sensordaten (Asynchron eingespeist)
    input  wire [31:0] sensor_delay_ps,
    input  wire [31:0] sensor_thermal_delta,
    input  wire [31:0] sensor_erf_value
);

    wire [7:0] core_data_out;
    wire       core_power_good;

    // Instanziierung des taktlosen ODHA-Cores
    odha_core_top obsidian_core (
        .data_in(s_axis_tdata),
        .simulated_delay_ps(sensor_delay_ps),
        .thermal_delta(sensor_thermal_delta),
        .erf_value(sensor_erf_value),
        .data_out(core_data_out),
        .power_good(core_power_good)
    );

    // Flow-Control: Der Core akzeptiert Daten, wenn der Empfaenger bereit ist
    assign s_axis_tready = m_axis_tready;

    // ZLDA-Durchgriff auf das AXI-Protokoll: 
    // Ist power_good = 0 (Amputation), wird tvalid auf 0 gezogen.
    // Das fehlerhafte Signal existiert auf dem Bus physisch nicht mehr.
    assign m_axis_tdata  = core_data_out;
    assign m_axis_tvalid = s_axis_tvalid & core_power_good;

endmodule
