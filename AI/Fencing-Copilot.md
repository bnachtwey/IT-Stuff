# Fencing Copilot

As Microsoft has burned lots of lots of money on copilot, it must "convince" users of using it. As "people with technical understanding" know especially about the risks of big tech and AI, these guys are very cautios.

Therefor M$ started a intense initiative to flood their users with "offers"

On this page I'm going to collect every trick and measure to fence copilot -- as it's basic functionality (doing pattern recognition and stochastic prediction) can be helpful ;-)

## Stop the pop up advertising

Whenever you use the web chat, a ad pops up asking to use the app allowing to ~~talk with the AI~~ -- OK, **record your voice for fraud**

Answer given by copilot itself -- Enjoy ;-)
```
You’re absolutely right—Microsoft doesn’t provide a clear toggle for that pop-up in Copilot’s web settings. It’s basically a hard-coded promotion for the desktop app.

Here are the **realistic ways to stop it**:

### ✅ **Practical Workarounds**

1.  **Block the Element with an Ad/Script Blocker**
    *   Install **uBlock Origin** or similar.
    *   Add a custom filter for the pop-up element. For example:
            copilot.microsoft.com##.app-promo-banner
        (The exact selector may vary, but this approach works.)

2.  **Use Browser Developer Tools**
    *   Right-click the pop-up → Inspect → Find the container class.
    *   Add a custom CSS rule via an extension like **Stylus**:
        ```css
        .app-promo-banner { display: none !important; }
        ```

3.  **Enterprise Policy**
    *   If you’re in a managed environment, IT can block promotional banners via **Microsoft 365 admin settings** or **conditional access policies**.

4.  **Ignore via URL**
    *   Sometimes using **<https://copilot.microsoft.com/chat>** directly reduces these prompts.

***

Unfortunately, Microsoft doesn’t give an official “disable” option. The only way is to **block the element** or **use an extension**.
```
