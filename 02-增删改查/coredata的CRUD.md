### CoreData 的增删改查

基本的增删改查的操作



#### 1 数据库的创建

```objective-c
- (void)createDB
{
    
    // 1.1 创建路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AT_CoreDataDemo1" withExtension:@"momd"];
    // 1.2 根据模型文件路径创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    
    
    // 2.1 创建持久化存储器 管理数据库
    // 传入模型的对象
    NSPersistentStoreCoordinator *storeCoord = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    
    // 3 数据库存放的路径
    // doc 文件夹路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) lastObject];
    // 数据库路径
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"student.sqlite"];
    
    //  4 设置数据库相关的信息
    //  存储器sqlite 类型
    NSError *error = nil;
    [storeCoord addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:&error];
    
    if (!error) {
        NSLog(@"数据库创建成功--%@",sqlPath);
    }else{
        NSLog(@"数据库创建失败");
        
    }
    
    
    // 创建上下文 对数据库进行操作
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    // 关联协调器
    context.persistentStoreCoordinator = storeCoord;
    // 关联全局的上下文 以便于操作数据库
    _context = context;
    
    
    
}
```



#### 2 插入数据

```objective-c
// 插入一条数据操作
- (IBAction)insertAction:(UIButton *)sender {
    
    
    // 1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    
    Student *stu = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    
    stu.name = [NSString stringWithFormat:@"编号%d",arc4random()% 1000];
    
    stu.age =  [[NSString stringWithFormat:@"%d",arc4random()% 100] integerValue];
    
//    stu.sex = (arc4random()%100) / 2 ? @"男":@"女";
    
    
    //2 查询所有的请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 执行操作
    NSError *error = nil;
    [_context executeRequest:req error:&error];
    
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:[_context executeFetchRequest:req error:nil]];
    [self.tableView reloadData];
    
    
    // 3 讲数据插入到数据库
    NSError *error2= nil;
    if ([_context save:&error2]) {
        NSLog(@"保存数据成功");
    }else{
        NSLog(@"保存数据失败");
    }
    


    
    NSLog(@"%@",_dataSource);
    
}

```



#### 2 更新数据

```objective-c
// 更新数据操作
- (IBAction)updateAction:(UIButton *)sender {
    
    // 1 创建查询请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 不添加任何条件的查询就是讲所有的数据查询出来
    // 使用谓词 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > %d", 50];
    
    req.predicate = pre;
    
    // 1.1 请求结果
    NSArray *resArr = [_context executeFetchRequest:req error:nil];
    
    // 2 更新数据
    for (Student *stu in resArr) {
        stu.name = @"标记:年龄已经大于50的人";
    }
    
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:resArr];
    
    // 3 进行保存操作
    NSError *error= nil;
    if ([_context save:&error]) {
        NSLog(@"保存数据成功");
    }else{
        NSLog(@"保存数据失败");
    }
 
    
}
```



####  3 删除数据

```objective-c
- (IBAction)deleteAction:(UIButton *)sender {
    // 1 创建删除请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 不添加任何条件的查询就是讲所有的数据查询出来
    // 使用谓词 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > %d && age < %d", 40,60];
    req.predicate = pre;
    
    NSArray *resArr = [_context executeFetchRequest:req error:nil];
    
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:resArr];
    [self.tableView reloadData];
    // 2 查询出来的数据进行删除操作
    for (Student *stu in resArr) {
        [_context deleteObject:stu];
    }
    
    
    // 3 进行操作操作
    NSError *error= nil;
    if ([_context save:&error]) {
        NSLog(@"删除数据成功");
    }else{
        NSLog(@"删除数据失败");
    }
    
    
    
}
```



#### 4 排序数据

```objective-c
- (IBAction)orderAction:(UIButton *)sender {
    
    //创建排序请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //实例化排序对象 将年龄按照升序排列
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age"ascending:YES];
    // 可以添加多个筛选条件
    request.sortDescriptors = @[ageSort];
    
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    [_dataSource removeAllObjects];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
}

```



#### 5 查询数据

```objective-c
// 查询数据
- (IBAction)queryAction:(UIButton *)sender {
    
    /* 谓词的条件指令
     1.比较运算符 > 、< 、== 、>= 、<= 、!=
     例：@"number >= 99"
     
     2.范围运算符：IN 、BETWEEN
     例：@"number BETWEEN {1,5}"
     @"address IN {'shanghai','nanjing'}"
     
     3.字符串本身:SELF
     例：@"SELF == 'APPLE'"
     
     4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
     例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
     @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
     @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
     
     5.通配符：LIKE
     例：@"name LIKE[cd] '*er*'"   //*代表通配符,Like也接受[cd].
     @"name LIKE[cd] '???er*'"
     
     *注*: 星号 "*" : 代表0个或多个字符
     问号 "?" : 代表一个字符
     
     6.正则表达式：MATCHES
     例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
     @"name MATCHES %@",regex
     
     注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
     
     7. 合计操作
     ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
     ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
     NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
     IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
     
     提示:
     1. 谓词中的匹配指令关键字通常使用大写字母
     2. 谓词中可以使用格式字符串
     3. 如果通过对象的key
     path指定匹配条件，需要使用%K
     
     */
    
    
    // 1 创建查询请求
    NSFetchRequest *req =[NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > 80"];
    
    req.predicate = pre;
    
    
    // 通过这个属性实现分页
    //request.fetchOffset = 0;
    
    // 每页显示多少条数据
    //request.fetchLimit = 6;
    
    NSArray *resArray = [_context executeFetchRequest:req error:nil];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    
}
```



6 获取查询条件的数据数

在开发过程中，有时候只需要所需数据的count值，如果像之前一样获取所有对象加载到内存，在去遍历是比较消耗内存的。

苹果提供了两种方式，去直接查询count值，count值的查询是在数据库层面完成的，不需要将托管对象加载到内存中，避免内存的大开销。

1. resultType 通过设置NSFetchRequest 对象的resultType 来获取count 值

```objective-c
    // 1 创建查询请求
    NSFetchRequest *req =[NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > 80"];
    
    req.predicate = pre;
    // 设置查询获取数量
    req.resultType = NSCountResultType;

    // 只查询数量 不查询对象
    NSArray *resArray = [_context executeFetchRequest:req error:nil];
    
    // 执行查询操作，数组中只返回一个对象，就是计算出的count 值
    NSInteger count = [resArray.firstObject integerValue];

    NSLog(@"count--%ld",count);
    
```



2 直接调用countForFetchRequest 方法获取数量

```objective-c
    // 1 创建查询请求
    NSFetchRequest *req =[NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > 80"];
    
    req.predicate = pre;
 
    
    // 只查询数量 不查询对象
    NSArray *resArray = [_context executeFetchRequest:req error:nil];
    
    // 执行查询操作，数组中只返回一个对象，就是计算出的count 值
    
    NSUInteger count = [_context countForFetchRequest:req error:nil];

    NSLog(@"count--%ld",count);
```

