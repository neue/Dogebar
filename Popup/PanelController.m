#import "ApplicationDelegate.h"
#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 380
#define PANEL_WIDTH 314
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize walletAddress = _walletAddress;
@synthesize aboutText = _aboutText;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.textField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *savedWalletAddress = [prefs stringForKey:@"dogecoinwallet"];

    NSLog(@"add:%@",savedWalletAddress);
    
    if(savedWalletAddress == NULL){ savedWalletAddress = @""; }
    
    
    [_walletAddress setStringValue: savedWalletAddress];

    NSBundle * myMainBundle = [NSBundle mainBundle];
    NSString * rtfFilePath = [myMainBundle pathForResource:@"Aboutdoge" ofType:@"rtf"];
    [_aboutText readRTFDFromFile:rtfFilePath];
    

    
    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    
    
    
    // Follow search string
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSearch) name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    //NSWindow *panel = [self window];
    //NSRect statusRect = [self statusRectForWindow:panel];
    //NSRect panelRect = [panel frame];
    
    //CGFloat statusX = roundf(NSMidX(statusRect));
    //CGFloat panelX = statusX - NSMinX(panelRect);
    
    //self.backgroundView.arrowX = panelX;
    self.backgroundView.arrowX = PANEL_WIDTH / 2;
    
    
    
//    NSRect searchRect = [self.searchField frame];
//    searchRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
//    searchRect.origin.x = SEARCH_INSET;
//    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET - NSHeight(searchRect);
//    
//    if (NSIsEmptyRect(searchRect))
//    {
//        [self.searchField setHidden:YES];
//    }
//    else
//    {
//        [self.searchField setFrame:searchRect];
//        [self.searchField setHidden:NO];
//    }
//    
//    NSRect textRect = [self.textField frame];
//    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
//    textRect.origin.x = SEARCH_INSET;
//    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
//    textRect.origin.y = SEARCH_INSET;
//    
//    if (NSIsEmptyRect(textRect))
//    {
//        [self.textField setHidden:YES];
//    }
//    else
//    {
//        [self.textField setFrame:textRect];
//        [self.textField setHidden:NO];
//    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

//- (void)runSearch
//{
//    NSString *searchFormat = @"";
//    NSString *searchString = [self.searchField stringValue];
//    if ([searchString length] > 0)
//    {
//        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
//    }
//    NSString *searchRequest = [NSString stringWithFormat:searchFormat, searchString];
//    [self.textField setStringValue:searchRequest];
//}

-(IBAction)editedAddress:(id)sender {
    
    NSTextField *addressObj = sender;
    
    NSLog(@"edited! %@",[addressObj stringValue]);
    //saveAddress([addressObj stringValue]);
    
    [self saveAddress:[addressObj stringValue]];

    //[(ApplicationDelegate *)[[NSApplication sharedApplication] delegate] updateBalance];
    
    
    

    // See if it was due to a return
}

-(IBAction)quitBar:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}


- (void)saveAddress:(NSString *)addressToSave {
    
    NSLog(@"Saving! %@",addressToSave);

    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:addressToSave forKey:@"dogecoinwallet"];
    [prefs synchronize];
    ApplicationDelegate* appDelegate = (ApplicationDelegate*)[[NSApplication sharedApplication] delegate];
    [appDelegate updateBalance:nil];
    
    
    


}


#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:panelRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
//    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
}

- (void)closePanel
{
    [self saveAddress:[_walletAddress stringValue]];
    

    ApplicationDelegate* appDelegate = (ApplicationDelegate*)[[NSApplication sharedApplication] delegate];
    [appDelegate updateBalance:nil];
    NSLog(@"CLOSING");

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

@end
