rails_root = File.expand_path('../../', __FILE__)

worker_processes 2
working_directory rails_root

listen "#{rails_root}/tmp/unicorn.sock"
pid "#{rails_root}/tmp/unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

stderr_path "#{rails_root}/log/unicorn_error.log"
stdout_path "#{rails_root}/log/unicorn.log"

# # nginxの設定
# /usr/local/etc/nginx/servers/rails_app.conf
#
# upstream unicorn {
#     server unix:/Users/taniguchikouji/Desktop/programing/Ruby/microposts/tmp/unicorn.sock;
# }
#
# server {
#    listen 8085;
#    server_name localhost;
#
#    root /Users/taniguchikouji/Desktop/programing/Ruby/microposts/public;
#
#    access_log /usr/local/var/log/nginx/microposts_access.log;
#    error_log /usr/local/var/log/nginx/microposts_error.log;
#
#    client_max_body_size 100m;
#    error_page 500 502 503 504 /500.html;
#
#    try_files $uri/index.html $uri @unicorn;
#
#    location @unicorn {
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header Host $http_host;
#     proxy_pass http://unicorn;
#    }
# }
