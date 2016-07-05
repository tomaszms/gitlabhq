class @Ansi2Html
  constructor: ->
    @_colorRegex = /\[[0-9]+;[0-9]?m/g
    @_colors = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white']
    @_html = []

  html: ->
    @_html

  convertTrace: (trace) ->
    if trace?
      @trace = trace.trim().split('\n')

      for line, i in @trace
        @convertLine(line, i+1)

    return @

  convertLine: (line, number) ->
    lineText = if line is '' then ' ' else line
    codes = @getAnsiCodes(line)

    lineEl = @createLine(lineText, number)
    lineEl.prepend @lineLink(number)

    if codes?
      lineEl
        .find('span')
        .addClass @getColorClass(codes.color, codes.type, codes.bold)
        .addClass @getModifierClass(codes.modifier)

    @_html.push(lineEl)

  createLine: (line, number) ->
    $('<p />',
      id: "line-#{number}"
      class: 'build-trace-line'
    ).append $('<span />',
      text: @removeAnsiCodes(line)
    )

  lineLink: (number) ->
    $('<a />',
      class: 'build-trace-line-number'
      href: "#line-#{number}"
      text: number
    )

  getAnsiCodes: (line) ->
    matches = line.match(@_colorRegex)

    if matches?
      match = matches[0]
      modifierSplit = match.split(';')
      color = modifierSplit[0].substring(1)
      colorInt = parseInt(color)
      colorText = @_colors[color[1]]
      modifier = modifierSplit[1][0]

      if colorText?
        return {
          color: colorText
          modifier: modifier
          bold: modifier is "1"
          type: @getLineType(color)
        }

  getLineType: (code) ->
    if code >= 40 and code < 90 or code >= 100
      'bg'
    else
      'fg'

  removeAnsiCodes: (line) ->
    line.replace(@_colorRegex, '')

  getColorClass: (color, type, bold) ->
    bold = if bold then 'l-' else ''

    "term-#{type}-#{bold}#{color}"

  getModifierClass: (modifier) ->
    unless modifier is "1"
      if modifier is "3"
        "term-italic"
      else if modifier is "4"
        "term-underline"
      else if modifier is "8"
        "term-conceal"
      else if modifier is "9"
        "term-cross"
