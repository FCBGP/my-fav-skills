# ⑨ 领域基座（Domain Primer：BGP 路由安全）

> 本文件给 reviewer 提供“通用 CS reviewer 不会自带”的领域底座，确保审查时不会把 ASPA 当 BGPsec、把 origin 当 path。审查时若对术语/语义不确定，先回这里对齐，再下结论。

## BGP 与路由通告基本模型

- BGP 是**信任链**：AS 之间按邻居关系传递 NLRI 前缀 + 属性（AS_PATH、AS_SET、LocalPref、Community…）。
- 决策（selection）基于路径属性与本地策略；传播（propagation）受“对等/客户/上游”盆关系（valley-free / sibling）约束——这是 route leak 的根源。
- 三类核心验证层：
  - **origin validation**：前缀能否由此 AS 宣告。
  - **path validation**：AS_PATH 是否被沿途各 AS 背书。
  - **policy validation**：通告是否符合相邻盆授权关系。

## RPKI / ROA / ROV

- RPKI = 公钥基础设施，用于为 IP 前缀签发 **ROA**（Route Origin Authorization）：“前缀 → 被授权源 AS + maxLength”。
- **ROV**（Route Origin Validation）：validator 把每条路由判为 Valid / Invalid / Unknown；**Invalid 才被策略拒收**（默认多数运营商只降权，不硬拒——部署现实！）。
- 边界：ROV 只处理**起源**，不约束路径与策略；maxLength 语义（超长前缀 invalid）。
- RFC 6811（ROV 语义）；RPKI 还有 Manifest/CRL/信任锚（本地信任锚、SLURM/例外）。
- **好审查知识**：ROV 的“Invalid ≠ 自动丢弃”是常见现实落差；混合部署下不部署 ROV 的 AS 依然接受 invalid 路由。

## BGPsec（RFC 8205）

- BGPsec 在 BGP 上增加 `BGPsec_Path`：每个传播的 AS 用自己的私钥对 **(前缀, 前一 AS 公钥, 自身公钥, 会话标识)** 签名，形成链。
- 保障：**签名段的 AS_PATH 完整性与真实性**（对合法密钥持有者）。
- **不保障 / 边界**：
  - 不约束路径长度、路由选择、LocalPref、策略评分；
  - 只对“加入了签名链”的段有效——**Edge-only 部署时中间段无保护**（这是影响力最大、审稿最常抓的边界）；
  - 密钥/AS 之间需知道彼此公钥（依赖 RPKI 类 PKI）。
- 配套：RFC 8209（证书 profile）、RFC 8210（RP）、RFC 8211（adverse actions，错误/撤销导致从“保护”降级到退化为普通 BGP 的行为）。

## ASPA（Autonomous System Provider Authorization）

- ASPA = RPKI 里的一种对象：**每个盆 AS 声明“谁是它的 provider（上游）的集合”**。
- 验证：对路径上的相邻 AS 对做 **provider/customer 授权检查**，确定某 AS 是否是合法的上游（用于检测/拒绝路径里出现非法上游 → 助力 route-leak 检测与多项式复杂度路径验证）。
- **边界**：
  - 它提供的是“邻居授权关系”证据，**不是路径完整性/签名**；
  - 不阻止 origin hijack 本身；
  - 有效性依赖“谁是谁的 provider”的全局登记质量（缺登记的 AS 会成为灰区）。
- 状态：IETF SIDROPS 工作组 drafts —— `draft-ietf-sidrops-aspa-profile`（对象格式）与
  `draft-ietf-sidrops-aspa-verification`（AS_PATH 验证算法），尚未正式成 RFC。
  ⚠️ 审稿引用时以 datatracker 最新状态为准（不要在论文里误写成 RFC 9586 —— 那是 IMAP RFC）。

## 历史/其它方案

- **S-BGP**：早期全量签名（origin + path + router 证书），部署成本高。
- **soBGP**：基于信任库/证书的对端授权，信任模型受质疑。
- **ARTEMIS**（NDSS'18）：实时检测/缓解前缀劫持的平台（基于测量监视 + 运营商反馈），是“检测类”代表，别把它当阻止类。
- **Route-leak 检测类**：启发式（如基于 valley-free、peer/prepend 模式）事后检测，可被有策略倾向的泄露绕过。

## 攻击与事故字典（审查时用的精确词）

- **Origin hijack**：非授权源宣告前缀（经典：YouTube/Pakistan 2008）。
- **Sub-prefix hijack / 更具体前缀攻击**：宣告更具体前缀吸引一部分流量。
- **Path manipulation / 路径伪造**：插入虚假 AS、删除真实段、篡改 AS_PATH 以吸引流量或绕过过滤。
- **Route leak**：把只应给客户对等/上游的路径错误传播给其它对等方（RFC 7908 定义）。
- **Traffic interception / diversion**：让数据面流量走攻击者路径。
- **Policy violation**：违反盆关系/上游授权的通告。
- **AS_PATH 类型**：AS_SEQUENCE（有序序列）、AS_SET（无序集合，常见于聚合/防环打破），签名完整性对 AS_SET 天然困难。

## 常用 RFC / 文档速查（审稿引用）

| 编号 | 内容 |
|------|------|
| RFC 6811 | BGP Prefix Origin Validation（ROV 语义 tri-state） |
| RFC 8205 | BGPsec Protocol（RFC 8209/8210/8211 配套） |
| RFC 7908 | Route leak 定义 |
| RFC 8212 | 默认 ebgp 无传递（防 default route leak 常态） |
| RFC 8608 | RPKI 签名算法（ECDSA P-256） |
| SIDROPS drafts | ASPA 对象与验证算法、RPKI 演进 |

## 审查校准建议

- 对“与 BGPsec/ASPA 比较”的论文：先确认作者对上述**安全语义边界**的理解是否准确；边界写错 = 对比结论不可信。
- 对“改进 ROV”的论文：务必区分 Valid/Invalid/Unknown 三值与运营商实际策略（拒绝 vs 降权）。
- 对“检测类”论文：先归类为“事后检测”，再评估其补充价值，不与阻止类机制混为一谈。

## 当域不只路由安全时

本 skill 可扩展到网络测量（IMC/PAM 类）、协议安全、SDN 路由、routing PKI。扩展时保持同一审查骨架：
- 问题被精确分类（检测/阻止/测量偏差/设计正确性）；
- 威胁模型显式；属性精确；实验可复现；部署现实；claim 有证据。
