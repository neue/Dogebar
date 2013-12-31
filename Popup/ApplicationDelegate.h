#import "MenubarController.h"
#import "PanelController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property NSTimer *updateTimer;


- (void)updateBalance:(NSTimer*)theTimer;


- (IBAction)togglePanel:(id)sender;

@end
