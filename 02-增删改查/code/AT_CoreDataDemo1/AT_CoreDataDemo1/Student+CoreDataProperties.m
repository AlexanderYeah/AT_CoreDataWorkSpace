//
//  Student+CoreDataProperties.m
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2018/12/28.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic age;
@dynamic name;
@dynamic which_class;
@dynamic sex;

@end
