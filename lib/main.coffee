KEY_CODE_CTRL = 17
KEY_CODE_SPACE = 32

pageInfo = ->
  activeEditor = atom.workspace.getActiveTextEditor()

  page = 1
  prefix = "p. "

  endRow = activeEditor.getLastBufferRow()
  endColumn = ( activeEditor.lineTextForBufferRow endRow ).length
  searchRange = [[ 0, 0 ], [ endRow, endColumn ]]
  searchRegexp = /\/(.*?)(\d+)\/\/\//

  activeEditor.backwardsScanInBufferRange searchRegexp, searchRange, ({ match, stop }) ->
    page = +match[ 2 ] + 1
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
        { page, prefix } = pageInfo()
        console.log "Control on"

    workspaceView.addEventListener "keyup", ( event ) ->
      activeEditor = atom.workspace.getActiveTextEditor()
      unless activeEditor
        return

      unless isCtrlDown
        return

      if event.keyCode is KEY_CODE_CTRL
        isCtrlDown = no
        console.log "Control off"

      else if event.keyCode is KEY_CODE_SPACE
        if range
          page += 1
          activeEditor.setTextInBufferRange range, " /#{prefix}#{page}///"
        else
          r = ( activeEditor.insertText " /#{prefix}#{page}///" )[ 0 ]
          # Range instances seem to be immutable.
          # Let's use a Range-compatible array.
          range = [
            [ r.start.row
              r.start.column ]
            # Offset for when the page number gets longer.
            # 10 orders of magnitude is enough.
            [ r.end.row
              r.end.column + 10 ]
          ]
          console.log range
