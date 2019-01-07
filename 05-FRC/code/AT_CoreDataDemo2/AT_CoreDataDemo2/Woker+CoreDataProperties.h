//
//  Woker+CoreDataProperties.h
//  AT_CoreDataDemo2
//
//  Created by TrimbleZhang on 2019/1/4.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//
//

#import "Woker+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Woker (CoreDataProperties)

+ (NSFetchRequest<Woker *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t age;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *sex;

@end

NS_ASSUME_NONNULL_END
