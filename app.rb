require 'sinatra'
require 'zache'
require 'erb'

require_relative 'api'
require_relative 'parser'

set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "views") }
set :public_folder, Proc.new { File.join(root, "public") }

set :erb, :format => :html5
set :static_cache_control, [:public]

Cache = Zache.new

def schedule(uid)
  Cache.get("schedule:#{uid}", lifetime: 6 * 60 * 60) do
    schedule = Api.public(uid)

    Parser.public(schedule).group_by { it[:day] }.map do |day, data|
      [day, data.sort { it[:order] }.reverse]
    end
  end
end


def current
  Cache.get(:current, lifetime: 1 * 60) do
    current = Api.current

    Parser.current(current)
  end
end

helpers do
  DAYS = %w[Понедельник Вторник Среда Четверг Пятница Суббота Воскресенье]

  # https://lks.bmstu.ru/portal4/cookie/login?back=https%3A%2F%2Flks.bmstu.ru%2Fprofile&profile_any=true
  def link_to_lks(uid)
    query = Rack::Utils.build_query({ back: "https://lks.bmstu.ru/progress" })
    href = "https://lks.bmstu.ru/portal4/cookie/login?#{query}"

    <<~HTML
      <a href="#{href}" class="mx-4" target="_blank">УСПЕВАЕМОСТЬ</a>
    HTML
  end

  def link_to_mail(uid)
    href = "https://student.bmstu.ru"

    <<~HTML
      <a href="#{href}" class="mx-4" target="_blank">ПОЧТА</a>
    HTML
  end

  def wday_to_day(wday)
    DAYS[wday - 1]
  end
end

before do
  cache_control :public, :must_revalidate, max_age: 86_400 # 1d
end

not_found do
  status 404
end

# f985a4c7-8a79-11ec-b81a-0de102063aa5
get '/:uid' do
  @uid = params['uid']
  @current = current
  @schedule = schedule(@uid).sort { it.first }.reverse.rotate(current[:day] - 1)

  etag current[:day]

  erb :index
end
