#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize text = _text;
@synthesize opacity = _opacity;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    return self;
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = 0.0;
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

	[icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:self.opacity];


    CGFloat textX = iconSize.width;
    CGFloat textY = iconY + 1;
    NSPoint textPoint = NSMakePoint(textX, textY);
    
    [self.text drawAtPoint:textPoint withAttributes:[self titleAttributes]];
}

- (NSColor *)titleForegroundColor {
    if (self.isHighlighted) {
        return [NSColor whiteColor];
    }
    else {
        return [NSColor blackColor];
    }
}

- (NSDictionary *)titleAttributes {
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];
    
    NSColor *foregroundColor = [self titleForegroundColor];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font,            NSFontAttributeName,
            foregroundColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)boundingRect {
    NSRect textRect = [self.text boundingRectWithSize:NSMakeSize(1e100, 1e100)
                                   options:0
                                attributes:[self titleAttributes]];
    return NSMakeRect(0, 0, NSWidth(textRect) + [self.image size].width + 3, NSHeight(textRect));
}

- (void)setText:(NSString *)text {
    if ([self.text isEqualToString:text]) {
        return;
    }
    
    _text = text;
    NSLog(@"setText called with %@", text);
    
    NSRect newBounds = [self boundingRect];
    int newWidth = newBounds.size.width;
    [self.statusItem setLength:newWidth];
    
    [self setNeedsDisplay:TRUE];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
