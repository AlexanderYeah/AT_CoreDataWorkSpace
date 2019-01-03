//
//  NewStudent+CoreDataProperties.m
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2019/1/3.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "NewStudent+CoreDataProperties.h"

@implementation NewStudent (CoreDataProperties)

+ (NSFetchRequest<NewStudent *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"NewStudent"];
}

@dynamic age;
@dynamic name;
@dynamic which_class;
@dynamic sex;
@dynamic score;

@end
