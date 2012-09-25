class ChartCandy::Builder::Counter < ChartCandy::Builder::Base

  def initialize(id, options={})
    super

    @chart.merge! nature: 'count', data: []
  end

  def add_primary(id, value)
    @chart[:data] << { nature: :primary, label: t("data.#{id}.label"), id: id, value: value }
  end
end
