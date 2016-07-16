
# TODO: always have a placeholder for new entries at the end, along with some margin, say half the screen height
# TODO: improve the initial experience
	# maybe center the first block vertically (i.e. give it 50vh margin-top)
	# maybe make the last entry have extra height so it's easier to click on
	# make it clear where you can click to start typing
	# and focus it automatically so you don't have to

# TODO: make it easier to put two blockquotes next to each other? (do blockquotes really need to be able to be multiline?)
# TODO: blockquotes with attribution

# TODO: drag and drop links
# TODO: fix link/hashtag ux
# TODO: possibly improve hashtag matching with https://github.com/draft-js-plugins/draft-js-plugins/tree/master/draft-js-hashtag-plugin

# TODO: paste or drag and drop images
# TODO: detect code when pasting, automatically make code blocks

# TODO: better show when the dropdown menu will affect a range of blocks

# TODO: zoom with Ctrl+mousewheel, Ctrl++, Ctrl+-, Ctrl+0 (is there a library for this?)

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

require "./src/context-menus"

container = document.createElement "div"
container.className = "app"
document.body.appendChild container

# TODO: allow (and encourage) user to save to a cloud-synced folder
# TODO: handle external changes because of that
file = "./journal.json"
loaded = no

save = (editorState)->
	contentState = editorState.getCurrentContent()
	json = JSON.stringify(convertToRaw(contentState))
	if loaded
		# TODO: guarantee last write is the one that ends up on disk
		fs.writeFile file, json, "utf8", (err)->
			console.error err if err
	# else
	# 	alert "Journal not loaded"
	# TODO: proper error handling for failing to load (alert doesn't work because it instantly pops up after closing)
	# (and alerts aren't good anyways; it's always better to put something on the page)

load = (callback)->
	fs.readFile file, "utf8", (err, json)->
		if err?.code is "ENOENT"
			callback null, ContentState.createFromBlockArray([])
			return
		return callback err if err
		try
			raw = JSON.parse(json)
		catch err
			return callback err if err
		contentState = convertFromRaw(raw)
		callback null, contentState

class App extends React.Component
	render: ->
		E Journal,
			onChange: save
			ref: "journal"
	
	componentDidMount: ->
		load (err, contentState)=>
			if err
				console.error err
				alert "Failed to load journal:\n#{err}"
				return
			loaded = yes
			@refs.journal.setContentState contentState

ReactDOM.render (E App), container
