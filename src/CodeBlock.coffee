
E = require "react-script"
React = require "react"

module.exports =
	class CodeBlock extends React.Component
		render: ->
			# TODO: extract this article timetamp stuff (DRY)
			E "article.block.code-block",
				data: timestamp: "<timestamp>"
				E "code",
					@props.children
