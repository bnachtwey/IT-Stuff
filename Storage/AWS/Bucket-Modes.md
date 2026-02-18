# Setting GOVERNANCE mode in AWS

<!--
AIA Primarily AI, Content edits, Human-initiated, Reviewed v1.0

# changelog
# date          version    remark
# 2026-02-18    0.1        initial coding: take suggestion from *copilot*, verify and fix it ;-)
#                          approach with xss-lock does not work, besides xss-lock and resolvectl run in different user scopes ...

-->

To get **retention = GOVERNANCE** in Amazon S3, you don’t put this *directly* into a normal bucket policy. Instead, you must use **S3 Object Lock (Governance mode)**, which has **two parts**:

1. **Create the bucket with Object Lock enabled**
2. **Apply a default retention (Governance) or per‑object retention**
3. *(Optionally)* use a **bucket policy** to control who may bypass governance retention

Below is the **correct, AWS-supported way**, with CLI examples and policy snippets.

***

## 1️⃣ Create an S3 bucket with Object Lock enabled (mandatory)

⚠️ **Important constraints**

* Object Lock **must be enabled at bucket creation**
* Versioning is **automatically enabled**
* Object Lock **cannot be disabled later**

### AWS CLI

```bash
aws s3api create-bucket \
  --bucket my-governance-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1 \
  --object-lock-enabled-for-bucket
```

AWS documentation confirms Object Lock **can only be enabled at creation time** [\[s3browser.com\]](https://s3browser.com/amazon-s3-object-lock.aspx), [\[letsupdateskills.com\]](https://www.letsupdateskills.com/tutorials/aws/object-lock)

***

## 2️⃣ Set default GOVERNANCE retention on the bucket

This ensures **every new object version** is automatically protected.

### Example: 365‑day Governance retention

```bash
aws s3api put-object-lock-configuration \
  --bucket my-governance-bucket \
  --object-lock-configuration '{
    "ObjectLockEnabled": "Enabled",
    "Rule": {
      "DefaultRetention": {
        "Mode": "GOVERNANCE",
        "Days": 365
      }
    }
  }'
```

This sets **bucket‑level default retention in GOVERNANCE mode** [\[docs.aws.amazon.com\]](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html), [\[s3browser.com\]](https://s3browser.com/amazon-s3-object-lock.aspx)

***

## 3️⃣ Apply GOVERNANCE retention to a specific object (optional)

You can also set retention **per object version**.

```bash
aws s3api put-object-retention \
  --bucket my-governance-bucket \
  --key example.txt \
  --retention '{
    "Mode": "GOVERNANCE",
    "RetainUntilDate": "2027-02-18T00:00:00Z"
  }'
```

This is useful if you don’t want a bucket‑wide default [\[docs.aws.amazon.com\]](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)

***

## 4️⃣ Bucket policy to control GOVERNANCE bypass (very important)

In **Governance mode**, users *can* delete or shorten retention **only if** they have:

* `s3:BypassGovernanceRetention`
* and explicitly set the bypass header

### ❌ Deny everyone from bypassing retention

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyBypassGovernanceRetention",
      "Effect": "Deny",
      "Action": "s3:BypassGovernanceRetention",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
```

This makes GOVERNANCE behave **almost like COMPLIANCE**, but still reversible by policy change [\[notes.kodekloud.com\]](https://notes.kodekloud.com/docs/Amazon-Simple-Storage-Service-Amazon-S3/AWS-S3-Management/Demo-S3-Object-Lock), [\[s3browser.com\]](https://s3browser.com/amazon-s3-object-lock.aspx)

***

## 5️⃣ Allow only a break‑glass admin to bypass retention (recommended)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBypassForAdmins",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/S3RetentionAdmin"
      },
      "Action": "s3:BypassGovernanceRetention",
      "Resource": "*"
    }
  ]
}
```

Only that role can delete objects early by sending:

`x-amz-bypass-governance-retention: true`

AWS explicitly documents this behavior for Governance mode [\[repost.aws\]](https://repost.aws/questions/QUbsy6xSvWTlCZp4dMwJPFAw/can-you-delete-a-bucket-with-object-lock-on-it), [\[s3browser.com\]](https://s3browser.com/amazon-s3-object-lock.aspx)

***

## ✅ Summary

| Step                             | Required                    |
| -------------------------------- | --------------------------- |
| Create bucket with Object Lock   | ✅ mandatory                |
| Enable GOVERNANCE retention      | ✅                          |
| Bucket policy for bypass control | ✅ best practice            |
| Compliance mode                  | ❌ (different, irreversible)|

***

## Official AWS references

* Object Lock overview & retention modes  
  <https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html> [\[docs.aws.amazon.com\]](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)
* Working with Governance retention  
  <https://docs.aws.amazon.com/AmazonS3/latest/userguide/batch-ops-governance-mode.html> [\[docs.aws.amazon.com\]](https://docs.aws.amazon.com/AmazonS3/latest/userguide/batch-ops-governance-mode.html)
