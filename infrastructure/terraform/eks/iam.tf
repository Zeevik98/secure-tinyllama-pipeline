# ...
data "aws_iam_policy_document" "sonarqube_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::YOUR_S3_BUCKET_FOR_REPORTS/*"]
  }
}

resource "aws_iam_policy" "sonarqube_policy" {
  name        = "${var.project_name}-sonarqube-policy"
  description = "Allows ephemeral SonarQube job to read/write scanning reports to S3"
  policy      = data.aws_iam_policy_document.sonarqube_policy.json
}

data "aws_iam_policy_document" "zap_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::YOUR_S3_BUCKET_FOR_REPORTS/*"]
  }
}

resource "aws_iam_policy" "zap_policy" {
  name        = "${var.project_name}-zap-policy"
  description = "Allows ephemeral ZAP job to read/write scanning reports to S3"
  policy      = data.aws_iam_policy_document.zap_policy.json
}

data "aws_iam_policy_document" "scanning_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "oidc:sub"
      # Adjust the below if needed to match your cluster's IRSA condition
      values   = ["system:serviceaccount:non-privileged-namespace:scanning-sa"]
    }
  }
}

resource "aws_iam_role" "scanning_irsa_role" {
  name               = "${var.project_name}-scanning-irsa"
  assume_role_policy = data.aws_iam_policy_document.scanning_trust.json
}

resource "aws_iam_role_policy_attachment" "scanning_sonar_policy_attach" {
  role       = aws_iam_role.scanning_irsa_role.name
  policy_arn = aws_iam_policy.sonarqube_policy.arn
}

resource "aws_iam_role_policy_attachment" "scanning_zap_policy_attach" {
  role       = aws_iam_role.scanning_irsa_role.name
  policy_arn = aws_iam_policy.zap_policy.arn
}
