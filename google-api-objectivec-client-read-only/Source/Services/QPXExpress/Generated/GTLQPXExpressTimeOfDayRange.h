/* Copyright (c) 2014 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLQPXExpressTimeOfDayRange.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   QPX Express API (qpxExpress/v1)
// Description:
//   Lets you find the least expensive flights between an origin and a
//   destination.
// Documentation:
//   http://developers.google.com/qpx-express
// Classes:
//   GTLQPXExpressTimeOfDayRange (0 custom class methods, 3 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLQPXExpressTimeOfDayRange
//

// Two times in a single day defining a time range.

@interface GTLQPXExpressTimeOfDayRange : GTLObject

// The earliest time of day in HH:MM format.
@property (copy) NSString *earliestTime;

// Identifies this as a time of day range object, representing two times in a
// single day defining a time range. Value: the fixed string
// qpxexpress#timeOfDayRange.
@property (copy) NSString *kind;

// The latest time of day in HH:MM format.
@property (copy) NSString *latestTime;

@end
