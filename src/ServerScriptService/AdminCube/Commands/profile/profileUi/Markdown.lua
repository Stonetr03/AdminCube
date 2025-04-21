-- Admin Cube - Stonetr03 - Markdown to Richtext

-- Code is based off MDify (https://devforum.roblox.com/t/mdify-convert-markdown-into-native-richtext/2579063)

local Markdown = {}

local Patterns = {
    "*%*%*[%w%p%s]-*%*%*",
    "*%*[%w%p%s]-*%*",
    "%*[%w%p%s]-%*",
    "~~[%w%p%s]-~~",
    "`[%w%p%s]-`",
    "__[%w%p%s]-__",
    "==[%w%p%s]-==",
}

local Syntax = {
    "***",
    "**",
    "*",
    "~~",
    "`",
    "__",
    "==",
}

local RichText = {
    {"<b><i>", "</i></b>"},
    {"<b>", "</b>"},
    {"<i>", "</i>"},
    {"<s>", "</s>"},
    {"<font family='rbxasset://fonts/families/RobotoMono.json'>", "</font>"},
    {"<u>", "</u>"},
    {"<mark color='#8D7E35'>", "</mark>"},
}

function Markdown.ToRichText(text: string): string
    -- Escape Rich Text Characters
    text = text:gsub('[&<>"\']',{
		['&'] = '&amp;',
		['<'] = '&lt;',
		['>'] = '&gt;',
		['"'] = '&quot;',
		['\''] = '&apos;',
	})
    -- Rich Text Formatting
    for patternIndex, markdownPattern in Patterns do
        text = text:gsub(
            markdownPattern,
            function(result)
                return `{RichText[patternIndex][1]}{result:gsub(Syntax[patternIndex], "")}{RichText[patternIndex][2]}`
            end
        )
    end
    
    return text
end

return Markdown;
