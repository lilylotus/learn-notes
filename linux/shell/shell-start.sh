1. 变量定义
variable=vlue
variable="value"
variable='value'
注意： 赋值号 = 的周围不能有空格
value 不包含任何空白符（例如空格、Tab 缩进等），那么可以不使用引号；
如果 value 包含了空白符，那么就必须使用引号包围起来。
以单引号 '' 包围变量的值时，单引号里面是什么就输出什么
以双引号" "包围变量的值时，输出时会先解析里面的变量和命令
建议：如果变量的内容是数字，那么可以不加引号；如果真的需要原样输出就加单引号；
    其他没有特别要求的字符串等最好都加上双引号，定义变量时加双引号是最常见的使用场景

2. 使用变量
autor="au"
echo $author
echo ${author}
注意： 变量名外面的花括号{ }是可选的，加花括号是为了帮助解释器识别变量的边界
如: echo "${author}'s" --> au's (正确)  [$author's $author, $author ,] 可以
echo "$author's" --> au's (正确)
echo "$authorName" --> 空 (错误)


3. 将命令的结果赋值给变量
variable=`command` (不推荐)
variable=$(command)

4. 只读变量， readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变。
var="readonly"
readonly var
var="new variable" --> error (这里会报错)

5. 删除变量
unset variable_name

=====================================================
1. 字符串操作
var="split-demo-test.sh"
1.1 字符串长度： ${#var}
1.2 # 和 ## 获取 尾部 子字符串
    # 最小限度的截取 ${var#*-} --> demo-test.sh
    ## 最大限度的截取 ${var##*-} --> test.sh

1.3 % 和 %% 获取 头部 子字符串
    % 最小限度 ${var%-*}  --> split-demon
    %%  最大限度 ${var%%-*}  -->

1.4 ${var:} 模式 获取子字符串
1.4.1 左边第几个字符开始以及子串中字符的个数 (从指定开始的后一个字符计算)
    ${var:0:5} --> split
    ${var:1:5} --> plit-
    ${var:6}  --> demo-test.sh

1.4.2 从右边第几个字符开始以及字符的个数 (从右向左数的第 n 个开始，1为起点，包含第 n 个)
    ${var:0-8:4} --> -tes
    ${var:0-8} --> -test.sh


=======================================================
Shell变量的作用域：Shell全局变量、环境变量和局部变量
Shell 变量的作用域可以分为三种：
有的变量只能在函数内部使用，这叫做局部变量（local variable）；
有的变量可以在当前 Shell 进程中使用，这叫做全局变量（global variable）；
而有的变量还可以在子进程中使用，这叫做环境变量（environment variable）。

注意： Shell 中定义的变量，默认就是全局变量
需要强调的是，全局变量的作用范围是当前的 Shell 进程，而不是当前的 Shell 脚本文件，它们是不同的概念。
打开一个 Shell 窗口就创建了一个 Shell 进程，打开多个 Shell 窗口就创建了多个 Shell 进程，
每个 Shell 进程都是独立的，拥有不同的进程 ID。
在一个 Shell 进程中可以使用 source 命令执行多个 Shell 脚本文件，此时全局变量在这些脚本文件中都有效。

1. Shell 函数中定义的变量默认也是全局变量，它和在函数外部定义变量拥有一样的效果。
function func() { a=100 } (函数写法错误)
function func() {
    a=100
}
func
echo "func inner a = $a" --> a = 100
注意：要想变量的作用域仅限于函数内部，可以在定义时加上 local 命令，此时该变量就成了局部变量
function func() { local a=100 }