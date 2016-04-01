
E = require "react-script"
React = require "react"
{EditorBlock} = require "draft-js"

module.exports =
	class EntryBlock extends React.Component
		# constructor: ->
		render: ->
			E "article.block.entry",
				E ".timestamp", contenteditable: "false", "<timestamp here>"
				E EditorBlock, @props # ??
				E ".controls", contenteditable: "false", "⋮"
