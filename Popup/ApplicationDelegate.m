#import "ApplicationDelegate.h"
#import "NSString+URLEncoding.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate


- (NSString *)getBalance
{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *suchWallet = [prefs stringForKey:@"dogecoinwallet"];

    //NSNumber *lat = [locationDict objectForKey:@"lat"];
    //NSNumber *lon = [locationDict objectForKey:@"lon"];
    
  //  NSString *wxUrl = [NSString stringWithFormat:@"http://dogechain.info//chain/Dogecoin/q/addressbalance/DQhNvZwXb1ttS9fkVC3MvxGcrxsthNd5Vi"];
    NSString *wxUrl = [NSString stringWithFormat:@"http://dogechain.info//chain/Dogecoin/q/addressbalance/%@",suchWallet];
    NSLog(@"WX URL: %@", wxUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wxUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *currentDoge = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"doge: %@", currentDoge);
//    SBJsonParser *parser = [[SBJsonParser alloc] init];

    NSScanner *ns = [NSScanner scannerWithString:currentDoge];
    float the_value;
    if ( [ns scanFloat:&the_value] ){
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setUsesSignificantDigits: TRUE];
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:2];
        
        
        
        
        return [formatter stringFromNumber:[NSNumber numberWithInteger:[currentDoge integerValue]]];
    } else {
        NSLog(@"ERROR");
        return NULL;
    }

    
    
   // } else {
   //     NSLog(@"ERROR");

        return NULL;
   // }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                        target:self
                                                      selector:@selector(updateBalance:)
                                                      userInfo:nil
                                                       repeats:YES];
    
    [self updateBalance:nil];
}

- (void)updateBalance:(NSTimer*)theTimer
{
    NSLog(@"Time tick");
    
    NSString *data = [self getBalance];
    
//    NSDictionary *current = [data objectForKey:@"currently"];
//    NSLog(@"%@ - %@F", [current objectForKey:@"summary"], [current objectForKey:@"temperature"]);
    
//    _menubarController.statusItemView.text = [NSString stringWithFormat:@"%@°F", [current objectForKey:@"temperature"]];
    
    if (data != NULL) {
        _menubarController.statusItemView.text = [NSString stringWithFormat:@"%@", data];
        _menubarController.statusItemView.opacity = 1;
    } else {
        _menubarController.statusItemView.text = [NSString stringWithFormat:@""];
        _menubarController.statusItemView.opacity = 0.5;
    }
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
