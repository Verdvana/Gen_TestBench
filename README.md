# Gen_TestBench

#### 项目介绍
&#160; &#160; &#160; &#160; TestBench生成器

##### 工程结构

- Gen_TestBench.exe

#### 日志

* 首次更新 `2021.8.14`
    * 根据**同一路径下的**Verilog/System Verilog文件生成相对应的TestBench；
    * 自定义时钟频率；
    * 适应不同编辑器；
    * 限制：
        * 只能生成单个文件的TestBench，且要在同一目录下；
        * 时钟信号必须包含“clock”或“clk”，大小写不限；
        * 复位信号必须包含“reset”或“rst”，大小写不限；
        * 后缀为“_n”的复位信号会被识别为低电平有效，否则默认高电平有效。