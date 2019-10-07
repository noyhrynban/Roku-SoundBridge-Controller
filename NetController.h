//
//  NetController.h
//  6
//
//  Created by Ryan on 7/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NetController : NSObject {
	IBOutlet NSTextField * inStatusField;
	IBOutlet NSTextField * outStatusField;
	IBOutlet NSTextField * titleField;
	IBOutlet NSTextField * artistField;
	IBOutlet NSTextField * albumField;
	NSInputStream * iStream;
	NSOutputStream * oStream;
	NSMutableData * dataBuffer;
		
}
- (IBAction)connectToServer:(id)sender;
- (IBAction)updateStreamStatuses:(id)sender;
- (void) receiveFullResponseFromRoku;
- (IBAction)updateTrackInfo:(id)sender;
- (IBAction)sendPause:(id)sender;

@end
