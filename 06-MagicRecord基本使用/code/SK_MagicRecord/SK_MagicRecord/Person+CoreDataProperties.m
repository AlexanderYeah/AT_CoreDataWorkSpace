//
//  Person+CoreDataProperties.m
//  
//
//  Created by TrimbleZhang on 2019/1/7.
//
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Person"];
}

@dynamic name;
@dynamic age;
@dynamic sex;

@end
