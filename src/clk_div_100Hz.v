// ============================================================================
// 时钟分频模块：50MHz -> 100Hz
// ============================================================================
// 功能：将50MHz系统时钟分频为100Hz，用于百分秒计数
// 分频比：500000 (50MHz / 100Hz = 500000)
// 实现：计数器计数到249999时翻转输出时钟（二分频）
// 用途：每100Hz时钟周期计数一次，实现0.01秒精度
// ============================================================================
module clk_div_100Hz (
    input wire clk_50MHz,
    input wire rst_n,
    output reg clk_100Hz
);

    // 分频比：50MHz / 100Hz = 500000
    // 计数器需要计数到 500000/2 - 1 = 249999
    parameter DIV_CNT = 249999;
    
    reg [17:0] cnt;  // 需要18位计数器（2^18 = 262144 > 250000）
    
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 18'd0;
            clk_100Hz <= 1'b0;
        end
        else begin
            if (cnt == DIV_CNT) begin
                cnt <= 18'd0;
                clk_100Hz <= ~clk_100Hz;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule

