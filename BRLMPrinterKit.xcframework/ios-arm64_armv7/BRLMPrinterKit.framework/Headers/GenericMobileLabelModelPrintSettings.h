//
//  GenericMobileLabelModelPrintSettings.h
//  BMSPrinterKit
//
//  Created by BMS on 9/12/12.
//  Copyright (c) 2012-13 Brother Mobile Solutions. All rights reserved.
//

#import "PrintSettings.h"



@interface GenericMobileLabelModelPrintSettings : PrintSettings <PrintSettingsDelegate>
{
    // provide subclasses with access to readonly properties via ivars.
    // Because they are readonly, there is no "Setter" method available in the superclass.
    // The subclasses should be the only place where these properties are set.
    // But, they will be used in this superclass.
    // Users of this superclass can read the values if desired, but in most cases this
    // will not be necessary.
    int _resolutionHorz;
    int _resolutionVert;
    int _headSizeDots;
    int _paperWidthDotsMin;
    int _paperWidthDotsMax;
    int _paperLengthDotsMin;
    int _paperLengthDotsMax;
    int _marginLengthDotsMin;
    int _marginLengthDotsMax;
    int _extraFeedMax;

}

// the following are defined somewhat arbitrarily to limit these settings to a
// reasonable value during validation.
// NOTE: We do NOT need "read only" properties for these since they will be the same
// for each model and subclass.
#define LABELSPACINGDOTS_MAX 1000
#define MARKWIDTHDOTS_MAX 1000
#define MARKOFFSETDOTS_MIN -1000
#define MARKOFFSETDOTS_MAX 1000


//*** IMPORTANT (for SDK Users):
// *** DO NOT INSTANTIATE AN OBJECT OF THIS CLASS!!!!! ***
// The GenericMobileLabelModelPrintSettings class is essentially an ABSTRACT class.
// Instead, you should instantiate the model-specific class, e.g. RJ4040PrintSettings.

//*** The following properties should be set by your app code, either PROGRAMMATICALLY
// or by using one of the PrintSettingsViewControllers (which may not set all properties).

// The properties and methods in this super-class will be COMMON for all
// of the RJ and TD printer models.
// They will be implemented in here generically, but will use the genericModelDelegate
// property above to get model-specific information.

// SDK Users: All of the properties below (and those in the PrintSettings superclass)
// are settable by you to change the printer behavior.
// If you are not using the PrintSettingsViewController (either the SDK's or your own custom one),
// then you should set each of these properties programmatically to your desired setting.
@property (nonatomic, assign) PAPERTYPE paperType;
// formFeedMode = NOFEED mode is used to implement "trimTapeAfterData" from Windows driver.
// This allows clipping white space from the bottom of the job to save paper.
@property (nonatomic, assign) FORMFEEDMODE formFeedMode;
@property (nonatomic, assign) DENSITY density;
@property (nonatomic,assign) int extraFeed; // used with kFormFeedModeNoFeed only

// Paper Size is defined by a Width and Length.
// Unprintable Margins impact printable area within this defined size.
// * Printable height will be calculated as:
//        "printableHeight = paperLengthDots - 2*marginLengthDots"
// * Printable width will be calculated as:
//        "printableWidth = paperWidthDots - 2*marginWidthDots"
// Also, since printer paper is "center justified", anything less than 4" width needs to be
// compensated for using "rightOffsetBytes" to shift the data relative to printhead origin.
// We calculate "rightOffsetBytes" in the DRIVER based on paperWidthDots and marginWidthDots.
//
// NOTE: RJ4040 requires the left/right margins (marginWidth) to be the same as each other,
// and it requires top/bottom margins (marginLength) to be the same as each other.
// Although TD2 firmware allows these to be different, we are NOT going to support that
// functionality. If any margin settings are needed that require these unprintable margins
// to be different, then use the "marginDots" property in the superclass to make these adjustments.
@property (nonatomic, assign) int paperWidthDots;
@property (nonatomic, assign) int paperLengthDots;
@property (nonatomic, assign) int16_t marginWidthDots; // left and right unprintable margin
@property (nonatomic, assign) int16_t marginLengthDots; // top and bottom unprintable margin
// this is for labels only:
@property (nonatomic, assign) int16_t labelSpacingDots; // distance between labels
// These 2 are for Marked Paper only:
@property (nonatomic, assign) int16_t markWidthDots; // width of mark
@property (nonatomic, assign) int16_t markOffsetDots; // distance from leading edge to marks. Can be negative.

// By default, the "Esc iUw [128 bytes]" command  will be sent by computing the 128-byte
// structure fields from the paperSize and other property settings.
// However, some types of media may not be adequately handled. In this case, we provide the
// option to disable sending this command. However, it will then be necessary to use the
// Windows driver to send a job to the printer to cause the appropriate "Esc iUw" command to
// be sent to the printer.
// *** The printer will remember the settings from the last time this command was sent. ***
// It will be important to assure that this class' property settings closely match the
// settings sent by the Windows driver.
@property (nonatomic, assign) BOOL sendAdditionalMediaInfoCommand;

//*** The properties below are READ ONLY. SDK Users can NOT set them!!
// Each subclass MUST set them to their model-specific values in their init method.
// The purpose of this GenericMobileLabelModelPrintSettings class is to implement COMMON
// code so it does not have to be duplicated for each similar printer model. However, it
// requires these model-dependent properties to be set by the SUBCLASS.
@property (readonly, nonatomic, assign) int resolutionHorz;
@property (readonly, nonatomic, assign) int resolutionVert;
@property (readonly, nonatomic, assign) int headSizeDots;
@property (readonly, nonatomic, assign) int paperWidthDotsMin;
@property (readonly, nonatomic, assign) int paperWidthDotsMax;
@property (readonly, nonatomic, assign) int paperLengthDotsMin;
@property (readonly, nonatomic, assign) int paperLengthDotsMax;
@property (readonly, nonatomic, assign) int marginLengthDotsMin;
@property (readonly, nonatomic, assign) int marginLengthDotsMax;
@property (readonly, nonatomic, assign) int extraFeedMax;


// *** PrintSettingsDelegate protocol
// All subclasses of PrintSettings are required to implement these methods.
// validatePrintSettings - This function assures that all properties are in range
// and that there are no conflicting settings. 
- (BOOL)validatePrintSettings;
- (void) loadPreferences;
- (void) savePreferences;
//generate strings from CURRENT settings, for convenience.
// This is part of the PrintSettingsDelegateProtocol too.
- (NSString *)stringFromCurrentPaperType;
// NOTE: PaperSize uses combination of internal settings to generate a string, formatted in inches.
- (NSString *)stringFromCurrentPaperSize;
- (NSString *)stringFromCurrentFormFeedMode;
- (NSString *)stringFromCurrentExtraFeed;
- (NSString *)stringFromCurrentDensity;


//*** generate strings from constants, for convenience
- (NSString *)stringFromPaperType: (PAPERTYPE)paperType;
// NOTE: paperSize for these models does not have a constant, so you can only use the CURRENT version below.
- (NSString *)stringFromFormFeedMode: (FORMFEEDMODE)ffmode;
- (NSString *)stringFromExtraFeed:(int)extraFeed;
- (NSString *)stringFromDensity: (DENSITY)density;


@end
