resource "aws_cloudwatch_log_group" "waf_cloudfront" {
  name              = "aws-waf-logs-cloudfront"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "waf_user_pool_b" {
  name              = "aws-waf-logs-user-pool-b"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "waf_user_pool_c" {
  name              = "aws-waf-logs-user-pool-c"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_cloudfront" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_cloudfront.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_user_pool_b" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_user_pool_b.arn]
  resource_arn            = aws_wafv2_web_acl.user_pool_b.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_user_pool_c" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_user_pool_c.arn]
  resource_arn            = aws_wafv2_web_acl.user_pool_c.arn
}
