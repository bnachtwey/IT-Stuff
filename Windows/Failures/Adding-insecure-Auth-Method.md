# Having asked "Copilot" how to avoid MS asking for my phone number

<!--
-->

## Prompt:

```
How to PERMANENTLY SKIP Microsoft asking for mobile number to "secure" my account?
I already set a TOTH and hardware bound MFA-Token, so SMS or calling DOES lower the account' security!
```

## Copilot's Answer 🤣

Here’s the **good news** and the **bad news** — and the **work‑arounds that actually *do* work**.

Before we dive in:  
Your enterprise data showed **no internal policies, chats, files or meeting notes** about disabling Microsoft’s mobile‑number prompts (totalResults indicated only tangential MFA material). So the answer relies entirely on verified public documentation and Microsoft’s own behavior.

***

### ✅ **Short Answer**

You **cannot permanently disable** Microsoft’s request for a phone number on a *personal* Microsoft account.  
For **Microsoft Entra ID / Office 365 (work account)**, you *can* stop the phone‑number requirement **if your admin configures Authentication Methods correctly** and disables all phone‑based methods.

***

### 🎯 **Your Situation**

You already use:

*   **TOTP (OATH)**
*   **Hardware‑bound MFA token (FIDO2 / OATH)**

…and you correctly note that:

*   **SMS and voice calls *reduce* security**,
*   Phishing‑resistant methods (FIDO2, passkeys, etc.) are the standard.  
    (Supported by BSI and also reflected in your own file: 2025-08-15‑IT‑Sicherheit …) [\[2025-08-15...er Telefon | PDF\]](https://cristiedatagmbh-my.sharepoint.com/personal/bjoern_nachtwey_cristie_de/Documents/Microsoft%20Teams-Chatdateien/2025-08-15-IT-Sicherheit%20f%c3%bcr%20Firmen_%20Effektive%20Ma%c3%9fnahmen%20gegen%20Vishing-Angriffe%20per%20Telefon.pdf?web=1)

So your stance is absolutely valid.

***

### 🛠️ **How to stop Microsoft from nagging for phone numbers (WORK ACCOUNT / ENTRA ID)**

#### ✔️ **1. Admin must disable phone‑based MFA methods**

Microsoft officially allows this:

Source: Microsoft Learn — Authentication Methods Policy    [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-manage-oath-tokens)

##### How to disable:

Entra admin center →  
**Entra ID → Authentication methods → 'Microsoft Authenticator' / 'Phone'**  
Disable these:

*   **SMS**
*   **Voice call**
*   **Authenticator app phone sign‑in / push** (optional)

Also ensure the Registration Campaign is not enforcing mobile app registration.    [\[redmondmag.com\]](https://redmondmag.com/articles/2025/05/20/how-to-disable-the-mandatory-microsoft-authenticator-app-requirement.aspx)

##### Additionally:

Disable or limit:

*   “Verification code from mobile app or hardware token” checkbox in legacy MFA settings  
    (This setting is confusing and should be disabled only if you moved fully to the new Authentication Methods Policy.)    [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-manage-oath-tokens)

***

#### ✔️ **2. Enable ONLY secure methods**

Recommended methods Microsoft considers phishing‑resistant:

*   **FIDO2 hardware keys**
*   **Certificate‑based authentication**
*   **Passkeys / Windows Hello for Business**
*   **Hardware OATH tokens (TOTP)**  
    (Explicitly supported and manageable at scale.)    [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-manage-oath-tokens)

Do this via:  
**Entra ID → Authentication Methods → FIDO2 / OATH**

***

#### ✔️ **3. Ensure "Registration Campaign" does NOT force mobile app**

Microsoft’s own docs state that the Registration Campaign can *force* the Authenticator App.    [\[redmondmag.com\]](https://redmondmag.com/articles/2025/05/20/how-to-disable-the-mandatory-microsoft-authenticator-app-requirement.aspx)

Disable it to avoid being nagged.

***

#### ✔️ **4. If Microsoft still asks: remove phone methods completely**

Microsoft Support article confirms you can remove sign‑in verification methods, including phone numbers:    [\[support.mi...rosoft.com\]](https://support.microsoft.com/en-us/account-billing/removing-a-sign-in-verification-method-4099aa36-bb4e-429e-a0d7-9e05617084f1)

**BUT**:  
Removing *all* security info puts the account in a **30‑day restricted state**, so make sure you have **FIDO2 + TOTP** registered *before* deleting the phone number.

***

### ❌ **For Personal Microsoft Accounts (outlook.com, xbox.com, etc.)**

There is **NO supported way** to permanently avoid the phone number prompt.

Even if you remove your number (supported method):    [\[support.mi...rosoft.com\]](https://support.microsoft.com/en-us/account-billing/removing-a-sign-in-verification-method-4099aa36-bb4e-429e-a0d7-9e05617084f1)

Microsoft may still prompt occasionally as part of "Security Info" validation.  
There is no permanent opt‑out, and attempts to bypass this requirement may lock the account.

***

### 🔐 **Summary: What *actually* works in organizations**

To fully avoid phone numbers, ensure:

#### ✔ Your admin configures:

1.  Disable SMS
2.  Disable Voice
3.  Disable Registration Campaign
4.  Enable OATH hardware tokens
5.  Enable FIDO2
6.  Enforce phishing‑resistant MFA via Conditional Access
7.  Turn on “Temporary Access Pass” for onboarding (no phone needed)  
    (Recommended in Microsoft Community)    [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/discussions/azure/mfa-without-a-cellphone/2197364)

#### ✔ Your user account:

*   Remove phone numbers in Security Info (optional)
*   Register at least 2 secure factors (FIDO2 + TOTP or Passkey)
