
//#define POINTS_TO_METERS_RATIO 1.0f


#define GRAVITY 0.0f

#define DEBUG_DRAW 1

#define PTM_RATIO 1.0f

#define POINTS_TO_METERS(n) ((n) / (PTM_RATIO))
#define METERS_TO_POINTS(n) ((n) * (PTM_RATIO))

#define kZoomInFactor 1//0.25 // 0.5 zoom out by 2
#define kBoundsRatioToScreen 1 // eg. 2 make the bounds twice the size as screen

#define CGLog(x,a) NSLog(x, [NSValue valueWithCGPoint:a]);