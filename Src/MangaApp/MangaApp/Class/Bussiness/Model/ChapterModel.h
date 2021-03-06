//
//  ChapterModel.h
//  MangaApp
//
//  Created by ThanhLD on 4/22/15.
//  Copyright (c) 2015 ThanhLD. All rights reserved.
//

#import "JSONModel.h"

@protocol ChapterModel

@end

@interface ChapterModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *titleChap;
@property (nonatomic, strong) NSArray<Optional> *images;
@end
