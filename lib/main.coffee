KEY_CODE_CTRL = 17
KEY_CODE_SPACE = 32

module.exports = AtomPlanner =
  activate: ->
    workspaceView = atom.views.getView atom.workspace

    isCtrlDown = no

    workspaceView.addEventListener "keydown", ( event ) ->
      unless isCtrlDown
        if event.keyCode is KEY_CODE_CTRL
          isCtrlDown = yes
          console.log "Control on"

    workspaceView.addEventListener "keyup", ( event ) ->
      if isCtrlDown
        if event.keyCode is KEY_CODE_CTRL
          isCtrlDown = no
          console.log "Control off"

        else if event.keyCode is KEY_CODE_SPACE
          console.log "Space off"
