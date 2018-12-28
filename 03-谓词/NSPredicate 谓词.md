#### NSPredicate 谓词

在查询数据的过程中，给NSFetchRequest设置一个过滤条件，不需要讲所有的托管对象加载到内存中去。这样的话就会节省内存和加快查找速度。

一 运算符

1  比较运算符



> 、< 、== 、>= 、<= 、!=

比如说age>80 

```objective-c
NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > 80"];
```





  2.范围运算符：IN 、BETWEEN 表示一个范围

```objective-c
   // 过滤条件 BETWEEN 年龄在27 到 30 之间的范围 IN 是 包含，过滤包含27 或者 28的对象
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age BETWEEN {27,30}"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age BETWEEN {27,28}"];
```



3 字符串本身:SELF

```objective-c
// 字符串本身 找到name等于某个字符串的操作
NSPredicate *pre = [NSPredicate predicateWithFormat:@"name == '编号322'"];

```





4 字符串相关的操作  BEGINSWITH（以某个字符串开头）、ENDSWITH（以某个字符串结束）、CONTAINS（包含某个字符串）

```objective-c
    // [c]不区分大小写
    // [d]不区分发音符号即没有重音符号
    // [cd]既不区分大小写，也不区分发音符号
    // CONTAINS 包含指定字符串的
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] '编号322'"];
	// BEGINSWITH 以指定字符串的开始的
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] '编号'"];
	// ENDSWITH 以指定字符串的结束的
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name ENDSWITH[cd] '2'"];
```



5 通配符 LIKE 常用于模糊查询

```objective-c
//    *注*: 星号 "*" : 代表0个或多个字符
//    问号 "?" : 代表一个字符
    // 找出编号开头的name
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name  LIKE[cd] '编号*'"];
```



6 keyPath 创建查询条件的时候，支持设置被匹配的目标的keypath，设置更为深层次的匹配目标

```
[NSPredicate predicateWithFormat:@"employee.name = %@", @"lxz"]
```



