# 🔄 Dev DB Refresh Pipeline (Staging from Production)

This folder outlines the process and pipeline to automate:
- Pulling a snapshot from the production Aurora PostgreSQL (Fargate mode)
- Masking sensitive data (e.g. SSNs, PII, emails)
- Restoring the masked data into a development/staging database

---

## 🧪 Process Overview

1. **Trigger**: Scheduled nightly (or on demand)
2. **Snapshot**: Take snapshot of production Aurora DB
3. **Clone**: Create a temporary clone of the snapshot
4. **Masking**: Run SQL masking scripts (via Lambda or container job)
5. **Dump**: Dump masked clone to S3
6. **Restore**: Load into dev Aurora instance
7. **Teardown**: Clean up temporary clone

---

## ⚙️ Tools/Infra Involved

- AWS Lambda or Fargate Job for masking
- AWS RDS Snapshot & Clone APIs
- `pg_dump` / `pg_restore`
- Secrets managed via AWS Secrets Manager or Vault
- S3 as intermediate backup target
- IAM role for pipeline execution

---

## 🔐 Masking SQL Snippet Example

```sql
-- mask_ssns.sql
UPDATE users SET ssn = CONCAT('XXX-XX-', RIGHT(ssn, 4));
UPDATE users SET email = CONCAT('user_', id, '@example.dev');
UPDATE users SET phone = '555-000-0000';
```

---

## 📦 Terraform Snippet (RDS Snapshot Export)

```hcl
resource "aws_rds_cluster_snapshot" "prod_snapshot" {
  db_cluster_identifier = "prod-aurora-cluster"
  db_cluster_snapshot_identifier = "daily-prod-snapshot-${formatdate("YYYYMMDD", timestamp())}"
}
```

---

## 🪄 Automation Ideas

- GitHub Actions / Lambda / Step Functions to orchestrate the steps
- Use `psql` or `pg_dump` inside a secure Fargate task with access to clone
- Auto-cleanup temp DB clone after dump is complete

---

## 🚨 Security Notes

- No raw PII or secrets are exposed to developers
- All masking must be done **before export**
- Access to prod snapshot & dev DB is scoped to CI/CD role only

---

## 🔁 Future Improvements

- Use a masking framework (e.g. `anon`, `maskaroo`, `psql-privacy`)
- Add email obfuscation logic in app layer
- Create Slack notifications for snapshot success/failure
