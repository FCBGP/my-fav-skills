# ⑤ Comparison 与相关工作的边界（RPKI / BGPsec / ASPA 基线）

## 基线全家桶（Baseline Family）

任何域间路由安全新机制都必须和下列基线显式对比其**安全语义、威胁模型、部署假设、成本**，而不是只在 Related Work 里引一句：

| 机制 | 保护什么（安全语义） | 不保护什么 | 部署依赖 | 参照 |
|------|--------------------|-----------|---------|------|
| RPKI ROA/ROV | origin 授权：前缀→源 AS 绑定；invalid 路由可被拒收 | 不约束路径、策略、传播 | 需 RPKI 签发 + validator + 策略 | RFC 6811 |
| BGPsec | AS_PATH 完整性/真实性（对签名段）：每个 hop 签名确认其邻接 | 不约束路径长度/策略/选择；Edge-only 部署对非签名段无保护；不阻止 origin 劫持本身 | 逐 AS 部署；转发面路由仍走 BGP 决策 | RFC 8205 |
| ASPA | 路径上“相邻 AS 对”的盆授权关系（provider/customer），用于检测/拒绝路径中的非法上游 AS、助力 route-leak | 不提供路径完整性；不阻止 origin hijack；依赖“谁是谁的上游”全局知识 | RPKI 对象类型；需全盆签发 | IETF SIDROPS drafts |
| S-BGP | 早期全量签名方案：origin + path + router public key 分发 | 大规模部署成本、性能 | 全量 PKI | 2000s work |
| soBGP | 早期基于证书/信任库的路径验证 | 部署与信任模型争议 | — | 2000s work |
| ARTEMIS | 事后检测/缓解前缀劫持与异常（实时平台） | 不阻止；依赖监测点覆盖 | 开源平台+ASP 采用 | ARTEMIS (NDSS'18) |
| Route-leak detection 类 | 事后/启发式检测策略违反 | 可绕过；控制面启发式 | 策略知识 | 综述类 work |

## Boundary Check（边界判定）

对新机制的增量贡献做三向判定：

1. **被包含（subsumed）**：现有机制在其假设下已解决问题的核心 → 增量不成立。
2. **互补（complementary）**：解决的是不同层/不同威胁 → 贡献成立但要重新精确定义（防止“换皮”）。
3. **超越/改进（improvement）**：在同样问题上更好（更安全/更便宜/更易部署） → 必须给出公平对比来支撑。

**追问模板（写进 comparison.md）：**

- 该机制保护了什么，而 RPKI/BGPsec/ASPA **在同样的威胁模型下**没有保护？
- 它是否依赖 RPKI/BGPsec 作为基础？若是 → 是**增量层**不是替代品；头部/尾部必须这样陈述，否则属于 over-claim。
- “第一个解决 X” 是否在同样层、同样假设下比对过 ARTEMIS 类检测？
- 与 BGPsec 对比性能时，是否在同一安全级别（同样密钥/签名套件/部署度）？与 ASPA 对比是否用同一路径验证语义？

## 公平对比规则（Fairness Rules）

- 同一威胁模型（不是“我们假设更强敌手所以证明自己更强”）。
- 同一部署假设（全量 vs 增量；Edge-only vs 全路径签名——绝不能拿全量假设的收益去对比 BGPsec 的半量部署成本）。
- 同一硬件/数据/参数调优水平（否则实验结论不可归因）。
- 同一指标（在路由场景要区分：控制面开销、收敛时间、CPU 验证开销、报文膨胀、数据面代价）。

## 相关工作中遗漏（Missing Citations）

- 漏掉近期 SIDROPS 进展（ASPA、RPKI 4-byte、validation 语义）→ ⑤ 维直接要求补。
- 漏掉签名类协议历史（S-BGP/soBGP/BGPsec 早前失败教训）→ 说明作者可能没汲取部署教训。
- 声称“首个”却未给出可证伪的排除过程 → 记 `claim-matrix.md`。

## Red Flags

- Related Work 只有引言式罗列，无安全语义对比表格。
- 拿本方案的全量部署成本去对比 BGPsec 的半量成本。
- 依赖 RPKI/BGPsec 却不承认是增量层。
- 性能对比硬件/密钥分布不一致。
- 声称“与 RPKI 正交”但不说明两机制的交互（如 ROV invalid + 新机制的冲突处理）。

## 输出到哪

`paper-review/comparison.md`（基线表 + 三向判定 + 公平性清单）；遗漏 → `claim-matrix.md` / Related-work Major。
