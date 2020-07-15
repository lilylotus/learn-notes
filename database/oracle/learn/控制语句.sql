一、条件结构

1. 简单IF结构
IF <布尔表达式> THEN
    满足条件时执行的语句
END IF;

2. IF-ELSE结构
IF <布尔表达式> THEN
    满足条件时执行的语句
ELSE
    不满足条件时执行的语句
END IF;

3. 多重IF
IF <布尔表达式1> THEN
    满足条件1时执行的语句
ELSIF <布尔表达式2> THEN
    满足条件2时执行的语句
ELSIF <布尔表达式3> THEN
    满足条件3时执行的语句
ELSE
    满足条件1、2、3均不满足时执行的语句
END IF;

4. CASE 语句1
CASE 条件表达式
    WHEN 条件表达式结果1 THEN 
        语句1
    WHEN 条件表达式结果2 THEN
        语句2
    ......
    WHEN 条件表达式结果n THEN
        语句n
  [ELSE 条件表达式结果]
END CASE;

5. CASE 语句2
CASE 
  WHEN 条件表达式1 THEN
     语句1
  WHEN 条件表达式2 THEN
     语句2
  ......
  WHEN 条件表达式n THEN 
     语句n
  [ELSE 语句]
END CASE;

-------------------------------------------------------------------
二、循环结构
1. 简单循环
LOOP
    循环体语句;
    [EXIT WHEN <条件语句>]
END LOOP;

2. WHILE循环
WHILE <布尔表达式> LOOP
    循环体语句;
END LOOP;

3. FOR循环
FOR 循环计数器 IN [ REVERSE ] 下限 .. 上限 LOOP
    循环体语句;
END LOOP;

FOR i IN 1..3 LOOP
    DBMS_OUTPUT.PUT_LINE (i);
END LOOP;