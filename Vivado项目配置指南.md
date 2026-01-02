# Vivado 2018.3 项目配置指南

## 一、创建新项目

### 1.1 启动Vivado并创建项目

1. 启动Vivado 2018.3
2. 选择 `Create Project`
3. 项目名称：`stopwatch_project`
4. 项目位置：选择合适的工作目录（例如：`D:\Vivado\Project`）
5. 项目类型：选择 `RTL Project`
6. 勾选 `Do not specify sources at this time`

### 1.2 选择器件

1. 在 `Default Part` 页面，选择：
   - **Family**: `Artix-7`
   - **Package**: 根据ETL3-7A35T开发板确定（通常是 `CSG324`）
   - **Speed**: `-1` 或 `-2`
   - **Part**: `xc7a35t` 系列
   - 具体型号：`xc7a35tcsg324-1` 或 `xc7a35tcsg324-2`

### 1.3 添加源文件

1. 在 `Add Sources` 页面，选择 `Add or create design sources`
2. 点击 `Add Files`，添加以下文件（按顺序）：
   ```
   src/clk_div_100Hz.v
   src/clk_div_10KHz.v
   src/counter_100.v
   src/counter_60.v
   src/counter_control.v
   src/bin_to_bcd.v
   src/bcd_to_seg7.v
   src/time_storage.v
   src/seg7_driver.v
   src/top_stopwatch.v
   ```
3. 将 `top_stopwatch.v` 设置为顶层模块：
   - 右键点击 `top_stopwatch.v`
   - 选择 `Set as Top`

### 1.4 添加约束文件

1. 在 `Add Constraints` 页面，选择 `Add or create constraints`
2. 点击 `Add Files`，添加：
   ```
   constraints/top_stopwatch.xdc
   ```
3. **重要**：约束文件已经根据ETL3-7A35T开发板配置好，无需修改

## 二、约束文件说明

### 2.1 约束文件内容

约束文件 `constraints/top_stopwatch.xdc` 包含：

1. **配置电压属性**：3.3V
2. **时钟约束**：50MHz系统时钟
3. **输入输出约束**：
   - 时钟引脚：Y19
   - 按键引脚：Y18, W22, Y22, V22
   - 数码管引脚：DATA[0-15]
   - LED引脚：LED_TEST[0-1], LED12-15
4. **时序约束**：输入/输出延迟约束
5. **其他约束**：KEEP属性、false_path等

### 2.2 引脚分配表

| 信号名 | 引脚 | I/O标准 | 说明 |
|--------|------|---------|------|
| clk | Y19 | LVCMOS33 | 50MHz系统时钟 |
| CLR | Y18 | LVCMOS33 | BTNC复位按键 |
| PAUSE | W22 | LVCMOS33 | BTNL暂停按键 |
| record_btn_raw | Y22 | LVCMOS33 | BUTR记录按键 |
| browse_btn_raw | V22 | LVCMOS33 | BUTU翻阅按键 |
| DATA[0-7] | K21, H20, J22, K22, K19, J20, H19, J21 | LVCMOS33 | 7段显示数据 |
| DATA[8-15] | L21, L20, M22, M21, T1, U1, G20, H22 | LVCMOS33 | 数码管位选 |
| LED_TEST[0] | AA20 | LVCMOS33 | LED2测试 |
| LED_TEST[1] | AB18 | LVCMOS33 | LED3测试 |
| LED15 | AA1 | LVCMOS33 | BTNC指示 |
| LED14 | AA3 | LVCMOS33 | BTNL指示 |
| LED13 | AA4 | LVCMOS33 | BTNR指示 |
| LED12 | AA5 | LVCMOS33 | BTNU指示 |

## 三、综合和实现

### 3.1 运行综合（Synthesis）

1. 在 `Flow Navigator` 中，点击 `Run Synthesis`
2. 等待综合完成（通常需要1-3分钟）
3. 检查综合报告：
   - 查看资源使用情况（LUT、FF、BRAM等）
   - 查看时序报告，确保满足时序要求
   - 检查警告信息，解决关键警告

**预期结果**：
- LUT使用：约850个（4.1%）
- FF使用：约240个（0.6%）
- 无严重警告

### 3.2 运行实现（Implementation）

1. 综合完成后，点击 `Run Implementation`
2. 等待实现完成（通常需要2-5分钟）
3. 检查实现报告：
   - 查看资源利用率
   - 查看时序报告（Setup Time、Hold Time）
   - 确保没有时序违规（Timing Violations）

**预期结果**：
- 时序满足要求（无违规）
- 资源利用率合理
- 无严重警告

### 3.3 生成比特流（Generate Bitstream）

1. 实现完成后，点击 `Generate Bitstream`
2. 等待比特流生成完成（通常需要1-2分钟）
3. 比特流文件位置：`<project_dir>/stopwatch_project.runs/impl_1/top_stopwatch.bit`

**预期结果**：
- 比特流生成成功
- 无DRC错误
- 文件大小：约1-2MB

## 四、下载和调试

### 4.1 硬件连接

1. 使用USB线连接开发板到PC
2. 确保开发板电源正常（电源指示灯亮）
3. 打开Vivado Hardware Manager

### 4.2 下载比特流

1. 在Vivado中，点击 `Open Hardware Manager`
2. 点击 `Open Target` -> `Auto Connect`
3. 选择对应的FPGA设备（通常是 `xc7a35t_0`）
4. 右键点击设备 -> `Program Device`
5. 选择生成的 `.bit` 文件：
   ```
   <project_dir>/stopwatch_project.runs/impl_1/top_stopwatch.bit
   ```
6. 点击 `Program`

### 4.3 功能测试

#### 4.3.1 复位测试
1. 按下BTNC按键
2. 观察：
   - 数码管是否全部显示0
   - LED15是否亮起

#### 4.3.2 计数测试
1. 释放BTNC按键
2. 观察：
   - 数码管是否正常计数
   - 百分秒、秒、分是否依次递增
   - 显示格式是否为MMSS:MS

#### 4.3.3 暂停测试
1. 按下BTNL按键
2. 观察：
   - 计数是否暂停
   - LED14是否亮起
3. 释放BTNL按键
4. 观察计数是否继续

#### 4.3.4 存储测试
1. 在实时模式下，按下BUTR按键
2. 观察：
   - LED13是否闪烁
   - LED2是否闪烁（边沿脉冲）
3. 继续计数一段时间
4. 再次按下BUTR按键
5. 验证是否存储了多组时间

#### 4.3.5 翻阅测试
1. 在实时模式下，按下BUTU按键
2. 观察：
   - LED12是否闪烁
   - LED3是否闪烁（边沿脉冲）
   - 计时器是否暂停
   - 是否显示第一个存储的时间
3. 按下BUTR按键
4. 观察是否切换到下一个存储时间
5. 按下BUTU按键
6. 观察是否退出翻阅模式，返回实时模式

## 五、常见问题解决

### 5.1 综合错误

**问题**：综合失败，出现语法错误

**解决方案**：
1. 检查所有源文件是否都已添加
2. 检查文件路径是否正确
3. 检查顶层模块是否设置正确
4. 查看综合日志，定位错误位置

### 5.2 时序违规

**问题**：实现后出现时序违规

**解决方案**：
1. 检查时钟约束是否正确
2. 检查是否有组合逻辑路径过长
3. 添加流水线寄存器
4. 优化关键路径

### 5.3 资源不足

**问题**：资源使用超过器件容量

**解决方案**：
1. 优化代码，减少资源使用
2. 使用BRAM替代寄存器数组（如果适用）
3. 简化某些功能

### 5.4 按键无响应

**问题**：按键按下后无反应

**解决方案**：
1. 检查按键引脚分配是否正确
2. 检查按键是低电平有效还是高电平有效
3. 使用ILA（集成逻辑分析仪）调试按键信号
4. 检查边沿检测逻辑

### 5.5 数码管显示异常

**问题**：数码管显示不正确或闪烁

**解决方案**：
1. 检查数码管引脚分配
2. 检查7段译码表是否正确（共阳极/共阴极）
3. 调整扫描频率
4. 检查动态扫描逻辑

### 5.6 DRC错误

**问题**：生成比特流时出现DRC错误

**解决方案**：
1. 检查所有端口是否都有I/O标准约束
2. 检查所有端口是否都有引脚位置约束
3. 检查约束文件语法是否正确
4. 确保顶层模块端口声明正确（注意逗号）

## 六、调试技巧

### 6.1 使用ILA（集成逻辑分析仪）

1. 在设计中添加ILA IP核：
   - `Tools` -> `IP Catalog`
   - 搜索 `ILA`
   - 双击 `ILA (Integrated Logic Analyzer)`
   - 配置采样深度和触发条件
   - 连接需要观察的信号

2. 生成调试比特流：
   - 综合和实现后，生成比特流
   - 下载调试比特流到FPGA

3. 在Hardware Manager中观察波形：
   - 打开 `hw_ila_1` 窗口
   - 设置触发条件
   - 运行捕获
   - 观察信号波形

### 6.2 使用约束文件调试

1. 添加KEEP约束，防止信号被优化：
   ```tcl
   set_property KEEP true [get_nets <net_name>]
   ```

2. 添加MARK_DEBUG属性，标记调试信号：
   ```tcl
   set_property MARK_DEBUG true [get_nets <net_name>]
   ```

### 6.3 仿真验证

1. 创建测试平台（Testbench）：
   - 创建 `sim/tb_top_stopwatch.v` 文件
   - 编写测试激励

2. 运行仿真：
   - `Flow` -> `Run Simulation` -> `Run Behavioral Simulation`
   - 观察波形，验证功能

## 七、性能优化建议

### 7.1 时序优化

1. **流水线设计**：在关键路径添加流水线寄存器
2. **寄存器复制**：对高扇出信号进行寄存器复制
3. **时钟域优化**：合理设计时钟域，减少跨时钟域信号

### 7.2 资源优化

1. **资源共享**：多个BCD转换可以共享资源
2. **状态编码**：使用独热码或格雷码优化状态机
3. **BRAM使用**：大容量存储使用BRAM替代寄存器

### 7.3 功耗优化

1. **时钟门控**：暂停时关闭计数器时钟
2. **信号优化**：减少不必要的信号翻转
3. **资源优化**：使用BRAM替代大容量寄存器

## 八、项目文件结构

```
stopwatch_project/
├── src/                    # 源文件目录
│   ├── clk_div_100Hz.v
│   ├── clk_div_10KHz.v
│   ├── counter_100.v
│   ├── counter_60.v
│   ├── counter_control.v
│   ├── bin_to_bcd.v
│   ├── bcd_to_seg7.v
│   ├── time_storage.v
│   ├── seg7_driver.v
│   └── top_stopwatch.v
├── constraints/            # 约束文件目录
│   └── top_stopwatch.xdc
├── sim/                    # 仿真文件目录（可选）
│   └── tb_top_stopwatch.v
├── stopwatch_project.xpr   # Vivado项目文件
└── stopwatch_project.runs/ # 运行结果目录
    ├── synth_1/            # 综合结果
    ├── impl_1/             # 实现结果
    └── impl_1/top_stopwatch.bit  # 比特流文件
```

## 九、版本信息

- **工具版本**：Vivado 2018.3
- **器件型号**：xc7a35tcsg324-1
- **开发板**：ETL3-7A35T
- **最后更新**：2024年

## 十、参考资源

1. **Xilinx文档**：
   - UG949: Vivado Design Suite User Guide
   - UG912: Vivado Design Suite User Guide - Design Flows Overview

2. **开发板文档**：
   - ETL3-7A35T用户手册
   - ETL3-7A35T引脚约束附录

3. **在线资源**：
   - Xilinx官方论坛
   - Xilinx Wiki
