class ChartCandy
  constructor: () ->
    @charts = []

    if @d3IsLoaded()
      $('div[data-chart-candy]').each (i, chart) =>
        switch $(chart).data('chart-candy')
          when 'counter' then @charts.push new ChartCandyCounter $(chart)
          when 'donut' then @charts.push new ChartCandyDonut $(chart)
          when 'line' then @charts.push new ChartCandyLine $(chart)

  d3IsLoaded: () -> if d3? then true else false



$ -> new ChartCandy
