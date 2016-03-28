
place_cursor_at_end_of_contenteditable_element = (el)->
	range = document.createRange()
	range.selectNodeContents(el)
	range.collapse(false) # false means collapse to end rather than the start
	selection = window.getSelection()
	selection.removeAllRanges() # remove any selections already made
	selection.addRange(range) # make new the range the visible selection


editing_el = null
# TODO: allow drag and drop by making elements contenteditable on dragover

document.body.addEventListener "mousedown", (e)->
	link = e.target.closest "a"
	if link?
		link.setAttribute "target", "_blank"
		return
	
	cell = e.target.closest ".cell"
	if cell?.classList.contains "entry"
		code_el = cell.querySelector ".cell > code"
		edit_el = code_el ? cell
		editing_el?.removeAttribute "contenteditable"
		editing_el = edit_el
		edit_el.setAttribute "contenteditable", "true"
		# TODO: allow following links

document.body.addEventListener "focusout", (e)->
	# console.log "focusout", e
	unless e.relatedTarget is editing_el
		editing_el?.removeAttribute "contenteditable"
		# TODO: when editing_el is the last cell (a placeholder for new entries),
		# add a new cell for new entries
		# (don't need to handle the case of when it's empty by
		# not removing the attribute and not creating a new element
		# because that should be functionally identical)

document.body.addEventListener "keydown", (e)->
	return if e.ctrlKey or e.altKey or e.metaKey
	switch e.keyCode
		when 13
			return if e.shiftKey # should this be?
			cell = e.target.closest ".cell"
			console.log "pressed enter in", cell
			if cell?.classList.contains "entry"
				e.preventDefault()
				
				new_cell = document.createElement "article"
				new_cell.className = "entry cell"
				new_cell.setAttribute "contenteditable", "true"
				
				selection = window.getSelection()
				
				selection.deleteFromDocument() # ...
				
				if selection.rangeCount
					for i in [0...selection.rangeCount]
						range = selection.getRangeAt(i)
						# range.setEnd cell, 1
						range.setEndAfter cell
						unless range.collapsed
							# new_cell.appendChild range.cloneContents()
							# new_cell.appendChild range.extractContents()
							# console.log range.extractContents().childNodes
							# console.log (a = range.extractContents()).childNodes
							# new_cell.appendChild a
							# contents = range.cloneContents()
							# if contents.childNodes[0].classList.contains "cell"
							# 	contents = contents.childNodes[0].childNodes
							# new_cell.appendChild contents
							{childNodes} = range.cloneContents()
							{childNodes} = childNodes[0] if childNodes[0]?.classList.contains "cell"
							# console.log child for child in childNodes
							# new_cell.appendChild child for child in childNodes
							for child in childNodes
								console.log "new_cell.appendChild", child
								new_cell.appendChild child if child?
							range.deleteContents()
				
				# document.body.insertAfter new_cell, cell
				document.body.insertBefore new_cell, cell.nextSibling
				
				if new_cell.children.length is 0
					new_cell.appendChild document.createElement "p"
				
				new_cell.focus()
		
		when 8 # backspace
			cell = e.target.closest ".cell"
			if cell?.classList.contains "entry"
				selection = window.getSelection()
				
				previous_cell = cell.previousElementSibling
				if previous_cell?.classList.contains "entry"
					console.log "previous_cell:", previous_cell
					
					at_start = no
					
					if selection.rangeCount
						for i in [0...selection.rangeCount]
							range = selection.getRangeAt(i)
							
							# console.log range.comparePoint cell, 0
							# range.compareBoundaryPoints Range.START_TO_START, other_range
							
							console.log "range", range.collapsed, range.startOffset, range.startContainer
							
							if range.collapsed # and range.startOffset is 0
								if range.startContainer.nodeType is Node.ELEMENT_NODE
									# note: not very solid logic just checking innerHTML on one element
									if range.startOffset > 0 and range.startContainer.children[range.startOffset - 1].innerHTML
										continue # as in, don't continue
								else
									if range.startOffset > 0
										continue # as in, don't continue
								container = range.startContainer
								loop
									if container?
										if container is cell
											at_start = yes
											break
										else
											not_at_start = no
											sibling = container
											while sibling = sibling.previousSibling
												console.log "hm?", sibling
												if sibling.nodeValue?.trim() or sibling.innerHTML
													console.log "not empty: has", sibling
													not_at_start = yes
													break
											if not_at_start
												break
										container = container.parentElement
									else
										console.log "didn't find a parent element eq to", cell
										break
								# if range.startContainer
					else
						console.log "no selection"
					
					console.log "at_start:", at_start
					
					if at_start
						e.preventDefault()
						previous_cell.setAttribute "contenteditable", "true"
						place_cursor_at_end_of_contenteditable_element previous_cell
						# TODO: use DocumentFragment to transfer I guess
						# for child in cell.childNodes
						# 	previous_cell.appendChild child
						
						childNodes = Array.from cell.childNodes
						
						# if the previous cell's last element and this cell's first element are both paragraphs
						previous_cell_last_el = previous_cell.childNodes[previous_cell.childNodes.length - 1]
						if previous_cell_last_el?.tagName is "P" and childNodes[0]?.tagName is "P"
							console.log "got two paragraphs to merge"
							p = childNodes.shift()
							merge_into_p = previous_cell_last_el
							console.log p, p.childNodes
							frag = document.createDocumentFragment()
							for child in p.childNodes
								frag.appendChild child if child?
							console.log "merging", frag.childNodes, "from", p, "into", merge_into_p
							merge_into_p.appendChild frag
						
						frag = document.createDocumentFragment()
						
						for child in childNodes
							if child?.tagName is "P"
								for grandkid in child.childNodes
									frag.appendChild grandkid if grandkid?
							else
								frag.appendChild child if child?
						
						cell.parentElement.removeChild cell
						previous_cell.appendChild frag

		
		when 46 # delete
			@TODO

document.body.addEventListener "paste", (e)->
	# TODO: remove font-size, font-family and probably line-height from styles of at least <p> elements
	# TODO: detect code, automatically make code blocks

# TODO: undo/redo
# TODO: multi-cell selection???
