---
name: bgp-security-paper-review
description: Evidence-based technical audit of network & systems security papers, specialized for inter-domain routing security (BGP, RPKI/ROA/ROV, BGPsec, ASPA, FC, CRC, route hijack, route leak, path/policy/origin validation) and extensible to network measurement, protocol security, SDN routing, and routing PKI. Use this skill to audit a single paper's problem definition, threat model, security properties, protocol correctness, cryptographic mechanisms, experiment design, live data, deployment cost, and boundaries against RPKI/BGPsec/ASPA, then judge whether its contributions actually hold. Prefer over generic paper-review skills for CCS/S&P/NDSS/USENIX Security/IMC/PAM routing-security manuscripts and pre-submission self-review.
allowed-tools: Read Write Edit Bash
license: MIT license
metadata: {"version": "1.2", "skill-author": "K-Dense Inc."}
---

# BGP & Network-Security Paper Review

## 立场（What this skill is）

本 skill 是**证据制技术审计**，不是“论文总结器”。审一篇网络/路由安全论文时，你要回答的不是“论文创新性较强”，而是：

> **问题定义是否成立？威胁模型是否自洽？协议/密码学是否正确？实验与现网数据能否支撑 claim？部署成本是否被忽略？它和 RPKI / BGPsec / ASPA 的边界在哪里？贡献是否真的成立？**

默认审查域（domain）远不止 BGP——它覆盖：

```text
BGP / RPKI (ROA/ROV) / BGPsec / ASPA / S-BGP / soBGP / ARTEMIS /
route hijack / route leak / 路径验证 / 网络意图 / SDN /
域间路由 / 网络测量 / routing PKI / 加密路由协议
```

对于通用论文审查（ML/系统/生物医学等），请改用仓库内的 `peer-review` 等 skill；本 skill 只在本域内使用。若需要跨论文系统性综述，联动 `literature-review` / `paper-lookup`，而不要在本 skill 内实现检索。

## When to Use

- 审查投稿或预印本：CCS、S&P、USENIX Security、NDSS、IMC、PAM、SIGCOMM、IETF 提案文档等，主题是路由安全 / 网络测量 / 协议安全。
- 对自己的草稿做投稿前自审（pre-submission self-review）。
- 对协议设计做深度审计（BGPsec / ASPA / FC / CRC 或类似机制的**协议正确性**）。
- 复核一篇论文的 claim 是否被实验/证据支撑（evidence audit）。
- 判断某个新机制相对 RPKI/BGPsec/ASPA 是否真的提供了增量贡献（boundary check）。

**不要用它**：写泛化优点/缺点评语、总结论文、做文献综述、评估 ML 模型。

---

## 为什么通用审稿 skill 在这里会失败

大多数通用 review skill 的默认 reviewer 是 **General CS / ML reviewer**，它们会问“Is the problem important? Is the contribution novel?”，但它不会自动知道：

- **ASPA 的安全语义到底是什么**（它验证的是“邻接对端 AS 的授权关系”，不提供路径完整性）；
- **BGPsec 到底保护了什么、不保护什么**（签名覆盖 AS_PATH，但不约束路径长度 / 策略 / 路由选择，且只对 Edge-AS 部分签名有防护意义）；
- **AS_PATH 操作与 route leak 的边界**；
- 部署现实：**增量 / 混合部署（mixed deployment）下安全属性如何逐级降级**。

结论：对路由安全论文，必须用**网络安全专用维度**来审，而不能套用通用模板。本 skill 的 8 个审查维度就是为此设计的。

---

## 8 个审查维度（8 Review Dimensions）

对每一篇论文，按下面 8 个维度逐项审计。每个维度的**完整 checklist 与模板**在 `references/` 中对应文件；想先看端到端示例，直接读 `references/10_worked_example.md`（虚构 BGPsec batch-verification 论文的完整审稿演示）。

| # | 维度 | 摘要 | 参考 |
|---|------|------|------|
| 1 | Problem Definition 问题定义 | 问题是否被精确定义、被正确归类 | `references/01_problem_definition.md` |
| 2 | Threat Model 威胁模型 | attacker 控制什么、能做什么、实验是否匹配 | `references/02_threat_model.md` |
| 3 | Security Properties 安全属性 | “防什么”必须精确，拒绝笼统声明 | `references/03_security_properties.md` |
| 4 | Protocol Correctness 协议正确性 | 消息→状态→校验→失败语义→安全后果 | `references/04_protocol_correctness.md` |
| 5 | Comparison 对比与边界 | 与 RPKI/BGPsec/ASPA 等的公平对比、增量贡献 | `references/05_comparison_rpkibgpsecaspa.md` |
| 6 | Evaluation 实验与数据 | 数据集、仿真/测量/实验台、基线、可复现性 | `references/06_evaluation.md` |
| 7 | Deployment 部署现实 | 增量/混合部署、成本、激励、兼容性 | `references/07_deployment.md` |
| 8 | Claim-Evidence 声明-证据 | 每条 claim 定位到证据，判定充分性，标出缺口 | `references/08_claim_evidence.md` |

领域基座（BGP/RPKI/BGPsec/ASPA 语义与 RFC）见 `references/09_domain_primer.md`；审稿前若对机制语义不确定，先读它再下结论。

### ① Problem Definition（问题定义）

不要只问 “Is the problem important?”。必须问精确的问题：

- **问题到底是什么？** 用一个具体失败场景（failure scenario）描述：谁被谁、在什么条件下、怎样侵害。
- **现有机制为什么解决不了？** 逐项追问：
  - 现有 RPKI 为什么不能解决？
  - BGPsec 为什么不能解决？
  - ASPA 为什么不能解决？
  - Route leak detection 为什么不能解决？
  - 有没有可能它解决的其实是“已解决的问题”的变体（即相关工作中已有机制覆盖）？
- **这篇论文解决的是哪一层？** 必须归类到：
  - origin validation（源验证）
  - path validation（路径验证）
  - policy validation（策略验证）
  - behavior verification（行为验证）
  - intent verification（意图验证）
  - anomaly detection（异常检测）
  如果作者说“提高 routing security”但不指明层，立刻标记为问题定义不清。

### ② Threat Model（威胁模型）

这是路由安全论文最常出问题的地方。必须把威胁模型显式化：

- **Attacker controls what?** 逐一过：
  - AS / Router / BGP session / 路由服务器（route server）/ IXP
  - PKI / RPKI CA / 签发机构 / Key（密钥）
  - 能否影响整个域还是单台设备
- **Can attacker …?** 逐一过：
  - forge（伪造） / replay（重放）
  - insert AS（插入 AS） / remove AS（删除 AS）
  - alter policy（篡改策略） / manipulate path（操纵路径）
  - collude（串谋，多个恶意者）
- **实验攻击模型是否真的覆盖论文声称的 threat model？**
  - 若声称防“route hijack”但实验只测了 origin hijack → **over-match/mismatch**，必须标注。
  - 若声称防“path attack”但攻击模型里 attacker 根本没有写路径的能力 → **under-match**，同样要标注。

### ③ Security Properties（安全属性）

论文说 “prevent route hijacking” 时，必须继续追问 “prevent what, exactly?”：

- Origin hijack（源劫持：前缀被非授权源宣布）
- Path manipulation（路径操纵）
- Route leak（路由泄露）
- Policy violation（策略违反）
- AS_PATH insertion / AS_PATH deletion
- Unauthorized propagation（未授权传播）
- Traffic interception（流量劫持/截获）

**不接受**笼统的安全声明，例如 “提高了 routing security / improves overall security”。一律要求作者给出：属性名 → 形式化/半形式化定义 → 保障在什么假设下成立 → 不保障什么。

### ④ Protocol Correctness（协议正确性）

对协议型论文（FC/CRC/BGPsec 类验证机制）做逐步语义审计，按如下链条：

```text
Message format（消息格式）
      ↓
State transition（状态迁移）
      ↓
Validation rule（校验规则）
      ↓
Failure semantics（失败语义：拒绝？忽略？降级？）
      ↓
Security consequence（安全后果：谁能利用该失败？）
```

**逐项检查以下边角情形**（对 BGPsec/ASPA/FC/CRC 尤其关键）：

- Malformed 消息（长度/字段/ASN 越界）
- Unknown 标识（Unknown FC / Unknown CRC / Unknown algorithm / Unknown ASN）
- Expired / 过期时间戳（replay window 处理）
- Missing signature / Invalid signature
- AS_PATH inconsistency（签名链与路径不一致）
- Repeated ASN、AS_SET、AS_SEQUENCE 的处理
- 密码学机制：算法套件、密钥轮换、签名/验证边界；若论文声称“batch verification”等优化，检查其基线与方法是否可归因（见 `references/04`、`06`）。

### ⑤ Comparison 与相关工作的边界（基线全家桶）

每个新机制都要和下列“基线全家桶”比较，并说清边界：

- **RPKI/ROA/ROV**（origin 授权，RFC 6811）
- **BGPsec**（AS_PATH 签名，RFC 8205）
- **ASPA**（邻接对端授权，用于路径/泄露）
- **S-BGP / soBGP**（历史全量签名方案）
- **ARTEMIS / 异常检测类**（仅事后检测）
- **route-leak detection / 策略类**

边界问题（boundary check）：

- 新机制是**被现有机制包含**（则无增量贡献），还是**互补**（则贡献要重新定义）？
- 对比时 baseline 是否公平（同样的威胁模型、同样的部署假设、同样的硬件/数据）？
- 若新机制依赖 RPKI/BGPsec，则它是“增量层”而不是“替代品”——论文必须在头尾明确这一点。

### ⑥ Evaluation（实验与数据）

对实验部分做审计，重点：

- **数据来源**：现网测量数据（real-world measurement）？仿真（simulation）？测试床（testbed）？合成数据（synthetic）？各自要标出并评估代表性与偏差。
- **可复现性**：数据/代码/拓扑是否公开？拓扑真相（ground truth / oracle）如何获得？测量方法是否易受自身偏差（如 vantage point 选择）影响？
- **基线公平**：硬件是否一致？参数是否调优？不同方案是否在同一牺牲/收益坐标系比较？
- **指标**：是否使用了正确的安全指标（而不是容易被投机取巧的吞吐量）？是否有消融实验（ablation）？
- **负结果**：是否如实呈现失败与适用范围？
- **规模**：是否真正扩展到全互联网规模（级联 ASPA 验证、BGPsec 实时验证开销）？

### ⑦ Deployment（部署现实）

路由安全的宿命是部署，必须核查：

- **增量部署 / 混合部署**：部分部署下安全属性如何变化？有没有分析“混合部署”下攻击面（比如只签了一部分路径时 BGPsec 其实不提供路径完整性）？
- **RPKI 采用背景**：论文是否建立在现实 RPKI 采用率上（谁 ROA 了、validator 分布）？
- **部署成本**：CPU/内存/带宽/密钥管理/运维成本；会不会改变路径选择导致流量迁移（连接受损）？
- **激励（incentives）**：谁有动机部署？非联盟成员呢？
- **兼容性**：与现有 RFC 机制、厂商实现、路由策略的兼容性；迁移路径是否平滑。

### ⑧ Claim-Evidence（声明-证据矩阵）

这是本 skill 的**核心产出**。把论文的每条可验证 claim 提取出来，映射到证据，判定充分性，标出缺口：

| Claim | Evidence（位置） | 是否充分 | 缺口 / 该补的实验 |
|-------|----------------|---------|------------------|
| 防止 route hijack | Exp. 1 | 部分 | 只测了 origin hijack，未测 path manipulation |
| 防止 route leak | （无） | 否 | 无 route-leak attack 实验 |
| 支持大规模部署 | Fig. 8 | 部分 | 仅仿真，未做真实 BGP 报文回放 |
| 比 BGPsec 快 6× | Exp. 4 | 待核 | 硬件/密钥分布不一致，无法归因 |
| 可增量部署 | §6 | 不充分 | 未分析 mixed deployment |

**判定标准：** claim 没有对应证据 → “否”；证据存在但与 claim 覆盖范围不一致 → “部分”；证据充分且覆盖 claim 全部含义 → “充分”。

---

## 审查流水线（Pipeline）

按多角色评审工作流执行，最终汇入单一结论：

```text
                        Paper PDF
                            │
                            ▼
                   ┌──────────────────┐
                   │  Paper Reviewer  │  ← 通读、抽取结构、建立 paper.md
                   └────────┬─────────┘
                            │
        ┌───────────────────┼─────────────────────┐
        ▼                   ▼                     ▼
 Problem Reviewer    Security Reviewer     Protocol Reviewer
 (① 问题定义)         (②③ 威胁/属性)         (④ 协议/密码学正确性)
        │                   │                     │
        └───────────────────┼─────────────────────┘
                            ▼
                  Evaluation Reviewer (⑥ 实验)
                            │
                            ▼
                  Deployment Reviewer (⑦ 部署)
                            │
                            ▼
                  Claim-Evidence Audit (⑧ 矩阵)
                            │
                            ▼
                   Final Reviewer（结论 + 审稿人问题）
```

原则：

1. 每个子维度独立审，**互抄结论前先各自给出证据位置**。
2. 一个维度发现的问题，带到其它维度复核（例如协议正确性问题会反向推翻实验结论）。
3. 最终结论必须由 **Claim→Evidence 矩阵** 支撑，而不是凭“总体印象”。

---

## 输出产物（Output bundle）

每次审查在项目内生成一个 `paper-review/` 目录（该目录已被 .gitignore 排除，不会误入库）：

```text
paper-review/
├── paper.md            # 论文结构化摘要：RQs、claims、机制、假设、限定
├── evidence.md         # 证据日志：每条声明 → 章节/图/表/公式
├── claim-matrix.md     # ①-⑧ 中最核心的 Claim→Evidence 矩阵（见模板）
├── threat-model.md     # ② 威胁模型显式化 + 实验覆盖对照
├── comparison.md       # ⑤ 与 RPKI/BGPsec/ASPA 基线的边界与公平性
├── experiment-audit.md # ⑥ 实验/数据/可复现性审计
└── final-review.md     # 总结论：Strengths / Major / Minor / 审稿人必须追问的问题
```

每个文件对应 `templates/` 中的骨架：`claim-matrix.md`、`threat-model.md`、`comparison.md`、
`experiment-audit.md`、`evidence.md`、`final-review.md`、`paper.md`。
模板头部可含 Reviewer / Venue / Date / Paper version。

---

## Loop Engineering（自审闭环）

如果是审**自己的论文**，审查不是终点，而是反馈环：

```text
论文
  ↓
初审（本 skill 8 维）
  ↓
发现问题（claim 缺口、威胁模型不匹配、实验不可复现）
  ↓
深入检索相关论文（联动 paper-lookup / literature-review）
  ↓
重新验证 claim（补证据 / 补实验 / 重写声明）
  ↓
再次 review
  ↓
直到主要问题收敛（major issues 收敛后收尾）
```

每次迭代只修“证据与声明不一致”，不要为了掩盖问题而弱化声明——那是审稿人第一眼抓的。

**自审 vs 审他人**：审他人论文，结论止于“发现 + 给作者的追问”；审自己的论文，同一发现要转成**修订任务**（补实验 / 收窄声明 / 重写证据），并在每次迭代后更新矩阵中对应 claim 的状态（❌→⚠️→✅），直到 major 收敛为止。

---

## What NOT to Do（反模式）

本 skill **禁止**产出以下内容：

- 泛化的 Strengths / Weaknesses / Score，无证据定位（“Section/Figure/Table” 缺失）。
- 笼统安全声明被接受：“提高了 routing security” 等，必须被追问。
- 未经对照的“创新性强、贡献明确”。
- 忽略部署现实的“理论可行即接受”。
- 对威胁模型与实验模型不匹配视而不见。
- 把“审”做成“总结”：只复述方法，不做判断。

---

## 交付前自检（Pre-delivery QA）

产出 final-review.md 前逐项自检，缺一项即回炉：

- [ ] 每条 Major/Minor 都标注了**关联 claim（C#）**与**维度（①-⑧）**，无“孤儿结论”。
- [ ] `claim-matrix.md` 中**每条 claim 都有充分性（✅/⚠️/❌）**，无“未审”项。
- [ ] 每条 evidence location 精确到 **Sec / Fig / Tab / Eq**，不使用“论文声称/据作者”这类不可定位引用。
- [ ] 摘要/引言里的安全词（prevent / secure / “首个”）都已**实例化为具体属性**并对照实验（②③⑧联动）。
- [ ] comparison 覆盖 RPKI/ROV、BGPsec、ASPA、检测类基线（⑤），并给**三向判定**（被包含 / 互补 / 超越）。
- [ ] 凡性能/开销类 claim，均确认**归因**（key distribution / 硬件 / 基线调优一致）。
- [ ] 部署类 claim 有 mixed-deployment / 成本 / 激励分析，或**明确标注缺失**（⑦）。
- [ ] 结论（Accept/Reject）的一句话依据能回溯到矩阵中最重的 1-2 条 claim。

## 相关 Skills 与边界

| Skill（仓库内） | 关系 |
|----------------|------|
| `peer-review` | 通用手稿/基金审查 —— 按报告标准走；本 skill 是其网络安全的专用变体 |
| `literature-review` / `paper-lookup` | 跨论文综述、补引用、验证相关工作 —— 与本 skill 的 ⑤⑥ 衔接 |
| `scientific-critical-thinking` | 一般证据质量评估框架 |
| `scholar-evaluation` | 定量打分框架 |
| `pdf` / `markitdown` / `liteparse` | 论文正文抽取：PDF → Markdown/文本，再进入审查 |

本 skill 与它们的分工：**本 skill = “一篇路由安全论文的证据制深度技术审计”；综述、检索、打分交给上述兄弟 skill。**

---

## 快速开始（Quick Start）

1. **接收论文**：PDF 先用 `pdf` / `markitdown` / `liteparse` 抽取为 Markdown/文本再审；源码则直接读。
2. 通读建立 `paper-review/paper.md`（模板见 `templates/paper.md`：RQs / claims / 机制 / 假设 / 限定）。
3. 依次跑 ①②…⑧，每个维度产出证据位置（Section/Figure/Table/Equation）。
4. 汇总到 `claim-matrix.md`，标注每条 claim 的充分性。
5. 写 `final-review.md`：Strengths / Major / Minor / 给作者的追问（questions）。
6. 若是自审，进入 Loop Engineering，直到 major issues 收敛。

**时间有限时的最小审查（minimal viable review）**：优先 ② 威胁模型 → ③ 安全属性 → ⑧ Claim−Evidence 矩阵，它们是路由安全论文最高产出的维度；①⑤⑥⑦ 视深度逐项补。若完全只能做一件事：做 ⑧，并让每条 final-review 结论都挂到矩阵上。
