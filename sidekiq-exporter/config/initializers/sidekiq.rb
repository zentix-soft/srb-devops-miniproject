require 'prometheus_exporter/instrumentation/sidekiq'

# Start standalone exporter web server on its own thread
if ENV["SIDEKIQ_PROMETHEUS_EXPORTER"] == "true"
  require 'prometheus_exporter/server'
  server = PrometheusExporter::Server::WebServer.new bind: "0.0.0.0", port: 9394
  server.start
end

PrometheusExporter::Instrumentation::Sidekiq.start