locals {
  # AWSManagedRulesCommonRuleSetのうち、リクエスト本体を検査するルール(ルール名 = 付与されるラベル名)
  common_rule_set_body_rules = {
    SizeRestrictions_BODY   = "SizeRestrictions_Body"
    CrossSiteScripting_BODY = "CrossSiteScripting_Body"
    GenericLFI_BODY         = "GenericLFI_Body"
    GenericRFI_BODY         = "GenericRFI_Body"
    EC2MetaDataSSRF_BODY    = "EC2MetaDataSSRF_Body"
  }
}

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

        # 本体(BODY)を検査するルール。画像のアップロードは、本体が8KBを超えるうえ、バイナリが
        # 攻撃文字列と誤検知されるため、これらのルールに止められる。ここではカウント(ラベル付け)
        # のみにし、ブロックは下の block-body-rules-except-image-upload で、アップロード用の
        # パス以外に限定して行う
        dynamic "rule_action_override" {
          for_each = local.common_rule_set_body_rules
          content {
            name = rule_action_override.key
            action_to_use {
              count {}
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  # ラベルは、付与したルールより後に評価されるルールでしか参照できないため、common-rule-setより後ろに置く
  rule {
    name     = "block-body-rules-except-image-upload"
    priority = 4

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          or_statement {
            dynamic "statement" {
              for_each = local.common_rule_set_body_rules
              content {
                label_match_statement {
                  scope = "LABEL"
                  key   = "awswaf:managed:aws:core-rule-set:${statement.value}"
                }
              }
            }
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string         = "/b/api/tours/"
                positional_constraint = "EXACTLY"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-body-rules-except-image-upload"
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

        managed_rule_group_configs {
          aws_managed_rules_anti_ddos_rule_set {
            client_side_action_config {
              challenge {
                usage_of_action = "DISABLED"
              }
            }
            sensitivity_to_block = "MEDIUM"
          }
        }
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

        managed_rule_group_configs {
          aws_managed_rules_anti_ddos_rule_set {
            client_side_action_config {
              challenge {
                usage_of_action = "DISABLED"
              }
            }
            sensitivity_to_block = "MEDIUM"
          }
        }
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

        managed_rule_group_configs {
          aws_managed_rules_anti_ddos_rule_set {
            client_side_action_config {
              challenge {
                usage_of_action = "DISABLED"
              }
            }
            sensitivity_to_block = "MEDIUM"
          }
        }
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
