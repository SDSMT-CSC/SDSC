#import "RHNetworkEngine.h"

#define TIMERTIME 3.0              // Timeout time

@implementation RHNetworkEngine

@synthesize address,
inputStream,
outputStream,
setupTimer,
timeout;

static RHNetworkEngine* sharedManager = nil;

#pragma mark - Public Static Methods

+ (void)initialize
{
    // If shared manager exisits, dump it
    if (sharedManager)
    {
        sharedManager = nil;
    }
    
    sharedManager = [[RHNetworkEngine alloc] init];
}

+ (void)sendJSON:(NSDictionary*)payload toAddressWithTarget:(id)targ withRetSelector:(SEL)rSel andErrSelector:(SEL)eSel
{
    // Check for a valid address, if not send the string back to the error selector
    if([[sharedManager address]isEqual:@""])
    {
        [targ performSelector:eSel withObject:@"no address."];
        return;
    }
    
    // Set the return target and selectors
    [sharedManager setTarget:targ];
    [sharedManager setRetMethod:rSel];
    [sharedManager setErrMethod:eSel];
    [sharedManager setPayload:payload];
    
    // Start the network traffic
    [sharedManager startNetworkTransaction];
}

#pragma mark - Private Mutators

- (id)init
{
    self = [super init];
    if (self) {
        address = @"";
    }

return self;
}

- (SEL)retMethod
{
    return retMethod;
}

- (SEL)errMethod
{
    return errMethod;
}

- (id)target
{
    return target;
}

- (void)setErrMethod:(SEL)e
{
    errMethod = e;
}

- (void)setRetMethod:(SEL)r
{
    retMethod = r;
}

- (void)setTarget:(id)t
{
    target = t;
}

#pragma mark - Networking Methods

- (void)startNetworkTransaction
{
    // Connect to the DDNS to get the address (this should be refactored into a class)
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // Create a connection
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, 80, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream*)readStream;
    outputStream = (__bridge NSOutputStream*)writeStream;
    
    [inputStream setDelegate:sharedManager];
    [outputStream setDelegate:sharedManager];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // Open the connection and set the timeout
    [inputStream open];
    [outputStream open];
    
    //[self startTimeoutTimer];
}

// Packages the data into JSON format and transmits it over the line
- (void)sendTCPIPData
{
    // Construct the message
    NSError* e = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:self.payload options:nil error:&e];
    
    // If an error occours return it
    if(e)
    {
        [target performSelector:errMethod withObject:[e localizedDescription]];
        
        // Clean up and close connections
        [self cleanUp];
        
        return;
    }
    [outputStream write:[data bytes] maxLength:[data length]];
    
}

// closes the sockets
- (void)cleanUp
{
    // Check for timers
    if(timeout.isValid)
    {
        [timeout invalidate];
    }
    
    [inputStream close];
    [outputStream close];
}

#pragma mark - Timeout

- (void)startTimeoutTimer
{
    timeout = [NSTimer scheduledTimerWithTimeInterval:TIMERTIME
                                               target:self
                                             selector:@selector(timeoutFire)
                                             userInfo:nil
                                              repeats:NO];
}


// Closes connections and cleans up
- (void)timeoutFire
{
    // Send an error back
    [target performSelector:errMethod withObject:@"timeout"];
    
    // Close sockets
    [self cleanUp];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Socket Open
    if(eventCode == NSStreamEventOpenCompleted) {
        // Invalidate timer
        [timeout invalidate];
        
        // Second timeout timer since the system has not ack
        [self startTimeoutTimer];
    }
    
    // Server disconnected
    if(eventCode == NSStreamEventEndEncountered) {
        
        // Send server closed socket error
        // Close the sockets
        [self cleanUp];
        
    }
    
    // Error
    if (eventCode == NSStreamEventErrorOccurred) {
        
        // Send a generic error code.
        
        // Close the sockets
        [self cleanUp];
    }
    
    // By: Ray Wenderlich
    // http://www.raywenderlich.com/3932/how-to-create-a-socket-based-iphone-app-and-server
    // If the system said somthing
    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[1024];
        int len;
        
        while ([inputStream hasBytesAvailable]) {
            len = [inputStream read:buffer maxLength:sizeof(buffer)];
            if(len > 0) {
                
                
                //Convert the JSON into a dictonary
                NSError *e;
                NSData *inputData = [NSData dataWithBytes:buffer length:len];
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:inputData
                                                                         options:kNilOptions
                                                                           error:&e];
                
                // If an error occours return it
                if(e)
                {
                    [target performSelector:errMethod withObject:[e localizedDescription]];
                    
                    // Clean up and close connections
                    [self cleanUp];
                    
                    return;
                } // End if
                
                // If the response is valid check to see if it is
                // a connection response
                NSArray* resArr = (NSArray*) [response objectForKey:@"DDNSConnected"];
                if (resArr != Nil && resArr[0]) {
                    // Invalidate second timer
                    [timeout invalidate];
                    
                    // Connection established send the registration data
                    [sharedManager sendTCPIPData];
                }
                
                // Else return the response
                else
                {
                    [target performSelector:retMethod withObject:response];
                }
                
                
            }
            
        }
    }
}

@end
