class Rack::Attack
  throttle("requests per IP", limit: 5, period: 1.minute) do |request|
    request.ip
  end

  Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"]

  retry_after = match_data[:period] - (match_data[:epoch_time] % match_data[:period])

  [
    429,
    {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s
    },
    [
      {
        error: "Rate limit exceeded. Please try again later.",
        retry_after: retry_after
      }.to_json
    ]
  ]
end

end