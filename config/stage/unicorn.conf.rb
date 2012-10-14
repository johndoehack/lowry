worker_processes 1
listen 18101
timeout 15
stderr_path "/opt/lowry/stage/log/unicorn.log"
stdout_path "/opt/lowry/stage/log/unicorn.log"
pid "/opt/lowry/stage/unicorn.pid"
