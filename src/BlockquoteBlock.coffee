
E = require "react-script"
React = require "react"

module.exports =
	class BlockquoteBlock extends React.Component
		render: ->
			# TODO: clean up by making this just a blockquote element
			# TODO: should blockquotes have timestamps?
			E "article.block.blockquote",
				# data: timestamp: "<timestamp>"
				E "blockquote",
					@props.children
