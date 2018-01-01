@interface LSResourceProxy : NSObject
- (NSDictionary *)iconsDictionary;
@end

@interface LSApplicationProxy : LSResourceProxy
@property (nonatomic, retain) NSString *applicationIdentifier;
@property (nonatomic, retain) NSString *localizedName;
+ (LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)identifier;
- (NSURL *)bundleURL;
- (id)_plistValueForKey:(NSString *)key;
- (BOOL)iconIsPrerendered;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *) defaultWorkspace;
- (NSArray *)allInstalledApplications; //7.0 and higher
@end
