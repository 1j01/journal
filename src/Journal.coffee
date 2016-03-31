
E = require "react-script"
React = require "react"
{Editor, EditorState, RichUtils} = require "draft-js"

module.exports =
	class Journal extends React.Component
		constructor: ->
			super
			@state = editorState: EditorState.createEmpty()
			@onChange = (editorState) => @setState {editorState}
		
		render: ->
			E ".journal", "Hello World!"
