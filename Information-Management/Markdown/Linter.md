# Notes on linter
<!--
AIA No AI, _This work was entirely human-created, without the use of AI._

# changelog
# date          version    remark
# 2026-02-24    0.1        initial coding

-->

Linters allow easily to check the written markdown code. For [`vscode`](https://code.visualstudio.com/) or [vsCodium](https://vscodium.com/) there are several addons available doing so, e.g.

- `markdownlint` by DavidAnson

Unfornately, the linters are very strict in their rules, but by adding a file called `.markdownlint.json` in the Repos top level folder, you can change or skip some rules.

For example:

```json
{
  # Disabled linter rules
  # MD013 - Line length
  "MD013": false,
  
  # MD024 - Multiple headings with the same content
  "MD024": false,
  
  # MD060 - Table column style
  "MD060": false
}
```
