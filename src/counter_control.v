// ============================================================================
// 计数控制模块：整合百分秒、秒、分计数器
// ============================================================================
// 功能：
//   1. 整合100进制计数器（百分秒）和两个60进制计数器（秒、分）
//   2. 形成完整的计时链：百分秒 -> 秒 -> 分
//   3. 支持暂停功能（pause信号）
// ============================================================================
module counter_control (
    input wire clk_100Hz,
    input wire rst_n,
    input wire pause,
    output wire [6:0] centisecond,  // 百分秒 0-99
    output wire [5:0] second,       // 秒 0-59
    output wire [5:0] minute        // 分 0-59
);

    wire centisecond_carry;
    wire second_carry;
    
    // 百分秒计数器（100进制）
    counter_100 u_centisecond (
        .clk(clk_100Hz),
        .rst_n(rst_n),
        .pause(pause),
        .cnt_out(centisecond),
        .carry_out(centisecond_carry)
    );
    
    // 秒计数器（60进制）
    counter_60 u_second (
        .clk(clk_100Hz),
        .rst_n(rst_n),
        .pause(pause),
        .enable(centisecond_carry),
        .cnt_out(second),
        .carry_out(second_carry)
    );
    
    // 分计数器（60进制）
    counter_60 u_minute (
        .clk(clk_100Hz),
        .rst_n(rst_n),
        .pause(pause),
        .enable(second_carry),
        .cnt_out(minute),
        .carry_out()  // 分钟不需要进位
    );

endmodule

