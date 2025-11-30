# Notes on security my web server running `Nginx Proxy Manager`

:construction:

## Problem

scanning one proxied sub site with [securityheaders](https://securityheaders.com/) I got a *F* mark in the *Security Report Summary*:

Header issues:

- Content-Security-Policy (CSP)

  Content Security Policy is an effective measure to protect your site from XSS attacks. By whitelisting sources of approved content, you can prevent the browser from loading malicious assets.

- X-Frame-Options
  
  X-Frame-Options tells the browser whether you want to allow your site to be framed or not. By preventing a browser from framing your site you can defend against attacks like clickjacking. Recommended value "X-Frame-Options: SAMEORIGIN".

- X-Content-Type-Options

  X-Content-Type-Options stops a browser from trying to MIME-sniff the content type and forces it to stick with the declared content-type. The only valid value for this header is "X-Content-Type-Options: nosniff".

- Referrer-Policy

  Referrer Policy is a new header that allows a site to control how much information the browser includes with navigations away from a document and should be set by all sites.

- Permissions-Policy

  Permissions Policy is a new header that allows a site to control which features and APIs can be used in the browser.

## Fixing it?

### CSP missing

### X-Frame-Options

### X-Content-Type-Options

### Referrer-Policy

### Permissions-Policy
