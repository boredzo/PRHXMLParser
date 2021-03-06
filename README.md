# PRHXMLParser
## A simple, easy-to-use, block-based XML parser for Cocoa

Want to parse some XML, but don't want to implement `NSXMLParserDelegate`? PRHXMLParser does that for you, so you simply write code like this:

	[parser setElementHandlerForElementPath:@"/rectlist" handler:^(NSXMLElement *element, NSDictionary *attributes) {
		<#…#>
	}];
	[parser setElementHandlerForElementPath:@"/rectlist/rectlist" handler:^(NSXMLElement *element, NSDictionary *attributes) {
		<#…#>
	}];
	[parser setElementHandlerForElementName:@"rect" handler:^(NSXMLElement *element, NSDictionary *attributes) {
		<#…#>
	}];
	
	[parser parseURL:inputXMLFileURL completionHandler:^{
		//This block is optional; you can pass nil instead
	}];

You specify elements by either of:

- Element name (e.g., `p`)
- A simple slash-separated path, which currently must always be absolute (e.g., `/html/body/h1`)

There's currently no provision yet for XPath or matching based on `id` attributes.

### The one gotcha

Because PRHXMLParser doesn't have separate begin and end events, it calls each matched element handler only when the element is completely traversed. This means that the traversal is depth-first, essentially “inside out”: You'll get called for the deepest matched elements before you get called for their parents/antecedents.

For what I was doing with this, that was fine. If you need to be notified when an element is entered as well as when it's finished, please post a request in the issue tracker and explain what you need it for.

### How does it work?

Currently, it uses NSXMLParser for the actual XML parsing. I've implemented `NSXMLParserDelegate` so you don't have to.

Elements are tracked using a stack, and the transformation of this stack into a path is looked up in a dictionary to find what blocks, if any, have been registered for that path. Similarly, blocks registered by element name are also looked up in a (separate) dictionary.

### Can I see it in action?

Sure. The included “slurpxml” project builds a command-line test program that reads an XML file like the one that's also included (sample.xml). It'll log messages for each of the elements it's looking for. As of this writing, it looks for three things:

- A rectlist element at the top level (path: /rectlist)
- A rectlist element inside of a top-level rectlist element (path: /rectlist/rectlist)
- Any rect element (name: rect)

slurpxml takes no arguments; it reads from standard input. Run it with something like `path/to/slurpxml < sample.xml` .
