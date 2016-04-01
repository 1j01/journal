
E = require "react-script"
React = require "react"
{EditorBlock} = require "draft-js"

module.exports =
	class CodeBlock extends React.Component
		render: ->
			E "article.block.entry",
				data: timestamp: "<timestamp>"
				E "code",
					E EditorBlock, @props # ??
