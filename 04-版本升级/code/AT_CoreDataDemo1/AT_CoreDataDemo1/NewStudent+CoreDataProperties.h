//
//  NewStudent+CoreDataProperties.h
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2019/1/3.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "NewStudent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NewStudent (CoreDataProperties)

+ (NSFetchRequest<NewStudent *> *)fetchRequest;

@property (nonatomic) int16_t age;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *which_class;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nonatomic) int64_t score;

@end

NS_ASSUME_NONNULL_END
