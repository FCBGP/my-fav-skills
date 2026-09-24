# ⑦ Deployment（部署现实审计）

## 立场

路由安全的宿命是**部署决策**，而不是纸面正确性。一个机制即使安全属性完美，只要没有增量/混合部署路径和现实成本，就难以落地。这一维专门检查论文是否在**现实采用背景**下论证。

## 增量 / 混合部署（Incremental & Mixed Deployment）

- **全量 vs 增量**：机制是否要求全网络部署才能有安全属性？若是，要指出这是“理想假设”，并追问现实路径。
- **混合部署的逐级降级分析**：部分部署时安全属性逐级退化——论文有没有给出“部署 X% 得到 Y% 保护”的量化曲线？
  - BGPsec 经典教训：Edge-only signing 时不签名段无路径完整性 → 论文若想部署该类机制，必须承认混合部署下属性不可用或降级。
  - 若论文自己声称“可增量部署”，必须给出具体部署顺序与最坏攻击面。
- **反向兼容**：未升级的 AS 如何与已升级 AS 交互？是不兼容还是优雅降级？

## RPKI 采用背景

- 论文是否基于现实 RPKI 采用率（ROA 覆盖、validator 部署、RIR 签发）？还是假设“大家都有 ROA”？
- 若依赖 RPKI：讨论 RPKI 自身的不完美（覆盖不全、SLURM/例外、local trust anchors、镜像冲突）了吗？
- 有没有区分“路由安全 reachable set”与现实 internet。

## 部署成本（Cost）

逐项评估论文是否量化或至少定性：

- CPU / 内存 / 带宽（报文膨胀：每个 hop 的签名导致的 MTU/慢速路径问题）。
- 密钥管理（BGPsec 的 key rollover、key server、ECC vs RSA 大小）。
- 运维（validator 维护、告警运营、人员负担）。
- **路径选择扰动**：部署后路径长度/路由选择是否会变 → 流量迁移、连接受损 → 这是运营者最敏感的隐性成本。

## 激励（Incentives）

- 谁有动机部署？who pays vs who benefits？
- 非联盟成员（非部署者）是否能搭便车？其存在是否削弱机制（free-rider attack surface）？
- 是否有基于激励的论文论证（如市场压力、安全评分）而不是只假设利他部署？

## 兼容性与迁移（Compatibility & Migration）

- 与 RFC 机制（ROV、BGPsec、ASPA）的互操作。
- 与厂商实现/标准设备（不支持新字段的路由器）的兼容。
- 迁移路径：如何从现状平滑过渡；过渡期的双栈/兼容模式。

## 现网数据锚定

- 若提到“现网可部署”，最好有：
  - 现实的拓扑（AS 规模分布、provider/customer 结构）；
  - 现实验证负载（用真实 RIB 的前缀数×路径数）；
  - 现实的测量（路径长度分布、更新率）。
- 纯理论部署论证但无任何数据锚定 → 记为“部署论证不充分”。

## Checklist 汇总

- [ ] 明确区分 full / incremental / mixed deployment 的安全语义。
- [ ] 给出 partial-deployment 的降级量化或至少定性边界。
- [ ] 量化部署成本（CPU/带宽/密钥/运维/路径扰动）。
- [ ] 分析激励与 free-rider。
- [ ] 与 RPKI/BGPsec/ASPA 的现实采用率挂钩。
- [ ] 说明与现有实现的兼容性与迁移路径。

## 输出到哪

若论文在 ⑦ 维有明显缺口（最常见：只做全量假设、无 mixed deployment 分析、无成本），该缺口应提升为 Final Review 的 Major 或 Echo，并写入 `final-review.md` 与 `claim-matrix.md`（“可增量部署”类 claim 的证据充分性）。
