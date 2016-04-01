
E = require "react-script"
React = require "react"
{EditorBlock} = require "draft-js"

module.exports =
	class CodeBlock extends React.Component
		render: ->
			# TODO: should .entry be on the code element?
			# TODO: extract this article timetamp stuff (DRY)
			E "article.block.code-block.entry",
				data: timestamp: "<timestamp>"
				E "code",
					E EditorBlock, @props # ??
