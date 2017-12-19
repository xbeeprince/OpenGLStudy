//
//  ViewController.m
//  OpenGLStudy
//
//  Created by prince on 2017/12/18.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "OpenGLViewController.h"
#import "OpenGlRenderView.h"

@interface OpenGLViewController ()<UINavigationControllerDelegate>
@property(nonatomic,strong)OpenGlRenderView *renderView;
@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"OpenGl";
    self.navigationController.delegate = self;
    
    _renderView = [[OpenGlRenderView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_renderView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (void)dealloc {
    self.navigationController.delegate = nil;
}
@end
