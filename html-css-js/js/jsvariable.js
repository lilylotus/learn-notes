类型                    前缀            示例        
数组(Array) 　　　 　     a 　 　 　　    aItems
布尔值(Boolean)    　　   b 　 　 　　    bIsComplete
浮点数(Float)    　　     f 　　  　　    fPrice
函数(Function)　　　 　   fn 　   　　    fnHandler
整数(Integer) 　　　 　   i 　　  　　    iItemCount
对象(Object) 　　　　     o 　　  　　    oDIv1
正则表达式(RegExp)        re 　   　　    reEmailCheck
字符串(String) 　　       s 　　  　　    sUserName
变量(Variant)　　 　 　   v 　　  　　    vAnything 


属性访问表达式运算可以得到一个对象属性或一个数组元素的值，javascript为属性访问定义了两种语法

MemberExpression . IdentifierName 
MemberExpression [ Expression ] 

对象创建表达式

对象创建表达式创建一个对象并调用一个函数初始化新对象的属性
new Object();
new Point(2,3);
如果一个对象创建表达式不需要传入任何参数给构造函数的话，那么这对空圆括号是可以省略的
new Object;

恒等运算符

恒等运算符'==='，也叫严格相等运算符，首先计算其操作数的值，然后比较这两个值，
比较过程没有任何类型转换，比较过程如下：
【1】如果两个值的类型不相同，则返回false
【2】如果两个值都是Undefined、Null、Boolean、Number、String相同原始类型的值，值相同，就返回true，
		否则，返回false
		
[注意]不论什么进制的数字，在进行关系比较时，最终都转换为十进制进行运算
console.log(NaN === NaN);//false
console.log(+0 === -0);//true
两个相同字符串值表现为：相同的长度和相同的字符对应相同的位置
console.log('abc' === 'abc');//true
console.log('abc' === 'acb');//false

【3】如果两个值引用同一个对象，则返回true，否则，返回false
[注意]更详细的解释是，javascript对象的比较是引用的比较，而不是值的比较。
对象和其本身是相等的，但和其他任何对象都不相等。
如果两个不同的对象具有相同数量的属性，相同的属性名和值，它们依然是不相等的


相等运算符

相等运算符'=='和恒等运算符相似，但相等运算符的比较并不严格，如果两个操作数不是同一类型，
相等运算符会尝试进行一些类型转换，然后再进行比较

当两个操作数类型相同时，比较规则和恒等运算符规则相同

当两个操作数类型不同时，相等运算符'=='会遵守如下规则：
【1】如果一个值是对象类型，另一值是原始类型，则对象类型会先使用valueOf()转换成原始值，
	如果结果还不是原始值，则再使用toString()方法转换，再进行比较
[注意]日期类只允许使用toString()方法转换为字符串。
	类似地，时间Date对象进行加法运算时使用toString()转换为字符串，
	而在其他数学运算，包括减法、乘法、除法、求余等运算中，
	都是使用Number()转换函数将时间Date对象使用valueOf()转换为数字