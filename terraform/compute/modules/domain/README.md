# Domain
Contains the common DNS records that domains in the infrastructure may require.

# Table Of Contents
- [Overview](#overview)

# Overview
Each domain I own usually has the same types of DNS records:

- Wildcard and apex pointing to main server
- Keybase verification code (Optional)
- Email records
  - Sender Policy Framework (SPF) to configure domain spam policies
  - Email server MX records (Optional)
  - DomainKeys Identified Mail (DKIM) records (Optional)
  - Domain-based Message Authentication, Reporting and Conformance (DMARC) record (Optional)
  - ProtonMail verification records (Optional)
