// ============================================================================
// 数码管驱动模块：动态扫描显示
// ============================================================================
// 功能：
//   1. 二进制转BCD码转换（分钟、秒、百分秒）
//   2. BCD码转7段显示码
//   3. 动态扫描控制（6个数码管，10KHz扫描频率）
// 显示格式：MMSS:MS（分分秒秒:毫秒）
// 扫描顺序：分高位、分低位、秒高位、秒低位、毫秒高位、毫秒低位
// ============================================================================
module seg7_driver (
    input wire clk_10KHz,
    input wire rst_n,
    input wire [5:0] minute,
    input wire [5:0] second,
    input wire [6:0] centisecond,
    output reg [7:0] seg_data,      // 7段显示数据
    output reg [7:0] seg_sel       // 数码管选择（8位，实际使用6位）
);

    // 扫描计数器
    reg [2:0] scan_cnt;
    
    // BCD码
    wire [3:0] min_tens_bcd, min_ones_bcd;
    wire [3:0] sec_tens_bcd, sec_ones_bcd;
    wire [3:0] centi_tens_bcd, centi_ones_bcd;
    
    // 7段显示码
    wire [6:0] seg_min_tens, seg_min_ones;
    wire [6:0] seg_sec_tens, seg_sec_ones;
    wire [6:0] seg_centi_tens, seg_centi_ones;
    
    // 二进制转BCD
    bin_to_bcd u_min_bcd (
        .bin_in({1'b0, minute}),
        .bcd_tens(min_tens_bcd),
        .bcd_ones(min_ones_bcd)
    );
    
    bin_to_bcd u_sec_bcd (
        .bin_in({1'b0, second}),
        .bcd_tens(sec_tens_bcd),
        .bcd_ones(sec_ones_bcd)
    );
    
    bin_to_bcd u_centi_bcd (
        .bin_in(centisecond),
        .bcd_tens(centi_tens_bcd),
        .bcd_ones(centi_ones_bcd)
    );
    
    // BCD转7段
    bcd_to_seg7 u_min_tens_seg (.bcd(min_tens_bcd), .seg7(seg_min_tens));
    bcd_to_seg7 u_min_ones_seg (.bcd(min_ones_bcd), .seg7(seg_min_ones));
    bcd_to_seg7 u_sec_tens_seg (.bcd(sec_tens_bcd), .seg7(seg_sec_tens));
    bcd_to_seg7 u_sec_ones_seg (.bcd(sec_ones_bcd), .seg7(seg_sec_ones));
    bcd_to_seg7 u_centi_tens_seg (.bcd(centi_tens_bcd), .seg7(seg_centi_tens));
    bcd_to_seg7 u_centi_ones_seg (.bcd(centi_ones_bcd), .seg7(seg_centi_ones));
    
    // 扫描计数器（6个数码管：分高位、分低位、秒高位、秒低位、毫秒高位、毫秒低位）
    always @(posedge clk_10KHz or negedge rst_n) begin
        if (!rst_n) begin
            scan_cnt <= 3'd0;
        end
        else begin
            scan_cnt <= (scan_cnt == 3'd5) ? 3'd0 : scan_cnt + 1'b1;
        end
    end
    
    // 数码管选择和数据显示
    // 显示格式：MMSS:MS（分分秒秒:毫秒）
    // 从左到右：分高位、分低位、秒高位、秒低位、毫秒高位、毫秒低位
    // 冒号由硬件固定显示在秒和毫秒之间，不需要单独的位选
    always @(posedge clk_10KHz or negedge rst_n) begin
        if (!rst_n) begin
            seg_sel <= 8'b00000000;
            seg_data <= 8'h00;
        end
        else begin
            case (scan_cnt)
                3'd0: begin  // 分高位（分钟十位，最左侧）
                    seg_sel <= 8'b00000010;  // LED_S1
                    seg_data <= {1'b0, seg_min_tens};
                end
                3'd1: begin  // 分低位（分钟个位）
                    seg_sel <= 8'b00000001;  // LED_S0
                    seg_data <= {1'b0, seg_min_ones};
                end
                3'd2: begin  // 秒高位（秒十位）
                    seg_sel <= 8'b10000000;  // LED_S7
                    seg_data <= {1'b0, seg_sec_tens};
                end
                3'd3: begin  // 秒低位（秒个位）
                    seg_sel <= 8'b01000000;  // LED_S6
                    seg_data <= {1'b0, seg_sec_ones};
                end
                3'd4: begin  // 毫秒高位（百分秒十位）
                    seg_sel <= 8'b00100000;  // LED_S5
                    seg_data <= {1'b0, seg_centi_tens};
                end
                3'd5: begin  // 毫秒低位（百分秒个位，最右侧）
                    seg_sel <= 8'b00010000;  // LED_S4
                    seg_data <= {1'b0, seg_centi_ones};
                end
                default: begin
                    seg_sel <= 8'b00000000;
                    seg_data <= 8'h00;
                end
            endcase
        end
    end

endmodule

