module key_expand (
    input  logic                clk,
    input  logic                rst_n,       // active-low reset
    input  logic                key_valid,   // pulse to load new key
    input  logic [127:0]        key_in,      // 128-bit AES key
    output logic [ 10:0][127:0] round_keys,  // K0..K10 (packed)
    output logic                keys_valid,  // asserted 1 cycle when round_keys ready
    output logic                busy         // high while expansion is running
);
  // ------------------------------------------------------------
  // S-box ROM (byte -> byte)
  // ------------------------------------------------------------
  logic [7:0] sbox[0:255];
  initial $readmemh("sbox.mem", sbox);

  // outputs registers
  logic [10:0][127:0] round_keys_reg;
  assign round_keys = round_keys_reg;

  // =============================
  // FLAT WIRES FOR ROUND KEYS
  // =============================
  // flat round-key wires
  wire [127:0] rk0  = {w0,  w1,  w2,  w3};
  wire [127:0] rk1  = {w4,  w5,  w6,  w7};
  wire [127:0] rk2  = {w8,  w9,  w10, w11};
  wire [127:0] rk3  = {w12, w13, w14, w15};
  wire [127:0] rk4  = {w16, w17, w18, w19};
  wire [127:0] rk5  = {w20, w21, w22, w23};
  wire [127:0] rk6  = {w24, w25, w26, w27};
  wire [127:0] rk7  = {w28, w29, w30, w31};
  wire [127:0] rk8  = {w32, w33, w34, w35};
  wire [127:0] rk9  = {w36, w37, w38, w39};
  wire [127:0] rk10 = {w40, w41, w42, w43};
  // =============================
  // FLAT DEBUG WIRES FOR w[i]
  // =============================
  wire [31:0] w0  = w[0];
  wire [31:0] w1  = w[1];
  wire [31:0] w2  = w[2];
  wire [31:0] w3  = w[3];

  wire [31:0] w4  = w[4];
  wire [31:0] w5  = w[5];
  wire [31:0] w6  = w[6];
  wire [31:0] w7  = w[7];

  wire [31:0] w8  = w[8];
  wire [31:0] w9  = w[9];
  wire [31:0] w10 = w[10];
  wire [31:0] w11 = w[11];

  wire [31:0] w12 = w[12];
  wire [31:0] w13 = w[13];
  wire [31:0] w14 = w[14];
  wire [31:0] w15 = w[15];

  wire [31:0] w16 = w[16];
  wire [31:0] w17 = w[17];
  wire [31:0] w18 = w[18];
  wire [31:0] w19 = w[19];

  wire [31:0] w20 = w[20];
  wire [31:0] w21 = w[21];
  wire [31:0] w22 = w[22];
  wire [31:0] w23 = w[23];

  wire [31:0] w24 = w[24];
  wire [31:0] w25 = w[25];
  wire [31:0] w26 = w[26];
  wire [31:0] w27 = w[27];

  wire [31:0] w28 = w[28];
  wire [31:0] w29 = w[29];
  wire [31:0] w30 = w[30];
  wire [31:0] w31 = w[31];

  wire [31:0] w32 = w[32];
  wire [31:0] w33 = w[33];
  wire [31:0] w34 = w[34];
  wire [31:0] w35 = w[35];

  wire [31:0] w36 = w[36];
  wire [31:0] w37 = w[37];
  wire [31:0] w38 = w[38];
  wire [31:0] w39 = w[39];

  wire [31:0] w40 = w[40];
  wire [31:0] w41 = w[41];
  wire [31:0] w42 = w[42];
  wire [31:0] w43 = w[43];



  //internal words
  logic [31:0] w   [0:43];
  logic over;

  integer idx;



  // ------------------------------------------------------------
  // Rcon table (AES-128 needs 10 rcon values)
  // ------------------------------------------------------------
  logic [ 7:0] Rcon[1:10];
  initial begin
    Rcon[1]  = 8'h01;
    Rcon[2]  = 8'h02;
    Rcon[3]  = 8'h04;
    Rcon[4]  = 8'h08;
    Rcon[5]  = 8'h10;
    Rcon[6]  = 8'h20;
    Rcon[7]  = 8'h40;
    Rcon[8]  = 8'h80;
    Rcon[9]  = 8'h1b;
    Rcon[10] = 8'h36;
  end

  // ------------------------------------------------------------
  // Helper functions: RotWord and SubWord
  // ------------------------------------------------------------

  function automatic [31:0] RotWord(input logic [31:0] inw);
    RotWord = {inw[23:0], inw[31:24]};  // left rotate by 8 bits
  endfunction

  function automatic [31:0] SubWord(input logic [31:0] inw);
    SubWord = {sbox[inw[31:24]], sbox[inw[23:16]], sbox[inw[15:8]], sbox[inw[7:0]]};
  endfunction

  always_ff @(posedge clk) begin
    keys_valid <= 1'b0;
    if (!rst_n) begin
      idx        <= 0;
      over       <= 1'b0;
      keys_valid <= 1'b0;
      busy       <= 1'b0;
      for (int r = 0; r < 45; r++) w[r] <= '0;

    end else begin
      if (busy) begin
        if (over) begin
          round_keys_reg[0] <= {w[0], w[1], w[2], w[3]};
          round_keys_reg[1] <= {w[4], w[5], w[6], w[7]};
          round_keys_reg[2] <= {w[8], w[9], w[10], w[11]};
          round_keys_reg[3] <= {w[12], w[13], w[14], w[15]};
          round_keys_reg[4] <= {w[16], w[17], w[18], w[19]};
          round_keys_reg[5] <= {w[20], w[21], w[22], w[23]};
          round_keys_reg[6] <= {w[24], w[25], w[26], w[27]};
          round_keys_reg[7] <= {w[28], w[29], w[30], w[31]};
          round_keys_reg[8] <= {w[32], w[33], w[34], w[35]};
          round_keys_reg[9] <= {w[36], w[37], w[38], w[39]};
          round_keys_reg[10] <= {w[40], w[41], w[42], w[43]};
          over <= 0;
          busy <= 0;
          keys_valid <= 1;
          idx <= 0;

        end else begin
          if (|idx[1:0]) begin
            w[idx] <= w[idx-1] ^ w[idx-4];
            if (idx == 43) begin
              over <= 1;
            end
          end else begin
            w[idx] <= w[idx-4] ^ (SubWord(RotWord(w[idx-1]))) ^ {Rcon[idx>>2], 24'h00};
          end
          idx <= idx + 1;
        end
      end else begin
        if (key_valid & !busy) begin
          // load initial key words (w0..w3)
          w[0] <= key_in[127:96];
          w[1] <= key_in[95:64];
          w[2] <= key_in[63:32];
          w[3] <= key_in[31:0];
          idx  <= 4;
          busy <= 1;
        end
      end
    end


  end
endmodule
