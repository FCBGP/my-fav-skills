# ⑩ 完整示例（Worked Example）

> **示例为合成的虚构论文**（基线=BGPsec 的 batch verification 优化），只用于演示本 skill 的用法，不代表真实论文。
> 目的是展示：paper.md → threat-model → claim-matrix → final-review 的端到端产出形态，以及“证据缺口”如何被定位。

## 0. 虚构论文设定（用于演示）

- 题目：《FastBGP: Batch Signature Verification for BGPsec》（虚构）
- 声称：batch verification 让 BGPsec 每跳验证开销降低 6×；宣称“提高路由安全”。
- 结构：§2 BGPsec 背景；§4 协议；§5.2+Fig.8 性能实验；§6 部署讨论。
- 已知事实性问题（演示时会抓出来）：Fig.8 的 baseline 用了不同 key distribution；§6 无混合部署分析；威胁模型声称防 hijack 但实验只测 origin hijack。

## 1. paper.md（抽取结果）

- RQ1：在保留 BGPsec 路径完整性的前提下，降低每跳验证开销。
- 机制：把一条路径上多个 ECDSA 签名做 batching，共享一对称量加速预计算。
- Claims 初稿：
  - C1 保持 BGPsec 等价路径完整性；
  - C2 batch 验证比逐签验证快 6×（§5.2+Fig.8）；
  - C3 可增量部署（§6）；
  - C4 降低路由劫持风险（Abstract）。
- 假设：全量 BGPsec 部署；密钥不泄露；时间同步。
- 作者自白不保障：无。

## 2. threat-model.md（②③ 结果）

| 声称威胁 | 章节 | 实验攻击模型 | 匹配 |
|---------|------|-------------|------|
| 防 route hijack (C4) | Abstract | 只做了 origin hijack 仿真 | ⚠️ 部分 |
| path manipulation | — | 无实验 | ❌ 未覆盖 |

→ ② 记录 mismatch：宣称“防 hijack”但未覆盖 path manipulation；batch 丢失/重放攻击也未建模。

## 3. claim-matrix.md（⑧ 结果，本 skill 的核心）

| Claim | Evidence | 充分性 | 缺口 / 该补的实验 |
|-------|----------|--------|------------------|
| C1 保持等价路径完整性 | §4 论证 + §5.1 正确性实验 | ⚠️ 部分 | 缺随机化错误注入；未证明 batching 不影响验签失败路径 |
| C2 比逐签快 6× | §5.2 + Fig.8 | ⚠️ 待核 | **baseline key distribution 不一致** → 归因不明；需固定 key distribution、仅改变 verification strategy |
| C3 可增量部署 | §6 文字 | ❌ 不充分 | 无 mixed deployment 降级分析；仅文字 |
| C4 降低劫持风险 | 无 | ❌ 否 | 无端到端攻击实验；且只测 origin，未测 path |

**归因复核**（C2）：claim 声称收益来自 batching；但 Fig.8 的 baseline 采用 different key distribution，混杂变量存在 → 提升不归因于 batching 本身。

## 4. final-review.md（摘要）

- Major M1（关联 C2，⑥④）：性能提升不可归因——固定 key distribution、仅改变 verification strategy 的对照缺失。
- Major M2（关联 C4，②③）：威胁模型声称防 hijack，实验只覆盖 origin hijack，path manipulation / replay 未建模。
- Major M3（关联 C3，⑦）：无混合部署分析，全量假设下讨论可部署性。
- Overall：❌ Reject（当前形态）；建议补三组实验后可 re-submit。
- 给作者追问：
  1. “Fig.8 的 baseline 用的是什么 key distribution？能否补固定 key distribution、只换 verification strategy 的对照？”
  2. “‘防 hijack’——你们对 path manipulation / replay 的防御和实验在哪里？”
  3. “只部署 X% 的 AS 时，路径完整性如何逐级降级？请给量化或至少边界。”

## 5. 从这个示例学到的模式（可作为复用手感）

- 每一条 final-review 的 Major 都能回溯到 matrix 里的 claim（C#）→ 不能被“印象”糊弄。
- “快 N× / 提升 XX%”类 claim 先查归因（key distribution / 硬件 / 基线调优 / 安全等级）。
- 摘要级安全词（“提高路由安全”“防劫持”）→ 必须实例化为具体属性 + 对应攻击实验。
- “可增量部署”是高频过度声明：没有 mixed deployment 分析 = 证据不充分。
