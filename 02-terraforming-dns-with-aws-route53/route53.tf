resource "aws_route53_zone" "example" {
  name     = "example.com"
}

resource "aws_route53_record" "nameservers" {
  allow_overwrite = true
  name            = "example.com"
  ttl             = 3600
  type            = "NS"
  zone_id         = aws_route53_zone.example.zone_id

  records = aws_route53_zone.example.name_servers
}

resource "aws_route53_record" "protonmail_txt" {
  zone_id = aws_route53_zone.example.zone_id
  name = ""
  type = "TXT"
  ttl = 1800

  records = [
    "protonmail-verification=<random_number>",
    "v=spf1 include:_spf.protonmail.ch mx ~all"
  ]
}

resource "aws_route53_record" "protonmail_mx" {
  zone_id = aws_route53_zone.example.zone_id
  name = ""
  type = "MX"
  ttl = 1800

  records = [
    "10 mail.protonmail.ch.",
    "20 mailsec.protonmail.ch."
  ]
}

resource "aws_route53_record" "protonmail_dkim_1" {
  zone_id = aws_route53_zone.example.zone_id
  name = "protonmail._domainkey"
  type = "CNAME"
  ttl = 1800

  records = [
    "domain_key1"
  ]
}

resource "aws_route53_record" "protonmail_dkim_2" {
  zone_id = aws_route53_zone.example.zone_id
  name = "protonmail2._domainkey"
  type = "CNAME"
  ttl = 1800

  records = [
    "<domain_key2>"
  ]
}

resource "aws_route53_record" "protonmail_dkim_3" {
  zone_id = aws_route53_zone.example.zone_id
  name = "protonmail3._domainkey"
  type = "CNAME"
  ttl = 1800

  records = [
    "domain_key3"
  ]
}