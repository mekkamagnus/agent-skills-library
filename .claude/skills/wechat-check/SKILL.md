---
name: wechat-check
description: WeChat Mini Program submission preparation guide. Covers app classification, content category selection (Sports/Fitness vs Education), prohibited content, payment integration, common rejection reasons, and appeal process. Use before submitting to WeChat Mini Program platform. Keywords: WeChat, Mini Program, submission, approval, rejection, category, review, publish.
---

# WeChat Mini Program Submission Guide

Navigate WeChat Mini Program submission requirements and avoid common rejections.

---

## Critical: Category Selection

**Choose correctly to avoid strict Education regulations:**

| Classification | Risk Level | Review Time | Use For |
|---------------|------------|-------------|---------|
| **Sports/Fitness (体育健身)** | ⭐ LOW | 1-3 days | Fitness, physical training, workouts |
| **Cultural Exchange (文化交流)** | ⭐ LOW | 1-3 days | Cultural content sharing |
| **Education (教育)** | ⚠️ HIGH | 7+ days | Academic tutoring (requires license) |
| **Social (社交)** | ⭐ LOW | 1-3 days | Community features |
| **E-commerce (电商)** | ⭐ LOW | 1-3 days | Product sales |

**⚠️ IMPORTANT:** For fitness/physical training platforms, **always use Sports/Fitness (体育健身)** — NOT Education (教育).

---

## Submission Checklist

| Item | Status | Notes |
|------|--------|-------|
| AppID registered | ⬜ | From WeChat Open Platform |
| App Name matches business | ⬜ | Must match business registration |
| Service Category | ⬜ | Choose Sports/Fitness for fitness apps |
| Privacy Policy URL | ⬜ | Must be accessible in-app |
| Terms of Service URL | ⬜ | Must be accessible in-app |
| Content Description | ⬜ | Accurately describe app functionality |
| Screenshots (3-5) | ⬜ | Show core features |
| Testing complete | ⬜ | Test on real devices |

---

## Prohibited Content (Always Rejected)

| Category | Examples |
|----------|----------|
| **Political** | Government criticism, political campaigning |
| **Religious** | Proselytizing, religious recruitment |
| **Pornography** | Sexually explicit content |
| **Violence** | Graphic violence, incitement |
| **Gambling** | Any form of gambling or betting |
| **Drugs** | Drug use, sale, promotion |
| **Fraud** | Scams, false advertising |
| **IP Infringement** | Pirated content, counterfeit goods |

---

## Common Rejection Reasons & Fixes

| Rejection | How to Fix |
|-----------|------------|
| "Category mismatch" | Re-submit under Sports/Fitness with explanation |
| "Content insufficient" | Add more pages: FAQ, About, Contact |
| "Privacy policy missing" | Add accessible privacy policy link |
| "Terms unclear" | Clarify subscription terms, refund policy |
| "Prohibited content" | Remove content, resubmit with explanation |
| "Functionality issues" | Test thoroughly, fix bugs, resubmit |

---

## Payment Integration (WeChat Pay)

| Requirement | Action |
|-------------|--------|
| Merchant account | Apply under Sports/Fitness category |
| Service description | "Fitness training" NOT "online courses" |
| Refund policy | Must be visible (7-day minimum) |
| Auto-renewal | Must be disclosed before subscription |
| Receipts | Provide digital receipts |

---

## If Your App Is Suspended

1. **Read suspension notice** — Understand the specific reason
2. **Check category** — Verify Sports/Fitness, not Education
3. **Review content** — Scan for prohibited content
4. **Fix issues** — Make necessary changes
5. **Submit appeal** — WeChat provides appeal process
6. **Wait** — Typically 1-7 days for review

---

## App Naming Best Practices

| ❌ Avoid | ✅ Use |
|----------|--------|
| "Online Course" | "Fitness Guide" |
| "Training Class" | "Practice Studio" |
| "Education Platform" | "Fitness Platform" |
| "School" | "Studio" / "Club" |
| "Teaching" | "Training" / "Practice" |

**Rule:** Avoid "education" keywords for fitness platforms to prevent classification under Education category.

---

## Key Resources

| Resource | URL |
|----------|-----|
| **WeChat Mini Program Dev Docs** | https://developers.weixin.qq.com/miniprogram/dev/framework/ |
| **Platform Policies** | https://developers.weixin.qq.com/miniprogram/product/product_review_policies.html |
| **WeChat Open Platform** | https://open.weixin.qq.com/ |

---

## Quick Decision Tree

```
WeChat-related question
       ↓
Submission/approval? → Check: Sports/Fitness category
       ↓
Prohibited content? → Check: moderation lists
       ↓
Suspension/appeal? → Fix issues, submit appeal
       ↓
Payment? → Check: WeChat Pay merchant requirements
       ↓
Default → General WeChat policy guidance
```

---

## Positioning Language Examples

### ❌ Avoid (Education classification risk)
- "Online learning platform"
- "Course provider"
- "Educational content"
- "Teaching videos"

### ✅ Use (Fitness classification)
- "Fitness practice platform"
- "Training studio"
- "Workout guides"
- "Practice videos"

---

## References

- **WeChat Policy agent:** `wechat-policy.md`
- **Content moderation:** `content-moderation.md`
- **Legal orchestrator:** `legal-orchestrator.md`
