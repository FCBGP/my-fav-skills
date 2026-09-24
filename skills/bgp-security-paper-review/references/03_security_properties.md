# ③ Security Properties（安全属性审计）

## 立场

路由安全论文的安全属性必须**精确到“防什么到底”**，否则 claim 无法证伪。审稿的核心文案动作是：**把笼统动词（prevent / mitigate / secure）替换为具体属性，再问该属性被什么机制、在什么假设下、以什么强度保障。**

## 属性词典（routing context）

论文说 “prevent route hijacking” 时，逐项追问并让作者定位：

| 属性 | 精确含义 | BGP 中对应的攻击 |
|------|---------|----------------|
| Origin validation / origin authenticity | 前缀的源 AS 是已授权持有者 | origin hijack、sub-prefix hijack |
| AS_PATH integrity / authenticity | 路径中每个 AS 都真实存在并签名认可 | path manipulation、插入/删除 |
| Path validity | 路径符合某种未被篡改的合法形态 | stub/backbone 结构被破坏 |
| Authorization / policy conformance | 通告符合相邻方授权关系（provider/customer/peer） | route leak、非法传输 |
| Confidentiality（罕见） | 路由信息不泄露给未授权方 | 前缀可达性信息窃取 |
| Availability | 路由系统在攻击下仍能收敛/可达 | 会话重置、黑洞、路径饥饿 |
| Data-plane integrity | 数据流量沿公告路径转发 | 数据面劫持（diversion） |

## 机制 vs 属性：不要混淆

- 机制（mechanism）：RPKI、BGPsec、ASPA、防火墙、过滤器 —— 是实现手段。
- 属性（property）：origin authentication、path integrity、policy conformance —— 是被保障的性质。

论文若把“我们用了 ASPA”直接说成“我们防了 route leak”，是**机制-属性混淆**。应要求作者明确：ASPA 只提供“邻居授权关系”证据，route-leak 检测/阻止=策略层应用，两者不能画等号。

## 要求作者给出的四件套

1. **属性名**：精确（e.g., "AS_PATH integrity for signed segments"）。
2. **形式化/半形式化定义**：哪怕是一段可证伪的断言（如“对任意合法密钥持有者集合，攻击者无法构造被 validator 接受的含未授权段路径”）。
3. **成立条件**：假设清单（密钥可信？time sync？部分部署？）。
4. **不保障什么**：明确的防御边界（e.g., “不约束路径长度/路由选择/策略评分”；“非签名段无保护”）。

缺任何一件 → 标注为 claim 缺陷，记入 `claim-matrix.md`。

## 强度分级

安全属性的强度应分级陈述：

- **阻止（block/prevent）**：恶意行为在源头被拒。
- **检测并告警（detect+alert）**：事后、可绕过。
- **降级/缓解（mitigate）**：减小影响但不断言阻止。
- **只改激励（incentive shift）**：提高攻击成本，不断言安全。

很多论文把“检测”当“阻止”写进 Abstract — 这是 ③ 维最重要的抓点之一。凡 Abstract/Intro 用 prevent/secure 而正文只实现 detect 的，一律 Major。

## 安全性 vs 存活性的边界

- 若论文是在**不丢失全局可达性**的约束下检测异常，要单独评估存活属性（convergence、pathlet 断供、路由振荡）。
- 安全属性与存活属性常互相牵扯（拦截恶意通告可能饿死合法前缀）——若论文没讨论这对权衡，属于 incomplete 安全论证。

## Red Flags

- [ ] “improves routing security” 未实例化到任何属性。
- [ ] Abstract/Intro 用 prevent/secure，正文只有 detection。
- [ ] 属性定义依赖额外信道，却没有说明该信道如何实现。
- [ ] 没有“不保障什么”的防御边界叙述。
- [ ] 声称 origin 与 path 同时保障，但机制只覆盖其一。

## 输出到哪

`paper-review/paper.md`（属性清单）+ `claim-matrix.md`（属性 claim 的证据与缺口）。
