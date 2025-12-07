module encrypt (
  input  logic                clk             ,
  rst_n,
  input  logic                data_valid      ,
  output logic                data_ready      ,
  input  logic [127:0]        dataIn          ,
  input  logic [ 10:0][127:0] round_keys      , // 0..10 (0 = initial)  <-- FIXED
  input  logic                keys_valid      ,
  output logic [127:0]        dataOut         ,
  output logic                encryption_valid
);
  // ============================================================
  // S-BOX ROM (loaded from .mem file)
  // ============================================================
  // Replace the sbox RAM + readmemh with this constant table
  // logic [7:0] sbox[0:255];

  // initial $readmemh("sbox.mem", sbox);  // OK in hardware + sim!
  // function automatic [7:0] s_lookup(input logic [7:0] in);
  //   return sbox[in];
  // endfunction
  localparam logic [7:0] SBOX[0:255] = '{
    8'h63,
    8'h7c,
    8'h77,
    8'h7b,
    8'hf2,
    8'h6b,
    8'h6f,
    8'hc5,
    8'h30,
    8'h01,
    8'h67,
    8'h2b,
    8'hfe,
    8'hd7,
    8'hab,
    8'h76,
    8'hca,
    8'h82,
    8'hc9,
    8'h7d,
    8'hfa,
    8'h59,
    8'h47,
    8'hf0,
    8'had,
    8'hd4,
    8'ha2,
    8'haf,
    8'h9c,
    8'ha4,
    8'h72,
    8'hc0,
    8'hb7,
    8'hfd,
    8'h93,
    8'h26,
    8'h36,
    8'h3f,
    8'hf7,
    8'hcc,
    8'h34,
    8'ha5,
    8'he5,
    8'hf1,
    8'h71,
    8'hd8,
    8'h31,
    8'h15,
    8'h04,
    8'hc7,
    8'h23,
    8'hc3,
    8'h18,
    8'h96,
    8'h05,
    8'h9a,
    8'h07,
    8'h12,
    8'h80,
    8'he2,
    8'heb,
    8'h27,
    8'hb2,
    8'h75,
    8'h09,
    8'h83,
    8'h2c,
    8'h1a,
    8'h1b,
    8'h6e,
    8'h5a,
    8'ha0,
    8'h52,
    8'h3b,
    8'hd6,
    8'hb3,
    8'h29,
    8'he3,
    8'h2f,
    8'h84,
    8'h53,
    8'hd1,
    8'h00,
    8'hed,
    8'h20,
    8'hfc,
    8'hb1,
    8'h5b,
    8'h6a,
    8'hcb,
    8'hbe,
    8'h39,
    8'h4a,
    8'h4c,
    8'h58,
    8'hcf,
    8'hd0,
    8'hef,
    8'haa,
    8'hfb,
    8'h43,
    8'h4d,
    8'h33,
    8'h85,
    8'h45,
    8'hf9,
    8'h02,
    8'h7f,
    8'h50,
    8'h3c,
    8'h9f,
    8'ha8,
    8'h51,
    8'ha3,
    8'h40,
    8'h8f,
    8'h92,
    8'h9d,
    8'h38,
    8'hf5,
    8'hbc,
    8'hb6,
    8'hda,
    8'h21,
    8'h10,
    8'hff,
    8'hf3,
    8'hd2,
    8'hcd,
    8'h0c,
    8'h13,
    8'hec,
    8'h5f,
    8'h97,
    8'h44,
    8'h17,
    8'hc4,
    8'ha7,
    8'h7e,
    8'h3d,
    8'h64,
    8'h5d,
    8'h19,
    8'h73,
    8'h60,
    8'h81,
    8'h4f,
    8'hdc,
    8'h22,
    8'h2a,
    8'h90,
    8'h88,
    8'h46,
    8'hee,
    8'hb8,
    8'h14,
    8'hde,
    8'h5e,
    8'h0b,
    8'hdb,
    8'he0,
    8'h32,
    8'h3a,
    8'h0a,
    8'h49,
    8'h06,
    8'h24,
    8'h5c,
    8'hc2,
    8'hd3,
    8'hac,
    8'h62,
    8'h91,
    8'h95,
    8'he4,
    8'h79,
    8'he7,
    8'hc8,
    8'h37,
    8'h6d,
    8'h8d,
    8'hd5,
    8'h4e,
    8'ha9,
    8'h6c,
    8'h56,
    8'hf4,
    8'hea,
    8'h65,
    8'h7a,
    8'hae,
    8'h08,
    8'hba,
    8'h78,
    8'h25,
    8'h2e,
    8'h1c,
    8'ha6,
    8'hb4,
    8'hc6,
    8'he8,
    8'hdd,
    8'h74,
    8'h1f,
    8'h4b,
    8'hbd,
    8'h8b,
    8'h8a,
    8'h70,
    8'h3e,
    8'hb5,
    8'h66,
    8'h48,
    8'h03,
    8'hf6,
    8'h0e,
    8'h61,
    8'h35,
    8'h57,
    8'hb9,
    8'h86,
    8'hc1,
    8'h1d,
    8'h9e,
    8'he1,
    8'hf8,
    8'h98,
    8'h11,
    8'h69,
    8'hd9,
    8'h8e,
    8'h94,
    8'h9b,
    8'h1e,
    8'h87,
    8'he9,
    8'hce,
    8'h55,
    8'h28,
    8'hdf,
    8'h8c,
    8'ha1,
    8'h89,
    8'h0d,
    8'hbf,
    8'he6,
    8'h42,
    8'h68,
    8'h41,
    8'h99,
    8'h2d,
    8'h0f,
    8'hb0,
    8'h54,
    8'hbb,
    8'h16
  };


  // ============================================================
  // Pipeline registers
  // 31 stages total
  // ============================================================
  logic [127:0]        stage         [0:30]            ;
  wire  [127:0]        stage_00             = stage[0] ;
  wire  [127:0]        stage_01             = stage[1] ;
  wire  [127:0]        stage_02             = stage[2] ;
  wire  [127:0]        stage_03             = stage[3] ;
  wire  [127:0]        stage_04             = stage[4] ;
  wire  [127:0]        stage_05             = stage[5] ;
  wire  [127:0]        stage_06             = stage[6] ;
  wire  [127:0]        stage_07             = stage[7] ;
  wire  [127:0]        stage_08             = stage[8] ;
  wire  [127:0]        stage_09             = stage[9] ;
  wire  [127:0]        stage_10             = stage[10];
  wire  [127:0]        stage_11             = stage[11];
  wire  [127:0]        stage_12             = stage[12];
  wire  [127:0]        stage_13             = stage[13];
  wire  [127:0]        stage_14             = stage[14];
  wire  [127:0]        stage_15             = stage[15];
  wire  [127:0]        stage_16             = stage[16];
  wire  [127:0]        stage_17             = stage[17];
  wire  [127:0]        stage_18             = stage[18];
  wire  [127:0]        stage_19             = stage[19];
  wire  [127:0]        stage_20             = stage[20];
  wire  [127:0]        stage_21             = stage[21];
  wire  [127:0]        stage_22             = stage[22];
  wire  [127:0]        stage_23             = stage[23];
  wire  [127:0]        stage_24             = stage[24];
  wire  [127:0]        stage_25             = stage[25];
  wire  [127:0]        stage_26             = stage[26];
  wire  [127:0]        stage_27             = stage[27];
  wire  [127:0]        stage_28             = stage[28];
  wire  [127:0]        stage_29             = stage[29];
  wire  [127:0]        stage_30             = stage[30];
  logic                vld           [0:30]            ;
  logic [127:0]        data_reg                        ;
  logic [ 10:0][127:0] round_keys_reg                  ;
  logic                data_sv, keys_sv, vld0, vld1;
  assign vld0       = vld[0];
  assign vld1       = vld[1];
  assign data_ready = !data_sv;
  // ============================================================
  // Stage 0: Initial AddRoundKey
  // ============================================================
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      vld[30] <= 0;
      data_sv <= 0;
      keys_sv <= 0;
    end else begin
      if (data_valid) begin
        data_reg <= dataIn;
        data_sv  <= 1;
      end
      if (keys_valid) begin
        round_keys_reg <= round_keys;
        keys_sv        <= 1;
      end
      if (keys_sv && data_sv) begin
        vld[0]   <= 1;
        stage[0] <= data_reg ^ round_keys_reg[0];
        data_sv  <= 0;
      end else begin
        vld[0] <= 0;
      end
    end


  end
  logic [127:0] rk0 ;
  logic [127:0] rk1 ;
  logic [127:0] rk2 ;
  logic [127:0] rk3 ;
  logic [127:0] rk4 ;
  logic [127:0] rk5 ;
  logic [127:0] rk6 ;
  logic [127:0] rk7 ;
  logic [127:0] rk8 ;
  logic [127:0] rk9 ;
  logic [127:0] rk10;

  // Expanded pipeline stage signals
  logic [127:0] stage0 ;
  logic [127:0] stage1 ;
  logic [127:0] stage2 ;
  logic [127:0] stage3 ;
  logic [127:0] stage4 ;
  logic [127:0] stage5 ;
  logic [127:0] stage6 ;
  logic [127:0] stage7 ;
  logic [127:0] stage8 ;
  logic [127:0] stage9 ;
  logic [127:0] stage10;
  logic [127:0] stage11;
  logic [127:0] stage12;
  logic [127:0] stage13;
  logic [127:0] stage14;
  logic [127:0] stage15;
  logic [127:0] stage16;
  logic [127:0] stage17;
  logic [127:0] stage18;
  logic [127:0] stage19;
  logic [127:0] stage20;
  logic [127:0] stage21;
  logic [127:0] stage22;
  logic [127:0] stage23;
  logic [127:0] stage24;
  logic [127:0] stage25;
  logic [127:0] stage26;
  logic [127:0] stage27;
  logic [127:0] stage28;
  logic [127:0] stage29;
  logic [127:0] stage30;


  assign rk0  = round_keys[0];
  assign rk1  = round_keys[1];
  assign rk2  = round_keys[2];
  assign rk3  = round_keys[3];
  assign rk4  = round_keys[4];
  assign rk5  = round_keys[5];
  assign rk6  = round_keys[6];
  assign rk7  = round_keys[7];
  assign rk8  = round_keys[8];
  assign rk9  = round_keys[9];
  assign rk10 = round_keys[10];

  assign stage0  = stage[0];
  assign stage1  = stage[1];
  assign stage2  = stage[2];
  assign stage3  = stage[3];
  assign stage4  = stage[4];
  assign stage5  = stage[5];
  assign stage6  = stage[6];
  assign stage7  = stage[7];
  assign stage8  = stage[8];
  assign stage9  = stage[9];
  assign stage10 = stage[10];
  assign stage11 = stage[11];
  assign stage12 = stage[12];
  assign stage13 = stage[13];
  assign stage14 = stage[14];
  assign stage15 = stage[15];
  assign stage16 = stage[16];
  assign stage17 = stage[17];
  assign stage18 = stage[18];
  assign stage19 = stage[19];
  assign stage20 = stage[20];
  assign stage21 = stage[21];
  assign stage22 = stage[22];
  assign stage23 = stage[23];
  assign stage24 = stage[24];
  assign stage25 = stage[25];
  assign stage26 = stage[26];
  assign stage27 = stage[27];
  assign stage28 = stage[28];
  assign stage29 = stage[29];
  assign stage30 = stage[30];

  // ============================================================
  // AES FUNCTIONS
  // ============================================================

  // ---------------- SubBytes ----------------
  function automatic [127:0] sub_bytes(input [127:0] in);
    logic [7:0] b[0:15];
    // unpack MSB-first: b[0] = in[127:120], b[15] = in[7:0]
    for (int i = 0; i < 16; i++) b[i] = in[(15-i)*8+:8];

    for (int i = 0; i < 16; i++) b[i] = SBOX[b[i]];

    // pack back MSB-first
    for (int i = 0; i < 16; i++) sub_bytes[(15-i)*8+:8] = b[i];
  endfunction


  // ---------------- ShiftRows ----------------
  function automatic [127:0] shift_rows(input [127:0] in);
    logic [7:0] b[0:15];

    // unpack in natural MSB→LSB order into AES column-major state
    for (int i = 0; i < 16; i++) b[i] = in[i*8+:8];

    // ShiftRows permutation
    return {
      b[15],
      b[10],
      b[5],
      b[0],  // column 0
      b[11],
      b[6],
      b[1],
      b[12],  // column 1
      b[7],
      b[2],
      b[13],
      b[8],  // column 2
      b[3],
      b[14],
      b[9],
      b[4]  // column 3
    };
  endfunction


  // ---------------- MixColumns helpers ----------------
  function automatic [7:0] xtime(input [7:0] x);
    xtime = {x[6:0], 1'b0} ^ (8'h1b & {8{x[7]}});
  endfunction

  function automatic [127:0] mix_columns(input [127:0] in);
    // 1. Unpack input state into row-major bytes (i=0 is MSB [127:120])
    logic [7:0] b[0:15];
    logic [7:0] out_bytes[0:15];
    logic [127:0] result;


    for (int i = 0; i < 16; i++) begin
      b[i] = in[(15-i)*8+:8];
    end

    for (int c = 0; c < 4; c++) begin
      logic [7:0] a0 = b[4*c+0];  // Col c, row 0
      logic [7:0] a1 = b[4*c+1];  // Col c, row 1
      logic [7:0] a2 = b[4*c+2];  // Col c, row 2
      logic [7:0] a3 = b[4*c+3];  // Col c, row 3

      // Standard MixColumns matrix multiplication formulas
      out_bytes[4*c+0] = xtime(a0) ^ (xtime(a1) ^ a1) ^ a2 ^ a3;
      out_bytes[4*c+1] = a0 ^ xtime(a1) ^ (xtime(a2) ^ a2) ^ a3;
      out_bytes[4*c+2] = a0 ^ a1 ^ xtime(a2) ^ (xtime(a3) ^ a3);
      out_bytes[4*c+3] = (xtime(a0) ^ a0) ^ a1 ^ a2 ^ xtime(a3);
    end

    // 2. Pack results back into [127:0] (CRITICAL FIX)
    // Ensures out_bytes[0] maps to result[127:120] (MSB)
    for (int i = 0; i < 16; i++) begin
      result[(15-i)*8+:8] = out_bytes[i];
    end
    return result;
  endfunction

  // ========================================================
  // ROUND 1
  // ========================================================

  // Stage A: SubBytes
  always_ff @(posedge clk) begin
    vld[1] <= vld[0];
    if (vld[0]) begin
      stage[1] <= sub_bytes(stage[0]);
    end
  end

  // Stage B: ShiftRows
  always_ff @(posedge clk) begin
    vld[2] <= vld[1];
    if (vld[1]) begin
      stage[2] <= shift_rows(stage[1]);
    end
  end

  // Stage C: MixColumns + AddRoundKey
  always_ff @(posedge clk) begin
    vld[3] <= vld[2];
    if (vld[2]) begin
      stage[3] <= mix_columns(stage[2]) ^ round_keys_reg[1];
    end
  end

  // ========================================================
  // ROUND 2
  // ========================================================
  always_ff @(posedge clk) begin
    vld[4] <= vld[3];
    if (vld[3]) stage[4] <= sub_bytes(stage[3]);
  end

  always_ff @(posedge clk) begin
    vld[5] <= vld[4];
    if (vld[4]) stage[5] <= shift_rows(stage[4]);
  end

  always_ff @(posedge clk) begin
    vld[6] <= vld[5];
    if (vld[5]) stage[6] <= mix_columns(stage[5]) ^ round_keys_reg[2];
  end

  // ========================================================
  // ROUND 3
  // ========================================================
  always_ff @(posedge clk) begin
    vld[7] <= vld[6];
    if (vld[6]) stage[7] <= sub_bytes(stage[6]);
  end

  always_ff @(posedge clk) begin
    vld[8] <= vld[7];
    if (vld[7]) stage[8] <= shift_rows(stage[7]);
  end

  always_ff @(posedge clk) begin
    vld[9] <= vld[8];
    if (vld[8]) stage[9] <= mix_columns(stage[8]) ^ round_keys_reg[3];
  end

  // ========================================================
  // ROUND 4
  // ========================================================
  always_ff @(posedge clk) begin
    vld[10] <= vld[9];
    if (vld[9]) stage[10] <= sub_bytes(stage[9]);
  end

  always_ff @(posedge clk) begin
    vld[11] <= vld[10];
    if (vld[10]) stage[11] <= shift_rows(stage[10]);
  end

  always_ff @(posedge clk) begin
    vld[12] <= vld[11];
    if (vld[11]) stage[12] <= mix_columns(stage[11]) ^ round_keys_reg[4];
  end

  // ========================================================
  // ROUND 5
  // ========================================================
  always_ff @(posedge clk) begin
    vld[13] <= vld[12];
    if (vld[12]) stage[13] <= sub_bytes(stage[12]);
  end

  always_ff @(posedge clk) begin
    vld[14] <= vld[13];
    if (vld[13]) stage[14] <= shift_rows(stage[13]);
  end

  always_ff @(posedge clk) begin
    vld[15] <= vld[14];
    if (vld[14]) stage[15] <= mix_columns(stage[14]) ^ round_keys_reg[5];
  end

  // ========================================================
  // ROUND 6
  // ========================================================
  always_ff @(posedge clk) begin
    vld[16] <= vld[15];
    if (vld[15]) stage[16] <= sub_bytes(stage[15]);
  end

  always_ff @(posedge clk) begin
    vld[17] <= vld[16];
    if (vld[16]) stage[17] <= shift_rows(stage[16]);
  end

  always_ff @(posedge clk) begin
    vld[18] <= vld[17];
    if (vld[17]) stage[18] <= mix_columns(stage[17]) ^ round_keys_reg[6];
  end

  // ========================================================
  // ROUND 7
  // ========================================================
  always_ff @(posedge clk) begin
    vld[19] <= vld[18];
    if (vld[18]) stage[19] <= sub_bytes(stage[18]);
  end

  always_ff @(posedge clk) begin
    vld[20] <= vld[19];
    if (vld[19]) stage[20] <= shift_rows(stage[19]);
  end

  always_ff @(posedge clk) begin
    vld[21] <= vld[20];
    if (vld[20]) stage[21] <= mix_columns(stage[20]) ^ round_keys_reg[7];
  end

  // ========================================================
  // ROUND 8
  // ========================================================
  always_ff @(posedge clk) begin
    vld[22] <= vld[21];
    if (vld[21]) stage[22] <= sub_bytes(stage[21]);
  end

  always_ff @(posedge clk) begin
    vld[23] <= vld[22];
    if (vld[22]) stage[23] <= shift_rows(stage[22]);
  end

  always_ff @(posedge clk) begin
    vld[24] <= vld[23];
    if (vld[23]) stage[24] <= mix_columns(stage[23]) ^ round_keys_reg[8];
  end

  // ========================================================
  // ROUND 9
  // ========================================================
  always_ff @(posedge clk) begin
    vld[25] <= vld[24];
    if (vld[24]) stage[25] <= sub_bytes(stage[24]);
  end

  always_ff @(posedge clk) begin
    vld[26] <= vld[25];
    if (vld[25]) stage[26] <= shift_rows(stage[25]);
  end

  always_ff @(posedge clk) begin
    vld[27] <= vld[26];
    if (vld[26]) stage[27] <= mix_columns(stage[26]) ^ round_keys_reg[9];
  end

  always_ff @(posedge clk) begin
    vld[28] <= vld[27];
    if (vld[27]) begin
      stage[28] <= sub_bytes(stage[27]);
    end
  end
  always_ff @(posedge clk) begin
    vld[29] <= vld[28];
    if (vld[28]) begin
      stage[29] <= shift_rows(stage[28]);
    end
  end
  always_ff @(posedge clk) begin
    vld[30] <= vld[29];
    if (vld[29]) begin
      stage[30] <= (stage[29]) ^ round_keys_reg[10];
    end
  end


  // ============================================================
  // Final Output
  // ============================================================
  assign dataOut          = stage[30];  // 0..30 = 31 pipeline stages
  assign encryption_valid = vld[30];

endmodule
