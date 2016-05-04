
E = require "react-script"
React = require "react"
ReactDOM = require "react-dom"
{Editor, EditorState, RichUtils, CompositeDecorator} = require "draft-js"
EntryBlock = require "./EntryBlock"
CodeBlock = require "./CodeBlock"
BlockquoteBlock = require "./BlockquoteBlock"
ProseBlock = require "./ProseBlock"

HASHTAG_REGEX = /\#[\w\u0590-\u05ff]+/g
LINK_REGEX = /(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/g

hashtagStrategy = (contentBlock, callback)->
	# return unless contentBlock.type in ["unstyled", "prose-block", "blockquote"]
	return if contentBlock.type in ["code-block"]
	findWithRegex(HASHTAG_REGEX, contentBlock, callback)

linkStrategy = (contentBlock, callback)->
	# return unless contentBlock.type in ["unstyled", "prose-block", "blockquote"]
	return if contentBlock.type in ["code-block"]
	findWithRegex(LINK_REGEX, contentBlock, callback)

findWithRegex = (regex, contentBlock, callback)->
	text = contentBlock.getText()
	while (matchArr = regex.exec(text)) isnt null
		start = matchArr.index
		callback(start, start + matchArr[0].length)

Hashtag = (props)->
	E "a.hashtag", href: "##{props.decoratedText.replace(/^[\s#]+/, "")}",
		props.children

Link = (props)->
	url = props.decoratedText
	unless url.match /^http:/
		url = "http://#{url}"
	E "a", href: url, target: "_blank",
		props.children

getSelectedBlockElement = ->
	selection = window.getSelection()
	return null if selection.rangeCount is 0
	node = selection.getRangeAt(0).startContainer
	loop
		return node if node.classList?.contains "block"
		node = node.parentNode
		break unless node

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
		
		E ".menuitem",
			{className, onClick: @onToggle}
			@props.label

BLOCK_TYPES = [
	{label: 'Paragraph', style: 'unstyled'}
	# {label: 'H1', style: 'header-one'}
	# {label: 'H2', style: 'header-two'}
	# {label: 'H3', style: 'header-three'}
	# {label: 'H4', style: 'header-four'}
	# {label: 'H5', style: 'header-five'}
	# {label: 'H6', style: 'header-six'}
	{label: 'Blockquote', style: 'blockquote'}
	{label: 'Prose', style: 'prose-block'}
	# {label: 'UL', style: 'unordered-list-item'}
	# {label: 'OL', style: 'ordered-list-item'}
	{label: 'Code Block', style: 'code-block'}
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
	{label: 'Bold', style: 'BOLD'}
	{label: 'Italic', style: 'ITALIC'}
	{label: 'Underline', style: 'UNDERLINE'}
	{label: 'Monospace', style: 'CODE'}
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

class BlockControlsDropdown extends React.Component
	constructor: ->
		@state = menuOpen: no
	
	render: ->
		# TODO: go to the left when space isn't fully available to the right
		{editorState} = @props
		onToggle = (style)=>
			@props.onToggle(style)
			@setState menuOpen: no
		E ".block-controls-dropdown-container",
			ref: "dropdownContainer"
			E "button.block-controls-dropdown-button",
				onClick: =>
					@setState menuOpen: not @state.menuOpen
				"⋮"
			E ".menu.block-controls-dropdown-menu",
				ref: "dropdownMenu"
				style: display: (if @state.menuOpen then "block" else "none")
				BlockStyleControls {editorState, onToggle}
				# E "hr"
				# E ".menuitem",
				# 	onClick: =>
				# 		alert "Not implemented. Delete it yourself."
				# 		@setState menuOpen: no
				# 	"Delete Block"
	
	componentDidMount: ->
		@onmousedown = addEventListener "mousedown", (e)=>
			return if e.target.closest(".block-controls-dropdown-container")
			@setState menuOpen: no
	
	componentWillUnmount: ->
		removeEventListener "mousedown", @onmousedown

module.exports =
	class Journal extends React.Component
		constructor: ->
			super
			
			compositeDecorator = new CompositeDecorator [
				{
					strategy: linkStrategy
					component: Link
				}
				{
					strategy: hashtagStrategy
					component: Hashtag
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
					when "media"
						component: MediaBlock
						editable: false
					when "code-block"
						component: CodeBlock
						editable: false
					when "blockquote"
						component: BlockquoteBlock
						editable: false
					when "prose-block"
						component: ProseBlock
						editable: false
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
			{editorState, readOnly} = @state
			{onChange} = @
			E ".journal",
				E Editor, {
					editorState
					readOnly
					onChange
					spellCheck: on
					handleKeyCommand: @handleKeyCommand
					blockRendererFn: @renderBlock
					ref: "editor"
				}
				E BlockControlsDropdown, {editorState, onToggle: @toggleBlockType, ref: "dropdown"}
		
		componentDidMount: ->
			ReactDOM.findDOMNode(@refs.editor).addEventListener "mousedown", @onmousedown = (e)=>
				if e.target.closest("a")
					@setState readOnly: yes
			
			addEventListener "mouseup", @onmouseup = =>
				setTimeout =>
					@setState readOnly: no
			
			addEventListener "resize", @onresize = =>
				@updateDropdownMenu()
		
		componentWillUnmount: ->
			ReactDOM.findDOMNode(@refs.editor).removeEventListener "mousedown", @onmousedown
			removeEventListener "mouseup", @onmouseup
			removeEventListener "resize", @onresize
		
		componentDidUpdate: ->
			@updateDropdownMenu()
		
		updateDropdownMenu: ->
			dropdownEl = ReactDOM.findDOMNode(@refs.dropdown)
			selectedBlockEl = getSelectedBlockElement()
			# FIXME: reposition when resizing with menu open
			if selectedBlockEl
				dropdownEl.style.display = ""
				dropdownEl.style.position = "absolute"
				additionalOffsetTop =
					if selectedBlockEl.classList.contains("code-block")
						selectedBlockEl.querySelector("code").offsetTop
					else if selectedBlockEl.classList.contains("prose-block")
						selectedBlockEl.querySelector(".prose").offsetTop
					else
						0
				dropdownEl.style.top = "#{selectedBlockEl.offsetTop + additionalOffsetTop}px"
				dropdownEl.style.left = "#{selectedBlockEl.offsetLeft + selectedBlockEl.offsetWidth - 4}px"
				dark = selectedBlockEl.classList.contains("code-block")
				dropdownEl.classList[if dark then "add" else "remove"]("over-dark-block")
				# console.log selectedBlockEl.classList, dark, dropdownEl.classList
			else
				setTimeout =>
					unless dropdownEl is document.activeElement.parentElement
						dropdownEl.style.display = "none"
