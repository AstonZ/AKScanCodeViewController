//
//  ViewController.m
//  AKScanCodeViewController
//
//  Created by Aston on 15/11/17.
//  Copyright © 2015年 Aston. All rights reserved.
//

#import "ViewController.h"

#import "AKScanCodeViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)actionGoScan:(id)sender {
    
#if TARGET_IPHONE_SIMULATOR
    DebugLog(@"Can not use simulator ~ ");
    
#elif TARGET_OS_IPHONE
    AKScanCodeViewController *scanVC = [[AKScanCodeViewController alloc] init];
    scanVC.blockEndScanWithText = ^(NSString *txt) {
        self.lbResult.text = txt;
    };
    [self.navigationController pushViewController:scanVC animated:YES];
    
#endif
    

    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
