module Frugal
  class Protection
    extend Logging

    def self.enable!(instance_id)
      autoscaling = Aws::AutoScaling::Client.new
      instance = autoscaling.describe_auto_scaling_instances(
        instance_ids: [instance_id],
        max_records: 1
      ).auto_scaling_instances.first

      if instance.protected_from_scale_in
        logger.info "Instance '#{instance_id}' is already protected_from_scale_in, no action needed"
      else
        logger.info "Setting protected_from_scale_in for #{instance_id} to true"
        autoscaling.set_instance_protection(
          instance_ids: [instance_id],
          auto_scaling_group_name: instance.auto_scaling_group_name,
          protected_from_scale_in: true
        )
      end
    end

    def self.disable!(instance_id)
      autoscaling = Aws::AutoScaling::Client.new
      instance = autoscaling.describe_auto_scaling_instances(
        instance_ids: [instance_id],
        max_records: 1
      ).auto_scaling_instances.first

      if instance.protected_from_scale_in
        logger.info "Setting protected_from_scale_in for #{instance_id} to false"
        autoscaling.set_instance_protection(
          instance_ids: [instance_id],
          auto_scaling_group_name: instance.auto_scaling_group_name,
          protected_from_scale_in: false
        )
      else
        logger.info "Instance '#{instance_id}' is already not protected_from_scale_in, no action needed"
      end
    end
  end
end
