//
//  NetController.m
//  6
//
//  Created by Ryan on 7/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NetController.h"


@implementation NetController

- (IBAction)connectToServer:(id)sender
{
	NSHost *host = [NSHost hostWithName:@"Soundbridge.local"];
	//NSHost *host = [NSHost hostWithName:@"soundbridge.local"];
	
	// iStream and oStream are instance variables
	
	[NSStream getStreamsToHost:host
						  port:5555
				   inputStream:&iStream
				  outputStream:&oStream];
	
	[iStream retain];
	[oStream retain];
	
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	
	
	[iStream open];	
	[oStream open];
	
	//we do this to clear from the iSream the default connection message
	//that the Roku device sends us: "roku: ready"
	[self receiveFullResponseFromRoku];
}

- (IBAction)updateStreamStatuses:(id)sender
{
	NSNumber *inStatus = [NSNumber numberWithInt:[iStream streamStatus]];
	[inStatusField setObjectValue:inStatus];
	
	NSNumber *outStatus = [NSNumber numberWithInt:[oStream streamStatus]];
	[outStatusField setObjectValue:outStatus];
}

- (void) receiveFullResponseFromRoku
{
	//this fills up the databuffer and tries to account for latency found
	//between the stream and the buffers by using usleep()
	//
	//This method is used to make sure that the whole message is received
	//before anything tries to read or parse the message
	//It is also useful for making sure that the return messages from the
	//Roku are taken out of the inputStream
	// eg. GetCurrentSongInfo OK
	
	while(![iStream hasBytesAvailable])
		usleep(1000);
	
	uint8_t buf[128];
	dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
	int len = 0;
	while([iStream hasBytesAvailable])
	{
		len = [iStream read:buf maxLength:128];
		if(len)
			[dataBuffer appendBytes:(const void *)buf
							 length:(NSUInteger)len];
		usleep(5000);
	}
	
}
- (IBAction)updateTrackInfo:(id)sender
{
	NSString *tempBuffer = @"GetCurrentSongInfo\n";
	[self sendRCPCommand:tempBuffer]; 
	
	NSString *returnedMessage = [[NSString alloc] initWithData:dataBuffer
													  encoding:NSUTF8StringEncoding];
	
	NSArray *linesOfOutput = [returnedMessage componentsSeparatedByCharactersInSet:
							  [NSCharacterSet newlineCharacterSet]];
	uint i;
	NSRange foundRange1;
	NSRange foundRange2;
	NSRange foundRange3;
	BOOL foundString1 = false;
	BOOL foundString2 = false;
	BOOL foundString3 = false;
	int titleIndex = 0;
	int artistIndex = 0;
	int albumIndex = 0;
	for(i = 0; i < [linesOfOutput count]; i++)
	{
		if(!titleIndex){
			foundRange1 = [[linesOfOutput objectAtIndex: i] rangeOfString:@"title: "];
			foundString1 = foundRange1.location != NSNotFound;
			if(foundString1)
				titleIndex = i;
		}
		if(!artistIndex)
		{
			foundRange2 = [[linesOfOutput objectAtIndex: i] rangeOfString:@"artist: "];
			foundString2 = foundRange2.location != NSNotFound;
			if(foundString2)
				artistIndex = i;
		}
		if(!albumIndex)
		{
			foundRange3 = [[linesOfOutput objectAtIndex: i] rangeOfString:@"album: "];
			foundString3 = foundRange3.location != NSNotFound;
			if(foundString3)
				albumIndex = i;
		}
		//if(foundString1 && foundString2)
		//	break;
	}
	/*
	 The arguments for 'substringFromIndex' are the length from the beginning
	 of the line to the first characters to get the actual information. ex.
	 the line with the title in it looks like:
	 
	 GetCurrentSongInfo: title: The Doldrums
	 
	 the 27 tells us that we need to skip 27 characters to get through the:
	 "GetCurrentSongInfo: title: "
	 to get to the:
	 "The Doldrums"
	 
	 These arguments will be different depending on the number of characters
	 it takes to get pasted all of the heading information and arrive at the
	 data we are looking for.
	 */
	[titleField setStringValue:[[linesOfOutput objectAtIndex: titleIndex] substringFromIndex: 27]];
	[artistField setStringValue:[[linesOfOutput objectAtIndex: artistIndex] substringFromIndex: 28]];
	[albumField setStringValue:[[linesOfOutput objectAtIndex: albumIndex] substringFromIndex: 27]];
}

- (void) sendRCPCommand: (NSString *) tempBuffer  {
  [oStream write:[tempBuffer cStringUsingEncoding:NSUTF8StringEncoding]
		 maxLength:[tempBuffer length]];
	[self receiveFullResponseFromRoku];

}

- (IBAction)sendPause:(id)sender
{
	NSString *tempBuffer = @"Pause\n";
	[self sendRCPCommand:tempBuffer];
}
@end
