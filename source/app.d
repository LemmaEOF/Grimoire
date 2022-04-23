import vibe.d;
import std.string : format;

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter;

	router.registerWebInterface(new GrimoireService);

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}

struct Story {
	string slug;
	string title;
	string summary;
	string storyTemplate;
	string contents;
	string[] tags;
	string[] contentWarnings;
	uint authorId;
	string[string] subpages;
}

struct Author {
	uint authorId;
	string handle;
	string username;
	string email;
	string avatarUrl;
	string bio;
	string[string] socialLinks;
	//TODO: permissions later
}

Author findAuthor(string authorHandle)
{
	return Author(
		0,
		"ExampleAuthor",
		"Example Author",
		"example@example.com",
		"https://lemmaeof.gay",
		"This is a sample bio!",
		null
	);
}

Story findStory(string authorHandle, string storySlug)
{
	return Story(
		"example-story",
		"Example Story",
		"An example summary for the example story.",
		"wiki",
		"",
		[],
		[],
		0,
		null
	);
}

class GrimoireService
{

	@path("/")
	void getHomepage(HTTPServerRequest req, HTTPServerResponse res)
	{

	}

	@path("/@:author")
	void getAuthor(HTTPServerRequest req, HTTPServerResponse res)
	{

	}

	@path("/@:author/:title")
	@method(HTTPMethod.GET)
	void getStory(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto author = findAuthor(req.params["author"]).username;
		auto title = findStory(req.params["author"], req.params["title"]).title;
		res.render!("wiki.dt", author, title);
	}
}
