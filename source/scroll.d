module scroll;

import vibe.http.server : HTTPServerResponse, render;
import std.stdio;
import std.file;
import std.algorithm : canFind;
import std.algorithm.iteration : substitute;
import std.array;
import std.regex;

struct Scroll {
    string[] requiredParams;
    string baseContents;
}

Scroll[string] allScrolls;

auto paramRegex = ctRegex!(`\#\{(\w+)\}`);

void refreshScrolls()
{
    allScrolls.clear;
    foreach (string name; dirEntries("scrolls", SpanMode.shallow)) {
        string baseContents = readText(name);
        string scrollName = name[8..$-5];
        string[] params = [];
        if (auto captures = matchAll!string(baseContents, paramRegex)) {
            foreach (capture; captures) {
                auto value = capture[1];
                if (!params.canFind(value)) {
                    params ~= [value];
                }
            }
        }
        Scroll scroll = Scroll(params, baseContents);
        allScrolls[scrollName] = scroll;
    }

}

void renderScroll(HTTPServerResponse res, string scrollName, string[string] params)
{
    if (scrollName in allScrolls) {
        Scroll scroll = allScrolls[scrollName];
        auto result = scroll.baseContents;
        foreach (string requiredParam; scroll.requiredParams) {
            if (!(requiredParam in params)) {
                auto parameter = requiredParam;
                res.render!("scroll-paramerror.dt", parameter);
            } else {
                result = result.replace("#{" ~ requiredParam ~ "}", params[requiredParam]);
            }
        }
        res.writeBody(result, "text/html; charset=UTF-8");
    } else {
        res.render!("scroll-nameerror.dt", scrollName);
    }
}