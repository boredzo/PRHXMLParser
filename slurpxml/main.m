#import "PRHXMLParser.h"

int main(void) {
	@autoreleasepool {
		PRHXMLParser *parser = [[PRHXMLParser alloc] init];
		[parser setElementHandlerForElementPath:@"/rectlist" handler:^(NSXMLElement *element,
			NSDictionary *attributesDict
		) {
			NSLog(@"Found rect list with attributes: %@", attributesDict);
		}];
		[parser setElementHandlerForElementName:@"rect" handler:^(NSXMLElement *element, NSDictionary *attributesDict) {
			NSLog(@"Found rect with contents: %@", element.stringValue);
		}];

		[parser parseData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile] completionHandler:nil];
	}
	return EXIT_SUCCESS;
}
