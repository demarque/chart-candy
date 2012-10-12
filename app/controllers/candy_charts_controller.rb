#*************************************************************************************
# TOCOMMENT
#*************************************************************************************
class CandyChartsController < ApplicationController
  before_filter :authenticate

  def show
    if @granted
      set_default_to if params[:from] and not params[:to]

      name = (params[:id].gsub('-', '_').camelize + 'Chart')

      begin
        chart = name.constantize.new(params)
      rescue
        raise "Chart Candy: You must defined #{name}"
      end

      builder = "ChartCandy::Builder::#{params[:nature].camelize}".constantize.new(params[:id], params)

      chart.build builder

      respond_to do |format|
        format.json { render json: builder.to_json }
        format.xls { render_xls builder }
      end
    else
      respond_to do |format|
        format.json { render json: { 'state' => 'access_refused' } }
        format.xls { render text: 'access_refused' }
      end
    end
  end

  def render_xls(builder)
    spreadsheet = StringIO.new
    builder.to_xls.write spreadsheet

    send_data spreadsheet.string, filename: builder.filename, type:  "application/vnd.ms-excel"
  end

  def authenticate
    auth = ChartCandy::Authentication.new(request.url, params)

    @granted = (auth.valid_token? and not auth.expired?)
  end

  def set_default_to
    if params[:nature] == 'line'
      params[:to] = case params[:step]
        when 'day' then (Time.now.utc - 1.day).end_of_day.iso8601
        when 'week' then (Time.now.utc - 1.week).end_of_week.iso8601
        when 'month' then (Time.now.utc - 1.month).end_of_month.iso8601
        else Time.now.utc.iso8601
      end
    else
      params[:to] = Time.now.utc.iso8601
    end
  end
end
