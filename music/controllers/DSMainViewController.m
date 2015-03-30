//
//  ViewController.m
//  music
//
//  Created by dima on 3/7/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSVersionsTableViewController.h"
#import "DSMainViewController.h"
#import "DSMainTableViewCell.h"
#import "DSCategoryTableViewCell.h"
#import "DSRateView.h"
#import "NFXIntroViewController.h"


@interface DSMainViewController () <DSRateViewDelegate>

@property (strong, nonatomic) PFRelation* relation;
@property (strong, nonatomic) NSArray* musicObjects;
@property (strong, nonatomic) NSArray* categories;
@property (assign, nonatomic) NSInteger activeItem;
@property (assign, nonatomic) NSInteger playItem;
@property (strong, nonatomic) NSTimer* playTimer;
@property (assign, nonatomic) NSInteger selectedRow;
@property (assign, nonatomic) NSInteger selectedTab;
@property (strong, nonatomic) NSString* selectCategory;
@property (strong, nonatomic) UIBarButtonItem* navBarItem;

@end

@implementation DSMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    
    UIImage *btnImg2 = [UIImage imageNamed:@"button_back.png"];
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0.f, 0.f, btnImg2.size.width, btnImg2.size.height);
    [btn2 setImage:btnImg2 forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.navigationItem.leftBarButtonItem = item2;
    
    
    
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
    self.selectedRow = -1;
    
    [self loadDataForSortType:@"top"];
    [DSSoundManager sharedManager].delegate = self;
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    
    
}
  
- (void)viewWillDisappear:(BOOL)animated
{
    [DSSoundManager sharedManager].delegate = nil;
    [self.playTimer invalidate];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UITableViewDataSource


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedTab == 2 && self.selectCategory == nil){
        return  [ self.categories count];
    } else {
        return  [self.musicObjects count];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainTableIdentifier = @"mainCell";
    static NSString *categoryIdentifier = @"category";
    
    if (self.selectedTab ==2 && self.selectCategory == nil){
    
       DSCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryIdentifier];
        if (cell == nil) {
            cell = [[DSCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
            
        }
       NSString* object = [self.categories objectAtIndex:indexPath.row];
        cell.categoryLabel.text = object  ;
        return cell;
    }else{
   DSMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableIdentifier];
    if (cell == nil) {
        cell = [[DSMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableIdentifier];
    }
    
    PFObject* object = [self.musicObjects objectAtIndex:indexPath.row];
    
    cell.rateView.delegate = self;
    cell.rateView.editable = YES;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"heart_empty@2x.png"];
    cell.rateView.halfSelectedImage =  [UIImage imageNamed:@"heart_half@2x.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"heart_full@2x.png"];
    cell.rateView.maxRating = 5;
    cell.rateView.rating = [ [object objectForKey:@"rate"] floatValue];
    if (self.selectedRow != indexPath.row) {
        [cell.rateView setHidden:YES];
    }
    cell.artistLabel.text = [object objectForKey:@"author"];
    cell.titleLabel.text = [object objectForKey:@"name"];
    cell.downloadBtn.tag = indexPath.row;
    [cell.downloadBtn addTarget:self action:@selector(downloadClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    
    
    cell.uaprogressBtn.fillOnTouch = YES;
    cell.uaprogressBtn.tintColor = [UIColor whiteColor];
    cell.uaprogressBtn.borderWidth = 2.0;
     cell.uaprogressBtn.lineWidth = 2.0;
    
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
    [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
    cell.uaprogressBtn.centralView = triangle;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48.0, 18.0)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = cell.uaprogressBtn.tintColor;
    label.backgroundColor = [UIColor clearColor];



    cell.uaprogressBtn.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
        if ([progressView.centralView isKindOfClass:[UILabel class]]){
            if (progress == 0) progress = 0.01;
            [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
        }
    };
    
    cell.uaprogressBtn.fillChangedBlock = ^(UAProgressView *progressView, BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor greenColor] : progressView.tintColor);
        progressView.centralView =label;
            if (animated) {
                [UIView animateWithDuration:0.3 animations:^{
                    [(UILabel *)progressView.centralView setTextColor:color];
                }];
            } else {
                [(UILabel *)progressView.centralView setTextColor:color];
            }
        
    };
    
    
    cell.uaprogressBtn.didSelectBlock = ^(UAProgressView *progressView){
        
        if (indexPath.row == self.playItem && [[DSSoundManager sharedManager] isPlaying]) {
            
            [[DSSoundManager sharedManager] pause];
        }
        else
            [self downloadAndPlay:indexPath.row forView:progressView];
        
    };
    
    cell.versionBtn.hidden = YES;
    
    return cell;
    }
}


#pragma marm - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    DSVersionsTableViewController* vc = [segue destinationViewController];
    vc.childrens = self.relation;
   
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.selectCategory != nil){
    
        PFObject *object = [self.musicObjects objectAtIndex:indexPath.row];
        self.relation = [object relationForKey:@"versions"];
        
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectedTab == 2 && self.selectCategory == nil){
        return 50;
    } else {
        if (self.selectedRow == indexPath.row){
        
            return 120;
        }
        else {
        
            return 80;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    if (self.selectedTab == 2  && self.selectCategory == nil){
        DSCategoryTableViewCell* cell =( DSCategoryTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
        self.selectCategory  = cell.categoryLabel.text;
        self.selectedRow = -1;
        [self loadCategory:self.selectCategory];

    } else {
        DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.rateView setHidden:NO];
        NSMutableArray *modifiedRows = [NSMutableArray array];
        [modifiedRows addObject:indexPath];
        [tableView reloadRowsAtIndexPaths:modifiedRows withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Self Methods

- (void) downloadClicked:(id)sender {
    
    UIButton* btn = sender;
    PFObject *object = [self.musicObjects objectAtIndex:btn.tag];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        if (!error) {
            NSLog(@"%@",soundFile.name);
        }
    }
    progressBlock:^(int percentDone) {
        
        NSLog(@"%d", percentDone);
        
    }];
}

- (void) downloadAndPlay:(NSUInteger) row forView:(UAProgressView*) progressView {
    
    self.activeItem = row;
    PFObject *object = [self.musicObjects objectAtIndex:row];
    PFFile *soundFile = object[@"mfile"];
    [soundFile getDataInBackgroundWithBlock:^(NSData *soundData, NSError *error) {
        
        if(self.playItem!=self.activeItem ) {
            NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
            DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
            
            UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
            [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
            cell.uaprogressBtn.centralView = triangle;
            [cell.uaprogressBtn setProgress:0];
        }
        
        if (!error) {
        
            self.playItem = row;
            [[DSSoundManager sharedManager] playSong:soundData];
            
        }
        
    }
    progressBlock:^(int percentDone) {
        dispatch_async(dispatch_get_main_queue(), ^{
                                   
                    [progressView setProgress: (float) percentDone/100];
        });
    }];
}
- (void) loadCategory:(NSString*) category {
    self.navigationItem.title = category;
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
    [query whereKey:@"ganre" equalTo:category];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = objects;
            
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void) loadCategories {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
    [query selectKeys:@[@"ganre"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (!error) {
             self.categories = [objects valueForKeyPath:@"@distinctUnionOfObjects.ganre"];
             [self.tableView reloadData];
         } else {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
}   ];
}
- (void) loadDataForSortType:(NSString*) key{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Music"];
    if ([key isEqualToString:@"top"]){
        [query orderByDescending:@"rate"];
    }
    if ([key isEqualToString:@"new"]){
        [query orderByDescending:@"createdAt"];
        
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.musicObjects = objects;
        
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) showInstruction {
    
    UIImage*i1 = [UIImage imageNamed:@"1.png"];
    UIImage*i2 = [UIImage imageNamed:@"2.png"];
    UIImage*i3 = [UIImage imageNamed:@"3.png"];
    UIImage*i4 = [UIImage imageNamed:@"4.png"];
    UIImage*i5 = [UIImage imageNamed:@"5.png"];
    UIImage*i6 = [UIImage imageNamed:@"6.png"];
    UIImage*i7 = [UIImage imageNamed:@"7.png"];
    UIImage*i8 = [UIImage imageNamed:@"8.png"];
    UIImage*i9 = [UIImage imageNamed:@"9.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3,i4,i5,i2,i6,i7,i8,i9]];
    [self presentViewController:vc animated:true completion:nil];
    
}

#pragma mark - DSSoundManagerDelegate
- (void) statusChanged:(BOOL) playStatus {
   NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
    DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
   
    if (playStatus == YES){
        UIImageView *square = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [square setImage:[UIImage imageNamed: @"square.png"] ];
        cell.uaprogressBtn.centralView = square;
    }
    else{
        
        UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
        [triangle setImage:[UIImage imageNamed: @"triangle.png"] ];
        cell.uaprogressBtn.centralView = triangle;

    }
}

#pragma mark - Timer
- (void) timerAction:(id)timer{

    if( [[DSSoundManager sharedManager] isPlaying]) {
        NSIndexPath* activeRow = [NSIndexPath indexPathForRow:self.playItem inSection:0];
        DSMainTableViewCell* cell =( DSMainTableViewCell*)  [self.tableView cellForRowAtIndexPath:activeRow];
   
        [cell.uaprogressBtn setProgress:[DSSoundManager sharedManager].getCurrentProgress];
   
    }
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    self.selectedTab = tabBar.selectedItem.tag;
    self.selectedRow = -1;
    switch (tabBar.selectedItem.tag) {
            
        case 0:{
            self.navigationItem.title = @"Тop";
            [self loadDataForSortType:@"top"];
            break;
        }
         
        case 1:{
            self.navigationItem.title = @"New";
            [self loadDataForSortType:@"new"];
            break;
        }
            
        case 2:{
            self.navigationItem.title = @"Categories";
            [self loadCategories];
            break;
        }
            
        case 3:{
            self.navigationItem.title = @"Downloads";
            break;
        }
        
        
    }
    
}

#pragma mark - DSRateViewDelegate

- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    
    
}

@end