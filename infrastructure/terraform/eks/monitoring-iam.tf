/*
  monitoring-iam.tf: minimal policy for CloudWatch logs & metrics, used by Falco, or other monitoring components.
*/
data "aws_iam_policy_document" "monitoring_policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "monitoring_policy" {
  name   = "${var.project_name}-monitoring-policy"
  policy = data.aws_iam_policy_document.monitoring_policy.json
}
