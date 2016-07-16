
E = require "react-script"
React = require "react"

module.exports =
	class ProseBlock extends React.Component
		render: ->
			# TODO: extract this article timetamp stuff (DRY)
			E "article.block.prose-block",
				data: timestamp: "<timestamp>"
				E ".prose",
					@props.children
