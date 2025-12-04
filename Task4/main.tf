provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "Kashish_Omar_Billing_Alarm_100INR"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # Check every 6 hours
  statistic           = "Maximum"
  threshold           = "100"
  alarm_description   = "Alarm when billing exceeds 100 INR"
  actions_enabled     = true

  dimensions = {
    Currency = "INR" # Matches the assessment requirement
  }
}