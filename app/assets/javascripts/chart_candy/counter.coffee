#*************************************************************************************
# TOCOMMENT
#*************************************************************************************
class @ChartCandyCounter
  constructor: (@holder) ->
    @initUpdateDelay()
    @updateChart()


  formatNumber: (num) ->
    num = num.toString()
    if num.length > 4
      num.replace(/\B(?=(?:\d{3})+(?!\d))/g, " ")
    else
      num


  initUpdateDelay: () ->
    holder = @holder

    if holder.data('update-delay')
      delay = holder.data('update-delay') * 1000

      holder.bind('update', () => @updateData())
      window.setInterval((=> holder.trigger('update')), delay)


  isSimilarData: (updated) -> @data.data[0].value is updated.data[0].value

  loadChart: () ->
    content = ''

    for d in @data.data
      content += '<span class="label ' + d.nature + '">' + d.label + '</span>' if d.label
      content += '<span class="value ' + d.nature + '" style="display:none">' + @formatNumber(d.value) + '</span>'

    @holder.find('div.templates div.chart').html(content)


  loadTemplates: (@data) ->
    @loadChart()
    @holder.find('div.templates span.value').fadeIn(400)
    @holder.css({ height: @holder.find('div.templates').innerHeight() + 'px' })


  reloadChart: (d) -> @holder.find('div.templates span.value').fadeOut(400, => @loadTemplates d)

  updateData: () -> d3.json(@holder.data('url'), (d) => if not @isSimilarData(d) then @reloadChart(d))

  updateChart: () -> d3.json(@holder.data('url'), (d) => @loadTemplates d)
