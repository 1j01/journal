
# TODO: always have a placeholder for new entries at the end

# TODO: use arrow keys to travel between blocks

# TODO: formatting

# TODO: autolink urls
	# can probably use regexp from https://github.com/bryanwoods/autolink-js/blob/master/autolink.coffee
# TODO: allow clicking links

# TODO: allow drag and drop

# onpaste:
	# TODO: remove font-size, font-family and probably line-height from styles of at least <p> elements
	# TODO: detect code, automatically make code blocks

# TODO: undo/redo
# TODO: multi-block selection

# TODO: context menus with https://github.com/mixmaxhq/electron-spell-check-provider

require "coffee-script/register"

E = require "react-script"
React = require "react"
ReactDOM = require "react-dom"
# console.log __dirname # why does this not give src/ when this file is in src/?
Journal = require "./src/Journal"

container = document.createElement "div"
container.className = "app"
document.body.appendChild container

ReactDOM.render E(Journal), container
