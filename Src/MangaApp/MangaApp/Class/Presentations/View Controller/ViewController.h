//
//  ViewController.h
//  MangaApp
//
//  Created by ThanhLD on 4/11/15.
//  Copyright (c) 2015 ThanhLD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChapterListService.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ChapterListService *chapterService;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@end

