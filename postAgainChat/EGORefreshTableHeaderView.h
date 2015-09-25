//
//  EGORefreshTableHeaderView.h
//  postAgainChat

#import <UIKit/UIKit.h>

@protocol EGORefreshTableHeaderDelegate;
//@end

typedef enum{
    EGOOPullRefreshPulling = 0,
    EGOOPullRefreshNormal,
    EGOOPullRefreshLoading,
} EGOPullRefreshState;

@interface EGORefreshTableHeaderView : UIView {
    
    id <EGORefreshTableHeaderDelegate> _delegate;
    EGOPullRefreshState _state;
    
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic,strong) id <EGORefreshTableHeaderDelegate> delegate;
@property (nonatomic, retain, readonly) UILabel *lastUpdatedLabel;
@property (nonatomic, retain, readonly) UILabel *statusLabel;
@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityView;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol EGORefreshTableHeaderDelegate<NSObject>
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;
@end


