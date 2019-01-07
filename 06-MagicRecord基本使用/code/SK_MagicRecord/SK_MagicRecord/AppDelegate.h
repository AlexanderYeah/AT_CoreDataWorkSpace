//
//  AppDelegate.h
//  SK_MagicRecord
//
//  Created by TrimbleZhang on 2019/1/7.
//  Copyright © 2019 AlexanderYeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

