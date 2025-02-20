
# SIEM-Like Aggregation with AWS Athena, S3 & OpenSearch

Scenario:
You're running a secure EKS-based ML pipeline (like TinyLlama deployment) and need centralized log analysis for security incidents & compliance monitoring.

✅ Data Sources for Logging:

1.EKS Audit Logs → Captures RBAC events, API calls.
2.Falco Logs → Detects runtime anomalies (e.g., exec in pod).
3.Istio Access Logs → Captures service-to-service traffic.
4.VPC Flow Logs → Monitors network traffic to/from EKS.
5.CloudTrail Logs → Tracks IAM & API activities.
6.Application Logs (SonarQube, OWASP ZAP, SageMaker, etc.) → Logs CI/CD & security scan results.


✅ Log Aggregation Flow

1.Logs Stored in S3 (Long-Term Storage & Querying via Athena)

All logs are pushed to an S3 bucket with event-based lifecycle rules (e.g., 30-day retention for security logs, 90 days for compliance).
Example setup:

resource "aws_s3_bucket" "security_logs" {
  bucket = "eks-security-logs"
  versioning { enabled = true }
  lifecycle_rule {
    id      = "expire-old-logs"
    enabled = true
    expiration { days = 90 }
  }
}



2.Athena Queries for Forensics & Anomaly Detection

AWS Athena queries raw logs in S3 without extracting them.
Example Athena SQL Query to detect unauthorized pod execs:


SELECT eventName, userIdentity.username, sourceIPAddress
FROM cloudtrail_logs
WHERE eventName = 'ExecIntoPod'
AND userIdentity.username NOT LIKE '%admin%'



3.Live Security Dashboard in OpenSearch

AWS OpenSearch ingests CloudTrail, Falco, Istio logs for real-time visualization.
Alerts trigger on high-severity events (e.g., Falco detecting reverse shell execution).
Example OpenSearch query to detect suspicious Istio traffic:


{
  "query": {
    "bool": {
      "must": [
        { "match": { "destination": "sagemaker-endpoint.internal" }},
        { "match": { "response_code": "500" }}
      ]
    }
  }
}


