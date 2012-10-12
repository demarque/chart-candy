#*************************************************************************************
# TOCOMMENT
#*************************************************************************************
class @ChartCandyDonut
  constructor: (@holder) ->
    @innerRadius = 55
    @labelMargin = 12
    @holeLineHeight = 20

    @holderChart = @holder.find('div.templates div.chart')
    @holderTable = @holder.find('div.templates div.table')

    @initTools()
    @initSize()

    d3.json(@holder.data('url'), (d) => @loadTemplates d)


  centerLabel: (d, radius, text, position) ->
    c = @arc.centroid(d)
    x = c[0]
    y = c[1]
    h = Math.sqrt(x * x + y * y)

    tX = (x / h * radius)
    tY = (y / h * radius)

    sizeText = if position is 'inside' then String(text).length * 3.5 else 0

    if tX > 0 then tX -= sizeText else tX += sizeText

    return "translate(" + tX + "," + tY + ")"

  drawChart: () ->
    @holderChart.html('')

    @root = d3.select("##{@holder.attr('id')} div.templates div.chart")
    @chart = @root.append("svg:svg").attr("width", @fullWidth()).attr("height", @fullHeight())
    @chart.data([@data.slices])

    donut = d3.layout.pie().sort(null)

    @arc = d3.svg.arc().innerRadius(@radius - @innerRadius).outerRadius(@radius)
    @arcs = @chart.selectAll("g.arc").data(donut.value((d) -> d.value)).enter().append("svg:g").attr("class", "arc").attr("transform", "translate(" + (@radius + @margins[3]) + "," + (@radius + @margins[0]) + ")")
    @arcs.append("svg:path").attr('class', (d, i) -> "slice-#{i+1}" ).attr "d", @arc


  drawHole: () ->
    hole = @chart.append("svg:g").attr("class", "hole").attr("transform", "translate(" + (@radius + @margins[3]) + "," + (@radius + @margins[0]) + ")")

    startY = (@data.hole.length * @holeLineHeight - @holeLineHeight) / -2

    for content, i in @data.hole
      hole.append("svg:text").attr("class", "label text#{i}").attr("dy", startY + (i * @holeLineHeight)).attr("text-anchor", "middle").text(content)


  drawLabels: () ->
    @drawLabel 'label', @radiusLabel, 'outside' if @data.show_label
    @drawLabel 'valuef', (@radiusLabel - @innerRadius/2.5 - 20), 'inside'


  drawLabel: (key, radius, position) ->
    @arcs.append("svg:text").attr("transform", (d,i) => @centerLabel(d, radius, @data.slices[i][key], position))
    .attr("dy", ".35em").attr("text-anchor", (d) -> (if (d.endAngle + d.startAngle) / 2 > Math.PI then "end" else "start"))
    .text (d,i) =>
      if @data.slices[i]['percent'] > 3 or position is 'outside'
        (if position is 'inside' then @data.slices[i][key] else @data.slices[i][key])
      else
        ''



  drawTooltip: () -> @tooltip = @root.append("div").attr('class', 'tooltip')

  fullHeight: () -> @height + @margins[0] + @margins[2]

  fullWidth: () -> @width + @margins[1] + @margins[3]

  initSize: () ->
    @margins = for side in ['Top', 'Right', 'Bottom', 'Left'] then Number(@holderChart.css('padding' + side).replace('px', ''))
    @holderChart.css('padding', '0px')

    @width = @holder.innerWidth() - @margins[1] - @margins[3]
    @height = @holder.innerHeight() - @margins[0] - @margins[2]
    @radius = Math.min(@width, @height) / 2
    @radiusLabel = @labelMargin + @radius


  initTools: () ->
    @tools = @holder.find('div.tools')
    @tools.find('div.holder-template').bind('change', (e) => @showTemplate())


  loadChart: () ->
    @drawChart()
    @drawHole()
    @drawLabels()
    @drawTooltip()
    @setChartEvents()


  loadTable: () ->
    content = '<table><thead><tr><th>' + @data.label + '</th><th>' + @data.value + '</th></thead><tbody>'
    for d,i in @data.slices then content += "<tr><td>#{d.label}</td><td>#{d.value}</td></tr>"
    content += '</tbody><tfoot><tr><td>' + @data.total.label + '</td><td>' + @data.total.value + '</td></tfoot>'
    content += '</table>'

    @holderTable.html(content)


  loadTemplates: (@data) ->
    @updateTitle()
    @loadChart()
    @loadTable()
    @holder.find('div.templates').fadeIn()
    @holder.css({ height: 'auto' })


  setChartEvents: () ->
    self = this

    @arcs.on("mouseover", (d,i) -> self.tooltip.text(self.data.slices[i].tooltip))
    @arcs.on("mousemove", (d,i) -> self.selectSlice(this))
    @arcs.on("mouseout", (d,i) -> self.unselectSlice(this))


  selectSlice: (slice) ->
    @root.selectAll('g.arc path').style('opacity', 0.3)
    @root.selectAll('g.arc text').style('opacity', 0.3)

    d3.select(slice).select('g.arc path').style('opacity', 1)
    d3.select(slice).selectAll('g.arc text').style('opacity', 1)

    cursorPosition = d3.mouse(d3.select('body').node())

    @tooltip.style "left", cursorPosition[0] + 10 + 'px'
    @tooltip.style "top", cursorPosition[1] + 10 + 'px'
    @tooltip.style "display", "block"


  showTemplate: () ->
    template = @tools.find('div.holder-template div.switch-field input').val()

    if template is 'chart'
      @holderTable.fadeOut(400, => @holderChart.fadeIn(400))
    else
      @holderChart.fadeOut(400, => @holderTable.fadeIn(400))


  updateTitle: () ->
    content = @data.title
    content += '<span class="subtitle">' + @data.period + '</span>' if @data.period

    @holder.find('h2.title-chart').html(content)


  unselectSlice: (slice) ->
    @root.selectAll('g.arc path').style('opacity', 1)
    @root.selectAll('g.arc text').style('opacity', 1)

    @tooltip.style("display", "none")

