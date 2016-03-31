###
# Enables spell-checking and the right-click context menu in text editors.
# Electron (`webFrame.setSpellCheckProvider`) only underlines misspelled words
# we must manage the menu ourselves.
#
# Run this in the renderer process.
###

{remote, webFrame} = require('electron')
SpellCheckProvider = require('electron-spell-check-provider')
buildEditorContextMenu = remote.require('electron-editor-context-menu')

selection = null
do resetSelection = ->
	selection =
		isMisspelled: false
		spellingSuggestions: []

# Reset the selection when clicking around, before the spell-checker runs and the context menu shows.
window.addEventListener('mousedown', resetSelection)

# The spell-checker runs when the user clicks on text and before the 'contextmenu' event fires.
# Thus, we may retrieve spell-checking suggestions to put in the menu just before it shows.
webFrame.setSpellCheckProvider 'en-US',
	# Not sure what this parameter (`autoCorrectWord`) does: https://github.com/atom/electron/issues/4371
	# The documentation for `webFrame.setSpellCheckProvider` passes `true` so we do too.
	true,
	new SpellCheckProvider('en-US').on 'misspelling', (suggestions)->
		# Prime the context menu with spelling suggestions _if_ the user has selected text. Electron
		# may sometimes re-run the spell-check provider for an outdated selection e.g. if the user
		# right-clicks some misspelled text and then an image.
		if window.getSelection().toString()
			selection.isMisspelled = true
			# Take the first three suggestions if any.
			selection.spellingSuggestions = suggestions.slice(0, 3)

window.addEventListener 'contextmenu', (e)->
	# Only show the context menu in text editors.
	return unless e.target.closest('textarea, input, [contenteditable="true"]')

	menu = buildEditorContextMenu(selection)

	# The 'contextmenu' event is emitted after 'selectionchange' has fired but possibly before the
	# visible selection has changed. Try to wait to show the menu until after that, otherwise the
	# visible selection will update after the menu dismisses and look weird.
	setTimeout ->
		menu.popup remote.getCurrentWindow()
	, 30
