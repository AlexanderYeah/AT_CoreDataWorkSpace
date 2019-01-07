### MagicRecord 使用

####  1 安装

* github 手动copy [✈️✈️✈️✈️](https://github.com/magicalpanda/MagicalRecord)
* cocoapod  "MagicalRecord"



中文翻译的文档： https://github.com/ios122/MagicalRecord



#### 2 使用

1 初始化

```objective-c

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // 初始化coredata 堆栈
    [MagicalRecord setupCoreDataStack];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    // 在应用退出的时候 调用clean up 的方法
    [MagicalRecord cleanUp];
    
    [self saveContext];
}

```

2  插入一条数据

* 获取上下文
* 在上下文中创建对象
* 保存数据

```objective-c
// 插入一条数据
- (IBAction)insertAction:(id)sender {
    
    // 0 获取当前全局默认上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    // 1 在当前上下文环境中创建一个新的Person对象
    Person *p = [Person MR_createEntityInContext:context];
    p.name = [NSString stringWithFormat:@"编号%d",arc4random()% 1000];
    p.age =  [[NSString stringWithFormat:@"%d",arc4random()% 100] integerValue];
    // 2 保存修改到当前上下文中.
    [context MR_saveToPersistentStoreAndWait];
    // 3 进行存到数据库 并且进行界面上的刷新数据
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        //  查询数据 并且刷新tableview
        NSArray *personArr = [Person  MR_findAll];
        [self.modelArr removeAllObjects];
        [self.modelArr addObjectsFromArray:personArr];
        [self.tableView reloadData];
    }];
    
}
```



3  删除一条数据

```objective-c
// 删除
- (IBAction)deleteAction:(id)sender {
    
    
        // 删除默认上下文中的实体
    //    [myPerson MR_deleteEntity];
    //
    //    // 删除默认上下文中全部的实体
    //    [Person MR_truncateAll];
    //    // 删除指定上下文中的实体
    //    [Person MR_deleteEntityInContext:otherContext];
    //    // 删除指定上下文中的所有实体:
    //    [Person MR_truncateAllInContext:otherContext];
    
    
    // 0 获取当前全局默认上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    // 1 在当前上下文环境中创建一个新的Person对象
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > 60"];
    // 2 创建要删除的一个对象在当前上下文中
    [Person MR_deleteAllMatchingPredicate:pre inContext:context];
    // 3 保存到上下文中去
    [context MR_saveToPersistentStoreAndWait];
    // 4 保存到本地 并且进行界面上的刷新数据
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        //  查询数据 并且刷新tableview
        NSArray *personArr = [Person  MR_findAll];
        [self.modelArr removeAllObjects];
        [self.modelArr addObjectsFromArray:personArr];
        [self.tableView reloadData];
    }];
    
}
```

4 查询一条数据

```objective-c
// 查询一条数据
- (IBAction)queryAction:(id)sender {
    
    NSArray *personArr = [Person MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"age < 20"]];
    
    [self.modelArr removeAllObjects];
    [self.modelArr addObjectsFromArray:personArr];
    [self.tableView reloadData];
    
    // 获取所有实体的数量
    NSNumber *count1 = [Person MR_numberOfEntities];
    // 获取指定符合过滤条件的实体的数量
    NSNumber *count2 = [Person MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"age < 20"]];
    
    NSLog(@"%d--%d",count1.intValue,count2.intValue);
    
    
}
```



5 更新数据

```objective-c
// 更新
- (IBAction)updateAction:(id)sender {
    
    // 当前上下文
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_defaultContext];
    // 获取想要修改的实体
    NSArray  * pArr = [Person MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"age < 30"]];
    
    for (Person *p in pArr) {
        p.name =[NSString stringWithFormat:@"这是我改的%d",arc4random()% 1000];
    }
    
    // 保存修改到上下文中去
    [ctx MR_saveToPersistentStoreAndWait];
    
    //
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        //  查询数据 并且刷新tableview
        NSArray *personArr = [Person  MR_findAll];
        [self.modelArr removeAllObjects];
        [self.modelArr addObjectsFromArray:personArr];
        [self.tableView reloadData];
    }];
    
}
```



#### 3 更多的方法

