// ============================================================================
// 时钟分频模块：50MHz -> 10KHz
// ============================================================================
// 功能：将50MHz系统时钟分频为10KHz，用于数码管动态扫描
// 分频比：5000 (50MHz / 10KHz = 5000)
// 实现：计数器计数到2499时翻转输出时钟（二分频）
// 用途：每个时钟周期切换一个数码管，实现动态扫描显示
// ============================================================================
module clk_div_10KHz (
    input wire clk_50MHz,
    input wire rst_n,
    output reg clk_10KHz
);

    // 分频比：50MHz / 10KHz = 5000
    // 计数器需要计数到 5000/2 - 1 = 2499
    parameter DIV_CNT = 2499;
    
    reg [11:0] cnt;  // 需要12位计数器（2^12 = 4096 > 2500）
    
    always @(posedge clk_50MHz or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 12'd0;
            clk_10KHz <= 1'b0;
        end
        else begin
            if (cnt == DIV_CNT) begin
                cnt <= 12'd0;
                clk_10KHz <= ~clk_10KHz;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule

