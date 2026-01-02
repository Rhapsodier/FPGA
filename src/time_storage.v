// ============================================================================
// 时间存储模块：存储6组时间，支持记录和翻阅
// ============================================================================
// 功能说明：
//   1. 存储6组时间，每组19位：分钟(6位) + 秒(6位) + 百分秒(7位)
//   2. 实时模式（browse_mode=0）：
//      - BUTR按键：记录当前时间到存储单元
//      - BUTU按键：进入翻阅模式
//   3. 翻阅模式（browse_mode=1）：
//      - BUTR按键：翻阅下一个存储时间（循环显示0-5组）
//      - BUTU按键：退出翻阅模式，返回实时模式
//   4. 翻阅模式下计时器自动暂停（通过browse_mode信号控制）
// ============================================================================
module time_storage (
    input wire clk,
    input wire rst_n,
    input wire record_btn,      // 记录按键（上升沿有效，BUTR）
    input wire browse_btn,      // 翻阅/退出按键（上升沿有效，BUTU）
    input wire [6:0] centisecond,
    input wire [5:0] second,
    input wire [5:0] minute,
    output reg [2:0] browse_index,  // 当前翻阅索引 0-5
    output reg [6:0] display_centisecond,
    output reg [5:0] display_second,
    output reg [5:0] display_minute,
    output reg browse_mode  // 1:浏览模式，0:实时模式
);

    // 存储6组时间，每组19位：分钟(6) + 秒(6) + 百分秒(7)
    reg [18:0] time_memory [5:0];
    reg [2:0] record_index;  // 记录索引
    
    integer i;
    
    // 边沿检测：检测record_btn和browse_btn的上升沿
    reg record_btn_dly, browse_btn_dly;
    wire record_btn_edge, browse_btn_edge;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            record_btn_dly <= 1'b0;
            browse_btn_dly <= 1'b0;
        end
        else begin
            record_btn_dly <= record_btn;
            browse_btn_dly <= browse_btn;
        end
    end
    
    // 检测上升沿：从0变到1
    assign record_btn_edge = record_btn & ~record_btn_dly;
    assign browse_btn_edge = browse_btn & ~browse_btn_dly;
    
    // 初始化存储单元
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 6; i = i + 1) begin
                time_memory[i] <= 19'd0;
            end
            record_index <= 3'd0;
            browse_index <= 3'd0;
            browse_mode <= 1'b0;
            display_centisecond <= 7'd0;
            display_second <= 6'd0;
            display_minute <= 6'd0;
        end
        else begin
            // 根据当前模式处理按键
            if (browse_mode) begin
                // 翻阅模式：
                // - BUTR（record_btn）：翻阅下一个存储时间
                // - BUTU（browse_btn）：退出翻阅模式，返回实时模式
                if (record_btn_edge) begin
                    // 翻阅下一个存储时间
                    browse_index <= (browse_index == 3'd5) ? 3'd0 : browse_index + 1'b1;
                end
                else if (browse_btn_edge) begin
                    // 退出翻阅模式
                    browse_mode <= 1'b0;
                end
            end
            else begin
                // 实时模式：
                // - BUTR（record_btn）：记录当前时间
                // - BUTU（browse_btn）：进入翻阅模式
                if (record_btn_edge) begin
                    // 记录当前时间
                    time_memory[record_index] <= {minute, second, centisecond};
                    record_index <= (record_index == 3'd5) ? 3'd0 : record_index + 1'b1;
                end
                else if (browse_btn_edge) begin
                    // 进入翻阅模式
                    browse_mode <= 1'b1;
                    browse_index <= 3'd0;  // 从第一个存储的时间开始显示
                end
            end
            
            // 显示数据选择：每个时钟周期更新
            if (browse_mode) begin
                // 显示存储的时间
                {display_minute, display_second, display_centisecond} <= time_memory[browse_index];
            end
            else begin
                // 显示实时时间
                display_minute <= minute;
                display_second <= second;
                display_centisecond <= centisecond;
            end
        end
    end

endmodule

