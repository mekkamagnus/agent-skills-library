# WeChat Privacy Requirements

**Source:** https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/privacy.html
**Last Accessed:** 2025-02-28
**Language:** English

## WeChat Mini Program Privacy Requirements

---

## Privacy Policy Requirements

### 1. Mandatory Privacy Policy
Every Mini Program must have a **privacy policy** that is:
- Accessible from within the Mini Program
- Written in **clear, understandable language**
- Provides comprehensive information on data practices

### 2. Required Content
The privacy policy must include:

#### a. Data Collected
- **User information:** User ID (openid), nickname, avatar, gender, location
- **Device information:** Device model, operating system, platform
- **Usage data:** Page visits, interaction data
- **Payment information:** Transaction records (processed by WeChat Pay)

#### b. Purpose of Collection
- Service delivery
- Account management
- Customer service
- Security and fraud prevention
- Analytics and improvement

#### c. Data Sharing
- **Third-party services:** List any third parties
- **Legal requirements:** When data is shared per law
- **Business transfers:** In case of merger/acquisition

#### d. User Rights
- Right to access personal data
- Right to correct inaccurate data
- Right to delete account and data
- Right to withdraw consent
- Right to complain to platform

#### e. Contact Information
- Email or in-app contact method
- Response time commitment

---

## User Consent Requirements

### 1. Explicit Consent
Before collecting ANY user information:
- Display privacy interface
- Obtain user's **affirmative consent**
- Allow users to **decline** essential collection

### 2. Separate Consent for Sensitive Data
For sensitive information:
- **Location**: Separate consent dialog
- **Camera/Microphone**: Explicit user permission
- **Address/Phone**: Additional consent layer

### 3. Consent Scope
- Collect **only necessary data**
- Purpose-limited use
- No pre-checked boxes for non-essential data

---

## API Usage Rules

### User Information APIs
| API | Consent Required | Purpose |
|-----|------------------|---------|
| `wx.getUserInfo` | Yes | User profile |
| `wx.getUserProfile` | Yes | Detailed profile |
| `wx.getLocation` | Yes | User location |
| `wx.chooseAddress` | Yes | Shipping address |
| `wx.getPhoneNumber` | Yes | Phone number |

### Privacy Interface (New Requirement)
Since October 2023, Mini Programs must:
1. Configure privacy interfaces in the Mini Program backend
2. Show consent dialog before calling privacy APIs
3. Handle user rejection gracefully

---

## Privacy Audit Requirements

### WeChat Privacy Reviews Check:
1. ✓ Privacy policy is accessible
2. ✓ Consent obtained before data collection
3. ✓ Data collection matches declared purpose
4. ✓ User can delete account/data
5. ✓ Contact information provided
6. ✓ No hidden data collection

### Common Rejection Reasons:
- "Privacy policy not accessible"
- "Missing user consent mechanism"
- "Collecting data beyond declared scope"
- "No account deletion option"

---

## Data Storage Requirements

### Within WeChat Ecosystem
- User data stored via WeChat cloud services
- Use `wx.setStorageSync` for local data
- Implement server-side encryption for sensitive data

### Data Retention
- Active users: Retain while account active
- Deleted accounts: Delete within 30 days
- Inactive users: Retain maximum 3 years

---

## Templates and Resources

**Privacy Policy Template Location:**
- WeChat Developer Docs: [Privacy Policy Guide](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/privacy.html)

**Required Disclosure Language:**
- "本小程序收集用户信息用于..."
- "用户有权访问、更正、删除其个人信息..."
- "联系我们：[email/phone]"
