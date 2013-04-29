

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

#define WIDTH_IPAD 1024
#define WIDTH_IPHONE_5 568
#define WIDTH_IPHONE_4 480
#define HEIGHT_IPAD 768
#define HEIGHT_IPHONE 320

// World Weather Online API Key, FREE API Level
#define WorldWeatherAPIKey @"gxuck92qu5mntpj6b38qawa8"


// base URL for Open Notify API
static NSString *const BaseURLString = @"http://api.open-notify.org/";

// base URL for World Weather API
static NSString *const BaseWWURLString = @"http://api.worldweatheronline.com/free/v1/";

//http://api.worldweatheronline.com/free/v1/weather.ashx?q=Guatemala&format=json&num_of_days=5&cc=no&key=gxuck92qu5mntpj6b38qawa8
