Chart Candy
===============

Chart Candy use D3.js library to quickly render AJAX charts in your Rails project. In a minimum amount of code, you should have a functional chart, styled and good to go.


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

Setup
-----

First you need to link the assets.

In your css manifest put : ``` require chart_candy ```

In your javascript manifest put : ``` require chart_candy ```

In your layout you must link the D3.js library. You can use the following helper method in order to do that.

```erb
<%= d3_include_tag %>
```

Usage
-----

Now, you're ready to add some charts to your project! Chart Candy currently offer 3 chart types : **line**, **donut** and **counter**.

### Line Chart

#### Data generation

You must create a class that will build the JSON data for the chart. We suggest to create a **app/charts** directory in your Rails project to hold all your charts. For example, if
I want the chart of downloaded books, I would create **app/charts/downloaded_books_chart.rb**.

```ruby
class DownloadedBooksChart < ChartCandy::BaseChart
  def build(chart)
    downloads = [ {"time"=>Time.now - 4.months, "value"=>69}, {"time"=>Time.now - 3.months, "value"=>74}, {"time"=>Time.now - 2.months, "value"=>83}, {"time"=>Time.now - 1.months, "value"=>84} ]

    chart.add_x_axis :date, downloads
    chart.add_y_axis :number, downloads

    chart.add_line 'downloads', downloads
  end
end
```

This build method will be call by the AJAX chart.


#### Chart rendering

In your view, you call the chart.

```ruby
<%= line_chart 'downloaded-book' %>
```

#### Labelling

Chart Candy use Rails I18n to manage text. In order to manage the labels on the chart you'll have to create a YAML that looks like that :

```yaml

fr:
  chart_candy:
    downloaded_books:
      title: "Downloaded Books from my Library"

      axis:
        x:
          label: "Period"
        y:
          label: "Quantity"
      lines:
        downloads:
          label: "Quantity of downloads"
          unit: "downloads"

```

### Donut Chart

*Coming Soon*


### Counter

*Coming Soon*


Copyright
---------

Copyright (c) 2012 De Marque inc. See LICENSE for further details.DownloadedBooks
