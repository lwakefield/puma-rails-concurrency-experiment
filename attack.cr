require "http/client"


target_throughput = ARGV.find(&.starts_with?("--target-throughput="))
        .not_nil!.split('=', 2)[1]
sleep_time = 1.second / target_throughput.to_i32
url = ARGV.find(&.starts_with?("--url="))
        .not_nil!.split('=', 2)[1]
start_at = Time.local
in_flight, completed = 0, 0

Signal::INT.trap do
        puts "Completed #{completed}/#{in_flight} in #{(Time.local - start_at).total_milliseconds}ms"
        exit 0
end

loop do
        spawn do
                in_flight += 1
                request_num = in_flight

                started_at = Time.local
                res = HTTP::Client.get url
                finished_at = Time.local
                latency = finished_at - started_at
                completed += 1 if res.success?

                puts "request #{request_num} status=#{res.status_code} latency=#{latency.total_milliseconds}ms"
        end
        sleep sleep_time
end
