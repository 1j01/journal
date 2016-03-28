
document.body.addEventListener "mousedown", (e)->
	cell = e.target.closest ".cell"
	if cell.classList.contains "entry"
		code_el = cell.querySelector ".cell > code"
		edit_el = code_el ? cell
		edit_el.setAttribute "contenteditable", "true"
