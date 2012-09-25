Chart Candy [![Build Status](https://secure.travis-ci.org/demarque/chart-candy.png?branch=master)](http://travis-ci.org/demarque/chart-candy)
===============

Form Candy use D3.js library to quickly render AJAX charts in your Rails project. In a minimum amount of code, you should have a functional chart, styled and good to go.


Install
-------

```
gem install chart-candy
```

### Rails 3

In your Gemfile:

```ruby
gem 'chart-candy'
```

Usage
-----

Form Candy currently offer 3 chart types : *line*, *donut* and *counter*.

### Line Chart

#### Data generation

```ruby
downloads = [ {"time"=>2012-01-01 00:00:00 UTC, "value"=>69}, {"time"=>2012-02-01 00:00:00 UTC, "value"=>74}, {"time"=>2012-03-01 00:00:00 UTC, "value"=>83}, {"time"=>2012-04-01 00:00:00 UTC, "value"=>84} ]

chart = ChartCandy::Line.new('downloaded_books')
chart.add_x_axis :date, downloads
chart.add_y_axis :number, downloads

chart.add_line 'downloads', downloads
```

#### Chart rendering

```ruby
line_chart chart_url('downloaded-book')
```

#### Labelling

Chart Candy use Rails I18n to manage text. In order to manage the labels on the chart you'll have to create a YAML that looks like that :

```yaml
loans_count:
	title: "Book downloads"

	axis:
  	x:
    	label: "Period"
    y:
    	label: "Quantity"
  lines:
  	downloads:
			label: "Number of downloads"
			unit: "downloads"
```

### Donut Chart


### Counter


```ruby
ChartCandy.new
```

Copyright
---------

Copyright (c) 2012 De Marque inc. See LICENSE for further details.
