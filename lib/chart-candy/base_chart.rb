module ChartCandy
  class BaseChart
    def initialize(params)
      @params = params

      @from = params[:from] ? Time.parse(params[:from]) : nil
      @to = params[:to] ? Time.parse(params[:to]) : Time.now
      @step = params[:step] || 'month'
    end
  end
end
