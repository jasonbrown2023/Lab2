//
//  ViewController.h
//  AudioLabSwift
//
//  Created by jason brown on 02/07/1402 AP.
//  Copyright © 1402 AP Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
class ViewController{
    @interface ViewController : NSObject
    
    +(ViewController*)sharedInstance;
    
    - (void)viewDidLoad();
    
    -(void)viewWillAppear:(BOOL)animated;
    
    -(void)viewDidAppear:(BOOL)animated;
    
    -(void)viewWillDisappear:(BOOL)animated;
    
    
    -(void)viewDidDisappear:(BOOL)animated;
    
    
    - (IBAction)onClickBtn:(id)sender;
    
    
    - (void)didReceiveMemoryWarning;
    
}
@end
NS_ASSUME_NONNULL_END
