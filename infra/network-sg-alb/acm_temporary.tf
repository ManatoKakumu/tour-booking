resource "tls_private_key" "alb_self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "alb_self_signed" {
  private_key_pem = tls_private_key.alb_self_signed.private_key_pem

  subject {
    common_name  = "tour-booking-alb.internal"
    organization = "tour-booking"
  }

  validity_period_hours = 8760 # 1年

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "alb_self_signed" {
  private_key      = tls_private_key.alb_self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.alb_self_signed.cert_pem
}
