# Regras de Baseline de Resiliência

## Visão Geral
Estas regras de resiliência são restrições transversais OBRIGATÓRIAS que se aplicam a todas as fases do AI-DLC. Elas são derivadas de frameworks estabelecidos de confiabilidade em nuvem (como o AWS Well-Architected Reliability Pillar e melhores práticas de resiliência) e se aplicam a workloads em qualquer provedor de nuvem. As regras estão organizadas em seis pilares: Objetivos de Negócio, Gerenciamento de Mudanças e Automação, Observabilidade Integrada, Alta Disponibilidade, Recuperação de Desastres e Melhoria Contínua.

**Aplicação**: Em cada estágio aplicável, o modelo DEVE verificar a conformidade com estas regras antes de apresentar a mensagem de conclusão do estágio ao usuário.

### Comportamento de Achado de Resiliência Bloqueante
Um **achado de resiliência bloqueante** significa:
1. O achado DEVE ser listado na mensagem de conclusão do estágio sob uma seção "Achados de Resiliência" com o ID da regra RESILIENCY e a descrição
2. O estágio NÃO DEVE apresentar a opção "Continuar para o Próximo Estágio" até que todos os achados bloqueantes sejam resolvidos
3. O modelo DEVE apresentar apenas a opção "Solicitar Alterações" com uma explicação clara do que precisa mudar
4. O achado DEVE ser registrado em `aidlc-docs/audit.md` com o ID da regra RESILIENCY, descrição e contexto do estágio

Se uma regra RESILIENCY não for aplicável ao projeto atual (ex.: RESILIENCY-07 quando nenhum dado com estado existir), marque-a como **N/A** no resumo de conformidade — isso não é um achado bloqueante.

### Aplicação Padrão
Todas as regras neste documento são **bloqueantes** por padrão. Se os critérios de verificação de qualquer regra não forem atendidos, é um achado de resiliência bloqueante — siga o comportamento de achado bloqueante definido acima.

### Formato dos Critérios de Verificação
Os itens de verificação neste documento são tópicos simples descrevendo verificações de conformidade. Eles são distintos dos checkboxes de rastreamento de progresso `- [ ]` / `- [x]` usados em arquivos de plano de estágio. Cada item deve ser avaliado como conforme ou não conforme durante a revisão.

### Pontos de Decisão do Usuário (o modelo DEVE perguntar, NÃO decidir)
Esta extensão segue o princípio do AI-DLC de que decisões arquiteturais e de processo pertencem ao usuário, não ao LLM. O modelo DEVE apresentar as perguntas de esclarecimento definidas nas regras abaixo e usar as respostas do usuário — NÃO DEVE escolher silenciosamente em nome do usuário. As decisões explicitamente delegadas ao usuário são:

| Decisão | Regra | Pergunta apresentada |
|---|---|---|
| Alvos RTO/RPO e estratégia de DR | RESILIENCY-02 | Seleção de estratégia de DR (Backup&Restore → Active/Active) |
| Processo de gerenciamento de mudanças | RESILIENCY-03 | Usar processo existente da org vs propor vs isentar |
| Ferramentas de CI/CD | RESILIENCY-04 | Usar pipeline existente vs propor |
| Mecanismo de rollback | RESILIENCY-04 | Redeploy de versão / blue-green / canary / DB-aware / existente |
| Estilo de implantação | RESILIENCY-04 | Direto / rolling / blue-green / canary |
| Topologia regional | RESILIENCY-08 | Single-region multi-zone vs multi-region active-passive/active |
| Processo de resposta a incidentes | RESILIENCY-15 | Usar processo existente da org vs propor |
| Abordagem de testes de resiliência | RESILIENCY-14 | Usar prática existente vs propor vs adiar para Operations |

Onde uma organização já tem um processo (gerenciamento de mudanças, CI/CD, resposta a incidentes, testes de DR), o modelo DEVE referenciá-lo e conformar-se a ele em vez de inventar um novo.

---

## PILAR 1: OBJETIVOS DE NEGÓCIO

---

## Regra RESILIENCY-01: Identificação e Priorização de Workloads Críticos

**Regra**: Todo projeto DEVE identificar e documentar seus workloads críticos e seu impacto de negócio:
- **Classificação de workload**: Cada componente implantável DEVE ser classificado por criticidade de negócio (Critical, High, Medium, Low)
- **Análise de impacto de negócio**: O impacto da indisponibilidade de cada componente DEVE ser documentado (perda de receita, impacto no usuário, consequências regulatórias)
- **Mapeamento de dependências**: Workloads críticos DEVEM ter suas dependências upstream e downstream identificadas e documentadas

**Verificação**:
- A documentação de design inclui uma classificação de criticidade de workload para cada componente
- O impacto de negócio da indisponibilidade é documentado para componentes críticos e de alta prioridade
- Mapas de dependências existem mostrando relacionamentos de serviços upstream e downstream

---

## Regra RESILIENCY-02: Alvos de Disponibilidade e Recuperação

**Regra**: Todo workload de produção DEVE ter alvos definidos de disponibilidade e recuperação alinhados com as expectativas de negócio:
- **Definição de SLA**: Uma porcentagem alvo de disponibilidade DEVE ser definida (ex.: 99.9%, 99.99%)
- **RTO (Recovery Time Objective)**: O tempo máximo aceitável de downtime DEVE ser definido para cada workload crítico
- **RPO (Recovery Point Objective)**: A janela máxima aceitável de perda de dados DEVE ser definida para cada workload com estado persistente
- **Alinhamento**: Alvos de disponibilidade DEVEM ser validados contra requisitos de negócio — over-engineering e under-engineering são ambos achados

**Verificação**:
- Cada workload crítico tem um alvo de SLA documentado
- RTO é definido e documentado para cada workload crítico
- RPO é definido e documentado para cada workload com dados persistentes
- Alvos são justificados por requisitos de negócio (não arbitrários)

**Pergunta de Acompanhamento (perguntar antes de finalizar requisitos)**:

Antes de finalizar a fase de Requisitos, o modelo DEVE perguntar ao usuário a seguinte pergunta de esclarecimento para capturar alvos de recuperação e estabelecer a estratégia de Recuperação de Desastres. A resposta do usuário impulsiona diretamente a seleção de estratégia de DR em RESILIENCY-11 e decisões de proteção de dados em RESILIENCY-12.

```markdown
## Question: RTO/RPO Goals and Disaster Recovery Strategy
What are your Recovery Time Objective (RTO) and Recovery Point Objective (RPO) goals? These determine the appropriate Disaster Recovery strategy and infrastructure redundancy level.

A) RPO/RTO: Hours — Backup & Restore strategy. Lowest cost ($). Data backed up, no services deployed. Redeploy from IaC and restore from backups on failure. Suitable for non-critical workloads.

B) RPO/RTO: 10s of minutes — Pilot Light strategy. Cost: $$. Data live, services idle. Infrastructure deployed but not running, scaled up on failover. Suitable for important workloads.

C) RPO/RTO: Minutes — Warm Standby strategy. Cost: $$$. Data live, services run at reduced capacity. Scaled up during failover. Suitable for business-critical applications.

D) RPO/RTO: Near real-time — Multi-site Active/Active strategy. Highest cost ($$$$). Data live, live services in multiple regions simultaneously. Suitable for mission-critical, zero-downtime requirements.

E) N/A — Single-region deployment is acceptable, no cross-region DR needed. Rely on multi-zone availability within one region.

X) Other (please describe after [Answer]: tag below)

[Answer]: 
```

Os alvos RTO/RPO selecionados pelo usuário DEVEM ser documentados na saída de requisitos e propagados para todos os estágios downstream (Design da Aplicação, Requisitos NFR, Design NFR, Design de Infraestrutura).

---

## PILAR 2: GERENCIAMENTO DE MUDANÇAS E AUTOMAÇÃO

---

## Regra RESILIENCY-03: Processo de Gerenciamento de Mudanças

**Regra**: Todo projeto DEVE integrar-se a um processo de gerenciamento de mudanças que minimize o risco de falhas induzidas por mudanças. A expectativa padrão é que a organização já TENHA um processo de gerenciamento de mudanças — esta regra direciona o projeto a identificá-lo e conformar-se a ele, não a inventar um novo.

**Pergunta de Esclarecimento (perguntar durante Requisitos; não presumir uma resposta)**:

```markdown
## Question: Change Management Process
How should production changes for this workload be governed? AI-DLC will conform the design to your answer rather than inventing a process.

A) Use our existing organizational change management process — provide the name/tool (e.g., ServiceNow, Jira Change, internal CAB). AI-DLC will reference it and ensure deployable artifacts fit that process (change records, approval gates).

B) No formal process exists yet — AI-DLC should propose a lightweight change management process (change record + approval + rollback note) for the team to adopt.

C) N/A — this workload is exempt from formal change management (e.g., internal tooling). Document the exemption rationale.

X) Other (describe after [Answer]: tag below)

[Answer]: 
```

**Verificação**:
- O processo de gerenciamento de mudanças é identificado por nome (processo existente da org) OU explicitamente proposto/isentado conforme a resposta do usuário
- Mudanças de produção referenciam o processo identificado para aprovação e registros de mudança
- O mecanismo de histórico de mudanças é identificado (ferramenta existente ou proposta)

**Nota**: Se o usuário selecionar A, o modelo NÃO DEVE redefinir o processo — apenas referenciá-lo e garantir que os artefatos (ex.: configs de implantação, runbooks) sejam compatíveis com ele.

---

## Regra RESILIENCY-04: Implantação Automatizada e Rollback

**Regra**: Todas as implantações de produção idealmente devem ser automatizadas, e a abordagem de rollback DEVE ser explicitamente escolhida pelo usuário — não inferida pelo modelo. O projeto DEVE reutilizar as ferramentas de CI/CD e convenções de implantação existentes da organização onde existirem.

**Definições** (para remover ambiguidade):
- **Rollback**: O mecanismo definido para retornar o workload em execução ao seu último estado conhecido como bom após uma implantação falha. Esta regra NÃO presume um mecanismo específico — o usuário seleciona um abaixo.
- **Estilo de implantação**: A estratégia usada para liberar uma mudança (direto/in-place, rolling, blue/green ou canary).

**Perguntas de Esclarecimento (perguntar durante Requisitos ou Design NFR; não presumir respostas)**:

```markdown
## Question: CI/CD and Deployment Tooling
What CI/CD tooling and deployment process should this workload use?

A) Use our existing CI/CD pipeline — provide the tool (e.g., GitHub Actions, GitLab CI, Jenkins, CodePipeline). AI-DLC will produce artifacts compatible with it.

B) No pipeline exists — AI-DLC should propose a CI/CD pipeline definition appropriate to the chosen IaC and runtime.

X) Other (describe after [Answer]: tag below)

[Answer]: 

## Question: Rollback Mechanism
How should a failed production deployment be rolled back?

A) Redeploy previous IaC/artifact version (version-pinned rollback)

B) Blue/green swap back to the previous environment

C) Canary auto-rollback on health/metric regression

D) Database-aware rollback required (schema/data migration reversal) — flag for explicit design

E) Use our organization's existing rollback procedure — provide reference

X) Other (describe after [Answer]: tag below)

[Answer]: 

## Question: Deployment Style
What deployment strategy is acceptable for this workload's risk profile?

A) Direct / in-place (lowest cost, highest blast radius) — acceptable for non-critical workloads

B) Rolling (gradual instance replacement)

C) Blue/green (zero-downtime cutover, higher cost)

D) Canary (progressive traffic shift with automated rollback)

X) Other (describe after [Answer]: tag below)

[Answer]: 
```

**Verificação**:
- A ferramenta IaC é identificada (padrão existente da org ou selecionada pelo usuário)
- O pipeline de CI/CD é identificado (existente) ou proposto conforme a resposta do usuário
- O mecanismo de rollback é explicitamente selecionado pelo usuário e documentado (não inferido)
- O estilo de implantação é explicitamente selecionado pelo usuário e corresponde à criticidade do workload de RESILIENCY-01
- Para rollbacks conscientes de banco de dados (Pergunta 2, opção D), uma abordagem de reversão de migração é documentada

---

## PILAR 3: OBSERVABILIDADE INTEGRADA

---

## Regra RESILIENCY-05: Monitoramento e Alertas para Workloads Críticos

**Regra**: Todo workload implantado DEVE ter monitoramento configurado nos três pilares de observabilidade — métricas, logs e traces:
- **Métricas**: Métricas operacionais-chave DEVEM ser coletadas (latência, taxa de erro, throughput, saturação) para cada componente
- **Logs**: Logging estruturado DEVE ser configurado e roteado para um serviço de log centralizado
- **Traces**: Para sistemas distribuídos com múltiplos serviços, tracing distribuído DEVE ser configurado para rastrear solicitações entre limites de serviços
- **Dashboards**: Um dashboard de monitoramento DEVE ser definido mostrando indicadores-chave de saúde do workload

**Verificação**:
- Cada componente tem coleta de métricas configurada (usando uma plataforma de observabilidade nativa da nuvem ou de terceiros)
- Logging estruturado é roteado para um serviço centralizado
- Tracing distribuído é configurado para arquiteturas multi-serviço (N/A para serviço único)
- Uma definição ou configuração de dashboard existe para monitoramento de saúde operacional

---

## Regra RESILIENCY-06: Health Checks

**Regra**: Todo componente de produção DEVE implementar health checks que reflitam com precisão sua capacidade de servir tráfego:
- **Health checks rasos**: Todo serviço DEVE expor um endpoint básico de saúde que confirme que o processo está em execução
- **Health checks profundos**: Serviços críticos DEVEM implementar health checks profundos que verifiquem conectividade com dependências downstream (bancos de dados, caches, APIs externas)
- **Integração com load balancer**: Health checks DEVEM ser integrados com load balancers ou service discovery para permitir roteamento automático de tráfego para longe de instâncias não saudáveis
- **Monitoramento sintético**: Endpoints voltados ao público DEVERIAM ter monitoramento sintético canary para detectar problemas de disponibilidade da perspectiva do usuário

**Verificação**:
- Cada serviço expõe um endpoint de health check
- Health checks profundos verificam conectividade de dependências downstream para serviços críticos
- Health checks são integrados com load balancers ou mecanismos de roteamento
- Monitoramento sintético é configurado para endpoints voltados ao público (ou documentado como não aplicável)

---

## Regra RESILIENCY-07: Monitoramento de Resiliência

**Regra**: A postura de resiliência de workloads implantados DEVE ser monitorada ativamente:
- **Avaliação de resiliência**: Workloads DEVERIAM ser registrados com uma ferramenta de avaliação de resiliência (nativa do provedor de nuvem ou de terceiros) para avaliação contínua da postura de resiliência
- **Configuração de alarmes**: Alarmes DEVEM ser configurados para condições que indiquem degradação de resiliência (ex.: operação em zona única, lag de replicação, falhas de backup)
- **Monitoramento de capacidade**: Métricas de auto-scaling e utilização de capacidade DEVEM ser monitoradas para detectar limites de escala antes que causem outages

**Verificação**:
- Alarmes específicos de resiliência são configurados (não apenas alarmes operacionais)
- Métricas de capacidade e escala são monitoradas
- Ferramentas de avaliação de resiliência são configuradas ou documentadas como melhoria futura

---

## PILAR 4: ALTA DISPONIBILIDADE

---

## Regra RESILIENCY-08: Implantação Multi-Zone e Multi-Region

**Regra**: Workloads de produção DEVEM ter uma topologia de isolamento de falhas explicitamente escolhida. O baseline multi-zone é obrigatório para produção; a decisão multi-region DEVE ser feita pelo usuário (impulsada pela resposta RTO/RPO em RESILIENCY-02), não inferida pelo modelo.

**Baseline multi-zone (obrigatório para produção)**:
- **Computação**: Recursos de compute (VMs, clusters de containers) DEVEM ser distribuídos em pelo menos 2 availability zones. Serviços serverless são tipicamente multi-zone por padrão.
- **Armazenamentos de dados**: Bancos de dados e caches DEVEM usar configurações multi-zone (replicados, clusterizados ou globalmente distribuídos)
- **Load balancing**: O tráfego DEVE ser distribuído entre zones usando um load balancer ou roteamento baseado em DNS
- **Estabilidade estática**: A arquitetura DEVE continuar operando se uma zone ficar indisponível, sem exigir operações do control plane para recuperar

**Decisão multi-region (impulsada pelo usuário — não inferir)**:

A escolha entre single-region multi-zone e multi-region é um tradeoff de custo/complexidade que DEVE ser feito pelo usuário. Se a resposta de RESILIENCY-02 foi D (Active/Active) ou C (Warm Standby com escopo cross-region), multi-region é implícito — confirme com o usuário. Caso contrário, pergunte:

```markdown
## Question: Regional Topology
Does this workload require multi-region deployment, or is single-region with multi-zone redundancy sufficient?

A) Single-region, multi-zone — tolerates zone failure, not full-region failure. Lower cost. (Aligns with RTO/RPO options A/B/E.)

B) Multi-region active-passive — survives region failure with failover. Higher cost. (Aligns with Warm Standby / Pilot Light cross-region.)

C) Multi-region active-active — survives region failure with no downtime. Highest cost. (Aligns with Active/Active.)

X) Other (describe after [Answer]: tag below)

[Answer]: 
```

**Verificação**:
- Recursos de compute são implantados em 2+ availability zones (ou usam serviços serverless inerentemente multi-zone)
- Armazenamentos de dados usam configurações multi-zone
- Load balancing distribui tráfego entre zones
- A topologia multi-region é explicitamente selecionada pelo usuário e consistente com o alvo RTO/RPO de RESILIENCY-02
- A documentação de arquitetura confirma estabilidade estática (sem dependência do control plane para failover de zone)

---

## Regra RESILIENCY-09: Auto-Scaling e Gerenciamento de Capacidade

**Regra**: Workloads de produção DEVEM implementar auto-scaling para lidar com variações de carga e prevenir outages induzidos por capacidade:
- **Políticas de auto-scaling**: Recursos de compute DEVEM ter auto-scaling configurado com gatilhos de escala apropriados (CPU, memória, contagem de solicitações, métricas customizadas)
- **Limites de escala**: Limites mínimos e máximos de capacidade DEVEM ser definidos para prevenir tanto under-provisioning quanto runaway scaling
- **Pre-warming**: Para workloads com padrões de tráfego previsíveis, scaling agendado ou pre-warming DEVERIA ser configurado
- **Limites serverless**: Funções serverless DEVEM ter limites de concorrência configurados para prevenir sobrecarga de serviços downstream
- **Consciência de cotas de serviço**: Equipes DEVEM identificar cotas e limites de serviços do provedor de nuvem relevantes ao workload (ex.: concorrência de funções, taxas de solicitação de API, limites de solicitações de armazenamento) e documentar quaisquer cotas que exijam aumentos antes do lançamento em produção. A utilização de cotas DEVERIA ser monitorada e alarmada em um limiar de 80%.

**Verificação**:
- Auto-scaling é configurado para recursos de compute (ou serverless é usado)
- Limites mínimos e máximos de escala são definidos
- Gatilhos de escala são apropriados para o padrão do workload
- Limites de concorrência serverless são configurados onde aplicável
- Cotas relevantes de serviços do provedor de nuvem são identificadas e documentadas
- Solicitações de aumento de cota são planejadas para quaisquer limites que possam ser excedidos sob carga esperada

---

## Regra RESILIENCY-10: Isolamento de Dependências e Circuit Breaking

**Regra**: Aplicações DEVEM implementar padrões para prevenir falhas em cascata de outages de dependências:
- **Timeouts**: Todas as chamadas externas (HTTP, banco de dados, cache) DEVEM ter timeouts explícitos configurados — sem waits ilimitados
- **Circuit breakers**: Serviços que chamam dependências externas DEVERIAM implementar padrões de circuit breaker para falhar rápido quando uma dependência está não saudável
- **Bulkheads**: Workloads críticos DEVERIAM isolar pools de dependências (connection pools, thread pools) para prevenir que uma dependência falha esgote recursos compartilhados
- **Degradação graciosa**: Aplicações DEVEM definir comportamento em modo degradado quando dependências não críticas estão indisponíveis

**Verificação**:
- Todas as chamadas externas têm timeouts explícitos configurados
- Padrões de circuit breaker são implementados para dependências externas críticas (ou documentados como não aplicáveis)
- Comportamento de degradação graciosa é documentado para falhas de dependências não críticas
- Connection pools e limites de recursos são configurados para prevenir esgotamento de recursos

---

## PILAR 5: RECUPERAÇÃO DE DESASTRES

---

## Regra RESILIENCY-11: Seleção de Estratégia de DR

**Regra**: Todo workload de produção com estado persistente DEVE ter uma estratégia documentada de recuperação de desastres apropriada aos seus alvos RTO/RPO:
- **Seleção de estratégia**: Escolher entre estratégias estabelecidas de DR com base nos requisitos de negócio:
  - Backup & Restore (RTO/RPO: horas) — menor custo
  - Pilot Light (RTO/RPO: dezenas de minutos) — dados ao vivo, serviços ociosos
  - Warm Standby (RTO/RPO: minutos) — dados ao vivo, serviços em capacidade reduzida
  - Hot Standby / Active-Passive (RTO/RPO: minutos) — dados ao vivo, serviços prontos
  - Active/Active (RTO/RPO: tempo real) — maior custo, zero downtime
- **Alinhamento de custo**: O custo da estratégia de DR DEVE ser justificado pelo impacto de negócio do downtime
- **Documentação**: A estratégia de DR escolhida DEVE ser documentada com procedimentos claros de failover e failback

**Verificação**:
- Uma estratégia de DR é selecionada e documentada para cada workload crítico
- A estratégia se alinha com os alvos RTO/RPO definidos (RESILIENCY-02)
- Procedimentos de failover e failback são documentados
- O custo da estratégia de DR é justificado contra o impacto de negócio

---

## Regra RESILIENCY-12: Backup e Replicação de Dados

**Regra**: Todos os dados persistentes DEVEM ser backed up e/ou replicados de acordo com o RPO definido:
- **Backups automatizados**: Backups de banco de dados e armazenamento DEVEM ser automatizados usando um serviço de backup gerenciado ou job agendado (ex.: snapshots automatizados de banco de dados, versionamento de object storage ou equivalente)
- **Replicação cross-region**: Dados críticos DEVERIAM ser replicados para uma região secundária para cenários de desastre regional
- **Validação de backup**: A integridade do backup DEVE ser periodicamente validada através de restores de teste
- **Política de retenção**: Períodos de retenção de backup DEVEM ser definidos e alinhados com requisitos de negócio e conformidade
- **Criptografia**: Backups DEVEM ser criptografados em repouso

**Verificação**:
- Backup automatizado é configurado para todos os armazenamentos de dados persistentes
- Replicação cross-region é configurada para dados críticos (ou documentada como não necessária com justificativa)
- Políticas de retenção de backup são definidas
- Criptografia de backup está habilitada
- Um processo de validação de backup é documentado (mesmo se manual)

---

## Regra RESILIENCY-13: Procedimentos de Failover e Recuperação

**Regra**: Toda estratégia de DR DEVE ter procedimentos documentados e testados de failover e recuperação:
- **Runbooks**: Runbooks passo a passo de failover e failback DEVEM ser documentados
- **Automação**: Procedimentos de failover DEVERIAM ser automatizados onde possível (ex.: roteamento baseado em health-check de DNS, replicação global gerenciada de banco de dados, serviços dedicados de recuperação de desastres)
- **Plano de comunicação**: Um plano de comunicação para stakeholders durante eventos de DR DEVE ser definido
- **Validação de recuperação**: Etapas de validação pós-failover DEVEM ser documentadas para confirmar que o workload está operando corretamente no ambiente de DR

**Verificação**:
- Runbooks de failover existem com procedimentos passo a passo
- Procedimentos de failback são documentados
- Mecanismos de failover automatizado são configurados onde aplicável
- Etapas de validação pós-failover são definidas

---

## PILAR 6: MELHORIA CONTÍNUA

---

## Regra RESILIENCY-14: Chaos Engineering e Testes de DR

**Regra**: Mecanismos de resiliência DEVEM ter uma abordagem definida de testes. Onde a organização já tem práticas de testes de DR ou chaos engineering, esta regra direciona o projeto a referenciá-las em vez de inventar novas.

**Pergunta de Esclarecimento (perguntar durante Design NFR; não presumir)**:

```markdown
## Question: Resiliency Testing Approach
How will resiliency mechanisms (failover, recovery) be validated?

A) Use our existing DR testing / game day / chaos engineering practice — provide the reference. AI-DLC will document test scenarios that fit it.

B) No practice exists — AI-DLC should propose a DR testing schedule and chaos experiment plan for adoption.

C) Defer to the Operations phase — capture test scenarios now, execute during Operations.

X) Other (describe after [Answer]: tag below)

[Answer]: 
```

**Verificação**:
- Uma abordagem de testes de resiliência é identificada (prática existente, plano proposto ou adiada para Operations conforme a resposta do usuário)
- Cenários de teste de DR são documentados para a estratégia de DR selecionada (RESILIENCY-11)
- O mecanismo de rastreamento de resultados de testes é identificado (existente ou proposto)

**Nota**: A execução de experimentos de chaos e drills de DR é uma atividade da fase de Operations. Esta regra garante que os cenários de teste e o cronograma sejam capturados no momento do design para que Operations tenha um ponto de partida definido.

---

## Regra RESILIENCY-15: Resposta a Incidentes e Correção de Erros

**Regra**: Todo projeto DEVE integrar-se a um processo de resposta a incidentes. Assim como no gerenciamento de mudanças, a expectativa padrão é que a organização já TENHA um processo de resposta a incidentes — esta regra direciona o projeto a referenciá-lo e conformar-se a ele.

**Pergunta de Esclarecimento (perguntar durante Requisitos ou Design NFR; não presumir)**:

```markdown
## Question: Incident Response Process
How are production incidents handled for this workload?

A) Use our existing incident response process — provide the reference (e.g., PagerDuty runbooks, internal IR/on-call process). AI-DLC will align alerting and runbooks to it.

B) No formal process exists — AI-DLC should propose a lightweight incident response and Correction of Errors (COE) process for adoption.

X) Other (describe after [Answer]: tag below)

[Answer]: 
```

**Verificação**:
- O processo de resposta a incidentes é identificado por nome (existente) ou proposto conforme a resposta do usuário
- Um mecanismo de COE/post-mortem é identificado (prática existente da org ou proposto)
- Alertas de RESILIENCY-05 roteiam para o processo de resposta a incidentes identificado
- O mecanismo de rastreamento de ações corretivas é identificado

**Nota**: Se o usuário selecionar A, o modelo DEVE referenciar o processo existente e garantir que observabilidade/alertas se integrem a ele — não redefini-lo.

---

## Integração de Aplicação

Estas regras são restrições transversais que se aplicam a cada estágio do AI-DLC. Em cada estágio:
- Avaliar todos os critérios de verificação das regras RESILIENCY contra os artefatos produzidos
- Incluir uma seção "Conformidade de Resiliência" no resumo de conclusão do estágio listando cada regra como conforme, não conforme ou N/A
- Se qualquer regra estiver não conforme, isso é um achado de resiliência bloqueante — siga o comportamento de achado bloqueante definido na Visão Geral
- Incluir referências às regras de resiliência na documentação de design, templates de infraestrutura e instruções de testes

---

## Apêndice: Mapeamento do Reliability Pillar (AWS Well-Architected)

A tabela a seguir mapeia cada regra para um conceito correspondente no AWS Well-Architected Reliability Pillar. Este mapeamento é informacional e demonstra alinhamento com um dos frameworks de confiabilidade em nuvem mais estabelecidos. As regras em si são agnósticas ao provedor de nuvem.

| Regra RESILIENCY | Conceito de Confiabilidade |
|---|---|
| RESILIENCY-01 | Workload architecture — understand business impact |
| RESILIENCY-02 | Design for availability — define recovery objectives |
| RESILIENCY-03 | Change management — control changes |
| RESILIENCY-04 | Deployment automation — automate changes |
| RESILIENCY-05 | Monitor workload resources — observability |
| RESILIENCY-06 | Design interactions to prevent failures — health checks |
| RESILIENCY-07 | Monitor workload resources — resiliency posture |
| RESILIENCY-08 | Use fault isolation — multi-zone |
| RESILIENCY-09 | Design for horizontal scaling — auto-scaling |
| RESILIENCY-10 | Design interactions to prevent failures — circuit breaking |
| RESILIENCY-11 | Plan for disaster recovery — strategy selection |
| RESILIENCY-12 | Back up data — automated backups |
| RESILIENCY-13 | Design for recovery — failover procedures |
| RESILIENCY-14 | Test reliability — chaos engineering and DR testing |
| RESILIENCY-15 | Operate and observe — incident response and learning |

## Apêndice: Mapeamento do Resilience Readiness Pillar (AWS RRR)

A tabela a seguir mapeia cada regra para um pilar no framework AWS Resilience Readiness Review (RRR). Este mapeamento é informacional; as regras se aplicam a qualquer provedor de nuvem.

| Área de Avaliação de Resiliência | Regras RESILIENCY |
|---|---|
| Objetivos de Negócio | RESILIENCY-01, RESILIENCY-02 |
| Gerenciamento de Mudanças e Automação | RESILIENCY-03, RESILIENCY-04 |
| Observabilidade Integrada | RESILIENCY-05, RESILIENCY-06, RESILIENCY-07 |
| Alta Disponibilidade | RESILIENCY-08, RESILIENCY-09, RESILIENCY-10 |
| Recuperação de Desastres | RESILIENCY-11, RESILIENCY-12, RESILIENCY-13 |
| Melhoria Contínua | RESILIENCY-14, RESILIENCY-15 |
