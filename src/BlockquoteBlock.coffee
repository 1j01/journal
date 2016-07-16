
E = require "react-script"
React = require "react"

module.exports =
	class BlockquoteBlock extends React.Component
		render: ->
			# TODO: blockquotes with attribution
			E "article.block.blockquote",
				E "blockquote",
					@props.children
