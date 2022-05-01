import vibe.d;
import std.string : format;
import scroll;
import std.uni;
import std.stdio;

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
	refreshScrolls();
	deleteMeTempInitStorage();
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
	// string[string] subpages;
}

struct Author {
	uint authorId;
	string handle;
	string username;
	string email;
	string avatarUrl;
	string bio;
	// string[string] socialLinks;
	//TODO: permissions later
}

//TODO: DELETE ME LATER! THIS IS TEMPORARY!
Author[string] authors;

Story[string][string] stories;

void deleteMeTempInitStorage() {
	authors["exampleauthor"] = Author(
		0,
		"ExampleAuthor",
		"Example Author",
		"example@example.com",
		"https://lemmaeof.gay",
		"This is a sample bio!"
	);
	stories["exampleauthor"]["example-story"] = Story(
		"example-story",
		"Example Story",
		"An example summary for the example story.",
		"wiki",
		"",
		[],
		[],
		0
	);
}

Author findAuthor(string authorHandle)
{
	return authors[authorHandle.toLower];
}

Story findStory(string authorHandle, string storySlug)
{
	return stories[authorHandle.toLower][storySlug.toLower];
}

class GrimoireService
{

	@path("/")
	void getHomepage(HTTPServerRequest req, HTTPServerResponse res)
	{
		res.writeBody(q{<!DOCTYPE html> <html><body>Temporary home page</body></html>}, "text/html");
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
		Story story = findStory(req.params["author"], req.params["title"]);
		res.renderScroll(story.storyTemplate, ["author": author, "title": story.title, "contents": story.contents]);
	}

	@path("/new")
	@method(HTTPMethod.GET)
	void getNew(HTTPServerResponse res) {
		res.render!("new.dt");
	}

	@path("/new")
	@method(HTTPMethod.POST)
	void postNew(string author, string slug, string title, string contents)
	{
		auto story = Story(
			slug,
			title,
			"Submitted through a template form, FIXME!",
			"wiki",
			contents, //XSS!
			[],
			[],
			findAuthor(author).authorId
		);
		
		stories[author][slug] = story;
		redirect("/@" ~ author ~ "/" ~ slug);
	}
}
