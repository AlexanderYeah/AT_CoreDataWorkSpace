//
//  Woker+CoreDataProperties.m
//  AT_CoreDataDemo2
//
//  Created by TrimbleZhang on 2019/1/4.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "Woker+CoreDataProperties.h"

@implementation Woker (CoreDataProperties)

+ (NSFetchRequest<Woker *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Woker"];
}

@dynamic name;
@dynamic age;
@dynamic title;
@dynamic sex;

@end
