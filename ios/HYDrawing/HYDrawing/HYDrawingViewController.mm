//
//  HYDrawingViewController.m
//  HYDrawing
//
//  Created by 李 雷川 on 15/7/16.
//  Copyright (c) 2015年 Founder. All rights reserved.
//

#import "HYDrawingViewController.h"
#import "HYBrushCore.h"
#import "BottomBarView.h"
#import "HYMenuViewController.h"
#import "DDPopoverBackgroundView.h"
#import "ImageEditViewController.h"
#import "Macro.h"
#import "WDColorPickerController.h"
#import "ZXHLayersViewController.h"
#import "CZViewImpl.h"

extern NSString *CZActivePaintColorDidChange;

@interface HYDrawingViewController ()<BottomBarViewDelegate,UIPopoverControllerDelegate,WDColorPickerControllerDelegate,
                                       CanvasViewDelegate > {
    UIPopoverController *popoverController_;
    BottomBarView *bottomBarView;
    ImageEditViewController *imageEditViewController;
    UIPopoverController *layersPopoverController;
}

@property (nonatomic,strong) WDColorPickerController* colorPickerController;
@end

@implementation HYDrawingViewController
{
    UIImage *_choosedImg;
    CGAffineTransform _transinfo;
}

// 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - Properties

- (WDColorPickerController*) colorPickerController {
    if (!_colorPickerController) {
        _colorPickerController = [[WDColorPickerController alloc] initWithNibName:@"ColorPicker" bundle:nil];
        _colorPickerController.delegate = self;
    }
    return _colorPickerController;
}

#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(tapMenu:)];
    
    self.navigationItem.leftBarButtonItems = @[menuItem];
    
    UIBarButtonItem *videoItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"video"] style:UIBarButtonItemStylePlain target:self action:@selector(tapMenu:)];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(tapMenu:)];
    UIBarButtonItem *pictureItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"picture"] style:UIBarButtonItemStylePlain target:self action:@selector(tapPicture:)];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(tapMenu:)];
    self.navigationItem.rightBarButtonItems = @[shareItem,pictureItem,settingItem,videoItem];
    
    
    // load brush core
    CGSize size = [UIScreen mainScreen].bounds.size;
    [[HYBrushCore sharedInstance]initializeWithWidth:size.width height:size.height];
    CanvasView *canvasView = [[HYBrushCore sharedInstance] getPaintingView];
    canvasView.delegate = self;
    [self.view insertSubview:canvasView atIndex:0];
    
    // bottom bar view
    bottomBarView = [[BottomBarView alloc]initWithWellColor:[[HYBrushCore sharedInstance]getActiveStatePaintColor]];
    bottomBarView.delegate = self;
    [self.view addSubview:bottomBarView];
    [self constrainSubview:bottomBarView toMatchWithSuperview:self.view];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(paintColorChanged:) name:CZActivePaintColorDidChange object:nil];
}

//-(BOOL)shouldAutorotate{
//    return YES;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return  UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//}

-(void)hiddenNavBar{
    self.navigationController.navigationBar.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    // 全透明背景
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
     self.navigationController.navigationBar.translucent = YES;
    // 去掉分割线
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapMenu:(id)sender{
    HYMenuViewController *menuViewController = [[HYMenuViewController alloc]init];
    UINavigationController *menuNavigationController = [[UINavigationController alloc]initWithRootViewController:menuViewController];
    menuNavigationController.navigationBar.barTintColor = UIPopoverBackgroundColor;
    menuNavigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIPopoverController *popoverController = [[UIPopoverController alloc]initWithContentViewController:menuNavigationController];

    popoverController.popoverBackgroundViewClass =[DDPopoverBackgroundView class];
    UIImage *image = [UIImage imageNamed:@"menu_popover_bg"];
    [DDPopoverBackgroundView setBackgroundImage:image];
    [DDPopoverBackgroundView setBackgroundImageCornerRadius:2.f];
    [DDPopoverBackgroundView setArrowBase:0];
    [DDPopoverBackgroundView setArrowHeight:2];
    [popoverController setPopoverContentSize:CGSizeMake(image.size.width, image.size.height-20)];
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

// 弹出相册图片选择
- (void)tapPicture:(id)sender{
    
    UIImagePickerController  *picker = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.sourceType = sourcheType;
    picker.delegate = self;
    UIPopoverController *popoverController = [[UIPopoverController alloc]initWithContentViewController:picker];
    popoverController.delegate = self;
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    if (iOS(8.0)) {
//        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//            [self presentViewController:picker animated:YES completion:nil];
//        }];
//    }
//    else{
//        [self presentViewController:picker animated:YES completion:nil];
//    }
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:nil
//                                  delegate:self
//                                  cancelButtonTitle:nil
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:@"拍照", @"从手机相册选取",nil];
//    [actionSheet showInView:self.view];
}


-(void)camera{
    
    UIImagePickerController  *picker = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourcheType =     UIImagePickerControllerSourceTypeCamera
;
    picker.sourceType = sourcheType;
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (iOS(8.0)) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
             [self presentViewController:picker animated:YES completion:nil];
        }];
    }
    else{
         [self presentViewController:picker animated:YES completion:nil];
    }
   
}
-(void)photoAlbum{
    UIImagePickerController  *picker = [[UIImagePickerController alloc]init];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.sourceType = sourcheType;
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (iOS(8.0)) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self presentViewController:picker animated:YES completion:nil];
        }];
    }
    else{
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - HYDrawingViewController Methods

- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    NSDictionary *metrics = @{@"vHeight":@(119),@"hPadding":@(11)};
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|-hPadding-[subview]-hPadding-|"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[subview(vHeight)]|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    [superview addConstraints:constraints];
    
    return constraints;
}

- (void) showColorPicker:(id)sender
{
    if ([self shouldDismissPopoverForClassController:[WDColorPickerController class] insideNavController:NO]) {
        [self hidePopovers];
        return;
    }
    
    [self showController:self.colorPickerController fromBarButtonItem:sender animated:NO];
}

- (void)showMessageView:(ShowingMessageType)msgType
{
    
}

- (void) paintColorChanged:(NSNotification *)aNotification
{
    WDColor *newPaintColor = [aNotification userInfo][@"pickedColor"];
    [self.colorPickerController setColor:newPaintColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - BottomBarViewDelegate Methods

- (void)bottomBarView:(BottomBarView*)bottomBarView forButtonAction:(UIButton*)button {
    switch (button.tag) {
        case COLORWHEEL_BTN:        ///< 调色板
            [self showColorPicker:button];
            break;
        case ERASER_BTN:
            [[HYBrushCore sharedInstance]activeEraser];
            break;
        case PENCIL_BTN:
            [[HYBrushCore sharedInstance]activePencil];
            break;
        case MARKERPEN_BTN:
            [[HYBrushCore sharedInstance]activeCrayon];
            break;
        case BUCKET_BTN:
            [[HYBrushCore sharedInstance]activeBucket];
            break;
        case EYEDROPPER_BTN:
            [[HYBrushCore sharedInstance]activeColorPicker];
            break;
        case LAYERS_BTN:
            [self showLayerPopoverController:button];
            break;
        default:
            break;
    }
}


#pragma mark 图层弹出视图
-(void)showLayerPopoverController:(UIButton*)sender{
//    NSLog(@"hello-----");
    ZXHLayersViewController *layersViewController = [ZXHLayersViewController new];
    
    layersPopoverController = [[UIPopoverController alloc]initWithContentViewController:layersViewController];
    layersPopoverController.popoverBackgroundViewClass =[DDPopoverBackgroundView class];
    [DDPopoverBackgroundView setContentInset:2];
    
    UIImage *image = [UIImage imageNamed:@"layers_popover_bg"];
    [DDPopoverBackgroundView setBackgroundImage:image];
    [DDPopoverBackgroundView setBackgroundImageCornerRadius:1.f];
    [DDPopoverBackgroundView setArrowBase:0];
    [DDPopoverBackgroundView setArrowHeight:2];
    [layersPopoverController setPopoverContentSize:CGSizeMake(image.size.width, image.size.height-30)];
    
    // 弹出位置
    CGRect popRect = sender.frame;
    popRect.origin.y -= 50;
    
    [layersPopoverController presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark - WDColorPickerControllerDelegate Methods
- (void) dismissViewController:(UIViewController *)viewController
{
    if (popoverController_) {
        [self hidePopovers];
    } else {
        [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) setActiveStateColor:(WDColor*)color from:(WDColorPickerController*) colorPickerController
{
    [[HYBrushCore sharedInstance] setActiveStateColor:[color UIColor]];
    bottomBarView.colorWheelButton.color = color;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self camera];
            break;
        case 1:
            [self photoAlbum];
            break;
            
        default:
            break;
    }
}

#pragma mark - 选择相册图片
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _choosedImg =info[@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        imageEditViewController = [[ImageEditViewController alloc]init];
        imageEditViewController.originalImg = _choosedImg;
        imageEditViewController.view.backgroundColor = [UIColor clearColor];\
        // 隐藏导航栏
        self.navigationController.navigationBar.hidden = YES;
        
        [self.view addSubview:imageEditViewController.view];
    }];
}



#pragma mark - Copied directly

- (BOOL) shouldDismissPopoverForClassController:(Class)controllerClass insideNavController:(BOOL)insideNav
{
    if (!popoverController_) {
        return NO;
    }
    
    if (insideNav && [popoverController_.contentViewController isKindOfClass:[UINavigationController class]]) {
        NSArray *viewControllers = [(UINavigationController *)popoverController_.contentViewController viewControllers];
        
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:controllerClass]) {
                return YES;
            }
        }
    } else if ([popoverController_.contentViewController isKindOfClass:controllerClass]) {
        return YES;
    }
    
    return NO;
}

- (void) showController:(UIViewController *)controller fromBarButtonItem:(UIBarButtonItem *)barButton animated:(BOOL)animated
{
    [self runPopoverWithController:controller from:barButton];
}

- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender
{
    [self hidePopovers];
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController_.delegate = self;
    
//    NSMutableArray *passthroughs = [NSMutableArray arrayWithObjects:self.topBar, self.bottomBar, nil];
//    if (self.isEditing) {
//        [passthroughs addObject:self.canvas];
//    }
//    popoverController_.passthroughViews = passthroughs;
//    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [popoverController_ presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    } else {
        [popoverController_ presentPopoverFromRect:CGRectInset(((UIView *) sender).bounds, 10, 10)
                                            inView:sender
                          permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown)
                                          animated:YES];
    }
    
    return popoverController_;
}

- (BOOL) popoverVisible
{
    return popoverController_ ? YES : NO;
}

- (void) hidePopovers
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:NO];
        popoverController_ = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == popoverController_) {
        popoverController_ = nil;
    }
}

@end