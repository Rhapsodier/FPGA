// ============================================================================
// 顶层模块：数字码表
// ============================================================================
// 功能说明：
//   1. 计时功能：百分秒（0-99）、秒（0-59）、分（0-59）计数
//   2. 控制功能：复位、暂停
//   3. 存储功能：支持存储6组时间，按键记录和翻阅
//   4. 显示功能：7段数码管动态扫描显示，格式为MMSS:MS
//   5. LED指示：按键状态LED指示和边沿脉冲测试LED
//
// 开发板：ETL3-7A35T XILINX ARTIX-7 FPGA
// 器件型号：xc7a35t
// 工具版本：Vivado 2018.3
// ============================================================================
module top_stopwatch (
    // 系统时钟和复位
    input wire clk,              // 50MHz系统时钟
    input wire CLR,              // 复位信号（高电平有效）
    
    // 控制信号
    input wire PAUSE,            // 暂停信号（低电平有效，按下时暂停）
    input wire record_btn_raw,   // 记录按键（原始输入）
    input wire browse_btn_raw,   // 翻阅按键（原始输入）
    
    // 数码管输出
    output wire [15:0] DATA,      // DATA[7:0]显示值，DATA[15:8]选择信号（8位，实际使用6位）
    
    // LED测试输出（用于测试按键是否正常工作）
    output wire [1:0] LED_TEST,   // LED_TEST[0]: record_btn脉冲, LED_TEST[1]: browse_btn脉冲
    
    // LED按键指示输出
    output wire LED15,            // BTNC按键指示（CLR）
    output wire LED14,            // BTNL按键指示（PAUSE）
    output wire LED13,            // BTNR按键指示（record_btn_raw）
    output wire LED12             // BTNU按键指示（browse_btn_raw）
);

    // 内部信号
    wire rst_n;
    wire clk_100Hz;
    wire clk_10KHz;
    wire record_btn;
    wire browse_btn;
    
    wire [6:0] centisecond;
    wire [5:0] second;
    wire [5:0] minute;
    
    wire [6:0] display_centisecond;
    wire [5:0] display_second;
    wire [5:0] display_minute;
    
    wire browse_mode;  // 翻阅模式信号，用于控制计时器暂停
    
    wire [7:0] seg_data;
    wire [7:0] seg_sel;  // 8位位选（实际使用6位，显示格式：MMSS:MS）
    
    // ========================================================================
    // 复位信号转换
    // ========================================================================
    // 按键为低电平有效（按下时为0，未按下时为1）
    // CLR按下时(0) -> rst_n=0 -> 复位
    // CLR未按下时(1) -> rst_n=1 -> 正常工作
    assign rst_n = CLR;
    
    // ========================================================================
    // 时钟分频模块
    // ========================================================================
    // 100Hz时钟：用于百分秒计数，每100Hz时钟周期计数一次，实现0.01秒精度
    clk_div_100Hz u_clk_div_100Hz (
        .clk_50MHz(clk),
        .rst_n(rst_n),
        .clk_100Hz(clk_100Hz)
    );
    
    // 10KHz时钟：用于数码管动态扫描，每个时钟周期切换一个数码管
    clk_div_10KHz u_clk_div_10KHz (
        .clk_50MHz(clk),
        .rst_n(rst_n),
        .clk_10KHz(clk_10KHz)
    );
    
    // ========================================================================
    // 按键边沿检测模块
    // ========================================================================
    // 功能：检测按键下降沿（按下），输出单时钟周期脉冲信号
    // 按键低电平有效：未按下时为1，按下时为0
    reg record_btn_raw_dly, browse_btn_raw_dly;
    wire record_btn_edge, browse_btn_edge;
    
    // 延迟寄存器：用于边沿检测
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            record_btn_raw_dly <= 1'b1;  // 初始化为1（按键未按下）
            browse_btn_raw_dly <= 1'b1;  // 初始化为1（按键未按下）
        end
        else begin
            record_btn_raw_dly <= record_btn_raw;
            browse_btn_raw_dly <= browse_btn_raw;
        end
    end
    
    // 检测下降沿：从1变到0（按键按下）
    // 输出单时钟周期脉冲信号
    assign record_btn_edge = ~record_btn_raw & record_btn_raw_dly;
    assign browse_btn_edge = ~browse_btn_raw & browse_btn_raw_dly;
    
    // 将边沿信号传递给time_storage模块
    assign record_btn = record_btn_edge;
    assign browse_btn = browse_btn_edge;
    
    // ========================================================================
    // 计数控制模块
    // ========================================================================
    // 功能：整合百分秒、秒、分计数器，形成完整的计时链
    // 暂停条件：PAUSE按键按下（低电平有效） 或 处于翻阅模式
    // PAUSE是低电平有效，按下时(0)暂停，需要取反
    counter_control u_counter_control (
        .clk_100Hz(clk_100Hz),
        .rst_n(rst_n),
        .pause(~PAUSE | browse_mode),  // 暂停条件：PAUSE按键按下 或 处于翻阅模式
        .centisecond(centisecond),      // 百分秒输出（0-99）
        .second(second),                // 秒输出（0-59）
        .minute(minute)                 // 分输出（0-59）
    );
    
    // ========================================================================
    // 时间存储模块
    // ========================================================================
    // 功能：
    //   1. 存储6组时间（每组19位：分钟6位+秒6位+百分秒7位）
    //   2. 实时模式：BUTR记录时间，BUTU进入翻阅模式
    //   3. 翻阅模式：BUTR翻阅下一个存储时间，BUTU退出翻阅模式
    //   4. 翻阅模式下计时器自动暂停
    time_storage u_time_storage (
        .clk(clk),
        .rst_n(rst_n),
        .record_btn(record_btn),        // 记录按键脉冲（BUTR）
        .browse_btn(browse_btn),        // 翻阅/退出按键脉冲（BUTU）
        .centisecond(centisecond),       // 当前百分秒值
        .second(second),                 // 当前秒值
        .minute(minute),                 // 当前分值
        .browse_index(),                 // 内部信号，不需要输出
        .display_centisecond(display_centisecond),  // 显示用百分秒值
        .display_second(display_second),           // 显示用秒值
        .display_minute(display_minute),           // 显示用分值
        .browse_mode(browse_mode)        // 翻阅模式状态，用于控制计时器暂停
    );
    
    // ========================================================================
    // 数码管驱动模块
    // ========================================================================
    // 功能：
    //   1. 二进制转BCD码转换
    //   2. BCD码转7段显示码
    //   3. 动态扫描控制（6个数码管，10KHz扫描频率）
    // 显示格式：MMSS:MS（分分秒秒:毫秒）
    seg7_driver u_seg7_driver (
        .clk_10KHz(clk_10KHz),          // 扫描时钟（10KHz）
        .rst_n(rst_n),
        .minute(display_minute),        // 显示用分值（0-59）
        .second(display_second),        // 显示用秒值（0-59）
        .centisecond(display_centisecond),  // 显示用百分秒值（0-99）
        .seg_data(seg_data),            // 7段显示数据输出
        .seg_sel(seg_sel)               // 数码管位选信号输出
    );
    
    // ========================================================================
    // 输出信号组合
    // ========================================================================
    // DATA[7:0]: 7段显示数据（8位，最高位为小数点，本设计未使用）
    // DATA[15:8]: 数码管选择信号（8位，实际使用6位，显示格式：MMSS:MS）
    assign DATA = {seg_sel, seg_data};
    
    // ========================================================================
    // LED测试输出：显示边沿检测后的脉冲
    // ========================================================================
    // LED_TEST[0]: record_btn脉冲（边沿检测后），连接到LED2（引脚AA20）
    // LED_TEST[1]: browse_btn脉冲（边沿检测后），连接到LED3（引脚AB18）
    assign LED_TEST[0] = record_btn;   // LED2显示record_btn脉冲
    assign LED_TEST[1] = browse_btn;    // LED3显示browse_btn脉冲
    
    // ========================================================================
    // LED按键指示输出：按键按下时LED亮
    // ========================================================================
    // 按键低电平有效（按下时为0），LED高电平点亮，所以需要取反
    assign LED15 = ~CLR;              // LED15显示BTNC（CLR）按键状态（引脚AA1）
    assign LED14 = ~PAUSE;            // LED14显示BTNL（PAUSE）按键状态（引脚AA3）
    assign LED13 = ~record_btn_raw;   // LED13显示BTNR（record_btn_raw）按键状态（引脚AA4）
    assign LED12 = ~browse_btn_raw;    // LED12显示BTNU（browse_btn_raw）按键状态（引脚AA5）

endmodule

