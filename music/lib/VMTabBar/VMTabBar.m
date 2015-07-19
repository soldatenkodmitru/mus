//
//  VMTabBar.m
//  VMTabbarCustomize
//
//  Created by Vu Mai on 4/21/15.
//  Copyright (c) 2015 VuMai. All rights reserved.
//

#import "VMTabBar.h"
@interface VMTabBar()

@property (nonatomic) NSMutableArray *listOfItemTabbar;
@property (nonatomic) NSMutableArray *listOfItemImageTabbar;
@property (nonatomic) NSMutableArray *listOfTextTabbar;
@property (nonatomic) NSMutableArray *listOfTextItemTabbar;
@property (nonatomic) NSMutableArray *listOfView;
@property (nonatomic) NSMutableArray *listOfCenterOriginIcon;
@property (nonatomic) NSMutableArray *listOfCenterOriginText;
@property (nonatomic) UIFont *fontTabBar;
@property (nonatomic) BOOL setSize;
@end

@implementation VMTabBar


-(void)addListOfItemImage:(NSMutableArray*)arr
{
    self.listOfItemImageTabbar = [NSMutableArray arrayWithArray:arr];
}

-(void)addListOfItemText:(NSMutableArray*)arr
{
    self.listOfTextTabbar = [NSMutableArray arrayWithArray:arr];
}

-(void)addListOfViewWhenClickTabbar:(NSMutableArray*)arr
{
    self.listOfView = [NSMutableArray arrayWithArray:arr];
}

-(void)setFontTabBar:(UIFont*)font
{
    self.fontTabBar = font;
}


- (void)layoutSubviews {
    NSInteger count = [self.listOfItemTabbar count];
    if (!self.setSize){
    for (int i = 0 ; i < count ; i++){
        CGPoint ct = CGPointMake(((self.frame.size.width/count) * (i+1) - self.frame.size.width/(count*2)   ),24);
        UIImageView *circle =  [self.listOfItemTabbar objectAtIndex:i];
        circle.center = ct;
        [self.listOfCenterOriginIcon replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:ct] ];
        CGPoint ctLb = CGPointMake(circle.center.x, circle.center.y + circle.bounds.size.height/2 + 8);
        UILabel *lb = [self.listOfTextItemTabbar objectAtIndex:i];
        [lb setCenter:ctLb];

        [self.listOfCenterOriginText replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:ctLb]];
    }
        self.setSize =YES;
    }
}


-(void)iconTabBarWithNumber:(NSInteger)num
{
  //  [self initScrollViewWithNumOfView:num];
    self.listOfItemTabbar = [NSMutableArray arrayWithCapacity:num];
    self.listOfTextItemTabbar = [NSMutableArray arrayWithCapacity:num];
    self.listOfCenterOriginIcon = [NSMutableArray arrayWithCapacity:num];
    self.listOfCenterOriginText = [NSMutableArray arrayWithCapacity:num];
    
    for (NSInteger i = 0; i < num; i++)
    {
        
        UIImageView *circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        NSLog(@"%f",self.frame.size.width);
        CGPoint ct = CGPointMake(((self.frame.size.width/num) * (i+1) - self.frame.size.width/(num*2)   ),22);
        circle.center = ct;
        [circle setImage:[UIImage imageNamed:[self.listOfItemImageTabbar objectAtIndex:i]]];
        [circle setTag:i+1];
        UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTab:)];
        [circle addGestureRecognizer:pan];
        [circle setUserInteractionEnabled:YES];
        [self addSubview:circle];
        [self.listOfItemTabbar addObject:circle];
        [self.listOfCenterOriginIcon addObject:[NSValue valueWithCGPoint:ct]];
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 80, 20)];
        [lb setTextColor:[UIColor colorWithRed:41/255.0f green:128/255.0f blue:185/255.0f alpha:1]];
        [lb setFont:[UIFont fontWithName:@"laCartoonerie" size:12.0]];
        [lb setText:[self.listOfTextTabbar objectAtIndex:i]];
        [lb setTag:i+10];
        CGPoint ctLb = CGPointMake(circle.center.x, circle.center.y + circle.bounds.size.height/2 + 8);
        [lb setCenter:ctLb];
        [lb setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:lb];
        [self.listOfTextItemTabbar addObject:lb];
        [self.listOfCenterOriginText addObject:[NSValue valueWithCGPoint:ctLb]];
    }
}

#pragma mark - Function progress

-(void)selectTabBarValueWithTag:(NSInteger)tag
{
    for (NSInteger i = 0; i<self.listOfItemTabbar.count; i++) {
        UIImageView *imgTab = (UIImageView*)[self.listOfItemTabbar objectAtIndex:i];
        
        if (imgTab.tag == tag) {
            [self animationTabbarWithTab:imgTab];
            [self.delegate VMTabBar:self switchTabWithTag:imgTab.tag];
        }
    }
}

-(void)centerReturnWhenClickTabWithTag:(NSInteger)tag
{
    for (NSInteger i = 0; i < 4; i++) {
        
        UIImageView *imgTab = (UIImageView*)[self.listOfItemTabbar objectAtIndex:i];
        UILabel *lb = [self.listOfTextItemTabbar objectAtIndex:i];
        
        if (imgTab.tag == tag) {
            continue;
        }
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             imgTab.transform = CGAffineTransformMakeScale(1, 1);
                             imgTab.center = [[self.listOfCenterOriginIcon objectAtIndex:i] CGPointValue];
                         } completion:^(BOOL finished) {
                             
                         }];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             lb.center = [[self.listOfCenterOriginText objectAtIndex:i] CGPointValue];
                         } completion:^(BOOL finished) {
                             
                         }];
        [imgTab setUserInteractionEnabled:YES];
    }
    
    
    
}

-(void)animationTabbarWithTab:(UIView *)tabView
{
    for (UIView *vi in self.listOfItemTabbar) {
        if (vi.tag == tabView.tag) {
            
            UILabel *lb = [self.listOfTextItemTabbar objectAtIndex:vi.tag - 1];
            
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn animations:^{
                                    vi.center = CGPointMake(vi.center.x, vi.center.y + 5);
                                    vi.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                } completion:^(BOOL finished) {
//                                    NSLog(@"%f,%f",vi.frame.size.height,vi.frame.size.width);
                                }];
            
            
            [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                lb.center = CGPointMake(lb.center.x, lb.center.y - 80);
                lb.transform = CGAffineTransformMakeScale(3, 3);
                lb.alpha = 0;
            } completion:^(BOOL finished) {
                CGPoint centerLb = [[self.listOfCenterOriginText objectAtIndex:vi.tag - 1] CGPointValue];
                lb.center = CGPointMake(centerLb.x, centerLb.y + 50);
                lb.transform = CGAffineTransformMakeScale(1, 1);
                lb.alpha = 1;
                
                [self centerReturnWhenClickTabWithTag:vi.tag];
            }];
            
        }
    }
}

-(void)changeColorTabbarWithColor:(UIColor*)color
{
    for (UIImageView *img in self.listOfItemTabbar) {
      //  img.image = [img.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //[img setTintColor:color];
       // img.layer.zPosition = 1;
    }
    
    for (UILabel *lb in self.listOfTextItemTabbar) {
        [lb setTextColor:color];
       // lb.layer.zPosition = 1;

    }
    }


#pragma mark - Gesture
-(void)clickTab:(UITapGestureRecognizer*)sender
{
    UIView *tabView = (UIView*)sender.view;
    [self animationTabbarWithTab:tabView];
   // [self.scrollView setContentOffset:CGPointMake(0, CGRectGetHeight(self.bounds)*(tabView.tag-1)) animated:NO];
    [tabView setUserInteractionEnabled:NO];
    [self.delegate VMTabBar:self switchTabWithTag:tabView.tag-1 ];
    
}



@end
