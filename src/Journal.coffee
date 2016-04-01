
E = require "react-script"
React = require "react"
{Editor, EditorState, RichUtils} = require "draft-js"
EntryBlock = require "./EntryBlock"

module.exports =
	class Journal extends React.Component
		constructor: ->
			super
			@state = editorState: EditorState.createEmpty()
			@onChange = (editorState) =>
				@setState {editorState}
			@renderBlock = (contentBlock)=>
				switch contentBlock.getType()
					when "image", "video"
						component: MediaBlock
						editable: false
						# props: foo: 'bar'
					when "code"
						component: CodeBlock
						editable: false
						# props: foo: 'bar'
					else
						component: EntryBlock
						editable: false
		
		render: ->
			{editorState} = @state
			{onChange} = @
			E ".journal",
				E Editor, {
					editorState
					onChange
					spellCheck: on
					blockRendererFn: @renderBlock
				}
