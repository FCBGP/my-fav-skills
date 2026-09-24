# ① Problem Definition（问题定义审计）

## 为什么这一维必须单独审

通用 reviewer 问 “Is the problem important?”；对路由安全论文这不够。很多路由安全论文的致命伤恰恰是**问题没被精确定义**，导致贡献被夸大或是对已解决问题换了个名字。这一维要回答三个问题：

1. **问题到底是什么**（要能写成一句可证伪的失败场景）；
2. **现有机制为什么解决不了**（逐项排除 RPKI/BGPsec/ASPA/检测类）；
3. **这篇论文解决的是哪一层**（origin/path/policy/behavior/intent/anomaly）。

## Layer 分类法

把作者的贡献强制归类，并检查归类与论文主张是否一致：

| Layer | 含义 | 典型机制 |
|-------|------|---------|
| Origin validation | 前缀是否由被授权源（AS）宣布 | RPKI ROA/ROV（RFC 6811） |
| Path validation | AS_PATH 是否可被各 hop 担保 | BGPsec（RFC 8205）、S-BGP |
| Policy validation | 路径/邻居是否符合（策略/盆）授权关系 | ASPA（IETF SIDROPS drafts）, 策略类方案 |
| Behavior verification | 观察到的行为是否与声称一致 | 检测类、意图类 |
| Intent verification | 路由选择是否符合网络运营者意图 | FC / CRC / intent-based routing |
| Anomaly detection | 事后发现异常（不阻止） | ARTEMIS、机器学习类 |

**审计动作**：如果一篇论文声称“解决路由安全”，但无法归入任何一层，或跨层但不说明层间关系 → 问题定义不清（Red Flag #1）。

## “为什么现有机制解决不了”逐项 drill

对论文声称的问题，逐项追问并把答案写进 `paper.md`：

- 现有 RPKI 为什么不能解决这个问题？
  - 它只绑定“前缀 ↔ 源 AS”，不约束路径、不约束策略、不做邻居授权。
- BGPsec 为什么不能解决？
  - 它签名 AS_PATH 支持路径完整性，但：不约束路径长度/策略/路由选择；只对“合法持有者”路径段签名，不约束传播策略；增量部署下（Edge-only signing）对非签名段无保护。
- ASPA 为什么不能解决？
  - 它验证“上游 AS 是否被盆授权为该对端的 provider”，用于检测/阻止路径上的非法上游 AS，但不提供完整路径签名，不阻止 origin 劫持本身。
- Route leak detection 为什么不能解决？
  - 检测类是事后、启发式、可绕过，不是阻止机制；且常依赖控制面信号而漏过有策略倾向的泄露。

如果论文声称解决的问题，其实能被上述某机制（在同样的假设下）解决 → 增量贡献不成立，审稿人应要求作者给出“技术原因”而不是“部署原因”。

## 可证伪的失败场景（failure scenario）

要求论文把问题写成：

> “在条件 C 下，攻击者 A 对受害者 V 实施攻击 X，导致后果 Y；本机制在假设 H 下阻止/检测 X。”

检查清单：
- C 是否现实可达（不是“所有 AS 都用 RPKI”这种理想假设）？
- A 的能力是否在 ② 威胁模型 中被显式承认？
- Y 是否真的是安全后果（而非性能/可用性的次要问题）？
- H 是否被实验覆盖（否则属于假设脱离验证）？

## Red Flags 汇总

- [ ] 通篇只说“提高 routing security / improves security”，不指层。
- [ ] 问题描述是“solves previous works' limitations”但没有指出是哪个具体限制、哪个场景。
- [ ] 该问题已由 RPKI/BGPsec/ASPA 在其假设下解决，作者只拿“部署率低”当创新理由。
- [ ] 层分类模糊：origin 与 path 混用，或把“检测”当“阻止”宣传。
- [ ] 声称“第一个解决 X”而未给出可验证的相关工作排除过程。

## 输出到哪

结论写入 `paper-review/paper.md`（问题定义小节）+ `claim-matrix.md`（若问题定义影响某 claim 的充分性）。
