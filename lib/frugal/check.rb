module Frugal
  class Check
    include Logging

    def initialize(instance_id:, interval: 60, threshold: 55, verbose: false, region: 'us-east-1', aws_access_key:, aws_secret_key:, aws_session_token: nil)
      logger.info 'Frugal Starting!'
      Frugal::Logging.set_debug_level if verbose

      @scheduler = Rufus::Scheduler.new

      logger.debug 'Arguments...'
      @instance_id = instance_id
      logger.debug "- instance_id: #{instance_id}"

      @interval = interval
      logger.debug "- interval: #{interval}"

      @threshold = threshold
      logger.debug "- threshold: #{threshold}"

      @region = region
      logger.debug "- region: #{region}"

      @aws_access_key = aws_access_key
      logger.debug "- aws_access_key: #{aws_access_key}"

      @aws_secret_key = aws_secret_key
      logger.debug "- aws_secret_key: #{aws_secret_key}"

      @aws_session_token = aws_session_token
      logger.debug "- aws_session_token: #{aws_session_token}"

      # validations

      if @instance_id.nil?
        logger.fatal 'Instance ID not provided'
        exit 1
      end

      if @aws_access_key.nil?
        logger.fatal 'AWS Access Key not provided'
        exit 1
      end

      if @aws_secret_key.nil?
        logger.fatal 'AWS Secret Key not provided'
        exit 1
      end

      Aws.config.update(region: @region, credentials: Aws::Credentials.new(@aws_access_key, @aws_secret_key, @aws_session_token))
    end

    def run!
      logger.info "About to start monitoring launch time for #{@instance_id}"
      logger.info "Will set instance autoscaling protection to false once #{@instance_id} has been alive for #{@threshold}m"

      ec2 = Aws::EC2::Resource.new
      instance = ec2.instance(@instance_id)
      autoscaling_group_name = instance.tags.find { |t| t['key'] == 'aws:autoscaling:groupName' }['value']
      logger.debug "Instance belongs to Auto Scaling Group '#{autoscaling_group_name}'"

      Loop.every @interval do
        instance = ec2.instance(@instance_id)
        minutes_since_launch = TimeDifference.between(instance.launch_time, Time.now.utc).in_minutes
        logger.debug "Instance was started at #{instance.launch_time}, #{minutes_since_launch}m ago"

        if minutes_since_launch % 60 >= @threshold
          logger.info "Launch time ago #{minutes_since_launch} >= #{@threshold}"
          Frugal::Protection.disable!(@instance_id)
        else
          logger.info "Launch time ago #{minutes_since_launch} < #{@threshold}"
          Frugal::Protection.enable!(@instance_id)
        end
      end
    end

  end
end
