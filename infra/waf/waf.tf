resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1
  name     = "cloudfront-web-acl"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "common-rule-set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "bad-input-rule-set"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "bad-input-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ddos-rule-set"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAntiDDoSRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ddos-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl" "user_pool_b" {
  name  = "user-pool-b-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "ddos-rule-set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAntiDDoSRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ddos-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "user-pool-b-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl" "user_pool_c" {
  name  = "user-pool-c-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "ddos-rule-set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAntiDDoSRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ddos-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "atp-rule-set"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesATPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "atp-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "user-pool-c-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "user_pool_b" {
  resource_arn = data.terraform_remote_state.network_sg_alb.outputs.user_pool_b_arn
  web_acl_arn  = aws_wafv2_web_acl.user_pool_b.arn
}

resource "aws_wafv2_web_acl_association" "user_pool_c" {
  resource_arn = data.terraform_remote_state.network_sg_alb.outputs.user_pool_c_arn
  web_acl_arn  = aws_wafv2_web_acl.user_pool_c.arn
}
