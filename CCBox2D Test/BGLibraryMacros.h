//
//  Macros.h
//
//  Created by Lawrence Lomax on 17/09/2012.
//  Copyright (c) 2012 Bell George. All rights reserved.
//

// Thread Safe shared instance singleton macro
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
{\
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \
}

// Shared Instance declaration
#define SHARED_INSTANCE_HEADER(class) + (class) sharedInstance;
#define SHARED_INSTANCE_IMPLEMENTATION(class, sharedObjectBlock) \
+ (class) sharedInstance \
{ \
DEFINE_SHARED_INSTANCE_USING_BLOCK(sharedObjectBlock) \
}


// Weakself macro for use in blocks
#if __has_feature(objc_arc_weak)
#define BG_WEAK_TYPE(object) __weak __typeof__(object)
#define BG_WEAK_DECL(object, name) BG_WEAK_TYPE(object) name = object;
#define BG_WEAK_DECL_SUFFIX(object, suffix) BG_WEAK_DECL(object, suffix##_##object)
#define BG_WEAK(object) BG_WEAK_DECL_SUFFIX(object, weak)
#define BG_WEAKSELF BG_WEAK_DECL(self, weakSelf)
#define WEAKSELF_T BG_WEAK_TYPE(self)
#else
#define BG_WEAK_TYPE(object) __block __typeof__(object)
#define BG_WEAK_DECL(object, name) BG_WEAK_TYPE(object) name = object;
#define BG_WEAK_DECL_SUFFIX(object, suffix) BG_WEAK_DECL(object, suffix##_##object)
#define BG_WEAK(object) BG_WEAK_DECL_SUFFIX(object, weak)
#define BG_WEAKSELF BG_WEAK_DECL(self, weakSelf)
#define WEAKSELF_T BG_WEAK_TYPE(self)
#endif

// Helpers For Bitwise Enums
#define BGBitmaskOn(enum, mask) ( (enum & mask) == mask )
#define BGBitmaskOff(enum, mask) ( (enum & mask) != mask )

// Some Helpers for returning
#define BGIsNull(value) (value == nil || value == NULL || [value isEqual:[NSNull null]])

#define BGNotNull(value) (!(BGIsNull(value)))

#define BGReturnIfTrue(errorRef, errorString, condition) \
if((condition)) \
{ \
BGReturnWithErrorString(errorRef,errorString) \
}

#define BGReturnIfFalse(errorRef, errorString, condition) BGReturnIfTrue(errorRef, errorString, !(condition))

#define BGReturnIfNull(errorRef, value) BGReturnIfTrue(errorRef, ([NSString stringWithFormat:@"Error: Value %s is null", #value]), BGIsNull(value))

#define BGReturnIfNotNull(errorRef, value) BGReturnIfFalse(errorRef, ([NSString stringWithFormat:@"Error: Value  %s is not null", @"value"]), BGNotNull(value))

#define BGReturnWithErrorString(errorRef, errorString) BGReturnWithError(errorRef, (NSString *)nil, 0, errorString, (NSDictionary *)nil)

#define BGReturnWithError(vErrorRef, vErrorDomain, vErrorCode, vErrorString, vErrorUserInfo) \
{ \
[BGErrorUtilities defaultPopulateError:vErrorRef errorString:vErrorString domain:vErrorDomain errorCode:vErrorCode userInfo:vErrorUserInfo];  \
return NO; \
}

#define BGRaiseIfError(error) if(error) \
{ \
    [NSException raiseWithError:error];\
}

#define BGReturnMissingResource(errorRef, bundle, resourcePath) \
{ \
NSURL * url___ = [bundle URLForResource:resourcePath withExtension:nil]; \
NSError * error__ = nil; \
[url___ checkResourceIsReachableAndReturnError:&error__]; \
BGReturnIfNotNull(errorRef, error__) \
}

#define BGBlockCallSafe(block, blockCall) \
{ \
    if(BGNotNull(block)) \
    { \
        blockCall; \
    } \
}

// Helpers for Debug logging
#ifdef DEBUG
#define BGDebugLog(...) NSLog(__VA_ARGS__)
#define BGDebugLogInfo(fmt, ...) NSLog((@"%s %s [Line %d] " fmt), __FILE__, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define BGDebugLog(...) {}
#define BGDebugLogInfo(fmt, ...) {}
#endif

// Return early
#define BAIL_IF_TRUE(condition, bail) if(condition){ return bail; }
#define BAIL_IF_FALSE(condition, bail) if(!(condition)){ return bail; }

// Destroy macro
#define SAFE_RELEASE(object) {[object release]; object = nil;}