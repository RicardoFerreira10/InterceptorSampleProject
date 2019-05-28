//
//  AppDelegate.h
//  InterceptorSampleProject
//
//  Created by Ricardo Ferreira on 28/05/2019.
//  Copyright © 2019 Ricardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

