module AES (
    input  logic         clk,
    input  logic         rst_n,            // active-low reset
    input  logic         key_valid,        // pulse to load new key
    input  logic [127:0] key_in,           // 128-bit AES key
    input  logic         data_valid,
    output logic         data_ready,
    input  logic [127:0] dataIn,
    output logic [127:0] dataOut,
    output logic         encryption_valid
);
  logic keys_valid, expander_busy;
  logic [10:0][127:0] round_keys;
  encrypt encrypt (
      .clk(clk),
      .rst_n(rst_n),
      .data_valid(data_valid),
      .data_ready(data_ready),
      .round_keys(round_keys),
      .encryption_valid(encryption_valid),
      .dataIn(dataIn),
      .dataOut(dataOut),
      .keys_valid(keys_valid)
  );
  key_expand key_expand (
      .rst_n(rst_n),
      .clk(clk),
      .key_valid(key_valid),
      .key_in(key_in),
      .round_keys(round_keys),
      .keys_valid(keys_valid),
      .busy(expander_busy)

  );
  initial begin
    $dumpfile("");
    $dumpvars(0, AES);

  end
endmodule
