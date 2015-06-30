//
//  ZCPhotoLibrary.m
//  TableViewDemo
//
//  Created by zuckchen on 6/29/15.
//  Copyright (c) 2015 zuckchen. All rights reserved.
//

#import "ZCPhotoLibrary.h"
#import <UIKit/UIKit.h>

@interface ZCPhotoLibrary ()

@property (nonatomic, assign) BOOL isDeletingPictures;
@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;

@end

@implementation ZCPhotoLibrary

+ (ZCPhotoLibrary*)sharedInstance
{
    static ZCPhotoLibrary* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZCPhotoLibrary alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isDeletingPictures = NO;
    }
    return self;
}

- (ALAssetsLibrary*)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    }
    return _assetsLibrary;
}

- (void)saveImageDatas:(NSArray*)imageDatas toAlbum:(NSString*)album withCompletionBlock:(void(^)(NSError *error))block
{
    if (imageDatas.count == 0) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            NSMutableArray* assets = [[NSMutableArray alloc]init];
            for (NSData* data in imageDatas) {
                @autoreleasepool {
                    UIImage *image = [UIImage imageWithData:data];
                    PHAssetChangeRequest* assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    [assets addObject:assetRequest.placeholderForCreatedAsset];
                }
            }
            
            // save to custom album
            if (assets.count > 0 && album.length > 0) {
                __block PHAssetCollectionChangeRequest* assetCollectionRequest = nil;
                PHFetchResult* result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PHAssetCollection* collection = (PHAssetCollection*)obj;
                    if ([collection isKindOfClass:[PHAssetCollection class]]) {
                        if ([[collection localizedTitle] isEqualToString:album]) {
                            assetCollectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                            [assetCollectionRequest addAssets:assets];
                            *stop = YES;
                        }
                    }
                }];
                if (assetCollectionRequest == nil) {
                    assetCollectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
                    [assetCollectionRequest addAssets:assets];
                }
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (block) {
                block(error);
            }
        }];
    }
    else {
        for (NSData* data in imageDatas) {
            __weak ALAssetsLibrary* lib = [self assetsLibrary];
            [[self assetsLibrary] writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL* assetURL, NSError* error) {
                if (error != nil) {
                    return;
                }
                
                // save to custom album
                __block BOOL albumWasFound = NO;
                [lib enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup* group, BOOL* stop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:album]) {
                        albumWasFound = YES;
                        [lib assetForURL:assetURL resultBlock:^(ALAsset* asset){
                            [group addAsset:asset];
                            if (block) {
                                block(nil);
                            }
                        }failureBlock:^(NSError* error) {
                            if (block) {
                                block(error);
                            }
                        }];
                        return;
                    }
                    if (group == nil && albumWasFound == NO) {
                        [lib addAssetsGroupAlbumWithName:album resultBlock:^(ALAssetsGroup* group) {
                        } failureBlock:^(NSError* error) {
                            [lib assetForURL:assetURL resultBlock:^(ALAsset* asset){
                                [group addAsset:asset];
                                if (block) {
                                    block(nil);
                                }
                            }failureBlock:^(NSError* error) {
                                if (block) {
                                    block(error);
                                }
                            }];
                        }];
                    }
                } failureBlock:^(NSError* error) {
                    if (block) {
                        block(error);
                    }
                }];
            }];
        }
    }
}

- (void)deleteAssets:(NSArray*)assets withCompletionBlock:(void(^)(NSError *error))block
{
    _isDeletingPictures = YES;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:assets];
    [self deleteAssetsEnumeration:array withCompletionBlock:block];
}

- (void)deleteAssetsEnumeration:(NSMutableArray*)assets withCompletionBlock:(void(^)(NSError *error))block
{
    if (assets.count > 0) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            NSMutableArray* assetURLs = [NSMutableArray array];
            for (ALAsset *asset in assets) {
                id property = [asset valueForProperty:ALAssetPropertyAssetURL];
                if (property) {
                    [assetURLs addObject:property];
                }
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHFetchResult * fecthResult = [PHAsset fetchAssetsWithALAssetURLs:assetURLs options:nil];
                [PHAssetChangeRequest deleteAssets:fecthResult];
            } completionHandler:^(BOOL success, NSError *error) {
                if (block) {
                    block(error);
                }
                _isDeletingPictures = NO;
            }];
        }
        else {
            __weak ALAsset *asset = [assets objectAtIndex:0];
            [asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    if (block) {
                        block(error);
                    }
                    return;
                }
                [assets removeObject:asset];
                [self deleteAssetsEnumeration:assets withCompletionBlock:block];
            }];
        }
    } else {
        _isDeletingPictures = NO;
        if (block) {
            block(nil);
        }
    }
}

- (void)enumerateAssetsWithGroupType:(ALAssetsGroupType)type usingBlock:(ZCPhotoLibraryEnumerationResultsBlock)block failureBlock:(void(^)(NSError *error))failureBlock
{
    [[self assetsLibrary] enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop1) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop2) {
            block(group, stop1, result, index, stop2);
        }];
    } failureBlock:^(NSError* error){
        failureBlock(error);
    }];
}
         
@end
