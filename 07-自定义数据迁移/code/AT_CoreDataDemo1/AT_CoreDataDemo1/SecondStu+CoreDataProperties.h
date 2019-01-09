//
//  SecondStu+CoreDataProperties.h
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2019/1/9.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "SecondStu+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SecondStu (CoreDataProperties)

+ (NSFetchRequest<SecondStu *> *)fetchRequest;

@property (nonatomic) int16_t a_age;
@property (nullable, nonatomic, copy) NSString *a_name;
@property (nullable, nonatomic, copy) NSString *a_which_class;

@end

NS_ASSUME_NONNULL_END
