
place_cursor_at_end_of_contenteditable_element = (el)->
	range = document.createRange()
	range.selectNodeContents(el)
	range.collapse(false) # false means collapse to end rather than the start
	selection = window.getSelection()
	selection.removeAllRanges() # remove any selections already made
	selection.addRange(range) # make new the range the visible selection
	# NOTE: might need to use this solution instead: http://stackoverflow.com/a/19588665/2624876


editing_el = null
# TODO: allow drag and drop by making elements contenteditable on dragover

document.body.addEventListener "mousedown", (e)->
	link = e.target.closest "a"
	
	if link?
		link.setAttribute "target", "_blank"
		return
	
	entry = e.target.closest ".entry"
	
	unless editing_el is entry
		editing_el?.removeAttribute "contenteditable"
		editing_el = null
	
	if entry?
		editing_el = entry
		entry.setAttribute "contenteditable", "true"

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
	
	# TODO: perform actions based on the selection ranges only, not e.target
	
	switch e.keyCode
		when 13
			return if e.shiftKey # should this be?
			entry = e.target.closest ".entry"
			console.log "pressed enter in", entry
			if entry?
				e.preventDefault()
				
				new_cell = document.createElement "article"
				new_cell.className = "cell"
				new_entry = document.createElement "p"
				new_entry.className = "entry"
				new_entry.setAttribute "contenteditable", "true"
				new_cell.appendChild new_entry
				
				selection = window.getSelection()
				
				selection.deleteFromDocument() # ...
				
				if selection.rangeCount
					for i in [0...selection.rangeCount]
						range = selection.getRangeAt(i)
						# range.setEnd entry, 1
						range.setEndAfter entry
						unless range.collapsed
							{childNodes} = range.cloneContents()
							{childNodes} = childNodes[0] if childNodes[0]?.classList.contains "entry" # "cell"? needed?
							# console.log child for child in childNodes
							# new_entry.appendChild child for child in childNodes
							for child in childNodes
								console.log "new_entry.appendChild", child
								new_entry.appendChild child if child?
							range.deleteContents()
				
				document.body.insertBefore new_cell, entry.closest(".cell").nextSibling
				
				new_entry.focus()
		
		when 8 # backspace
			entry = e.target.closest ".entry"
			if entry?
				selection = window.getSelection()
				
				previous_entry = entry.closest(".cell").previousElementSibling.querySelector(".entry")
				if previous_entry?
					console.log "previous_entry:", previous_entry
					
					at_start = no
					
					if selection.rangeCount
						for i in [0...selection.rangeCount]
							range = selection.getRangeAt(i)
							
							# console.log range.comparePoint entry, 0
							# range.compareBoundaryPoints Range.START_TO_START, other_range
							
							console.log "range", range.collapsed, range.startOffset, range.startContainer
							
							if range.collapsed # and range.startOffset is 0
								if range.startContainer.nodeType is Node.ELEMENT_NODE
									# note: not very solid logic just checking innerHTML on one element
									if range.startOffset > 0 and range.startContainer.children[range.startOffset - 1]?.innerHTML
										continue # as in don't continue
								else
									if range.startOffset > 0
										text = range.startContainer.nodeValue
										if range.startOffset > "#{text}|".length - "#{text}|".trim().length
											continue # as in don't continue
								container = range.startContainer
								loop
									if container?
										if container is entry
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
										console.log "didn't find a parent element eq to", entry
										break
								# if range.startContainer
					else
						console.log "no selection"
					
					console.log "at_start:", at_start
					
					if at_start
						e.preventDefault()
						previous_entry.setAttribute "contenteditable", "true"
						place_cursor_at_end_of_contenteditable_element previous_entry
						# TODO: use DocumentFragment to transfer I guess
						# for child in entry.childNodes
						# 	previous_entry.appendChild child
						
						childNodes = Array.from entry.childNodes
						
						# if the previous entry's last element and this entry's first element are both paragraphs
						previous_entry_last_el = previous_entry.childNodes[previous_entry.childNodes.length - 1]
						if previous_entry_last_el?.tagName is "P" and childNodes[0]?.tagName is "P"
							console.log "got two paragraphs to merge"
							p = childNodes.shift()
							merge_into_p = previous_entry_last_el
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
						
						cell = entry.closest ".cell"
						cell.parentElement.removeChild cell
						previous_entry.appendChild frag

		
		when 46 # delete
			@TODO

document.body.addEventListener "paste", (e)->
	# TODO: remove font-size, font-family and probably line-height from styles of at least <p> elements
	# TODO: detect code, automatically make code blocks

# TODO: undo/redo
# TODO: multi-cell selection???
