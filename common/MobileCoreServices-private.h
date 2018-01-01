@interface LSResourceProxy : NSObject
@property (nonatomic,readonly) NSDictionary *iconsDictionary;
@end

@interface LSApplicationProxy : LSResourceProxy
@property (nonatomic, retain) NSString *applicationIdentifier;
@property (nonatomic, retain) NSString *localizedName;
@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) BOOL iconIsPrerendered;

+ (LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)identifier;

- (id)_plistValueForKey:(NSString *)key;

@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *) defaultWorkspace;
- (NSArray *)allInstalledApplications; //7.0 and higher
@end
