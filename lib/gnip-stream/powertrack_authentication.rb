module GnipStream
  class PowertrackAuthentication
    attr_accessor :cookies, :location
    def initialize(url, username, password)
      @url = url
      @username = username
      @password = password
    end

    def authenticate
      EM.run do
        http = EM::HttpRequest.new(@url).get(
          :head => {"authorization" => [@username, @password]})
        http.headers { |head| parse_response_header(head) }
        http.callback { EM.stop }
        http.error do 
          raise "Gnip Authentication Failed. Reason was #{http.error}"
        end
      end
    end

    def parse_response_header(header)
      @location = header["LOCATION"]
      @cookies = (header["SET_COOKIE"].first.split(";")[0..2].join(";"))
    rescue => e
      raise "Gnip Authentication Failed. Reason was #{e.inspect}"
    end
  end
end