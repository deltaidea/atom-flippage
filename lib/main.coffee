KEY_CODE_CTRL = 17
KEY_CODE_SPACE = 32
KEY_CODE_LESS = 226

lastPageInfo = ->
  activeEditor = atom.workspace.getActiveTextEditor()

  page = 0
  prefix = ""

  endPoint = activeEditor.getCursorBufferPosition()
  searchRange = [[ 0, 0 ], [ endPoint.row, endPoint.column ]]
  searchRegexp = /\/([^\/]*?)(\d+)\/\/\//

  activeEditor.backwardsScanInBufferRange searchRegexp, searchRange, ({ match, stop }) ->
    page = +match[ 2 ]
    prefix = match[ 1 ]
    stop()

  { page, prefix }


module.exports = AtomPlanner =
  activate: ->
    workspaceView = atom.views.getView atom.workspace

    isCtrlDown = no
    page = 1
    range = null
    prefix = null

    workspaceView.addEventListener "keydown", ( event ) ->
      activeEditor = atom.workspace.getActiveTextEditor()
      unless activeEditor
        return

      if isCtrlDown
        return

      if event.keyCode is KEY_CODE_CTRL
        range = null
        isCtrlDown = yes
        { page, prefix } = lastPageInfo()
        page += 1

    workspaceView.addEventListener "keyup", ( event ) ->
      activeEditor = atom.workspace.getActiveTextEditor()
      unless activeEditor
        return

      unless isCtrlDown
        return

      if event.keyCode is KEY_CODE_CTRL
        isCtrlDown = no

      else if event.keyCode is KEY_CODE_SPACE
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
        page = lastPageInfo().page or 1
        cursorPoint = activeEditor.getCursorBufferPosition()
        insertRange = [ cursorPoint, cursorPoint ]
        r = activeEditor.setTextInBufferRange insertRange, "//// /#{page}///"
        activeEditor.setCursorBufferPosition [ r.start.row, r.start.column + 3 ]

      else
        console.log event.keyCode
