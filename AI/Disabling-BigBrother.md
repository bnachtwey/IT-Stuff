# Disabling BigBrother aka AI 
The *hottest AI shice* is not welcome to everybody. Maybe some people are paranoid -- or just have red [Nineteen Eighty-Four](https://en.wikipedia.org/wiki/Nineteen_Eighty-Four) by George Orwell and got the key points. Well, these people cannot be *convinced to share their most private data with BigTech*, so some force is used by adding and enabling such "features" by default.

Furtunately, there are some tools which violate the basic principle of “Privacy-by-Default (PbD)”, but still allow such functions to be switched off.

## Apple Siri
- Starting with iOS 18 you cannot disable Siri completely if you still want to use *Apple CarPlay* 🤮
  - As a workaround you may limit the access to Siri *on pressing the side button only*

## Mozilla Firefox
- [Disable and remove all AI features in Firefox](https://www.askvg.com/how-to-disable-and-remove-all-ai-features-in-mozilla-firefox), Last updated on March 6, 2025 by Vishal Gupta
- Step-by-Step:
  - STEP 1: Open Mozilla Firefox and type `about:config` in the address bar and press Enter. It’ll show you a warning message, click on “Accept the Risk and Continue” button. It’ll open Firefox’s hidden secret advanced configuration page i.e. about:config page.
  - STEP 2: Now type chat inside the preference search box and look for following preference:
    ```
    browser.ml.chat.enabled
    ```
  - STEP 3: The preference decides whether the new AI chatbot and other AI features should be enabled or not.
 
    To deactivate and disable all AI features in Firefox, double-click on the preference and it’ll change its value to **False**. Alternatively, you can click on the Toggle icon given next to the preference name to modify it.

Well, [Librewolf](https://librewolf.net/) _A custom version of Firefox, focused on privacy, security and freedom._ has no AI enabled by default :-D
