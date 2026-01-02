// ============================================================================
// 60进制计数器（秒和分计数）
// ============================================================================
// 功能：实现0-59的计数，用于秒和分计数
// 时钟：100Hz（与百分秒计数器同步）
// 输出：cnt_out[5:0]（0-59），carry_out（进位信号）
// 使能：通过enable信号控制，只有收到进位信号时才计数
// 暂停：支持pause信号控制
// ============================================================================
module counter_60 (
    input wire clk,
    input wire rst_n,
    input wire pause,
    input wire enable,  // 进位使能
    output reg [5:0] cnt_out,  // 0-59
    output reg carry_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_out <= 6'd0;
            carry_out <= 1'b0;
        end
        else if (!pause && enable) begin
            if (cnt_out == 6'd59) begin
                cnt_out <= 6'd0;
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

