// ============================================================================
// 100进制计数器（百分秒计数）
// ============================================================================
// 功能：实现0-99的计数，用于百分秒计数
// 时钟：100Hz（每0.01秒计数一次）
// 输出：cnt_out[6:0]（0-99），carry_out（进位信号）
// 暂停：支持pause信号控制
// ============================================================================
module counter_100 (
    input wire clk,
    input wire rst_n,
    input wire pause,
    output reg [6:0] cnt_out,  // 0-99
    output reg carry_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_out <= 7'd0;
            carry_out <= 1'b0;
        end
        else if (!pause) begin
            if (cnt_out == 7'd99) begin
                cnt_out <= 7'd0;
                carry_out <= 1'b1;
            end
            else begin
                cnt_out <= cnt_out + 1'b1;
                carry_out <= 1'b0;
            end
        end
        else begin
            carry_out <= 1'b0;
        end
    end

endmodule

