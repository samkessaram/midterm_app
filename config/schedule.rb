set :output, "#{path}/log/cron.log"
every 15.minutes do
  rake "db:check"
end