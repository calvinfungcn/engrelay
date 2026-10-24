# Lite 参考输入与采用边界

本记录对应任务 1.1。核对日为 2026-10-22；参考输入自报版本 0.2.0，README 以 EngRelay 1.9.6 比较，CHANGELOG 称借鉴 1.9.2–1.9.4 的交接思路。未提供可核实的独立上游提交，本记录只固定本次收到的文件字节，不把自报版本当作不可变上游出处。

## 输入指纹

路径相对于所提供的 Lite 输入根；不公开其私人存放位置。全部 13 个文件共 36,929 字节。

| 相对路径 | 字节 | SHA256 |
| --- | ---: | --- |
| .gitignore | 28 | B743E6D6086F9367034FB7E810E0E9EF9E81B7261097068F4C342F77D0C759D9 |
| CHANGELOG.md | 2435 | CCEFBA404B02B65F32749B5DF8EB11AB96A0723DDED32EBDA7138A6419E41995 |
| install.ps1 | 8431 | 4D21807511E3AE52C24B5A0ADA67329824C3BF74DFC37FD97501190FD8EA28A7 |
| LICENSE | 1097 | 36F27F5DAE6DAB21A5762552CB209E0315EF3D7F88DB9157EF8DEE36ACA0313C |
| README.md | 10275 | 6138361FD1DE4CB67E6225CB475D3D90519A48C6BA65055DE192A8647F96518F |
| core/agents-block.md | 526 | 349ED010FBE7D5347AD8F6AC4D01831D2B6C570492606C9A47261D0F273D67AA |
| core/check.ps1 | 2660 | 2156E6C55D8B48FA79F2590E5D1A4A46E702534D26E206A882879FD11AE0FC6D |
| core/RULES.md | 8271 | 9E5CA1C486844428126CA5BA86B6F99FFF23FB85B82D3F524314ECFA35311A17 |
| core/VERSION | 6 | 1F930DD1F133C1F97A94FE3ACB8DB34372CF4C01FFDB2B3FF4CA72F9494121E9 |
| core/templates/handoff.md | 717 | 19376FB6BCEADEDCE37D64384D8D8C3259C46D3E352A20352AD7F209BFBDD58B |
| core/templates/project-config.md | 926 | D2B170C2019061024DF9E4FF9538AFA51E90CFCB0AF90F09915795604E05CC12 |
| core/templates/queue.md | 1137 | BAAD848485FE450D5B9899E0DB04F91ED16051E7961B27A5BB2AF61D60218D5E |
| core/templates/task-note.md | 420 | C9E10E43F2590A524DB5CE7C7AFF5D3EC80107404CAFD57376F09011075566F6 |

## 可观察差异与处理

| 输入观察 | 官方整合处理 | 依据或限制 |
| --- | --- | --- |
| 一份短规则、聚合执行职责 | 采用小读取集合和聚合职责 | Full 已允许同一 Agent 连续执行；不宣称这是对强制多会话的修复 |
| 顺序任务队列 | 采用已批准任务、显式依赖和各任务暂停快照 | 不宣称已提供后台自动唤醒 |
| 以文档／小改动举例 S | 改按实际行为影响分类 | 规则、配置或权限文字也可能改变高风险行为 |
| M 修一轮后收口，只有 H 明确复核 | M 必须修项保留独立复核；H 保留所需独立验证 | 文件短不豁免真实独立性 |
| 任意覆盖、技术取舍也列为闸门 | 使用原授权优先及实质决定边界 | 已批准正常编辑不重复请示；真实权限仍须满足 |
| 最大修订号解决冲突 | 明确来源和旧状态指纹匹配，冲突不应用 | 修订只在同任务内比较，不认证来源 |
| 与 Full 共用 .ai/handoff.md | Lite 使用隔离运行态根 | 不转换旧任务或覆盖其证据 |
| 交接后只允许读四份文件 | 四份是入口，源码／模块规则／具名证据按需读 | 不建立封闭读取限制 |
| 安装将旧目录移走，再复制新目录 | 不采用该安装器 | 官方生命周期继续逐项归属、预检冲突及保留恢复材料 |
| 检查脚本只看文件／标记和其他 Skill | 重新提供按配置的只读诊断 | 他方 Skill 存在不等于激活；输入脚本的 CHECK 文本不等于机器非零失败 |
| 项目配置优先于默认规则 | 配置表达项目命令、可用工具和明确额外限制 | 不能由空白配置、模型偏好或无来源的说明推导新授权或取消独立性 |
| README 对 Full 的度量／角色描述较重 | 人类指南按保证和读取范围比较 | Full 小任务已有短路，估算可选；人数不是能力边界 |

## 采用方式与来源限制

第一期只保存比较、设计和虚构样例。第二期在 canonical payload 内编写英文规范，不直接合并整个输入目录，不复制 install.ps1 或 check.ps1，也不把参考 README 的比较当作官方事实。规则、模板若有采用或改写，保守保留下列原通知及原有 EngRelay 通知，并在实际发行时同步两份来源说明。

输入 README 声称独立编写、未复制其他项目；本次仅核对所提供文本和相关 EngRelay 基线，没有做全部潜在来源的表达审计，不能据此证明独立作者关系、权利完整性、无第三方改写或上游背书。输入指纹证明对应字节，不证明作者身份。没有将来源判断扩展为对其他项目许可的重新判断。

## 输入随附通知

以下是所提供 LICENSE 的通知正文，保留原文；其适用范围为实际采用或改写的对应材料，不替代已有第三方通知。

```text
MIT License

Copyright (c) 2026 Eric Fung and EngRelay-Lite contributors

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
```
