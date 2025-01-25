# Getting the Secret from a QR-Code image

You may call me paraniod, but I DO NOT TRUST neither Google nor Microsoft. So using the Autenticators published by both are a kind of security breach.

But to be honest, both apps address a problem many people ignore: how to get access to your TOTP-secured accounts if the authenticator is {stolen|broken|in any way unavailable}?

Mistrusting Google (and Apple, too), haveing a backup in the *GoogleDrive* or *iCloud* isn't a solution -- especially if you need your lost TOTP device for accessing your data.

In the end, there must be a way to have a backup copy of your TOTP-Secret to restore the 2nd Factor again. 

Many Implementations of TOTP offer to use a *secret string* instead of the QR code to creat your Credentials, but not all do (e.g. datto.com offers an image only)

Trying to get the secret with my iPhone failed because the iPhone starts the "passwords" app when I tried to take a photo of the QR code.

Getting a picture of it otherwise (e.g. by Snapshot / *Windows Snipping Tool*) seems to work.

## Solution for Linux users
If you're working with linux you can examine your picture e.g. with the [*Zbar bar code reader*](https://github.com/mchehab/zbar):
- Install the tool, e.g. by `sudo apt-get -y zbar-tools`
- Get the secret by<br>
  ```bash
  $ zbarimg QR-Code.png
  Connection Error (Failed to connect to socket /run/dbus/system_bus_socket: No such file or directory)
  Connection Null
  QR-Code:otpauth://totp/<Application>%20%40%20<uid>%40<Domain>?secret=<HERE THE SECRET IS SHOWN :-)>
  scanned 1 barcode symbols from 1 images in 0.03 seconds
  ```
- Enter the secret in your TOTP authenticator

- Works well with [1Password](https://1password.com/) and [KeepassXC](https://keepassxc.org/) :-)

## Solution for Windows users
t.b.d. 🚧

## Solution for Mac users
I don't have a mac, so no idea ..
