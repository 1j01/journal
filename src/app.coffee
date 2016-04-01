
# TODO: always have a placeholder for new entries at the end
# TODO: improve the initial experience
	# maybe center the first block vertically (i.e. give it 50vh margin-top)
	# maybe make the last entry have extra height so it's easier to click on
	# make it clear where you can click to start typing
	# and focus it automatically so you don't have to


# TODO: drag and drop links
# TODO: autolink urls
	# can probably use regexp from https://github.com/bryanwoods/autolink-js/blob/master/autolink.coffee
# TODO: allow clicking links
# TODO: allow clicking hashtags

# TODO: paste or drag and drop images
# TODO: detect code when pasting, automatically make code blocks

# Done until paged loading is implemented: use arrow keys to travel between blocks
# Done until paged loading is implemented: undo/redo
# Done until paged loading is implemented: multi-block selection

require "coffee-script/register"

fs = require "fs"

E = require "react-script"
React = require "react"
ReactDOM = require "react-dom"
{convertFromRaw, convertToRaw, ContentState} = require "draft-js"
Journal = require "./src/Journal"

container = document.createElement "div"
container.className = "app"
document.body.appendChild container

class App extends React.Component
	constructor: ->
		@file = "./journal.json"
		fs.readFile @file, "utf8", (err, json)=>
			return if err?.code is "ENOENT"
			return console.error err if err
			blocks = convertFromRaw(JSON.parse(json))
			contentState = ContentState.createFromBlockArray(blocks)
			@refs.journal.setContentState contentState
		@onChange = (editorState)=>
			contentState = editorState.getCurrentContent()
			json = JSON.stringify(convertToRaw(contentState))
			# TODO: protect against saving empty (or near-empty) document before document is loaded
			fs.writeFile @file, json, "utf8", (err)->
				console.error err if err
	
	render: ->
		E Journal,
			onChange: @onChange
			ref: "journal"

ReactDOM.render (E App), container
