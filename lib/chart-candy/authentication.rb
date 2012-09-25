module ChartCandy
  class Authentication
    def self.compact_params(original_params)
      compacted_params = ''

      original_params.each { |k,v| compacted_params << (k.to_s + v.to_s) if not self.reserved_params.include?(k.to_s) }

      return compacted_params
    end

    def self.reserved_params
      ['action', 'class', 'controller', 'format', 'from', 'nature', 'step', 'to', 'token', 'tools', 'update_every', 'version']
    end

    def self.tokenize(str)
      HMAC::SHA1.hexdigest(Rails.configuration.secret_token, str.chars.sort.join.gsub('/', ''))
    end

    def initialize(request_url, params={})
      @request_url = request_url
      @params = params
    end

    def expired?
      @params[:timestamp] and Time.parse(@params[:timestamp]) + 12.hours < Time.now
    end

    def valid_token?
      @params[:token] == tokenize(filter_url)
    end

    private

    def filter_url
      filtered_url = @request_url.split('?').first.rpartition('/').first

      return filtered_url + ChartCandy::Authentication.compact_params(@params)
    end

    def tokenize(str)
      ChartCandy::Authentication.tokenize(str)
    end
  end
end
