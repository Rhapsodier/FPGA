// ============================================================================
// 二进制转BCD码模块
// ============================================================================
// 功能：将二进制数转换为BCD码（十位和个位）
// 输入：二进制数（最多7位，最大99）
// 输出：十位和个位的BCD码（各4位）
// 实现：使用组合逻辑（除法/取模运算）
// ============================================================================
module bin_to_bcd (
    input wire [6:0] bin_in,
    output reg [3:0] bcd_tens,   // 十位BCD
    output reg [3:0] bcd_ones    // 个位BCD
);

    always @(*) begin
        if (bin_in < 10) begin
            bcd_tens = 4'd0;
            bcd_ones = bin_in[3:0];
        end
        else begin
            bcd_tens = bin_in / 10;
            bcd_ones = bin_in % 10;
        end
    end

endmodule

