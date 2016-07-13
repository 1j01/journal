
# TODO: always have a placeholder for new entries at the end
# TODO: improve the initial experience
	# maybe center the first block vertically (i.e. give it 50vh margin-top)
	# maybe make the last entry have extra height so it's easier to click on
	# make it clear where you can click to start typing
	# and focus it automatically so you don't have to

# TODO: drag and drop links
# TODO: fix link/hashtag ux

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

# console.log "wtf"
# require "./src/context-menus"

container = document.createElement "div"
container.className = "app"
document.body.appendChild container

# class App extends React.Component
# 	constructor: ->
# 		@file = "./journal.json"
# 		@loaded = no
# 		fs.readFile @file, "utf8", (err, json)=>
# 			return if err?.code is "ENOENT"
# 			if err
# 				console.error err
# 				alert "Failed to load journal:\n#{err}"
# 				return
# 			contentState = convertFromRaw(JSON.parse(json))
# 			console.log "@refs.journal", @refs.journal
# 			@refs.journal.setContentState contentState
# 		@onChange = (editorState)=>
# 			contentState = editorState.getCurrentContent()
# 			json = JSON.stringify(convertToRaw(contentState))
# 			if @loaded
# 				fs.writeFile @file, json, "utf8", (err)->
# 					console.error err if err
# 			else
# 				alert "Journal not loaded"
# 	
# 	render: ->
# 		E Journal,
# 			onChange: @onChange
# 			ref: "journal"
# 
# ReactDOM.render (E App), container

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
			console.log "@refs.journal", @refs.journal
			@refs.journal.setContentState contentState

ReactDOM.render (E App), container, ->
	console.log @, arguments
	
