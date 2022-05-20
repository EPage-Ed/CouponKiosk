//
//  RJ2050PrintSettingsViewController.h
//  BMSPrinterKit
//
//  Created by BMS on 9/6/16.
//  Copyright (c) 2016 Brother Mobile Solutions. All rights reserved.
//

#import "GenericMobileLabelModelPrintSettingsViewController.h"
#import "RJ2050PrintSettings.h"

// This is the DEFAULT popup contentSize for RJ2050PrintSettingsViewController.
//
// You can override this by setting the "popoverSize" property (defined in the
// PrintSettingsViewController superclass) to something different
// before showing the ViewController.
//
// The popoverSize setting will be propagated to all of the "child" ViewControllers
// of the main ViewController so all of the detail views will be the SAME size as each other.
//
// NOTE: iPad1 and iPad2 size = 1024 x 768, iPad3 = 2048 x 1536
//#define RJ2050POPUPCONTENTSIZE CGSizeMake(400,480)
#define RJ2050POPUPCONTENTSIZE CGSizeMake(400,548)
#define RJ2050POPUPCONTENTSIZE_IOS7 CGSizeMake(400,588)


/*
 This class is a subclass of GenericMobileLabelModelPrintSettingsViewController,
 which implements all the major functionality.
 
 *** SDK Users:  
 DO NOT INSTANTIATE an instance of GenericMobileLabelModelPrintSettingsViewController.
 Always instantiate a model-specific class, e.g. RJ2050PrintSettingsViewController
 */

@interface RJ2050PrintSettingsViewController : GenericMobileLabelModelPrintSettingsViewController
{
}

@end


