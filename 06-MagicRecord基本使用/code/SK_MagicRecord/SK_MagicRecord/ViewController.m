//
//  ViewController.m
//  SK_MagicRecord
//
//  Created by TrimbleZhang on 2019/1/7.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//  

#import "ViewController.h"

#import <MagicalRecord/MagicalRecord.h>
#import "Person+CoreDataProperties.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** */
@property (nonatomic,strong)NSMutableArray *modelArr;


@end

@implementation ViewController

- (NSMutableArray *)modelArr
{
    
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSArray *personArr = [Person  MR_findAll];
    [self.modelArr removeAllObjects];
    [self.modelArr addObjectsFromArray:personArr];
    [self.tableView reloadData];
    
}



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
// 查询
- (IBAction)queryAction:(id)sender {
    
    NSArray *personArr = [Person MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"age < 20"]];
    [self.modelArr removeAllObjects];
    [self.modelArr addObjectsFromArray:personArr];
    [self.tableView reloadData];
    
    // 获取实体的数量
    NSNumber *count1 = [Person MR_numberOfEntities];
    // 获取指定符合过滤条件的实体的数量
    NSNumber *count2 = [Person MR_numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"age < 20"]];    
    NSLog(@"%d--%d",count1.intValue,count2.intValue);
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArr.count;
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
    
    cell.textLabel.numberOfLines = 0;
    Person *p = self.modelArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@ \n 年龄:%d",p.name,p.age];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}




@end
