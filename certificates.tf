resource "tls_private_key" "ssl_cert" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a self-signed certificate for HTTPS
resource "tls_self_signed_cert" "ssl_cert" {
  private_key_pem = tls_private_key.ssl_cert.private_key_pem

  subject {
    common_name = "test.domain.lab"  # You can set this to your domain or public IP
  }

  validity_period_hours = 8760 # 1 year validity


  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

}

resource "aws_acm_certificate" "ssl_cert" {
  private_key       = tls_private_key.ssl_cert.private_key_pem
  certificate_body  = tls_self_signed_cert.ssl_cert.cert_pem

  tags = {
    Name = "Self-Signed Certificate"
  }
}