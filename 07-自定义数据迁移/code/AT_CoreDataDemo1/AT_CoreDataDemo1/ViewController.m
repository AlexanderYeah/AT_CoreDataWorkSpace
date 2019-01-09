//
//  ViewController.m
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2018/12/26.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>

#import "SecondStu+CoreDataProperties.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    // 上下文
    NSManagedObjectContext * _context;
    // tb 数据源
    NSMutableArray * _dataSource;
    // PSC
    NSPersistentStoreCoordinator *_coord;
    
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建数据库
    [self createDB];
    _dataSource = [NSMutableArray array];
    
    // 更新数据源 查询数据
    NSFetchRequest *req  = [NSFetchRequest fetchRequestWithEntityName:@"SecondStu"];
    [_dataSource removeAllObjects];
    
    [_dataSource addObjectsFromArray:[_context executeFetchRequest:req error:nil]];
    
    NSLog(@"%@",_dataSource);
    [self.tableView reloadData];
    
}

// 判断是否需要迁移 是否已经迁移过了
- (BOOL)isHaveMigration
{
    // 原来的数据库路径 不存在直接进行返回
    
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"student.sqlite"];
    NSURL *sqlURL = [NSURL fileURLWithPath:sqlPath];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:sqlPath]) {
        return NO;
    }
    
    // 比较存在模型数据的元数据
    
    NSError *error =  nil;
    
    // 数据库的数据结构
    NSDictionary *sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sqlURL options:nil error:&error];
    
    // 比较数据库的数据 和目标数据是否相同 如果相同 不需要迁移操作
    NSManagedObjectModel  *destinationModel = _coord.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetaData]) {
        return NO;
    }
    
    return YES;
    
    
}

- (BOOL)startMigration
{
    BOOL success = NO;
    NSError *error = nil;
    
    // 旧的数据库路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"student.sqlite"];
    NSURL *sqlURL = [NSURL fileURLWithPath:sqlPath];
    
    
    // 原来的数据模型信息
    NSDictionary *sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sqlURL options:nil error:&error];
    
    
    // 原来的数据模型
    NSManagedObjectModel *soureceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetaData];
    // 当前的数据模型信息
    NSManagedObjectModel  *destinationModel = _coord.managedObjectModel;
    
    // 加载数据迁移的模型 mappingModel
    NSMappingModel *mapModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:soureceModel destinationModel:destinationModel];
    
    if (mapModel) {
        // 迁移管理器
        NSMigrationManager *mgr = [[NSMigrationManager alloc]initWithSourceModel:soureceModel destinationModel:destinationModel];
        
        
        // 监听的数据迁移的进度
        // 监听的进度可以用来给用户进行展示 例如说QQ新版本更新完之后打开之后，有一个进度条会更新数据，应该就是这个操作
        [mgr addObserver:self
              forKeyPath:@"migrationProgress"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];

        // 先把模型存储到临时的sqlite 迁移完成再进行替换操作
        // 目的路径
        NSString *destPath = [docStr stringByAppendingPathComponent:@"temp2.sqlite"];
        NSURL *destURL = [NSURL fileURLWithPath:destPath];
        success = [mgr migrateStoreFromURL:sqlURL type:NSSQLiteStoreType options:nil withMappingModel:mapModel toDestinationURL:destURL destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        
        if (success) {
            // 证明数据迁移成功
            [self replaceStore:sqlURL withStore:destURL];
        }else{
            // 迁移数据失败
            NSLog(@"%@",error.description);
        }
        
    }
    
    return success;
}

// 响应监听的方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float progress =
            [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            
            int percentage = progress * 100;
            NSString *string =
            [NSString stringWithFormat:@"Migration Progress: %i%%",
             percentage];
            NSLog(@"%@",string);
            
        });
    }
}



// 将旧的移除新的放置在旧的上面
-(BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new
{
    BOOL success = NO;
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }
    }
    return success;
}





- (void)createDB
{
    
    // 1.1 创建路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AT_CoreDataDemo1" withExtension:@"momd"];
    // 1.2 根据模型文件路径创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    
    // 3 数据库存放的路径
    // doc 文件夹路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES) lastObject];
    // 数据库路径 不需要迁移数据库的
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"student.sqlite"];
    
    
    
    // 2.1 创建持久化存储器 管理数据库
    // 传入模型的对象
    NSPersistentStoreCoordinator *storeCoord = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    
    _coord = storeCoord;
    
    NSLog(@"isHaveMigration--%@",[self isHaveMigration] ? @"YES":@"NO");
    // 判断是否需要迁数据
    if ([self isHaveMigration]) {
       
        // 如果需要开始数据迁移
        [self startMigration];
        // 如果迁移数据库的路径
    }
    
    
    
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
    
    _context = context;
    
    
    
}



// 插入一条数据操作
- (IBAction)insertAction:(UIButton *)sender {
    
    
    // 1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    
    SecondStu *stu = [NSEntityDescription insertNewObjectForEntityForName:@"SecondStu" inManagedObjectContext:_context];
    
    stu.a_name = [NSString stringWithFormat:@"编号%d",arc4random()% 1000];
    
    stu.a_age =  [[NSString stringWithFormat:@"%d",arc4random()% 100] integerValue];
    
//    stu.sex = (arc4random()%100) / 2 ? @"男":@"女";
    
    
    //2 查询所有的请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"SecondStu"];
    
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

// 删除一条数据操作
- (IBAction)deleteAction:(UIButton *)sender {
    // 1 创建删除请求
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"SecondStu"];
    
    // 不添加任何条件的查询就是讲所有的数据查询出来
    // 使用谓词 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age > %d && age < %d", 40,60];
    req.predicate = pre;
    
    NSArray *resArr = [_context executeFetchRequest:req error:nil];
    
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:resArr];
    [self.tableView reloadData];
    // 2 查询出来的数据进行删除操作
    for (SecondStu *stu in resArr) {
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
    for (SecondStu *stu in resArr) {
        stu.a_name = @"标记:年龄已经大于50的人";
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
// 排序数据操作
- (IBAction)orderAction:(UIButton *)sender {
    

    
}


// 查询数据
- (IBAction)queryAction:(UIButton *)sender {
    

    
    
}


#pragma mark - 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIDA = @"CellIDA";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDA];
    }
    
    SecondStu *stu = _dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@---年龄:%d",stu.a_name,stu.a_age];
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}


@end
