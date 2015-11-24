KEY_CODE_CTRL = 17
KEY_CODE_SPACE = 32
KEY_CODE_LESS = 226

isCtrlDown = no
page = 1
range = null
prefix = null

lastPageInfo = ->
  activeEditor = atom.workspace.getActiveTextEditor()

  parsedPage = 0
  parsedPrefix = ""

  endPoint = activeEditor.getCursorBufferPosition()
  searchRange = [[ 0, 0 ], [ endPoint.row, endPoint.column ]]
  searchRegexp = /\/([^\/]*?)(\d+)\/\/\//

  activeEditor.backwardsScanInBufferRange searchRegexp, searchRange, ({ match, stop }) ->
    parsedPage = +match[ 2 ]
    parsedPrefix = match[ 1 ]
    stop()

  page: parsedPage
  prefix: parsedPrefix


keydownListener = ( event ) ->
  activeEditor = atom.workspace.getActiveTextEditor()
  unless activeEditor
    return

  if isCtrlDown
    return

  if event.keyCode is KEY_CODE_CTRL
    console.info "CTRL DOWN"
    range = null
    isCtrlDown = yes
    { page, prefix } = lastPageInfo()
    page += 1


keyupListener = ( event ) ->
  activeEditor = atom.workspace.getActiveTextEditor()
  unless activeEditor
    return

  unless isCtrlDown
    return

  if event.keyCode is KEY_CODE_CTRL
    console.info "CTRL UP"
    isCtrlDown = no

  else if event.keyCode is KEY_CODE_SPACE
    console.log "KEY_CODE_SPACE"
    if range
      range[ 1 ][ 1 ] = range[ 0 ][ 1 ] + "/#{prefix}#{page}/// ".length
      page += 1
      activeEditor.setTextInBufferRange range, "/#{prefix}#{page}/// "
    else
      cursorPoint = activeEditor.getCursorBufferPosition()
      insertRange = [ cursorPoint, cursorPoint ]
      originalRange = activeEditor.setTextInBufferRange insertRange, "/#{prefix}#{page}/// "
      # Convert to an array because the original Range is immutable.
      range = originalRange.serialize()

  else if event.keyCode is KEY_CODE_LESS
    console.log "KEY_CODE_LESS"
    page = lastPageInfo().page or 1
    cursorPoint = activeEditor.getCursorBufferPosition()
    insertRange = [ cursorPoint, cursorPoint ]
    r = activeEditor.setTextInBufferRange insertRange, "//// /#{page}///"
    activeEditor.setCursorBufferPosition [ r.start.row, r.start.column + 3 ]

  else
    console.log event.keyCode


module.exports = AtomPlanner =
  activate: ->
    workspaceView = atom.views.getView atom.workspace
    workspaceView.addEventListener "keydown", keydownListener
    workspaceView.addEventListener "keyup", keyupListener

  deactivate: ->
    console.log "deactivating!"
    workspaceView = atom.views.getView atom.workspace
    workspaceView.removeEventListener "keydown", keydownListener
    workspaceView.removeEventListener "keyup", keyupListener
