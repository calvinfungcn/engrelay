# Sources and licensing

[Simplified Chinese](THIRD-PARTY-NOTICES.zh-CN.md)

EngRelay's original material uses the MIT License, selected by the project owner
on 2026-10-14. Applicable third-party notices follow. Third-party rights are not
changed by the EngRelay name or the root license.

## Oh My OpenAgent / OmO

- Project: https://github.com/code-yeongyu/oh-my-openagent
- Terms checked on 2026-10-14:
  https://github.com/code-yeongyu/oh-my-openagent/blob/dev/LICENSE.md
- The checked terms place otherwise-unlicensed material under Sustainable Use
  License 1.0, with external-distribution limits and notice requirements.
- Local research examined a tree marked 5.1.29 with no Git metadata. This does
  not identify an immutable upstream release or commit.

The local research records mechanism inspiration: scoped role exits, executable
design review, continuity, and complete dispatch context. The actual local
implementation commit is f50fff8. Its design requires independent project
wording. A broader comparison of the four affected local documents and their
introduced lines with 60 relevant upstream prompt files found no exact normalized
12-token expression matches. This bounded result does not establish independent
authorship, rule out other adaptations, or grant permission to relicense them.

The owner clarified that an Agent implemented the OmO-inspired work. The audited
implementation provides evidence of mechanism-level inspiration and no identified
verbatim import in the selected corpus. The owner selected MIT after reviewing
those findings and limits. No upstream OmO source tree is bundled here. The MIT
license does not relicense OmO expression; any subsequently identified restricted
expression requires removal, independent replacement, or applicable permission.

## Every's Compound Engineering

- Project: https://github.com/EveryInc/compound-engineering-plugin
- Historical license checked on 2026-10-14 through GitHub's official contents API:
  https://github.com/EveryInc/compound-engineering-plugin/blob/4043703d32c5df9e35f22757dee22f3a72a99c66/LICENSE
- Release compound-engineering-v3.29.0 points to that commit. The checked license
  is MIT, Copyright (c) 2025 Every; Git blob SHA1
  `959dd283c510cfac6fd912555f99b14613ee9018`.
- The local records cite that release and pull requests 1719,1772,1771.
  The notice conservatively covers the local CE-derived material below; it does
  not assert byte-for-byte equivalence with upstream Skills.
- Selective sync checked compound-engineering-plugin commit
  `50532b00de523980010d97fe950965b35382a3b7` (v3.30.5 compare against that
  baseline), adopting PR 1791, 1792, and 1852 rules only.
- Potentially adapted local paths:
  `payload/docs/ai-collaboration/compound-engineering.md` and the four canonical
  `ce-code-review`, `ce-debug`, `ce-simplify-code`, `ce-compound` Skills.

The applicable original copyright and full MIT notice follow. Preserve them
with redistributed adapted content, including installed copies. The local
canonical Skills have been tailored to the kit's authority and activation rules;
they are not an upstream plugin release. No affiliation or endorsement is claimed.

### Every's MIT notice

MIT License

Copyright (c) 2025 Every

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Unbundled tools and private material

Generated OpenSpec host Skills/commands, local plugin dependencies and their
node_modules, personal tool settings, original project rules, raw backups,
runtime handoffs, and old Git history are excluded. Installing this kit does not
redistribute or install those tools. The maintained role workflow uses OpenSpec
when explicitly selected; consumers obtain that tool separately under its terms.
