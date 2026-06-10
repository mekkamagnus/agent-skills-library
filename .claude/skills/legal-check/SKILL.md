---
name: legal-check
description: Scan content for Chinese platform regulatory compliance. Use before publishing: posts, articles, app descriptions, marketing copy, announcements. Checks for prohibited content (political, religious, territorial), sensitive topics, and unsafe keywords. Returns risk assessment with safe alternatives. Keywords: content, review, compliance, publish, safe, risk, check, Chinese, platform, moderation.
---

# Legal Content Compliance Check

Quick compliance scan for content before publishing on Chinese platforms.

## Quick Checklist

Before publishing any content, verify:

| Category | Check | Status |
|----------|-------|--------|
| **Political** | No government criticism, political commentary | ⬜ |
| **Religious** | No proselytizing, religious debates | ⬜ |
| **Territorial** | No disputed regions mentioned | ⬜ |
| **Adult** | No sexual/suggestive content | ⬜ |
| **Violence** | No graphic violence | ⬜ |
| **Fraud** | No false claims, misleading statements | ⬜ |
| **Result** | ALL PASS = ✅ Safe to publish | |

---

## High-Risk Keywords to Avoid

| Category | DO NOT USE |
|----------|------------|
| **Political** | 政治, 民主, 选举, 抗议, 专制, 独裁 |
| **Religious** | 传教, 洗礼, 信徒, 改宗, 异教 |
| **Territorial** | Taiwan, Tibet, Xinjiang, Hong Kong, South China Sea, 台湾, 西藏, 新疆, 香港, 南海 |
| **Sensitive Events** | Various historical events dates |

---

## Safe Alternatives

| Instead of... | Use... |
|---------------|-------|
| Political commentary | Focus on techniques, fitness, culture |
| Religious promotion | Cultural traditions (folklore, NOT faith) |
| Territorial mentions | Geographically neutral content |
| Sensitive events | Historical context (if relevant) |

---

## Risk Levels by Content Type

| Content Type | Risk | Notes |
|-------------|------|-------|
| Technique tutorials | ✅ LOW | Safe if purely instructional |
| History/culture | ⚠️ MEDIUM | Must be historical, NOT political |
| Personal stories | ✅ LOW | Safe if non-political |
| News/current events | ⚠️ HIGH | Avoid political topics |
| International comparisons | ⚠️ HIGH | Avoid country comparisons |

---

## Content Self-Review Process

```
1. Scan for prohibited keywords
       ↓
2. Check for political references
       ↓
3. Verify no religious promotion
       ↓
4. Ensure no territorial mentions
       ↓
5. Confirm adult content excluded
       ↓
6. Validate no false claims
       ↓
ALL PASS → Safe to publish
ANY FAIL → Remove/revise content
```

---

## Examples

### ❌ High Risk (Do Not Publish)

"Our fitness program promotes democratic values through physical discipline..."

### ✅ Safe

"Our fitness program builds physical discipline through proven training methods..."

### ❌ High Risk

"Join our community of believers practicing together..."

### ✅ Safe

"Join our community practicing together..."

---

## When to Escalate

If unsure about content safety:
1. Err on the side of caution — remove risky content
2. For complex situations, consult with `legal-orchestrator` agent
3. For official guidance, consult qualified legal counsel

---

## Platform-Specific Rules

| Platform | Additional Rules |
|----------|-----------------|
| **WeChat Mini Program** | No external links, no gambling |
| **Douyin/TikTok** | No political content |
| **Xiaohongshu** | No false medical claims |
| **Bilibili** | Strict political moderation |

---

## References

- **WeChat Content Policies:** https://developers.weixin.qq.com/miniprogram/product/content_spec.html
- **Content moderation agent:** `content-moderation.md`
- **Legal orchestrator:** `legal-orchestrator.md`
