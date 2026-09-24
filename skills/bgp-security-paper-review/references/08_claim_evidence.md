# ⑧ Claim-Evidence（声明-证据审计）

## 为什么这是核心产出

其它维度（①②③④⑤⑥⑦）各管一部分，但**声明-证据矩阵**把整篇论文的可验证声明统一成一张可证伪的表，是判断“贡献是否成立”的直接依据。一张严谨的 claim-matrix 比一个 Accept/Reject 更有科研价值。

## 提取规则（How to extract claims）

1. 只提取**可验证声明**（可证伪），排除价值判断与展望句。
2. 每条 claim 记录：**Claim**（精确措辞+编号 C1…Cn） → **Evidence location**（Section / Figure / Table / Equation / Appendix） → **覆盖范围**（claim 所有组成部分都要有对应证据）。
3. 没有 Evidence location 的 → “无证据”。

证据位置示例：
- `C3: batch verification 降低验证开销` → `Evidence: Sec 5.2 + Fig 8`。

## 充分性分级（Sufficiency grading）

| 级别 | 判定标准 | 处理 |
|------|---------|------|
| ✅ 充分（sufficient） | 证据覆盖 claim 的**全部含义**，且方法可归因 | 放行 |
| ⚠️ 部分（partial） | 证据存在但只覆盖 claim 一部分 / 存在混杂变量 | 要求补实验或收窄 claim |
| ❌ 否（unsupported） | 无证据，或证据与 claim 无关 / 相矛盾 | 必须标注并视为 assertion |

## 混合变量 / 归因审计（Attribution audit）

对每个“提升”类 claim，检查是否存在混杂变量使结果不能归因于论文声称的机制：

- 硬件不一致（不同机器/不同优化水平）？
- 基线未调优？
- key distribution 不同？
- 实验拓扑/数据范围不同？
- 不同实现语言/库版本？

**典型反例（本 skill 标准示例）——BGPsec batch verification：**

```text
Claim C3:
  作者声称 batch verification 能降低验证开销。

Evidence:
  Section 5.2 + Figure 8

问题:
  实验比较的是「N 个 signature verification」，
  但 baseline 使用的是 different key distribution。

  因此该 comparison 并不能直接证明 batch verification
  本身带来的 gain。

缺失实验:
  固定 key distribution，仅改变 verification strategy。
→ 判定：⚠️ 部分（归因不明）→ 需要补上述对照实验。
```

## 缺口标注（Gap tagging）

对每个 ⚠️/❌ 的 claim，明确写出“缺什么实验 / 应重写什么声明”，不要只写“证据不足”：

- 缺攻击类型：声称防 route hijack 但只测 origin hijack → 补 path manipulation attack。
- 缺部署维度：声称“可大规模部署”但只仿真 → 补真实 RIB 回放或全规模验证开销。
- 缺混合部署：声称“可增量部署”但无 mixed deployment 分析 → 补部分部署降级实验。

## 输出模板

```markdown
| Claim | Evidence | 充分性 | 缺口 / 该补的实验 |
|-------|----------|--------|------------------|
| C1 防止 route hijack       | Exp.1（只测 origin）        | ⚠️ 部分 | 补 path manipulation / deletion |
| C2 防止 route leak         | （无）                      | ❌ 否   | 无 route-leak attack 实验 |
| C3 支持大规模部署            | Fig.8（仅仿真）              | ⚠️ 部分 | 真实 BGP 报文回放 |
| C4 比 BGPsec 快 6×          | Exp.4                      | ⚠️ 待核 | key distribution/硬件不一致 |
| C5 可增量部署               | §6                         | ❌ 不充分| 无 mixed deployment 分析 |
```

## 处理规则（Rules of engagement）

- **无证据的 claim** 不能靠“可信作者”放行 → 一律 ❌。
- **证据与 claim 范围不一致** → ⚠️，并要求“补实验或收窄声明”二选一。
- 若作者在正文明确限定假设（如“在 RPKI 全部署下”），claim 的充分性在该假设内评估，但该假设的现实性交给 ①⑤⑦ 维。
- 审查结束前，**每条 claim 都必须有充分性标注**——不允许“未审”的漏网 claim。

## 与其它维度的联动

- ② 威胁模型 → 实验攻击模型不匹配 = 直接表现为 claim 的 ⚠️/❌。
- ④ 协议正确性 → 可被触发失败分支 = claim 的“安全性”不成立。
- ⑥ 实验审计 → 混杂变量 = 归因问题。
- ⑦ 部署 → “可部署/可增量”类 claim 的证据充分性。

## 输出到哪

`paper-review/claim-matrix.md` —— 本 skill 最终结论的**唯一权威依据**；Final Review 的每条 Major/Minor 都必须能在矩阵中追溯到对应 claim。
