module Instrumentation
  def self.measure(label)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    LOGGER.info("▶️ START #{label}")

    result = yield

    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    LOGGER.info("✅ END #{label} (#{(duration * 1000).round(1)} ms)")

    result
  rescue => e
    LOGGER.error("❌ FAIL #{label}: #{e.class} #{e.message}")
    raise
  end

  def self.disabled?
    ENV["RACK_ENV"] == "production" && !ENV["INSTRUMENTATION"]
  end
end
