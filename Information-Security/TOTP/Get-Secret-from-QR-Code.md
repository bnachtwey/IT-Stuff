# Getting the Secret from a QR-Code image
👷
You may call me paraniod, but I DO NOT TRUST neither Google nor Microsoft. So using the Autenticators published by both are a kind of security breach.

But to be honest, both apps address a problem many people ignore: how to get access to your TOTP-secured accounts if the authenticator is {stolen|broken|in any way unavailable}?

Mistrusting Google (and Apple, too), haveing a backup in the *GoogleDrive* or *iCloud* isn't a solution -- especially if you need your lost TOTP device for accessing your data.

In the end, there must be a way to have a backup copy of your TOTP-Secret to restore the 2nd Factor again. 

Many Implementations of TOTP offer to use a *secret string* instead of the QR code to creat your Credentials, but not all do (e.g. datto.com offers an image only)
