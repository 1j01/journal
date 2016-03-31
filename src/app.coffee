
# TODO: always have a placeholder for new entries at the end

# TODO: perform actions based on the selection ranges only, not e.target
# TODO: use arrow keys to travel between blocks

# TODO: allow clicking links
# TODO: allow drag and drop

# onpaste:
	# TODO: remove font-size, font-family and probably line-height from styles of at least <p> elements
	# TODO: detect code, automatically make code blocks

# TODO: undo/redo
# TODO: multi-block selection

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
