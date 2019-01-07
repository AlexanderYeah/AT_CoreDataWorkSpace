### NSFetchedResultsController 

一般来讲，是配合CoreData 进行使用



####  1 控制器的创建

*  一个fetch request.必须包含一个sort descriptor用来给结果集排序。
* 一个managed object context。 控制器用这个context来执行取数据的请求。
* 一个可选的key path作为section name。控制器用key path来把结果集拆分成各个section。（传nil代表只有一个section）。
*  一个cachefile的名字，用来缓冲数据，生成section和索引信息。



当控制器创建好之后，用performFectch 来执行查询操作

```objective-c
	在viewDidLoad 里面编写如下代码    

    // 一个请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Woker"];
    // 排序方式
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    req.sortDescriptors = @[ageSort];
    // 实例化
    self.frc =  [[NSFetchedResultsController alloc]initWithFetchRequest:req managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
	// 设置代理方法 监听数据的变化
    self.frc.delegate = self;    
    // 执行数据请求
    [self.frc performFetch:&error1];
```



#### 2 控制器的代理方法

NSFetchedResultsControllerDelegate 

为控制器设置代理方法，代理会收到从它的managed object context中传来改变通知。自动更新显示的内容。

```objective-c
// 将要发生改变
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
        
}


// 已经发生改变 常用于刷新数据
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 整体刷新
    [self.tableview reloadData];
}

//  监听是增删改查的操作  更新、插入、删除或者行的移动会走这个代理方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            NSString *sectionKeyPath = [controller sectionNameKeyPath];
            if (sectionKeyPath == nil)
                break;
            NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
            NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
            id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
            for (int i = 0; i < [keyParts count] - 1; i++) {
                NSString *onePart = [keyParts objectAtIndex:i];
                changedObject = [changedObject valueForKey:onePart];
            }
            sectionKeyPath = [keyParts lastObject];
            NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
            if ([[committedValues valueForKeyPath:sectionKeyPath]isEqual:currentKeyValue])
                break;
            NSUInteger tableSectionCount = [self.tableview numberOfSections];
            NSUInteger frcSectionCount = [[controller sections] count];
            if (tableSectionCount != frcSectionCount) {
                // Need to insert a section
                NSArray *sections = controller.sections;
                NSInteger newSectionLocation = -1;
                for (id oneSection in sections) {
                    NSString *sectionName = [oneSection name];
                    if ([currentKeyValue isEqual:sectionName]) {
                        newSectionLocation = [sections indexOfObject:oneSection];
                        break;
                    }
                }
                if (newSectionLocation == -1)
                    return; // uh oh
                if (!((newSectionLocation == 0) && (tableSectionCount == 1)
                      && ([self.tableview numberOfRowsInSection:0] == 0)))
                    [self.tableview insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation]
                                  withRowAnimation:UITableViewRowAnimationFade];
                NSUInteger indices[2] = {newSectionLocation, 0};

            }
        }
        case NSFetchedResultsChangeMove:
            if (newIndexPath != nil) {
                [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
                [self.tableview insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationRight];
            }
            else {
                [self.tableview reloadSections:[NSIndexSet
                                                indexSetWithIndex:[indexPath section]]withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        default:
            break;
    }

}



```



#### 3 和tableview的绑定使用

NSFetchedResultsSectionInfo 是一个NSFetchedResultController组装成的对象，用来封装section的对象集合。

包含了几个成员，indexTitle,name,numberofObjects和objects,
其中name指的是section名，indexTitle指的是索引名，numberofObject指的是section下面的对象数量（如果用UItableView显示的话，这个一般就是section下面row的数量），objects是对象数组。



```objective-c
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    
    sectionInfo = self.frc.sections[section];
    
    return sectionInfo.objects.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIDA = @"CellIDA";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDA];
    }
    // 获取对象
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    
    sectionInfo = self.frc.sections[indexPath.section];
    
    Woker *work = (Woker *) [sectionInfo objects][indexPath.row];
  
    cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@\n年龄:%d\n性别:%@",work.name,work.age,work.sex];
    
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

```

