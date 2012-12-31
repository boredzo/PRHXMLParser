//
//  PRHXMLParser.m
//
//  Copyright (c) 2011–2012 Peter Hosey. All rights reserved.
//

#import "PRHXMLParser.h"

@interface PRHXMLParser (XMLParserDelegate) <NSXMLParserDelegate>
@end

@interface PRHXMLParser ()
- (NSString *)currentElementPath;
@end

@implementation PRHXMLParser
{
	NSMutableArray *elementNamesStack;
	NSMutableArray *elementAttributesStack;
	NSMutableArray *elementChildrenStack;

	NSMutableDictionary *elementHandlersByPath;
	NSMutableDictionary *elementHandlersByName;
	dispatch_block_t completionHandler;
}

- (id)init {
    self = [super init];
    if (self) {
		elementNamesStack = [NSMutableArray new];
		elementAttributesStack = [NSMutableArray new];
		elementChildrenStack = [NSMutableArray new];

        elementHandlersByPath = [NSMutableDictionary new];
        elementHandlersByName = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)currentElementPath {
	return [@"/" stringByAppendingPathComponent:[elementNamesStack componentsJoinedByString:@"/"]];
}
- (PRHXMLElementHandler) elementHandlerForElementPath:(NSString *)elementPath {
	return [elementHandlersByPath objectForKey:elementPath];
}
- (void) setElementHandlerForElementPath:(NSString *)elementPath handler:(PRHXMLElementHandler)handler {
	NSParameterAssert([elementPath hasPrefix:@"/"]);
	[elementHandlersByPath setObject:handler forKey:elementPath];
}

- (PRHXMLElementHandler) elementHandlerForElementName:(NSString *)elementName {
	return [elementHandlersByName objectForKey:elementName];
}
- (void) setElementHandlerForElementName:(NSString *)elementName handler:(PRHXMLElementHandler)handler {
	[elementHandlersByName setObject:handler forKey:elementName];
}

- (bool) useParser:(NSXMLParser *)parser completionHandler:(dispatch_block_t)endHandler {
	completionHandler = endHandler;
	parser.delegate = self;
	return [parser parse];
}
- (bool) parseURL:(NSURL *)URL completionHandler:(dispatch_block_t)endHandler {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	return [self useParser:parser completionHandler:endHandler];
}
- (bool) parseData:(NSData *)XMLData completionHandler:(dispatch_block_t)endHandler {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLData];
	return [self useParser:parser completionHandler:endHandler];
}

@end

@implementation PRHXMLParser (XMLParserDelegate)

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[elementNamesStack addObject:elementName];
	[elementAttributesStack addObject:attributeDict];
	[elementChildrenStack addObject:[NSMutableArray new]];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	NSXMLNode *node = [NSXMLNode textWithStringValue:string];
	[[elementChildrenStack lastObject] addObject:node];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSDictionary *attributeDict = [elementAttributesStack lastObject];
	NSArray *children = [elementChildrenStack lastObject];
	NSXMLElement *element = [NSXMLElement elementWithName:elementName children:children attributes:nil];
	[element setAttributesWithDictionary:attributeDict];

	PRHXMLElementHandler handler = [self elementHandlerForElementPath:[self currentElementPath]];
	if (handler) {
		handler(element, attributeDict);
	}
	handler = [self elementHandlerForElementName:elementName];
	if (handler) {
		handler(element, attributeDict);
	}

	[elementNamesStack removeLastObject];
	[elementAttributesStack removeLastObject];
	[elementChildrenStack removeLastObject];

	[[elementChildrenStack lastObject] addObject:element];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if (completionHandler) completionHandler();
}

@end
