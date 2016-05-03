
E = require "react-script"
React = require "react"
{EditorBlock} = require "draft-js"

module.exports =
	class BlockquoteBlock extends React.Component
		render: ->
			# TODO: extract this article timetamp stuff (DRY)
			# TODO: should blockquotes have timestamps?
			# TODO: maybe have a prose block styled similarly but with timestamps (and no big quote characters)
			E "article.block.blockquote",
				# data: timestamp: "<timestamp>"
				E "blockquote",
					E EditorBlock, @props # ??
