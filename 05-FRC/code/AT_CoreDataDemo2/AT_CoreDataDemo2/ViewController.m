//
//  ViewController.m
//  AT_CoreDataDemo2
//
//  Created by TrimbleZhang on 2019/1/3.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>

#import "Woker+CoreDataProperties.h"

@interface ViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource>

/** 上下文 */
@property (nonatomic,strong)NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UITableView *tableview;


/** */
@property (nonatomic,strong)NSMutableArray *dataSource;

/** */
@property (nonatomic,strong)NSFetchedResultsController *frc;


@end

@implementation ViewController


#pragma mark - 0 LazyLoad

- (NSManagedObjectContext *)context
{
    
    if (!_context) {
        _context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _context;
    
}



#pragma mark - 1 LifeCycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataSource = [NSMutableArray array];
    
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    [self createDB];
    
    NSError *error1 = nil;
    
    
    
    // 一个请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Woker"];
    // 排序方式
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    req.sortDescriptors = @[ageSort];
    // 实例化
    self.frc =  [[NSFetchedResultsController alloc]initWithFetchRequest:req managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
    // 执行数据请求
    [self.frc performFetch:&error1];
    
    
    if (!error1) {
        NSLog(@"获取数据成功");
    }
    
    
    [self.tableview reloadData];

    
}
#pragma mark - 2 Create UI

#pragma mark - 3 LoadData

#pragma mark - 4 Delegate Method

// NSFetchedResultsControllerDelegate

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

#pragma mark - 5 Action Response

- (IBAction)insertAction:(id)sender {
    
    
    Woker *worker = [NSEntityDescription insertNewObjectForEntityForName:@"Woker" inManagedObjectContext:self.context];

    worker.name = [NSString stringWithFormat:@"编号%d",arc4random()% 1000];

    worker.age = arc4random()% 60;

    worker.sex = (arc4random()%100) / 2 == 0 ? @"男":@"女";

    NSArray *titleArr = @[@"销售部",@"研发部",@"保安部",@"人事部",@"财务部"];
    worker.title = titleArr[arc4random()%4];
    
    
    // 创建请求对象
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Woker"];
    
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    req.sortDescriptors = @[ageSort];
    
    NSError *error2 = nil;
   
    [self.context save:&error2];
    
    if (!error2) {
        NSLog(@"存储数据成功");
    }
    
    
    
}

- (IBAction)cancelAction:(id)sender {
    
    
}


#pragma mark - 6 Extract Method



- (void)createDB
{
    // 1.1 创建路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AT_CoreDataDemo2" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    
    // 2.1 创建持久化存储器 管理数据库  传入模型的对象
   
    NSPersistentStoreCoordinator *storeCoord = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    
    // 3 数据库存放的路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) lastObject];
    // 数据库路径
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"coredata2.sqlite"];
    
    NSLog(@"sqlPath-%@",sqlPath);
    
    //  4 设置数据库相关的信息
    //  存储器sqlite 类型
    NSError *error = nil;
    [storeCoord addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:&error];
    
    // 5 上下文
    self.context.persistentStoreCoordinator = storeCoord;
    
}


@end
