require 'net/http'
require 'json'

module Api
  BASE = 'https://lks.bmstu.ru/lks-back/api/v1/schedules'

  class << self
    def public(uid)
      uri = URI("#{BASE}/groups/#{uid}/public")

      JSON.parse(Net::HTTP.get(uri))
    end

    def current
      uri = URI("#{BASE}/current")

      JSON.parse(Net::HTTP.get(uri))
    end
  end
end
