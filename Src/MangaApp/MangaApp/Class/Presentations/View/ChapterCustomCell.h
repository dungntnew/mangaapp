//
//  ChapterCustomCell.h
//  MangaApp
//
//  Created by ThanhLD on 4/12/15.
//  Copyright (c) 2015 ThanhLD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseCell.h"

@interface ChapterCustomCell : CustomBaseCell

@property (nonatomic, copy) void (^onStartReadingButton)();
@property (weak, nonatomic) IBOutlet UILabel *chapNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapTitleLabel;

- (IBAction)onReadingButton:(id)sender;
@end
