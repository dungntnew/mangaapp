//
//  ChapterViewController.h
//  MangaApp
//
//  Created by ThanhLD on 4/19/15.
//  Copyright (c) 2015 ThanhLD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChapterService.h"

@interface ChapterViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScollView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;

@property (strong, nonatomic) ChapterService *chapterService;
@property (strong, nonatomic) ChapterModel *chapModel;

- (IBAction)onBackButton:(id)sender;
@end
