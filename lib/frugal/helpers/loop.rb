module Frugal
  class Loop
    extend Logging

    PAUSE_BEFORE_FIRST_LOOP = 1 #second - leave time for SOME initialisation

    def self.every(frequency, &block)
      logger.debug "Starting loop every #{frequency}s"
      EM.run do
        scheduler = Rufus::Scheduler::EmScheduler.start_new
        scheduler.in "#{PAUSE_BEFORE_FIRST_LOOP}s" do
          in_loop(frequency, scheduler, &block)
        end
      end
    end

    def self.in_loop(frequency, scheduler, &block)
      time = Benchmark.realtime do
        begin
          block.call
        rescue StandardError => e
          logger.error e
        end
      end
      time_to_next_loop = [frequency - time.round, 1].max.to_s + 's'
      scheduler.in time_to_next_loop do
        in_loop(frequency, scheduler, &block)
      end
    end
  end
end
