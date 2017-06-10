//
//  ParkingPointManager.h
//  Car-Connect
//
//  Created by Matthew Dutton on 1/31/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParkingPointManager : NSObject

@property (nonatomic, strong) NSMutableArray* parkingPoint;

+ (ParkingPointManager*) sharedManager;

@end
