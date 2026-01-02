# time_storage功能修复说明

## 修复内容

根据用户需求，修复了time_storage模块的功能问题，实现了以下改进：

### 1. 翻阅模式退出功能

**问题**：翻阅模式无法退出

**解决方案**：
- 在翻阅模式下，BUTU按键用于退出翻阅模式
- 按下BUTU后，系统返回实时模式，继续显示实时计时值

### 2. 翻阅模式下计时器暂停

**问题**：翻阅模式下计时器仍在运行

**解决方案**：
- 添加`browse_mode`信号输出
- 在顶层模块中，将`browse_mode`信号连接到`counter_control`的`pause`输入
- 当`browse_mode=1`时，计时器自动暂停

### 3. 按键功能重新定义

**实时模式（browse_mode = 0）**：
- **BUTR按键（record_btn_raw）**：记录当前时间到存储单元
- **BUTU按键（browse_btn_raw）**：进入翻阅模式

**翻阅模式（browse_mode = 1）**：
- **BUTR按键（record_btn_raw）**：翻阅下一个存储的时间（循环显示0-5组）
- **BUTU按键（browse_btn_raw）**：退出翻阅模式，返回实时模式

## 修改的文件

### 1. src/time_storage.v

**主要修改**：
- 重新设计按键逻辑，根据`browse_mode`状态区分按键功能
- 实时模式下：BUTR记录，BUTU进入翻阅模式
- 翻阅模式下：BUTR翻阅，BUTU退出翻阅模式
- 进入翻阅模式时，自动从第0组开始显示

**关键代码逻辑**：
```verilog
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
```

### 2. src/top_stopwatch.v

**主要修改**：
- 添加`browse_mode`信号声明
- 将`browse_mode`信号从`time_storage`模块输出
- 在`counter_control`模块的`pause`输入中，添加`browse_mode`条件

**关键代码修改**：
```verilog
// 添加browse_mode信号
wire browse_mode;  // 翻阅模式信号，用于控制计时器暂停

// 计数控制模块：在翻阅模式下也暂停
counter_control u_counter_control (
    .clk_100Hz(clk_100Hz),
    .rst_n(rst_n),
    .pause(~PAUSE | browse_mode),  // 暂停条件：PAUSE按键按下 或 处于翻阅模式
    ...
);

// time_storage模块：输出browse_mode信号
time_storage u_time_storage (
    ...
    .browse_mode(browse_mode)   // 输出翻阅模式状态，用于控制计时器暂停
);
```

### 3. 设计文档.md

**更新内容**：
- 更新了存储管理模块的说明
- 详细说明了两种工作模式（实时模式和翻阅模式）
- 更新了按键功能说明
- 更新了暂停功能的说明

## 功能验证

### 测试步骤

1. **实时模式测试**：
   - 系统上电后，默认处于实时模式
   - 按下BUTR按键，应记录当前时间
   - 按下BUTU按键，应进入翻阅模式

2. **翻阅模式测试**：
   - 进入翻阅模式后，计时器应自动暂停
   - 按下BUTR按键，应切换到下一个存储的时间
   - 按下BUTU按键，应退出翻阅模式，返回实时模式

3. **计时器暂停测试**：
   - 进入翻阅模式后，观察计时器是否停止计数
   - 退出翻阅模式后，计时器应继续从暂停时的值继续计数

## 注意事项

1. **按键消抖**：当前设计使用边沿检测，按键按下时会产生一个时钟周期的脉冲信号
2. **模式切换**：模式切换是即时的，按键按下后立即生效
3. **存储循环**：存储和翻阅都是循环的，超过6组后会从第0组重新开始
4. **计时器暂停**：翻阅模式下计时器暂停，退出后继续计数，不会丢失时间

## 后续优化建议

1. 可以考虑添加模式指示LED，显示当前处于实时模式还是翻阅模式
2. 可以考虑添加按键消抖模块，提高按键响应稳定性
3. 可以考虑添加翻阅模式下的时间组编号显示（如使用LED显示当前是第几组）

