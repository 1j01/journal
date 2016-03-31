
{expect} = chai

suite "content editing", ->
	test "entering text", ->
		entry = $("#empty-entry")
		entry.trigger("mousedown")
		entry.trigger("click")
		entry.focus()
		entry.trigger("keypress/keydown isn't going to work")
	
	test "formatting text", ->
	test "deleting text", ->
	test "creating new entries", ->
	test "joining entries with backspace", ->
	test "joining entries with delete"
	test "joining spanning tags"
	test "navigating entries with the arrow keys"
	test "clicking links", ->
	test "editing links"
	test "drag and drop"
	test "pasting html"
	test "pasting horrible html"
	# test "pasting images"
	# test "pasting code"
	test "enter enter backspace enter", ->
	test "checking if the cursor is at the begining of an entry"
	test "up up down down left right left right a b b a"
