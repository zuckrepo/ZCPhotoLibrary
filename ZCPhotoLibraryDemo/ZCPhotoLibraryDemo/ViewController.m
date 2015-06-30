//
//  ViewController.m
//  ZCPhotoLibraryDemo
//
//  Created by zuckchen on 6/29/15.
//  Copyright (c) 2015 zuckchen. All rights reserved.
//

#import "ViewController.h"
#import "ZCPhotoLibrary.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton* saveImgBtn;
@property (nonatomic, strong) UIButton* deleteImgBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _saveImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImgBtn.frame = CGRectMake(0, 150, self.view.frame.size.width, 50);
    [_saveImgBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_saveImgBtn setTitle:@"Save Images of Photos App" forState:UIControlStateNormal];
    [_saveImgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveImgBtn setBackgroundColor:[UIColor greenColor]];
    [_saveImgBtn addTarget:self action:@selector(onSaveImagesBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveImgBtn];
    
    _deleteImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteImgBtn.frame = CGRectMake(0, 250, self.view.frame.size.width, 50);
    [_deleteImgBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_deleteImgBtn setTitle:@"Delete Images of Photos App" forState:UIControlStateNormal];
    [_deleteImgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_deleteImgBtn setBackgroundColor:[UIColor redColor]];
    [_deleteImgBtn addTarget:self action:@selector(onDeleteImagesBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteImgBtn];
}

- (void)onSaveImagesBtnAction:(id)sender
{
    NSArray* urls = [NSArray arrayWithObjects:
                     @"http://a.hiphotos.baidu.com/image/pic/item/3c6d55fbb2fb43166d8f7bc823a4462308f7d3eb.jpg",
//                     @"http://f.hiphotos.baidu.com/image/pic/item/0e2442a7d933c895a4d3df3cd21373f0830200c3.jpg",
//                     @"http://c.hiphotos.baidu.com/image/pic/item/08f790529822720ec663a5bd78cb0a46f31fabcc.jpg",
//                     @"http://b.hiphotos.baidu.com/image/pic/item/77c6a7efce1b9d16e45ddd26f0deb48f8d5464da.jpg",
                     nil];
    NSMutableArray* array = [NSMutableArray array];
    for (NSString* url in urls) {
        NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLResponse* res = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
        [array addObject:data];
    }
    
    [[ZCPhotoLibrary sharedInstance]saveImageDatas:array toAlbum:@"ZCPhotoLibraryDemo" withCompletionBlock:^(NSError* error){
        if (error) {
            [self showAlertViewWithMessage:error.description];
        }
        else {
            [self showAlertViewWithMessage:@"save successfully!"];
        }
    }];
}

- (void)onDeleteImagesBtnAction:(id)sender
{
    __block BOOL isFound = NO;
    [[ZCPhotoLibrary sharedInstance]enumerateAssetsWithGroupType:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *groupStop, ALAsset *asset, NSUInteger index, BOOL *assetStop) {
        if (asset) {
            if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
                isFound = YES;
                *assetStop = YES;
                *groupStop = YES;
                [[ZCPhotoLibrary sharedInstance]deleteAssets:@[asset] withCompletionBlock:^(NSError* error) {
                    if (error) {
                        [self showAlertViewWithMessage:error.description];
                    }
                    else {
                        [self showAlertViewWithMessage:@"delete successfully!"];
                    }
                }];
            }
        }
        else {
            if (isFound == NO) {
                [self showAlertViewWithMessage:@"no asset found!"];
            }
        }
    } failureBlock:^(NSError *error) {
        [self showAlertViewWithMessage:error.description];
    }];
}

- (void)showAlertViewWithMessage:(NSString*)message
{
    void (^showBlock)() = ^(){
        UIAlertView* view = [[UIAlertView alloc]initWithTitle:@"ZCPhotoLibraryDemo" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    };
    if ([NSThread isMainThread]) {
        showBlock();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            showBlock();
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
