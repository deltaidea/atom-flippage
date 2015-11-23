KEY_CODE_CTRL = 17
KEY_CODE_SPACE = 32

module.exports = AtomPlanner =
  activate: ->
    workspaceView = atom.views.getView atom.workspace

    isCtrlDown = no
    page = 1
    range = null
    prefix = null

    workspaceView.addEventListener "keydown", ( event ) ->
      unless isCtrlDown
        if event.keyCode is KEY_CODE_CTRL
          page = 1
          range = null
          prefix = "p. "
          isCtrlDown = yes
          console.log "Control on"

    workspaceView.addEventListener "keyup", ( event ) ->
      if isCtrlDown
        if event.keyCode is KEY_CODE_CTRL
          isCtrlDown = no
          console.log "Control off"

        else if event.keyCode is KEY_CODE_SPACE
          activeEditor = atom.workspace.getActiveTextEditor()
          if activeEditor
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
