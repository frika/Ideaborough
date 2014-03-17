_isString = (value) ->
  # Stolen from _.js
  Object::toString.call(value) == "[object String]"

# Workaround for IE
activeDragAndDropTypes = null

class DragAndDrop
  iconAndSize: null
  _typesForEvent: (e) ->
    return activeDragAndDropTypes if activeDragAndDropTypes

    keys = for key in e.dataTransfer.types
      key

    keys

  _mouseIsOutside: (e, element) ->
    rect = element.getBoundingClientRect()
    x = e.clientX
    y = e.clientY
    (x < rect.left || x >= rect.right || y < rect.top || y >= rect.bottom)

  _setDataForEvent: (e, elements, options) ->
    if options.context
      context = options.context(elements, e.currentTarget, e.dataTransfer)
      keys = []

      supportsCustomTypes = try
        e.dataTransfer.setData("test/com.metalabdesign.dnd", "success")
        e.dataTransfer.clearData("test/com.metalabdesign.dnd")
        true
      catch error
        false

      if supportsCustomTypes
        for key, value of context
          value = if _isString(value) then value else JSON.stringify(value)
          e.dataTransfer.setData(key, value)
      else
        keys = for key, value of context
          key
        activeDragAndDropTypes = keys

        if URL = context.URL
          e.dataTransfer.setData "URL", URL

        e.dataTransfer.setData "Text", JSON.stringify(context)


  _dataFromEvent: (e) ->
    if activeDragAndDropTypes
      value = e.dataTransfer.getData("Text")
      data = try
        JSON.parse value
      catch error
        value

      return data

    else
      data = {}
      for type in e.dataTransfer.types
        try
          value = e.dataTransfer.getData(type)
        catch error
          if type == "Files"
            value = e.dataTransfer.files # IE workaround

        data[type] = try
          JSON.parse value
        catch error
          value

      return data

  _addElementsForEvent: (e) ->
    if @options.addElements
      elements = @options.addElements e, e.dataTransfer, @_elements[0]
      @_elements = elements

  _shouldAccept: (e) ->
    return true if !@options.accepts

    types = @_typesForEvent(e.originalEvent)
    data = @_dataFromEvent(e.originalEvent)
    value = @options.accepts(e, types, data)
    if _isString value
      value = types.indexOf(value) >= 0
    value

  _setupDragImage: (e) ->
    return if !@options.iconAndSize
    dataTransfer = e.dataTransfer
    @iconAndSize = @options.iconAndSize(@_elements, dataTransfer)

    image = @iconAndSize[0]
    if image instanceof Image && !image.complete
      # Early exit; not loaded image will not work and more importantly it craches Safari 6
      return

    if dataTransfer.setDragImage
      if image instanceof HTMLElement
        # Chrome hack; position the drag element where the UA are suppost to position it.
        # This since UA's requires it to be in the DOM and Chrome requires it to be in view…
        @iconAndSize[0] = image = image.cloneNode true
        image.style.position = "absolute"
        image.style.left = "#{e.clientX - @iconAndSize[1]}px"
        image.style.top = "#{e.clientY - @iconAndSize[2]}px"
        document.body.appendChild image
        # Remove it from the DOM at the next run loop
        setTimeout(->
          document.body.removeChild image
        , 0)

      dataTransfer.setDragImage.apply dataTransfer, @iconAndSize

class Draggable extends DragAndDrop
  constructor: (@el, options) ->
    @_elements = []
    @$el = $ @el
    @options = _.defaults options,
      "selector": null
    @enable()

  enable: ->
    @$el.on "dragstart", @options.selector, $.proxy(this, "_dragStart")

  disable: ->
    @$el.off "dragstart", @options.selector, @_dragStart

  _dragEvent: (e) ->
    @options.drag(e, @_elements)

  _dragEndEvent: (e) ->
    @options.stop(e, @_elements) if @options.stop

    @$el.off "drag", @options.selector, @_dragEvent
    @$el.off "dragend", @options.selector, @_dragEndEvent

  _dragStart: (e) ->
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer.effectAllowed = "move" if dataTransfer

    @_elements = [e.currentTarget]
    @_addElementsForEvent e.originalEvent

    @_setDataForEvent e.originalEvent, @_elements, @options

    @_setupDragImage e.originalEvent

    @$el.on "drag", @options.selector, $.proxy(this, "_dragEvent") if @options.drag
    @$el.on "dragend", @options.selector, $.proxy(this, "_dragEndEvent")

    @options.start(e, @_elements) if @options.start

class @Droppable extends DragAndDrop
  isBound: false
  enabled: false
  constructor: (@el, options) ->
    @$el = $ @el
    @options = _.defaults options,
      "selector": null
      "greedy": true

    @enable()

  enable: ->
    return if @enabled
    @enabled = true
    @$el.on "dragenter", @options.selector, $.proxy(this, "_dragenter")

  disable: ->
    @_cleanUp()
    @$el.off "dragenter", @options.selector, @_dragenter
    @enabled = false

  destroy: ->
    @disable()

  _cleanUp: ->
    @$el.off "drop", @options.selector, @_dropEvent
    @$el.off "dragleave", @options.selector, @_dragleave
    @$el.off "dragover", @options.selector, @_dragover
    @isBound = false

  _dragenter: (e) ->
    nativeEvent = e.originalEvent || e
    return if !@_shouldAccept e

    $(e.currentTarget).addClass(@options.hoverClass) if @options.hoverClass
    @options.over(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.over

    return false if @isBound
    @$el.on "drop", @options.selector, $.proxy(this, "_dropEvent")
    @$el.on "dragleave", @options.selector, $.proxy(this, "_dragleave")
    @$el.on "dragover", @options.selector, $.proxy(this, "_dragover")
    @isBound = true
    false

  _dropEvent: (e) ->
    @options.drop(e, @_dataFromEvent(e.originalEvent)) if @options.drop
    $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
    @_cleanUp()

    return if !@options.drop # Make it progagate if no drop event is spesified

    e.stopPropagation()
    false

  _dragleave: (e) ->
    # Hack
    if @_mouseIsOutside(e.originalEvent, e.currentTarget)
      $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
      @options.out(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.out

    if @_mouseIsOutside(e.originalEvent, @el)
      @_cleanUp()

    false

  _dragover: (e) ->
    @options.dragOver(e, e.currentTarget) if @options.dragOver
    e.preventDefault()
    true

class @Sortable extends DragAndDrop
  isBound: false
  enabled: false

  placeholder: null

  constructor: (@el, options = {}) ->
    @_elements = []
    @$el = $ @el
    @options = _.defaults options,
      "skipRender":  false
      "tolerance":   12
      "items":       "[draggable=true]"
      "placeholder": (e, index) ->
        element = document.createElement("li")
        element.className = "placeholder"
        element

    @enable()

  enable: ->
    return if @enabled
    @$el.on "dragstart", @options.items, $.proxy(this, "_dragstartEvent")
    @$el.on "dragover", @options.items, $.proxy(this, "_dragoverEvent")
    @enabled = true

  disable: ->
    @$el.off "dragstart", @options.selector, @_dragStart
    @$el.off "dragover", @options.items, @_dragoverEvent

    @enabled = false

    $(@placeholder).remove() if @placeholder

  _dropEvent: (e) ->
    e.preventDefault()

    return if !@placeholder?.parentNode

    $elements = $ @_elements

    data = @_dataFromEvent(e.originalEvent)
    data.originalIndex = {
      start: $elements.first().index()
      end: $elements.last().index()
    }

    $elements.remove()

    $placeholder = $ @placeholder
    _index = $placeholder.index()

    # If were moving the elements "up", then the placeholder would be above where the elements
    # came from, so we'll need to -1 from the originalIndex indices.
    if (_index < data.originalIndex.start)
      data.originalIndex.start -= 1
      data.originalIndex.end -= 1

    #TODO should probably switch to a document fragment..
    $placeholder.after($elements) if !@options.skipRender
    $placeholder.remove()

    @options.sort.call this, e, _index, data, @_elements if @options.sort
    @options.stop.call this, e, @_elements if @options.stop

    false

  _dragendEvent: (e) ->
    if @_elements.length
      @options.stop e, @_elements if @options.stop
      $(@placeholder).remove()
      @placeholder = null

    @_elements = []
    @_cleanUp()

  _cleanUp: ->
    @$el.off "drop", @el, @_dropEvent
    @$el.off "dragend", @options.items, @_dragendEvent
    @$el.off "dragleave", @_dragleave
    @isBound = false

  _dragleave: (e) ->
    if @_mouseIsOutside(e.originalEvent, e.currentTarget)
      $(@placeholder).remove()
      @placeholder = null

    if @_mouseIsOutside(e.originalEvent, @el)
      @options.out(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.out

  _dragstartEvent: (e) ->
    $currentTarget = $ e.currentTarget
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer.effectAllowed = "move" if dataTransfer

    @_elements = [e.currentTarget]
    @_addElementsForEvent e.originalEvent

    @_setDataForEvent e.originalEvent, @_elements, @options

    @_setupDragImage e.originalEvent

    @options.start(e, @_elements) if @options.start

    e.stopPropagation()

  boot: ->
    return if @isBound

    @$el.on "drop", @el, $.proxy(this, "_dropEvent")
    @$el.on "dragend", @options.items, $.proxy(this, "_dragendEvent")
    @$el.on "dragleave", $.proxy(this, "_dragleave")

    @isBound = true

  _dragoverEvent: (e) ->
    e.preventDefault()
    placeholderIndex = $(@placeholder).index()
    targetIndex = $(e.currentTarget).index()

    rect = e.currentTarget.getBoundingClientRect()
    x = e.originalEvent.clientX
    y = e.originalEvent.clientY
    return if placeholderIndex == targetIndex

    if placeholderIndex == -1
      if (rect.top - y + @options.tolerance) >= 0
        @_flip(e, "before")
      else if (rect.bottom - y - @options.tolerance) <= 0
        @_flip(e, "after")
      return

    if placeholderIndex > targetIndex
      if (rect.top - y + @options.tolerance) >= 0
        @_flip(e, "before")
    else
      if (rect.bottom - y - @options.tolerance) <= 0
        @_flip(e, "after")

    return

  _flip: (e, keyword) ->
    return if e.currentTarget == @placeholder

    nativeEvent = e.originalEvent || e
    return if !@_shouldAccept e
    @boot()

    @options.over(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.over

    @placeholder ||= @options.placeholder(e, @_elements.length)
    $(@placeholder).remove()
    $(e.currentTarget)[keyword](@placeholder)

    e.stopPropagation()

$.fn.droppable = (options = {}) ->
  values = for element in this
    (new Droppable(element, options))

  values

$.fn.draggable = (options = {}) ->
  values = for element in this
    (new Draggable(element, options))

  values

$.fn.sortable = (options = {}) ->
  values = for element in this
    (new Sortable(element, options))

  values
