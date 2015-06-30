//
//  ZCPhotoLibrary.h
//  TableViewDemo
//
//  Created by zuckchen on 6/29/15.
//  Copyright (c) 2015 zuckchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <Photos/PHAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ZCPhotoLibraryEnumerationResultsBlock)(ALAssetsGroup *group, BOOL *groupStop, ALAsset *asset, NSUInteger index, BOOL *assetStop);

@interface ZCPhotoLibrary : NSObject

+ (ZCPhotoLibrary*)sharedInstance;

/**
 *  save multi image datas to specified album
 *
 *  @param imageDatas NSData class array
 *  @param album      album title
 *  @param block      result block
 */
- (void)saveImageDatas:(NSArray*)imageDatas toAlbum:(NSString*)album withCompletionBlock:(void(^)(NSError *error))block;

/**
 *  delete multi assets from Photos App
 *
 *  @param assets ALAsset class array
 *  @param block  result block
 */
- (void)deleteAssets:(NSArray*)assets withCompletionBlock:(void(^)(NSError *error))block;

/**
 *  enumerate assets with ALAssetsGroupType and process in block
 *
 *  @param type         ALAssetsGroupType
 *  @param block        process block
 *  @param failureBlock failure process block
 */
- (void)enumerateAssetsWithGroupType:(ALAssetsGroupType)type usingBlock:(ZCPhotoLibraryEnumerationResultsBlock)block failureBlock:(void(^)(NSError *error))failureBlock;

@end
