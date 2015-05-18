//
//  ChapterViewController.m
//  MangaApp
//
//  Created by ThanhLD on 4/19/15.
//  Copyright (c) 2015 ThanhLD. All rights reserved.
//

#import "ChapterViewController.h"
#import "PageViewController.h"
#import "PhotoViewController.h"
#import "Definition.h"
#import "StaminaConfig.h"

@interface ChapterViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) BOOL isShowingBarView;
@end

#define kTagShowStamina 100

@implementation ChapterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _currentPage = 0;
    _isShowingBarView = YES;
    
    _chapterService = [[ChapterService alloc] initWithModel:_chapModel];
    [_chapterService getChapHistoryWithChapName:_chapModel.chapName];
    
    [self createUI];
    [self loadDataToView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStaminaView:) name:kUpdateStaminaView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBarViews:) name:kShowBarView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStaminaExpired:) name:kShowStaminaExpired object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self loadDataForScrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateStaminaView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowBarView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowStaminaExpired object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI {
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    _processSlider.minimumValue = 1.0;
    _processSlider.maximumValue = _chapModel.chapterJSONModel.images.count;
    
    // Create Page view controller
    NSString *zeroImage = _chapModel.chapterJSONModel.images.firstObject;
    PhotoViewController *pageZero = [PhotoViewController photoViewControllerForPageIndex:0 imageName:zeroImage andService:_chapterService];
    if (pageZero != nil)
    {
        // assign the first page to the pageViewController (our rootViewController)
        _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageSubViewController"];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        
        [_pageViewController setViewControllers:@[pageZero]
                                     direction:UIPageViewControllerNavigationDirectionForward
                                      animated:NO
                                    completion:NULL];
        
        // Change the size of page view controller
        _pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [_pageViewController didMoveToParentViewController:self];
        
        [self.view bringSubviewToFront:_headerView];
        [self.view bringSubviewToFront:_bottomView];
    }
}

- (void)loadDataToView {
    StaminaConfig *config = [StaminaConfig sharedConfig];
    _processView.progress = config.stamina/config.maxStamina;
    _staminaLabel.text = [NSString stringWithFormat:@"%ld/%d", (long)config.stamina,(int)config.maxStamina];
    
    _titleLabel.text = _chapModel.chapterJSONModel.titleChap;
    _pageLabel.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)_chapModel.chapterJSONModel.images.count];
}

#pragma mark - PageViewController data sources
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentPage = index;
    [self reloadBottomViewDataWithPageIndex:(index + 1)];
    if (index) {
        return [PhotoViewController photoViewControllerForPageIndex:(index - 1) imageName:_chapModel.chapterJSONModel.images[index - 1] andService:_chapterService];
    }else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentPage = index;
    [self reloadBottomViewDataWithPageIndex:(index + 1)];
    if (index < _chapModel.chapterJSONModel.images.count - 1) {
        return [PhotoViewController photoViewControllerForPageIndex:(index + 1) imageName:_chapModel.chapterJSONModel.images[index + 1] andService:_chapterService];
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    if (_isShowingBarView) {
        [self hiddenBarViews];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}
#pragma mark - Others
- (void)hiddenBarViews {
    _isShowingBarView = NO;
    _headerView.hidden = YES;
    _bottomView.hidden = YES;
}

- (void)showBarViews {
    _isShowingBarView = YES;
    _headerView.hidden = NO;
    _bottomView.hidden = NO;
}

- (void)showBarViews:(NSNotification *)notification {
    if (_isShowingBarView) {
        [self hiddenBarViews];
    }else {
        [self showBarViews];
    }
}

- (void)reloadBottomViewDataWithPageIndex:(NSInteger )pageIndex {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_processSlider setValue:pageIndex animated:NO];
        _pageLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)pageIndex, (unsigned long)_chapModel.chapterJSONModel.images.count];
    });
}

- (void)showStaminaExpired:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"体力がなくなりました"
                                                   delegate:self
                                          cancelButtonTitle:@"戻る"
                                          otherButtonTitles:@"全回復する", nil];
    alert.tag = kTagShowStamina;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)updateStaminaView:(NSNotification *)notification {
    StaminaConfig *config = [StaminaConfig sharedConfig];
    dispatch_async(dispatch_get_main_queue(), ^{
        _processView.progress = config.stamina/config.maxStamina;
        _staminaLabel.text = [NSString stringWithFormat:@"%ld/%d", (long)config.stamina,(int)config.maxStamina];
    });
}

#pragma mark - UIAlert View delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTagShowStamina) {
        if (buttonIndex == 1) {
            // Buy stamina on app store
        }else {
            // Back to Chapter List Screen
            [self onBackButton:nil];
        }
    }
}

#pragma mark - Button Function
- (IBAction)changePage:(id)sender {
    NSUInteger index = (NSUInteger)(_processSlider.value + 0.5);
    
    if (index > _currentPage + 1) {
        PhotoViewController *nextPage = [PhotoViewController photoViewControllerForPageIndex:(index - 1) imageName:_chapModel.chapterJSONModel.images[index - 1] andService:_chapterService];;
        [_pageViewController setViewControllers:@[nextPage]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    }else if (index < _currentPage + 1) {
        PhotoViewController *previousPage = [PhotoViewController photoViewControllerForPageIndex:(index - 1) imageName:_chapModel.chapterJSONModel.images[index - 1] andService:_chapterService];;
        [_pageViewController setViewControllers:@[previousPage]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
    }
    _currentPage = index - 1;
    [self reloadBottomViewDataWithPageIndex:index];
}

- (IBAction)onBackButton:(id)sender {
    [[StaminaConfig sharedConfig] saveData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
