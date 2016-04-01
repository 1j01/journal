
# TODO: always have a placeholder for new entries at the end

# Done until loading is implemented: use arrow keys to travel between blocks

# TODO: autolink urls
	# can probably use regexp from https://github.com/bryanwoods/autolink-js/blob/master/autolink.coffee
# TODO: allow clicking links

# Done: allow drag and drop

# TODO: toggle block types and delete blocks from three dots menu

# onpaste:
	# Done: remove font-size, font-family and probably line-height from styles of at least <p> elements
	# TODO: detect code, automatically make code blocks

# Done until loading is implemented: undo/redo
# Done at least until loading is implemented: multi-block selection

# Done: context menus with https://github.com/mixmaxhq/electron-spell-check-provider

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
