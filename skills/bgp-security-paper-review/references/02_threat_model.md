# ② Threat Model（威胁模型审计）

## 为什么这一维是安全论文的高发事故区

路由安全论文最常见的三类威胁模型错误：

1. **over-match（夸大）**：声明“防止 route hijack”，实验只测了 origin hijack → 威胁模型比实验宽。
2. **under-match（不足）**：攻击模型给了 attacker 无法实现的能力（例如 attacker 能任意写 BGPsec 签名链，却没有对应密钥）→ 实验比威胁模型宽。
3. **未显式化**：全文不交代 attacker 的能力 / 位置 / 目标，导致安全属性无法被证伪。

## Attacker controls what?（能力清单）

逐项打勾，并把论文声称的能力记录到 `threat-model.md`：

| 受控对象 | 说明 | 是否被论文显式声明 |
|---------|------|------------------|
| AS（整个自治域） | 全域恶意运营商，可改本地策略、任意宣告 | ☐ |
| Router（单台路由器） | 被入侵设备，可插入/篡改/丢弃报文 | ☐ |
| BGP session（会话层） | 中间人 / 会话劫持，可注入报文 | ☐ |
| PKI / RPKI CA | 可签发/撤销证书、ROA、TA 信任根受损 | ☐ |
| Route server（路由服务器） | 可操纵汇聚/反射逻辑 | ☐ |
| Key（密钥） | 某 AS 的签名私钥泄露（BGPsec/ASPA 语境关键） | ☐ |
| 网络切片 / IXP | 可窃听/篡改控制面 | ☐ |

## Can attacker …?（动作清单）

| 动作 | 含义 | 论文是否覆盖 |
|------|------|------------|
| forge | 伪造签名/证书/ROA/消息 | ☐ |
| replay | 重放旧消息/旧签名（过期窗口） | ☐ |
| insert AS | 在 AS_PATH 中插入不存在/被越权 AS | ☐ |
| remove AS | 从路径中删除 AS（路径截断） | ☐ |
| alter policy | 修改本地策略、盆/邻居授权关系 | ☐ |
| manipulate path | 操纵通告路径以吸引/劫持流量 | ☐ |
| collude | 多 AS 串谋（是否被考虑） | ☐ |

## 攻击者位置 / 目标

- 位置：off-path（只观察）/ on-path（可改写路径）/ 既是受害者上游又是攻击者。
- 目标：流量拦截、黑洞、路径窃取、策略绕过、数据面污染。
- 诚实但失误（accidental misconfiguration）与恶意是否被区分？（很多路由“安全”工作的真正价值在防误配，而不仅是防敌手——check 论文是否把两类都覆盖。）

## 实验覆盖对照（关键矩阵）

必须构造一张 `实验攻击模型 vs 声称威胁模型` 的对照表：

| 声称的威胁 | 声称章节 | 实验中的攻击模型 | 匹配？ | 结论 |
|-----------|---------|----------------|-------|------|
| 防 origin hijack | §N | 恶意 AS 宣告受害前缀 | ✅/❌ | ... |
| 防 path manipulation | §N | 只测了插入未测删除 | ⚠️ 部分 | 缺删除实验 |
| 防 collusion | §N | 实验只 1 个恶意 AS | ❌ | 威胁模型夸大 |

若论文声称的 threat model 与实验攻击模型不一致 → 直接升级为 Major issue，并在 `final-review.md` 要求补对应攻击实验。

## 隐性假设检查

- 密钥安全性：BGPsec/ASPA 依赖私钥可信；论文是否讨论私钥泄露时属性如何崩溃？
- 时间基准：全局时钟/时间戳假设（replay window）是否成立？
- 通信信道：假设安全信道（带外）的部分是否现实？
- If the paper depends on RPKI：是否把 RPKI 当作可信根，而 RPKI 自身的 CA 信任模型是否被考虑？

## 输出到哪

`paper-review/threat-model.md`（能力清单 + 动作清单 + 覆盖对照矩阵）；若发现 mismatch，同步到 `claim-matrix.md`。
