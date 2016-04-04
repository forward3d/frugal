# Frugal

Frugal is a companion process that helps you maximize the time your autoscaling machines are operating. AWS charge for a full hour of EC2 usage even if you only autoscaling a machine for under an hour, so you might as well use it for as long as possible. In December of 2015 they introduced a new feature for autoscaling groups called 'Instance Protection' and that makes this possible.

## How it works

It currently only has one mode of operation...

  * Monitor the duration since the launch time of the provided instance ID and adjusts the instance protection accordingly

It asks the AWS API for the launch time of the instance, compares that to the current time every interval it will call the API again to either set the protection to on or off depending on the threshold set.

## IAM Policy

This is an example IAM policy that has all the actions required for Frugal to run. Remember to restrict the `Resource` to what you actually need in your account.

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeInstances"
                ],
                "Resource": [
                    "*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "autoscaling:DescribeAutoScalingInstances",
                    "autoscaling:SetInstanceProtection"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }

## How to run the Docker container

The absolute minimum required to run the container...

`docker run forward3d/frugal -d i-16acdaac -r us-west-2 -a "AK....." -s "cp2..."`

If you run this it will output all possible arguments to the container...

`docker run -it forward3d/frugal --help`

## How to run the code (not inside the container)

The `check` executable takes several arguments...

* `-d INSTANCE_ID` the ID of the EC2 instance we want to monitor
* `-i INTERVAL` how often in seconds we should check (defaults to 60)
* `-t THRESHOLD` how many minutes must pass within an hour before turning the instance protection off
* `-a AWS_ACCESS_KEY` AWS access key that has enough access to the API to see Autoscaling Groups and EC2 instances
* `-s AWS_SECRET_KEY` AWS secret key
* `-r AWS_REGION` AWS region that the instance resides in
* `-v` turn on debug logging

Example...

`./bin/check -d i-16acdaac -r us-west-1 -i 90 -t 30 -a "AK....." -s "cp2..."`

This would check the instance `i-16acdaac` in `us-west-2` every `90`seconds and would disable instance protection after `30`minutes since launch
