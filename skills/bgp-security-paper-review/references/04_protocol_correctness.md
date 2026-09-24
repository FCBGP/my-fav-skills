# ④ Protocol Correctness（协议正确性审计）

## 适用范围

FC / CRC / BGPsec / ASPA / 任何"签名-验证-通告"类协议设计论文。目标是找出：**在边角输入、状态迁移、失败处理下，协议是否仍保持声称的安全属性，且不引入可用性/DoS 漏洞。**

## 审查链条

对每个协议行为，按链逐层过：

```text
Message format（消息格式）
      ↓ 字段、长度、编码、类型标签
State transition（状态迁移）
      ↓ 收到消息后，状态机如何迁移
Validation rule（校验规则）
      ↓ 何时通过/拒绝；校验顺序与短路逻辑
Failure semantics（失败语义）
      ↓ 拒绝（reject）/忽略（ignore）/降级（degrade）/告警（alert）？
Security consequence（安全后果）
      ↓ 该失败能否被攻击者诱发并造成安全或可用性危害？
```

**核心问题：每个失败分支，攻击者能否通过构造输入主动触发，而不是只靠诚实方犯错？**

## 边角情形清单（对 BGPsec/ASPA/FC/CRC 逐一打勾）

- ☐ Malformed 消息：字段长度、ASN 边界、编码（0 vs 4 字节 ASN）、尾部填充。
- ☐ Unknown 标识：Unknown FC（功能码）、Unknown CRC、Unknown ASN、Unknown algorithm / signature suite。
- ☐ Expired 时间戳 / 退出重放窗口：过期如何处理；clock skew 容忍；replay window 是否可被攻击者扩展。
- ☐ Missing signature / Invalid signature：哪个字段被签名、验签失败时丢弃整条还是忽略某跳。
- ☐ AS_PATH inconsistency：签名链与实际 AS_PATH 不一致（插入未签名段、删除签名段、路径重排）。
- ☐ Repeated ASN：路径中同一 AS 出现多次（prepending/防环语义）在签名验证下的处理。
- ☐ AS_SET / AS_SEQUENCE：聚合/乱序路径在签名完整性下的行为（AS_SET 无法线性签名 → 很多方案退化为不保护）。
- ☐ 空路径 / 单跳路径 / 超长路径边界。
- ☐ 认证链：受信任 PKI 链的构造、证书过期/撤销（CRL/Manifest）如何处理。

## 密码学机制审查

- 算法套件：是否规定明确（如 ECDSA P-256 之于 BGPsec）？是否有算法协商被降级风险？
- 密钥轮换 / 多密钥：新旧密钥并存期间的验证语义。
- 签名/验证的边界：签名覆盖哪些字段；是否覆盖可达性/策略相关字段（未覆盖 = 不保障该字段）。
- **性能优化声明的可归因性**（如 batch verification）：
  - baseline 是否与方案在同一密钥分布/同一安全级别下比较？
  - 若对比的是“N 个独立签名验证”而 baseline 用 different key distribution，则无法归因于 batch 本身 → 需要**固定 key distribution、仅改变 verification strategy** 的对照实验。

## 失败语义 → 安全后果（逐分支分析示例）

| 输入 | 校验行为（作者） | 攻击者可诱发？ | 安全后果 |
|------|----------------|--------------|---------|
| Unknown FC | 丢弃 | 是 | 可能被用作 DoS（大量恶意 FC 淹没） |
| Expired CRC | 忽略不拒 | 是 | 明文可重放 → 属性被绕过 |
| Invalid signature on non-adjacent hop | 丢弃整条 | 可能 | 可达性丢失（可用性） |
| Missing segment for partial signing | 接受 | 是 | 未签名段无保护（混合部署的核心边界） |

## 形式化 / 证明审查

- 若论文给安全证明（游戏 / 不变量 / 归纳），检查：
  - 假设是否与威胁模型一致（证明里假设的东西能不能被攻击者破坏）？
  - 证明覆盖的是属性还是只是机制流程？
  - 是否存在“诚实方模型”与“敌手模型”混用。
- 若无证明，指出该机制哪些属性依赖定性论证，并要求给出至少非形式化可证伪性论证。

## RFC 语境（正确性基准）

- BGPsec：RFC 8205（协议）+ RFC 8209/8210/8211（adverse actions / 撤销 / 错误处理）——凡与 RFC 语义冲突或忽略 adverse-action 处理的，标准符合性问题。
- ROV：RFC 6811（valid/invalid/unknown 三元语义）——很多“改进 ROV”的论文省略 invalid→withdraw 的副作用分析 → 标记。
- ASPA：IETF SIDROPS drafts 的验证算法（pairwise provider/customer 检查）——注意其只对“路径中相邻关系”做授权检查，没有路径完整性。
- 论文若定义了自己的状态机，要求与 IETF 对照或明确背离理由。

## Red Flags

- 无失败语义定义（全部内部状态为“通过/拒绝”两值，没有 unknown 三值）。
- 验签失败静默降级却不告警/不计数。
- 混合部署下“部分签名路径”的安全语义完全没讨论。
- 性能优化对比归因不清（key distribution 不一致）。
- 没有 replay window 相关设计。

## 输出到哪

`paper-review/paper.md`（协议语义小节）+ 若发现可被攻击者触发的失败分支 → 直接进 `final-review.md` 的 Major。
