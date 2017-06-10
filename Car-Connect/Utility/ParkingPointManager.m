//
//  ParkingPointManager.m
//  Car-Connect
//
//  Created by Matthew Dutton on 1/31/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

#import "ParkingPointManager.h"

@interface ParkingPointManager()


@end

@implementation ParkingPointManager

+ (instancetype)sharedManager {
    static ParkingPointManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [ParkingPointManager new];
    });
    
    return _sharedManager;
}

- (id) init {
    if (self = [super init]) {
        self.parkingPoint = [NSMutableArray new];
    }
    return self;
}



@end
