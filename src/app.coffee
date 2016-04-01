
# TODO: always have a placeholder for new entries at the end

# TODO: drag and drop links
# TODO: autolink urls
	# can probably use regexp from https://github.com/bryanwoods/autolink-js/blob/master/autolink.coffee
# TODO: allow clicking links
# TODO: allow clicking hashtags

# TODO: toggle block types and delete blocks from three dots menu

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
		# convertFromRaw, convertToRaw
		# @state = editorState: null
		@file = "./journal.json"
		fs.readFile @file, "utf8", (err, json)=>
			return if err?.code is "ENOENT"
			return console.error err if err
			# editorState = convertFromRaw(JSON.parse(json))
			# @setState {editorState}
			# @refs.journal.onChange(editorState)
			# contentState = convertFromRaw(JSON.parse(json))
			blocks = convertFromRaw(JSON.parse(json))
			contentState = ContentState.createFromBlockArray(blocks)
			@refs.journal.setContentState contentState
		@onChange = (editorState)=>
			# @setState {editorState}
			contentState = editorState.getCurrentContent()
			json = JSON.stringify(convertToRaw(contentState))
			# console.log json
			# TODO: protect against saving empty (or near-empty) document before document is loaded
			fs.writeFile @file, json, "utf8", (err)->
				console.error err if err
	
	render: ->
		E Journal,
			# editorState: @state.editorState
			onChange: @onChange
			ref: "journal"

ReactDOM.render (E App), container
