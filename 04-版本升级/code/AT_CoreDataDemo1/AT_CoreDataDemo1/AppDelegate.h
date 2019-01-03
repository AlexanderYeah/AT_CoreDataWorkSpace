//
//  AppDelegate.h
//  AT_CoreDataDemo1
//
//  Created by TrimbleZhang on 2018/12/26.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

