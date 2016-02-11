module Frugal
  module Logging

    @@level = Logger::INFO

    def self.set_debug_level
      @@level = Logger::DEBUG
      logger_for(self).debug 'Verbose logging'
    end

    def self.set_info_level
      @@level = Logger::INFO
    end

    def logger
      classname = self.class.name == 'Class' ? self : self.class.name
      log = Logging.logger_for(classname)
      log.level = @@level
      @logger ||= log
    end

    @loggers = {}

    class << self
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      def configure_logger_for(classname)
        logger = Logger.new(STDOUT)
        logger.progname = classname
        logger
      end
    end

  end
end
