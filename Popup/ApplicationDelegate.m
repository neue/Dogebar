#import "ApplicationDelegate.h"
#import "NSString+URLEncoding.h"
#import "SBJson.h"

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

- (NSDictionary *)geocode:(NSString *)locationText
{
    NSString *escapedLocationText = [locationText urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *geoUrl = [NSString stringWithFormat:@"http://nominatim.openstreetmap.org/search?format=json&q=%@", escapedLocationText];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:geoUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *data = [parser objectWithString:json_string];
    
    NSNumber *lat;
    NSNumber *lon;
    if ([data count] > 0) {
        lat = [data[0] objectForKey:@"lat"];
        lon = [data[0] objectForKey:@"lon"];
    } else {
        return NULL;
    }
    return @{@"lat": lat, @"lon":lon};
}

- (NSDictionary *)getWeatherFor:(NSDictionary *)locationDict
{
    // DarkSky API key from https://developer.darkskyapp.com/
    NSString *apiKey = @"api_key";
    
    NSNumber *lat = [locationDict objectForKey:@"lat"];
    NSNumber *lon = [locationDict objectForKey:@"lon"];
    
    NSString *wxUrl = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%0.4f,%0.4f",
                       apiKey, [lat doubleValue], [lon doubleValue]];
    NSLog(@"WX URL: %@", wxUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wxUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    return [parser objectWithString:json_string];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    NSString *locationText = @"Evanston, IL";
    
    NSDictionary *loc = [self geocode:locationText];
    
    if (loc == NULL) {
        NSLog(@"Couldn't find %@", locationText);
        return;
    }
    
    NSDictionary *data = [self getWeatherFor:loc];
    
    NSDictionary *current = [data objectForKey:@"currently"];
    NSLog(@"%@ - %@F", [current objectForKey:@"summary"], [current objectForKey:@"temperature"]);
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
