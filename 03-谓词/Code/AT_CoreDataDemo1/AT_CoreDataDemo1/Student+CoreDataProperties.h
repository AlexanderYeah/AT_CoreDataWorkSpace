//
//  Student+CoreDataProperties.h
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2018/12/26.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t age;
@property (nullable, nonatomic, copy) NSString *which_class;
@end

NS_ASSUME_NONNULL_END
