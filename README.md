## ZCPhotoLibrary

A very simple and convenient utility class to operate assets in System Photos Library.

## Usage

**1. Get Instance of ZCPhotoLibrary Class:**

        ZCPhotoLibrary* library = [ZCPhotoLibrary sharedInstance];

**2. Enumerate Assets in System Photos Library:**  

        [library enumerateAssetsWithGroupType:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *groupStop, ALAsset *asset, NSUInteger index, BOOL *assetStop) {
        
        } failureBlock:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];

**3. Save Multi Image Datas to System Photos Library:**  

        // imageDatas is NSData array
        [library saveImageDatas:imageDatas toAlbum:@"ZCPhotoLibraryDemo" withCompletionBlock:^(NSError* error){
            if (error) {
                NSLog(@"%@", error.description);
            }
            else {
                NSLog(@"save successfully!");
            }
        }];

**4. Delete Multi Assets in System Photos Library:**  

        // assets is ALAsset array
        [library deleteAssets:assets withCompletionBlock:^(NSError* error) {
            if (error) {
                NSLog(@"%@", error.description);
            }
            else {
                NSLog(@"delete successfully!");
            }
        }];

