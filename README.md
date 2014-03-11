UIViewController-Keyboard
=========================

## Usage

AppDelegate

	#import "UIViewController+Keyboard.h"
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
    	// Override point for customization after application launch.
    	[UIViewController setupKeyboardResize];
    
    	return YES;
	}


ViewController

	- (void)viewDidLoad
	{
    	[super viewDidLoad];
		// Do any additional setup after loading the view, typically from a nib.
    
    	[self setEnableKeyboardResize:YES];
	}
	
	