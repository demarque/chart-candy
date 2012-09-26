module ChartCandy::Helpers
  def counter_chart(id, options={})
    ChartCandyTagHelper.new(self, id, options[:from], options[:to], options[:step]).counter(options)
  end

  def d3_include_tag
    ('<![if ! lt IE 9]>' + javascript_include_tag("d3") + '<![endif]>').html_safe
  end

  def donut_chart(id, options={})
    ChartCandyTagHelper.new(self, id, options[:from], options[:to], options[:step]).donut(options)
  end

  def line_chart(id, options={})
    ChartCandyTagHelper.new(self, id, options[:from], options[:to], options[:step]).line(options)
  end

  def excel_chart_button(id, options={})
    ChartCandyTagHelper.new(self, id, options[:from], options[:to], options[:step]).excel_chart_button(options)
  end

  class ChartCandyTagHelper
    def initialize(rails_helpers, id, from, to, step)
      @rails_helpers = rails_helpers
      @id = id
      @from = from
      @to = to
      @step = step
    end

    def counter(options={})
      options.reverse_merge! update_every: 1.minute, tools: nil

      chart 'counter', options
    end

    def excel_chart_button(options={})
      build_url 'line', options if not @url

      tool_export_xls options[:label]
    end

    def line(options={})
      options.reverse_merge! tools: { export_xls: true, step: true, template: true }

      chart 'line', options
    end

    def donut(options={})
      options.reverse_merge! tools: { export_xls: true, step: false, template: true }

      chart 'donut', options
    end

    private

    def build_url(nature, options={})
      params = { format: 'json', id: @id, nature: nature, nonce: SecureRandom.hex(20), timestamp: Time.now.utc.iso8601, version: 'v1' }

      options.each { |k,v| params[k] = v if not ['class', 'tools'].include? k.to_s }

      params[:token] = build_url_token(params)

      @url = @rails_helpers.candy_chart_url params
    end

    def build_url_token(params)
      compacted_params = ChartCandy::Authentication.compact_params(params)

      url = @rails_helpers.candy_charts_url + compacted_params

      return ChartCandy::Authentication.tokenize(url)
    end

    def chart(nature, options={})
      options.reverse_merge! class: ""
      options[:class] += " wrapper-chart chart-#{nature}"

      build_url nature, options

      content = ''
      content += title_tag
      content += chart_tools(nature, options[:tools]) if options[:tools]
      content += content_tag(:div, content_tag(:div, '', class: 'chart') + content_tag(:div, '', class: 'table'), class: 'templates')

      wrapper_options = { id: @id, class: options[:class], 'data-chart-candy' => nature, 'data-url' => @url}
      wrapper_options['data-update-delay'] = options[:update_every].to_i if options[:update_every]

      return content_tag(:div, content.html_safe, wrapper_options)
    end

    def chart_tools(nature, options={})
      content = form_tag(@url) do
        tools = ''
        tools += tool_export_xls if options[:export_xls]
        tools += tool_step if options[:step]
        tools += tool_template if options[:template]

        tools.html_safe
      end

      return content_tag(:div, content.html_safe, class: 'tools')
    end

    def t(path)
      I18n.translate("chart_candy.#{path}")
    end

    def title_tag
      content_tag(:h2, t("#{@id.underscore}.title").html_safe, class: 'title-chart')
    end

    def tool_export_xls(label=nil)
      label = t('base.xls_export') if not label

      content = link_to(content_tag(:span, label, class: 'text'), @url.gsub('.json', '.xls'), class: 'button', title: t('base.xls_export'))

      return content_tag(:div, content.html_safe, class: 'tool holder-export-xls')
    end

    def tool_step
      choices = ['day', 'week', 'month'].map{ |c| [t("base.steps.#{c}"), c] }

      return content_tag(:div, candy.select('step', choices, 'month'), class: 'tool holder-step')
    end

    def tool_template
      choices = ['chart', 'table'].map { |c| [t("base.template.#{c}"), c] }

      return content_tag(:div, candy.switch('template', choices, 'chart'), class: 'tool holder-template')
    end

    def method_missing(*args, &block)
      if [:candy, :content_tag, :form_tag, :link_to].include?(args.first)
        return @rails_helpers.send(*args, &block)
      else
        raise NoMethodError.new("undefined local variable or method '#{args.first}' for #{self.class}")
      end
    end
  end

  ::ActionView::Base.send :include, self
end
