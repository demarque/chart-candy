#*************************************************************************************
# TOCOMMENT
#*************************************************************************************
class @ChartCandyLine
  constructor: (@holder) ->
    @tickSize = 80
    @legendItemMargin = 30
    @legendHeight = 40
    @legendItemIndent = [@legendItemMargin]
    @pointerRadius = 6
    @tooltipPadding = 30
    @tooltipMargin = 15

    @holderChart = @holder.find('div.templates div.chart')
    @holderTable = @holder.find('div.templates div.table')

    @initTools()
    @initSize()

    @loadData @holder.data('url')
    @initUpdateDelay()

  buildPointer: (line, num) ->
    pointer = @chart.append("svg:g").attr("class", "pointer pointer-#{num}")
    pointer.append('svg:circle').attr('r', @pointerRadius)

    xData = for d in line.data then new Date(d.x)
    yData = for d in line.data then d.y
    element = d3.select("##{@holder.attr('id')} g.pointer-#{num}")

    return { xData: xData, yData: yData, element: element }


  currentStep: () ->
    path = if @tools.find('div.holder-step select').length > 0 then 'select' else 'div.select-field input'

    return @tools.find('div.holder-step ' + path).val()


  drawAxis: (orientation, domain, size, nature, maxTicks) ->
    translate = switch orientation
      when 'left' then [0,0]
      when 'bottom' then [0,size]
      when 'right' then [size, 0]
      else [0,0]

    qteTicks = if orientation is 'bottom' then @width else @height
    qteTicks = Math.round(qteTicks / @tickSize)
    qteTicks = maxTicks if qteTicks > maxTicks

    padding = if orientation is 'bottom' then 20 else 12

    formatNumber = d3.format(",.0f") # for formatting integers
    formatCurrency = (d) -> formatNumber(d) + "$"

    axis = d3.svg.axis()
    axis = axis.scale(domain).tickSize(-size).ticks(qteTicks).orient(orientation).tickSubdivide(1).tickPadding(padding)

    switch(nature)
      when 'date' then axis = axis.tickFormat d3.time.format("%d-%m")
      when 'money' then axis = axis.tickFormat formatCurrency

    @chart.append("svg:g").attr("class", orientation + " axis").attr("transform", "translate(#{translate[0]}, #{translate[1]})").call axis

    #@rotateLabel() if nature is 'date'


  drawChart: () ->
    @holderChart.html('')

    @chart = d3.select("##{@holder.attr('id')} div.templates div.chart").append("svg:svg").append("svg:g").attr('class', 'chart')
    @chart = @chart.attr("width", @width + @margins[1] + @margins[3])
    @chart = @chart.attr("height", @height + @margins[0] + @margins[2])
    @chart = @chart.attr("transform", "translate(" + @margins[3] + "," + @margins[0] + ")")

    @chart.append('svg:rect').attr('class', 'bg').attr('width', @width).attr('height', @height)

    return @chart


  drawLegend: () ->
    self = this

    legend = @chart.append("svg:g").attr("class", "legend").attr('width', @width).attr("transform", "translate(1,10)")
    holder = legend.append('svg:rect').attr('width', @width-1).attr('height', @legendHeight)
    holder_id = @holder.attr('id')

    itemIndent = @legendItemIndent[0]

    for l,i in @data.lines
      item = legend.append("svg:g").attr("class", "item item-#{i+1}").attr("transform", "translate(#{itemIndent}, 22)").datum({ target: "line-#{i+1}", pointer: "pointer-#{i+1}" })
      item.append('text').attr('transform', "translate(50, 0)").text(l.label)
      item.append('line').attr('x1', 0).attr('y1', -4).attr('x2', @legendHeight).attr('y2', -4)
      item.on('mouseover', (d, i) -> d3.select("##{holder_id} g.#{d.target}").classed('selected', true))
      item.on('mouseout', (d, i) -> d3.select("##{holder_id} g.#{d.target}").classed('selected', false))
      item.on('click', (d, i) -> self.toggleLine(this, d3.select("##{holder_id} g.#{d.target}"), d3.select("##{holder_id} g.#{d.pointer}")))

      @legendItemIndent[i+1] = item.select('text').node().getBBox().width + 50 + @legendItemMargin if not @legendItemIndent[i+1]

      itemIndent += @legendItemIndent[i+1]


  drawLine: (dataset, num) ->
    # TODO: Code the right Y axis
    axis = if dataset.axis_y is 'left' then @yAxis else @yAxis

    line = @chart.append('svg:g').attr('class', "line line-#{num}")

    @drawShape line, 'line', axis, dataset, num
    @drawShape line, 'area', axis, dataset, num if num is 1 and @data.lines.length < 3


  drawPointer: () ->
    self = this

    @pointers = for lineData,i in @data.lines then @buildPointer(lineData, i+1)

    @chart.on('mousemove', (d) -> self.updatePointers d3.mouse(this)[0])
    @chart.on('mouseout', (d) -> self.hidePointers())
    @chart.on('mouseover', (d) -> self.showPointers())


  drawShape: (holder, nature, axis, line, num) ->
    data = @data
    values = for d in line.data then d.y

    shape = d3.svg[nature]().interpolate("monotone")
    shape = shape.x((d,i) => @xAxis(if data.axis.x.nature is 'date' then new Date(line.data[i].x) else line.data[i].x))
    shape = if nature is 'line' then shape.y((d) -> axis(d)) else shape.y0(@height).y1((d) -> axis(d))

    class_name = if nature is 'line' then 'stroke' else nature

    shape = holder.append("svg:path").attr("class", "#{class_name}").attr("clip-path", "url(#clip)").attr("d", shape(values))


  drawTooltip: () ->
    @tooltip = @chart.append('svg:g').attr('class', 'tooltip')
    @tooltip.append('svg:rect').attr('rx', 10).attr('ry', 10)
    @tooltip.append('svg:text').text('')


  drawXAxis: () ->
    axis = @data.axis.x
    min = axis.min
    max = axis.max

    @xAxis = if axis.nature is 'date'
      d3.time.scale().domain([new Date(min), new Date(max)]).range([0, @width])
    else
      d3.scale.linear().domain([min, max]).range([0, @width])

    @drawAxis 'bottom', @xAxis, @height, axis.nature, axis.max_ticks


  drawYAxis: (side) ->
    axis = @data.axis.y
    min = axis.min
    max = axis.max

    if axis.nature is 'date'
      @yAxis = d3.time.scale().domain([min, max]).range([@height, 0])
    else
      upperGap = (Math.round(max / ((@height * 0.75)/@tickSize)))
      @yAxis = d3.scale.linear().domain([min, max+upperGap]).range([@height, 5])

    @drawAxis side, @yAxis, @width, axis.nature, axis.max_ticks

  exportXls: () ->
    url = @tools.find('div.holder-export-xls a.button').attr('href') + '&step=' + @currentStep()

    location.href = url

    return false


  hidePointers: () ->
    for pointer in @pointers then pointer.element.transition().duration(200).style("opacity", 0)
    @tooltip.transition().duration(200).style("opacity", 0)


  initSize: () ->
    @margins = for side in ['Top', 'Right', 'Bottom', 'Left'] then Number(@holderChart.css('padding' + side).replace('px', ''))
    @holderChart.css('padding', '0px')

    @width = @holderChart.innerWidth() - @margins[1] - @margins[3]
    @height = @holderChart.innerHeight() - @margins[0] - @margins[2]


  initTools: () ->
    @tools = @holder.find('div.tools')
    @tools.find('div.holder-step div.select-field').bind('change', (e) => @reloadChart())
    @tools.find('div.holder-step select').change (e) => @reloadChart()
    @tools.find('div.holder-template').bind('change', (e) => @showTemplate())
    @tools.find('div.holder-template select').change (e) => @showTemplate()
    @tools.find('div.holder-export-xls a.button').click (e) => @exportXls()


  initUpdateDelay: () ->
    holder = @holder

    if holder.data('update-delay')
      delay = holder.data('update-delay') * 1000

      holder.bind('update', () => @reloadChart())
      window.setInterval((=> holder.trigger('update')), delay)


  loadChart: () ->
    @drawChart()
    @drawXAxis()
    @drawYAxis('left')
    for d, i in @data.lines then @drawLine(d, i+1)
    @drawLegend() if @data.legend
    @drawPointer()
    @drawTooltip()

  loadData: (url) -> d3.json(url, (d) => if d then @loadTemplates d)


  loadTable: () ->
    content = '<table><thead><tr>'
    content += '<th>' + @data.axis.x.label + '</th>'
    for l in @data.lines then content += '<th>' + l.label + '</th>'
    content += '</thead><tbody>'
    for l,i in @data.lines[0].data
      content += "<tr><td>#{l.label_x}</td>"
      for c in @data.lines then content += "<td class=\"" + @data.axis.y.nature + "\">#{c.data[i].y}</td>"
      content += '</tr>'
    content += "</tbody><tfoot><tr>"
    content += '<td>' + @data.lines[0].total.label + '</td>'
    for l in @data.lines then content += '<td class="' + @data.axis.y.nature + '">' + l.total.value + '</td>'
    content += "</tr></tfoot></table>"

    @holderTable.html(content)


  loadTemplates: (@data) ->
    @updateTitle()
    @loadChart()
    @loadTable()
    @holder.find('div.templates').fadeIn()
    @holder.css({ height: 'auto' })


  mainAxis: () -> if @data.axis then @data.axis else @data.axis_left

  reloadChart: () ->
    url = @tools.find('form').attr('action')
    url += '?' if url.indexOf('?') is -1
    url += "&step=#{@currentStep()}"

    @holder.css({ height: @holder.height() + 'px' })
    @holder.find('div.templates').fadeOut(400, => @loadData(url))


  showPointers: () ->
    for pointer in @pointers then pointer.element.transition().duration(200).style("opacity", 1) if not pointer.element.classed('disabled')
    @tooltip.transition().duration(200).style("opacity", 1)


  showTemplate: () ->
    if @tools.find('div.holder-template select').length > 0
      template = @tools.find('div.holder-template select').val()
    else
      template = @tools.find('div.holder-template div.switch-field input').val()

    if template is 'chart'
      @holderTable.fadeOut(400, => @holderChart.fadeIn(400))
    else
      @holderChart.fadeOut(400, => @holderTable.fadeIn(400))


  toggleLine: (legendItem, target, pointer) ->
    if target.style("opacity") is '1'
      target.transition().duration(400).style("opacity", 0.2)
      pointer.classed('disabled', true)
      pointer.transition().duration(400).style("opacity", 0)
      d3.select(legendItem).classed('disabled', true)
    else
      target.transition().duration(400).style("opacity", 1)
      pointer.classed('disabled', false)
      pointer.transition().duration(400).style("opacity", 1)
      d3.select(legendItem).classed('disabled', false)


  updatePointers: (x) ->
    xDataApprox = @xAxis.invert(x)

    for pointer, p_count in @pointers
      selection = 0

      for item,i in pointer.xData then selection = i if Math.abs(xDataApprox - item) < Math.abs(xDataApprox - pointer.xData[selection])

      posX = @xAxis(pointer.xData[selection])
      posY = @yAxis(pointer.yData[selection])

      pointer.element.attr("transform", "translate(#{posX}, #{posY})")

    @updateTooltip(selection) if @data.tooltip


  updateTitle: () ->
    content = @data.title
    content += '<span class="subtitle">' + @data.period + '</span>' if @data.period

    @holder.find('h2.title-chart').html(content)


  updateTooltip: (selection) ->
    @tooltip.selectAll("text").remove()

    tText = @tooltip.append('svg:text')

    for pointer, p_count in @pointers
      if p_count == 0
        posX = @xAxis(pointer.xData[selection])
        posY = @yAxis(pointer.yData[selection])

        tText.append('svg:tspan').attr('class', 'x').attr('dy', 25).attr('x', 10).text(@data.lines[p_count].data[selection].label_x)
        tText.append('svg:tspan').attr('class', 'y').attr('dy', 25).attr('x', 10).text(@data.lines[p_count].data[selection].label_y)
      else
        tText.append('svg:tspan').attr('class', 'y').attr('dy', 15).attr('x', 10).text(@data.lines[p_count].data[selection].label_y)

    tooltipSize = tText.node().getBBox()

    if posX - (tooltipSize.width + @tooltipMargin + @tooltipPadding) < 0
      posX += @tooltipMargin
    else
      posX -= (tooltipSize.width + @tooltipMargin + @tooltipPadding)

    @tooltip.attr("transform", "translate(#{posX}, #{posY - @tooltipMargin})")

    @tooltip.selectAll('rect').attr('width', tooltipSize.width + @tooltipPadding).attr('height', tooltipSize.height + @tooltipPadding)


  #rotateLabel: () ->
    #@chart.selectAll(".axis text").attr("transform", (d) -> "translate(" + this.getBBox().height*-2 + "," + this.getBBox().height + ")rotate(-45)")

