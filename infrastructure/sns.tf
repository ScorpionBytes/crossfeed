resource "aws_sns_topic" "alarms" {
  name = var.sns_topic_alarms

  tags = {
    Project = var.project
    Stage   = var.stage
  }
}
