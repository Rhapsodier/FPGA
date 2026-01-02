# 数字码表约束文件
# 开发板：ETL3-7A35T XILINX ARTIX-7 FPGA
# 工具：Vivado 2018.3

################################################################################
# 配置电压属性
################################################################################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

################################################################################
# 时钟约束
################################################################################
# 系统时钟：50MHz
# 注意：需要根据实际开发板的时钟引脚进行修改
# 时钟约束：50MHz系统时钟
create_clock -period 20.000 -name clk [get_ports clk]
# 注意：如果Y19是时钟专用引脚，可以删除下面这行约束
# 如果Y19不是时钟专用引脚，保留此约束（可能会产生警告，但可以忽略）
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

################################################################################
# 输入输出约束
################################################################################
# 系统时钟输入：50MHz
set_property PACKAGE_PIN Y19 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# 复位信号（CLR）- 使用BUTC按键
set_property PACKAGE_PIN Y18 [get_ports CLR]
set_property IOSTANDARD LVCMOS33 [get_ports CLR]
# 上拉电阻
set_property PULLUP true [get_ports CLR]

# 暂停信号（PAUSE）- 使用BUTL按键
set_property PACKAGE_PIN W22 [get_ports PAUSE]
set_property IOSTANDARD LVCMOS33 [get_ports PAUSE]
# 上拉电阻
set_property PULLUP true [get_ports PAUSE]

# 记录按键 - 使用BUTR按键
set_property PACKAGE_PIN Y22 [get_ports record_btn_raw]
set_property IOSTANDARD LVCMOS33 [get_ports record_btn_raw]
# 上拉电阻
set_property PULLUP true [get_ports record_btn_raw]

# 翻阅按键 - 使用BUTU按键
set_property PACKAGE_PIN V22 [get_ports browse_btn_raw]
set_property IOSTANDARD LVCMOS33 [get_ports browse_btn_raw]
# 上拉电阻
set_property PULLUP true [get_ports browse_btn_raw]

# 数码管输出 DATA[15:0]
# DATA[7:0]: 7段显示数据（对应LED_A到LED_G，共7段，LED_DP为小数点）
# DATA[15:8]: 数码管位选信号（8位，实际使用6位，显示格式：MMSS:MS）

# DATA[0] - LED_A (SEG0)
set_property PACKAGE_PIN K21 [get_ports {DATA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[0]}]

# DATA[1] - LED_B (SEG1)
set_property PACKAGE_PIN H20 [get_ports {DATA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[1]}]

# DATA[2] - LED_C (SEG2)
set_property PACKAGE_PIN J22 [get_ports {DATA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[2]}]

# DATA[3] - LED_D (SEG3)
set_property PACKAGE_PIN K22 [get_ports {DATA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[3]}]

# DATA[4] - LED_E (SEG4)
set_property PACKAGE_PIN K19 [get_ports {DATA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[4]}]

# DATA[5] - LED_F (SEG5)
set_property PACKAGE_PIN J20 [get_ports {DATA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[5]}]

# DATA[6] - LED_G (SEG6)
set_property PACKAGE_PIN H19 [get_ports {DATA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[6]}]

# DATA[7] - LED_DP (小数点，本设计中未使用，可保留)
set_property PACKAGE_PIN J21 [get_ports {DATA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[7]}]

# DATA[8] - LED_S0 (数码管位选0，最左侧)
set_property PACKAGE_PIN L21 [get_ports {DATA[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[8]}]

# DATA[9] - LED_S1 (数码管位选1)
set_property PACKAGE_PIN L20 [get_ports {DATA[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[9]}]

# DATA[10] - LED_S2 (数码管位选2)
set_property PACKAGE_PIN M22 [get_ports {DATA[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[10]}]

# DATA[11] - LED_S3 (数码管位选3)
set_property PACKAGE_PIN M21 [get_ports {DATA[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[11]}]

# DATA[12] - LED_S4 (数码管位选4)
set_property PACKAGE_PIN T1 [get_ports {DATA[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[12]}]

# DATA[13] - LED_S5 (数码管位选5)
set_property PACKAGE_PIN U1 [get_ports {DATA[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[13]}]

# DATA[14] - LED_S6 (数码管位选6，百分秒个位)
set_property PACKAGE_PIN G20 [get_ports {DATA[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[14]}]

# DATA[15] - LED_S7 (数码管位选7，当前未使用，连接到LED_S7引脚)
set_property PACKAGE_PIN H22 [get_ports {DATA[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[15]}]

################################################################################
# LED测试输出（用于测试按键是否正常工作）
################################################################################
# LED_TEST[0] - LED2，显示record_btn脉冲（边沿检测后）
set_property PACKAGE_PIN AA20 [get_ports {LED_TEST[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_TEST[0]}]

# LED_TEST[1] - LED3，显示browse_btn脉冲（边沿检测后）
set_property PACKAGE_PIN AB18 [get_ports {LED_TEST[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_TEST[1]}]

################################################################################
# LED按键指示输出
################################################################################
# LED15 - 显示BTNC（CLR）按键状态（AA1）
set_property PACKAGE_PIN AA1 [get_ports LED15]
set_property IOSTANDARD LVCMOS33 [get_ports LED15]

# LED14 - 显示BTNL（PAUSE）按键状态（AA3）
set_property PACKAGE_PIN AA3 [get_ports LED14]
set_property IOSTANDARD LVCMOS33 [get_ports LED14]

# LED13 - 显示BTNR（record_btn_raw）按键状态（AA4）
set_property PACKAGE_PIN AA4 [get_ports LED13]
set_property IOSTANDARD LVCMOS33 [get_ports LED13]

# LED12 - 显示BTNU（browse_btn_raw）按键状态（AA5）
set_property PACKAGE_PIN AA5 [get_ports LED12]
set_property IOSTANDARD LVCMOS33 [get_ports LED12]

################################################################################
# 时序约束
################################################################################
# 输入延迟约束
# 注意：按键信号已设置false_path，但仍保留输入延迟约束以提供时序参考
set_input_delay -clock clk -max 2.000 [get_ports CLR]
set_input_delay -clock clk -min 1.000 [get_ports CLR]
set_input_delay -clock clk -max 2.000 [get_ports PAUSE]
set_input_delay -clock clk -min 1.000 [get_ports PAUSE]
# 按键信号（record_btn_raw和browse_btn_raw）已设置false_path，输入延迟约束可选
# 如果产生警告，可以注释掉以下4行
set_input_delay -clock clk -max 2.000 [get_ports record_btn_raw]
set_input_delay -clock clk -min 1.000 [get_ports record_btn_raw]
set_input_delay -clock clk -max 2.000 [get_ports browse_btn_raw]
set_input_delay -clock clk -min 1.000 [get_ports browse_btn_raw]

# 输出延迟约束
set_output_delay -clock clk -max 2.000 [get_ports {DATA[*]}]
set_output_delay -clock clk -min 1.000 [get_ports {DATA[*]}]
# 注意：DATA现在是15位（DATA[14:0]）

# LED按键指示输出延迟约束
set_output_delay -clock clk -max 2.000 [get_ports LED15]
set_output_delay -clock clk -min 1.000 [get_ports LED15]
set_output_delay -clock clk -max 2.000 [get_ports LED14]
set_output_delay -clock clk -min 1.000 [get_ports LED14]
set_output_delay -clock clk -max 2.000 [get_ports LED13]
set_output_delay -clock clk -min 1.000 [get_ports LED13]
set_output_delay -clock clk -max 2.000 [get_ports LED12]
set_output_delay -clock clk -min 1.000 [get_ports LED12]

################################################################################
# 其他约束
################################################################################
# 禁止优化某些信号（用于调试）
# 防止关键信号被综合工具优化掉，便于ILA调试
set_property KEEP true [get_nets record_btn_raw]
set_property KEEP true [get_nets browse_btn_raw]
set_property KEEP true [get_nets record_btn]
set_property KEEP true [get_nets browse_btn]
# 如果需要调试按键消抖模块内部信号，可以取消注释以下行
# set_property MARK_DEBUG true [get_nets {u_record_debounce/button_stable}]
# set_property MARK_DEBUG true [get_nets {u_record_debounce/button_out}]
# set_property MARK_DEBUG true [get_nets {u_time_storage/record_btn_edge}]

# 多周期路径约束（如果需要）
# set_multicycle_path -setup 2 -from [get_clocks clk_100Hz] -to [get_clocks clk]

# 伪路径约束（异步信号）
set_false_path -from [get_ports record_btn_raw]
set_false_path -from [get_ports browse_btn_raw]

################################################################################
# 引脚分配说明
################################################################################
# 根据ETL3-7A35T开发板引脚约束附录配置：
#
# 时钟：
#   - clk: Y19 (CLK_50M)
#
# 按键（轻触开关，低电平有效，已配置上拉）：
#   - CLR: Y18 (BUTC) - 复位按键
#   - PAUSE: W22 (BUTL) - 暂停按键
#   - record_btn_raw: Y22 (BUTR) - 记录按键
#   - browse_btn_raw: V22 (BUTU) - 翻阅按键
#
# 数码管段选（DATA[7:0]）：
#   - DATA[0]: K21 (LED_A/SEG0) - 段a
#   - DATA[1]: H20 (LED_B/SEG1) - 段b
#   - DATA[2]: J22 (LED_C/SEG2) - 段c
#   - DATA[3]: K22 (LED_D/SEG3) - 段d
#   - DATA[4]: K19 (LED_E/SEG4) - 段e
#   - DATA[5]: J20 (LED_F/SEG5) - 段f
#   - DATA[6]: H19 (LED_G/SEG6) - 段g
#   - DATA[7]: J21 (LED_DP) - 小数点（本设计未使用）
#
# 数码管位选（DATA[15:8]）：
#   - DATA[9]: L20 (LED_S1) - 位选1（分钟十位，最左侧）
#   - DATA[8]: L21 (LED_S0) - 位选0（分钟个位）
#   - DATA[15]: H22 (LED_S7) - 位选7（秒十位）
#   - DATA[14]: G20 (LED_S6) - 位选6（秒个位）
#   - DATA[13]: U1 (LED_S5) - 位选5（毫秒十位）
#   - DATA[12]: T1 (LED_S4) - 位选4（毫秒个位，最右侧）
#   - DATA[10]: M22 (LED_S2) - 位选2（未使用）
#   - DATA[11]: M21 (LED_S3) - 位选3（未使用）
#
# LED按键指示：
#   - LED15: AA1 - 显示BTNC（CLR）按键状态
#   - LED14: AA3 - 显示BTNL（PAUSE）按键状态
#   - LED13: AA4 - 显示BTNR（record_btn_raw）按键状态
#   - LED12: AA5 - 显示BTNU（browse_btn_raw）按键状态
#
# 注意：
#   1. 开发板有8个数码管（LED_S0到LED_S7），本设计使用6个，显示格式：MMSS:MS（分分秒秒:毫秒）
#   2. 冒号由硬件固定显示在秒和毫秒之间，不需要单独的位选
#   3. 按键为轻触开关，低电平有效，已配置上拉电阻
#   4. 数码管为共阳极，段选信号低电平点亮
#   5. LED为高电平点亮，按键按下时（低电平）LED亮

################################################################################
# ILA调试配置已移除
# 如果需要使用ILA调试，请重新添加ILA IP核和相应的约束
################################################################################
