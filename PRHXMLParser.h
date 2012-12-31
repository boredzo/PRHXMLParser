//
//  PRHXMLParser.h
//
//  Copyright (c) 2011–2012 Peter Hosey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PRHXMLElementHandler)(NSXMLElement *element, NSDictionary *attributes);

//Element paths follow a very simple subset of XPath, namely slash-separated element names. Currently, paths MUST be absolute (start with /).
//Traversal is depth-first. If you have handlers that match an element and handlers that match a descendant of that element, the handlers for the descendant will be called first, *before* the handlers for the outer element.

@interface PRHXMLParser : NSObject

//If an element is matched both by path and by name, both handlers will be called.
- (PRHXMLElementHandler) elementHandlerForElementPath:(NSString *)elementPath;
- (void) setElementHandlerForElementPath:(NSString *)elementPath handler:(PRHXMLElementHandler)handler;

- (PRHXMLElementHandler) elementHandlerForElementName:(NSString *)elementName;
- (void) setElementHandlerForElementName:(NSString *)elementName handler:(PRHXMLElementHandler)handler;

- (bool) parseURL:(NSURL *)URL completionHandler:(dispatch_block_t)endHandler;
- (bool) parseData:(NSData *)XMLData completionHandler:(dispatch_block_t)endHandler;

@end
