
E = require "react-script"
React = require "react"
ReactDOM = require "react-dom"
{Editor, EditorState, RichUtils, CompositeDecorator} = require "draft-js"
EntryBlock = require "./EntryBlock"

HASHTAG_REGEX = /(?:^|\s)\#[\w\u0590-\u05ff]+/g

hashtagStrategy = (contentBlock, callback)->
	findWithRegex(HASHTAG_REGEX, contentBlock, callback)

findWithRegex = (regex, contentBlock, callback)->
	text = contentBlock.getText()
	while (matchArr = regex.exec(text)) isnt null
		start = matchArr.index
		callback(start, start + matchArr[0].length)

HashtagSpan = (props)->
	E "span.hashtag", props,
		props.children

getSelectedBlockElement = ->
	selection = window.getSelection()
	# console.log selection
	return null if selection.rangeCount is 0
	# selection.getRangeAt(0).startContainer?.closest("[data-block='true']")
	node = selection.getRangeAt(0).startContainer
	loop
		# return node if node.getAttribute?('data-block') is 'true'
		return node if node.classList?.contains "block"
		node = node.parentNode
		break unless node

# Custom overrides for "code" style.
# styleMap =
# 	CODE:
# 		backgroundColor: 'rgba(0, 0, 0, 0.05)'
# 		fontFamily: '"Inconsolata", "Menlo", "Consolas", monospace'
# 		fontSize: 16
# 		padding: 2

# getBlockStyle = (block)->
# 	switch block.getType()
# 		when 'blockquote' then 'RichEditor-blockquote'
# 		else null

class StyleButton extends React.Component
	constructor: ->
		super
		@onToggle = (e)=>
			e.preventDefault()
			@props.onToggle(@props.style)

	render: ->
		className = 'RichEditor-styleButton'
		if @props.active
			className += ' RichEditor-activeButton'

		E "span",
			{className, onMouseDown: @onToggle}
			@props.label

BLOCK_TYPES = [
	{label: 'H1', style: 'header-one'},
	{label: 'H2', style: 'header-two'},
	{label: 'H3', style: 'header-three'},
	{label: 'H4', style: 'header-four'},
	{label: 'H5', style: 'header-five'},
	{label: 'H6', style: 'header-six'},
	{label: 'Blockquote', style: 'blockquote'},
	{label: 'UL', style: 'unordered-list-item'},
	{label: 'OL', style: 'ordered-list-item'},
	{label: 'Code Block', style: 'code-block'},
]

BlockStyleControls = (props) =>
	{editorState} = props
	selection = editorState.getSelection()
	blockType = editorState
		.getCurrentContent()
		.getBlockForKey(selection.getStartKey())
		.getType()
	
	E ".RichEditor-controls",
		BLOCK_TYPES.map (type) =>
			E StyleButton,
				key: type.label
				active: type.style is blockType
				label: type.label
				onToggle: props.onToggle
				style: type.style

INLINE_STYLES = [
	{label: 'Bold', style: 'BOLD'},
	{label: 'Italic', style: 'ITALIC'},
	{label: 'Underline', style: 'UNDERLINE'},
	{label: 'Monospace', style: 'CODE'},
]

InlineStyleControls = (props) =>
	currentStyle = props.editorState.getCurrentInlineStyle()
	E ".RichEditor-controls",
		INLINE_STYLES.map (type)=>
			E StyleButton,
				key: type.label
				active: currentStyle.has(type.style)
				label: type.label
				onToggle: props.onToggle
				style: type.style

module.exports =
	class Journal extends React.Component
		constructor: ->
			super
			
			compositeDecorator = new CompositeDecorator [
				{
					strategy: hashtagStrategy
					component: HashtagSpan
				}
			]
			
			@state = editorState: EditorState.createEmpty(compositeDecorator)
			
			@onChange = (editorState)=>
				@props.onChange(editorState)
				@setState {editorState}
			
			@setContentState = (contentState)=>
				@setState editorState: EditorState.createWithContent(contentState, compositeDecorator)
			
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
		
		handleKeyCommand: (command)=>
			newState = RichUtils.handleKeyCommand(@state.editorState, command)
			if newState
				@onChange newState
				return true
			false
		
		toggleBlockType: (blockType)=>
			@onChange RichUtils.toggleBlockType(@state.editorState, blockType)
		
		toggleInlineStyle: (inlineStyle)=>
			@onChange RichUtils.toggleInlineStyle(@state.editorState, inlineStyle)
		
		render: ->
			{editorState} = @state
			{onChange} = @
			E ".journal",
				E Editor, {
					editorState
					onChange
					spellCheck: on
					handleKeyCommand: @handleKeyCommand
					blockRendererFn: @renderBlock
				}
				E "button.block-controls-dropdown-button",
					ref: "dropdownButton"
					"⋮"
		
		componentDidUpdate: ->
			# TODO: also on window resize
			dropdownButtonEl = ReactDOM.findDOMNode(@refs.dropdownButton)
			selectedBlockEl = getSelectedBlockElement()
			# console.log selectedBlockEl
			if selectedBlockEl
				dropdownButtonEl.style.display = ""
				dropdownButtonEl.style.position = "absolute"
				dropdownButtonEl.style.top = "#{selectedBlockEl.offsetTop}px"
				dropdownButtonEl.style.left = "#{selectedBlockEl.offsetLeft + selectedBlockEl.offsetWidth}px"
			else
				setTimeout =>
					unless dropdownButtonEl is document.activeElement
						dropdownButtonEl.style.display = "none"
