# Final Review

> Reviewer / Venue / Date / Paper version / Recommendation

## 严重性定义（Severity taxonomy）

- **Major（致命级，通常决定 Reject/Borderline）**：
  1. 安全属性本身不成立——代码/协议/机制层面可利用的漏洞或失败分支（④）；
  2. 威胁模型与实验攻击模型显著错位，或威胁模型夸大（②）；
  3. 关键 claim 无证据，或证据与 claim 相矛盾（⑧）；
  4. 机制被现有工作包含 / 贡献在同样假设下被解决（⑤①）；
  5. 只在全量/理想部署下成立，无任何增量或混合部署路径（⑦）。
- **Minor（可修级，通常不影响结论方向）**：
  1. 表述不清、术语/机制混淆可修正；2. 缺个别消融/对照实验但主结论成立（⑥）；
  3. 相关工作引用不全但不改变贡献判定（⑤）；4. 数值/图号笔误（核对后修正）。
- 每条 Major/Minor 必须标注：**关联 claim 编号（C#）** 与 **所属维度（①-⑧）**。

## 论文一句话

（问题、机制、结论，3 句话以内）

## 摘要（Summary / Strengths）

- S1 ········································
- S2 ········································
- S3 ········································

## Major Issues（每条必须能追溯到 claim-matrix）

- **M1** ·········（关联 C#，所属维度 ①②③④⑤⑥⑦⑧）
- **M2** ·········（关联 C#…）
- **M3** ·········

典型 Major 来源：
- 威胁模型与实验攻击模型不匹配（②）
- 安全属性笼统 / mechanism-property 混淆（③）
- 可被攻击者触发的失败分支（④）
- 性能/收益不可归因（④⑥）
- 无 mixed-deployment 分析 / 全量假设（⑦）
- claim 无证据（⑧）

## Minor Issues

- m1 ········································
- m2 ········································

## 给作者的必须追问（Questions for Authors）

1. ```text
   Claim C4：<原文>？你们与 baseline 的 key distribution 是否一致？
   能否补“固定 key distribution、仅改变 verification strategy”的对照？
   ```
2. ```text
   混合部署（只部署 X%）下，<安全属性>如何逐级降级？请给量化或至少边界。
   ```
3. ········································

## 维度汇总打分（非正式）

| 维度 | 评价 | 主要问题 |
|------|------|---------|
| ① Problem Definition | ☐ 清晰 ☐ 模糊 ☐ 错位 | |
| ② Threat Model | ☐ 自洽 ☐ 夸大 ☐ 不足 | |
| ③ Security Properties | ☐ 精确 ☐ 笼统 | |
| ④ Protocol Correctness | ☐ 正确 ☐ 存疑 ☐ 有可利用分支 | |
| ⑤ Comparison | ☐ 公平 ☐ 不公平 ☐ 边界不清 | |
| ⑥ Evaluation | ☐ 充分 ☐ 部分 ☐ 不足 | |
| ⑦ Deployment | ☐ 充分 ☐ 未分析 | |
| ⑧ Claim-Evidence | 覆盖 N/M 条 claim；❌ 条无证据 | |

## 总体结论 / Recommendation

- ☐ Accept ☐ Weak Accept ☐ Borderline ☐ Reject
- 一句话依据（必须引用 claim-matrix 中最重的 1-2 条）：
  ·········································
