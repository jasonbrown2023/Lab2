//
//  ViewController.m
//  AudioLabSwift
//
//  Created by jason brown on 02/07/1402 AP.
//  Copyright © 1402 AP Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface ViewController (){
    UIViewController *anotherView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad is running");
    
    anotherView = [UIViewController new];
    anotherView.view.backgroundColor = [UIColor redColor];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear is running");
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear is running");
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear is running");
}


-(void)viewDidDisappear:(BOOL)animated{
     NSLog(@"viewDidDisappear is running");
}


- (IBAction)onClickBtn:(id)sender {
    [self presentViewController:anotherView animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
