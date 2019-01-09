//
//  SecondStu+CoreDataProperties.m
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2019/1/9.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "SecondStu+CoreDataProperties.h"

@implementation SecondStu (CoreDataProperties)

+ (NSFetchRequest<SecondStu *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SecondStu"];
}

@dynamic a_age;
@dynamic a_name;
@dynamic a_which_class;

@end
