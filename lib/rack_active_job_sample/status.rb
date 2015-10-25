require 'redis'
require 'json'
require 'pp'

q = ENV['q']
q ||= 'default'

r = Redis.new

pp r.smembers("queues:#{q}")

r.smembers('processes').each do |proc|
  r.hmget(proc, 'info').each do |info|
    proc_info = JSON.parse(info, symbolize_names: true)
    next unless proc_info[:queues].include?(q)
    print "#{proc_info[:identity]}\t\t#{r.hmget(proc, 'busy').first.to_i}/#{proc_info[:concurrency]}\n"
  end
end

