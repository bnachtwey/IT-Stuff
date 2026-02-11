# AI attribution for improved transparency

Due to <https://aiattribution.github.io/> :

_An attribution statement identifies not only the presence of AI involvement, but also how AI was used. This approach makes important distinctions between different types and amounts of AI contributions, allowing creators to maintain ownership over co-created work and consumers to calibrate their trust._

## Some Basic AIA codes

| Abbreviated statement | Full statement | expanded statement |
| :-------------------: | :------------: | :----------------- |
| `AIA No AI v1.0` | `AIA No AI v1.0` | _This work was entirely human-created, without the use of AI._ |
| `AIA Ph Se Hin R v1.0` | `AIA Primarily human, Stylistic edits, Human-initiated, Reviewed v1.0` | _This work was primarily human-created. AI was used to make stylistic edits, such as changes to structure, wording, and clarity. AI was prompted for its contributions, or AI assistance was enabled. AI-generated content was reviewed and approved._ |

### Examples for Markdown

```bash
<!--
AIA Primarily AI, Content edits, Human-initiated, Reviewed v1.0

# changelog
# date          version    remark
# 2026-01-13    0.1        initial coding: take suggestion from *copilot*, verify and fix it ;-)
#                          approach with xss-lock does not work, besides xss-lock and resolvectl run in different user scopes ...

-->
```

```bash
<!--
AIA No AI, _This work was entirely human-created, without the use of AI._

# changelog
# date          version    remark
# 2026-01-13    0.1        initial coding

-->
```
