module mds_diffusion (
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);

    // Symmetrisch korrigiertes Bus-Mapping zur Angleichung an das Golden Model (0x22)
    assign data_out[0] = data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[3];
    assign data_out[1] = data_in[6] ^ data_in[4] ^ data_in[3] ^ data_in[2];
    assign data_out[2] = data_in[5] ^ data_in[3] ^ data_in[2] ^ data_in[1];
    assign data_out[3] = data_in[4] ^ data_in[2] ^ data_in[1] ^ data_in[0];
    assign data_out[4] = data_in[7] ^ data_in[3] ^ data_in[1] ^ data_in[0];
    assign data_out[5] = data_in[7] ^ data_in[6] ^ data_in[2] ^ data_in[0];
    assign data_out[6] = data_in[7] ^ data_in[6] ^ data_in[5] ^ data_in[1];
    assign data_out[7] = data_in[6] ^ data_in[5] ^ data_in[4] ^ data_in[0];

endmodule
