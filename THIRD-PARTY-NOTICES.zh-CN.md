# 来源与许可

[English](THIRD-PARTY-NOTICES.md)

EngRelay 原创材料采用 MIT 许可证，由项目负责人于 2026-10-14 选定。适用第三方声明如下。EngRelay 名称或根许可证不改变第三方权利。

## Oh My OpenAgent / OmO

- 项目：https://github.com/code-yeongyu/oh-my-openagent
- 2026-10-14 核对的条款：
  https://github.com/code-yeongyu/oh-my-openagent/blob/dev/LICENSE.md
- 所核对条款将 otherwise 未许可材料置于 Sustainable Use License 1.0 下，含外部分发限制与声明要求。
- 本地研究检查过标记为 5.1.29 且无 Git 元数据的树。这不能标识不可变的上游发布或提交。

本地研究记录机制启发：范围化角色退出、可执行设计审查、连续性与完整派发上下文。实际本地实现提交为 f50fff8。其设计需要独立项目表述。对四个受影响本地文档及其引入行与 60 个相关上游提示文件的较宽比较，未发现精确规范化 12-token 表达匹配。这一有界结果不证明独立著作权、不排除其他改编，也不授予再许可权限。

负责人澄清 Agent 实现了 OmO 启发的工作。经审计的实现提供机制级启发证据，在所选语料中未识别逐字导入。负责人在审阅上述发现与限制后选择 MIT。此处不捆绑任何上游 OmO 源码树。MIT 许可证不再许可 OmO 表达；后续识别的受限表达须移除、独立替换或取得适用许可。

## Every 的 Compound Engineering

- 项目：https://github.com/EveryInc/compound-engineering-plugin
- 2026-10-14 通过 GitHub 官方 contents API 核对的历史许可：
  https://github.com/EveryInc/compound-engineering-plugin/blob/4043703d32c5df9e35f22757dee22f3a72a99c66/LICENSE
- 发布 compound-engineering-v3.29.0 指向该提交。所核对许可为 MIT，Copyright (c) 2025 Every；Git blob SHA1
  `959dd283c510cfac6fd912555f99b14613ee9018`。
- 本地记录引用该发布与 pull request 1719、1772、1771。本声明保守覆盖下列本地 CE 衍生材料；不断言与上游 Skill 字节级等价。
- 2026-10-16 选择性同步核对 compound-engineering-plugin 提交 `50532b00de523980010d97fe950965b35382a3b7`（相对上述基线的 v3.30.5 比较），仅采用 PR 1791、1792、1852 相关规则；完整 MIT 声明仍适用。
- 可能改编的本地路径：
  `payload/docs/ai-collaboration/compound-engineering.md` 与四个规范
  `ce-code-review`、`ce-debug`、`ce-simplify-code`、`ce-compound` Skill。

下列适用原创版权与完整 MIT 声明须保留。与再分发的改编内容（含已安装副本）一并保留。本地规范 Skill 已针对本工具包的权威与激活规则定制；它们不是上游插件发布。不声称隶属或背书。

### Every 的 MIT 声明

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

## 未捆绑工具与私有材料

生成的 OpenSpec 宿主 Skill/命令、本地插件依赖及其 node_modules、个人工具设置、原项目规则、原始备份、运行交接与旧 Git 历史均排除。安装本工具包不会再分发或安装那些工具。受维护的角色工作流在显式选择时使用 OpenSpec；使用者须依其条款单独获取该工具。

## 中文摘要

负责人已选择自有内容采用 MIT，第三方条款保持适用。OmO 当前采用 SUL；本地记录要求独立表述，实际变更与 60 个相关上游文件的比较未发现长连续原文，仍不证明所有表达的归属。Every 3.29.0 历史许可已核实为 MIT，完整通知保留在本文件和本地 CE 改写文档/Skill 中，安装或生成副本时随同保留。2026-10-16 对 CE v3.30.5 提交的选择性核对仅纳入 PR 1791/1792/1852 相关规则，不更改上述 MIT blob 事实。
