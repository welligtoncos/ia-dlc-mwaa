# Baseline de Resiliência — Opt-In

**Extensão**: Baseline de Resiliência (Resiliency Baseline)

## Prompt de Opt-In

A seguinte pergunta é automaticamente incluída nas perguntas de esclarecimento da Análise de Requisitos quando esta extensão é carregada:

```markdown
## Question: Resiliency Extensions
O baseline de resiliência deve ser aplicado neste projeto?

**O que esta extensão é.** Ativá-la aplica um conjunto de **melhores práticas direcionais de design** para construir sistemas resilientes, derivadas do **AWS Well-Architected Framework (Reliability Pillar)** e orientações de revisão de resiliência. Ela direciona requisitos, design e código para tolerância a falhas, alta disponibilidade, observabilidade e recuperabilidade — cobrindo 15 áreas de prática entre objetivos de negócio, gerenciamento de mudanças, observabilidade, alta disponibilidade, recuperação de desastres e melhoria contínua.

**O que esta extensão NÃO é.** Ativá-la **não** torna seu workload pronto para produção, nem certifica ou garante qualquer alvo de disponibilidade, RTO ou RPO. É um **ponto de partida** que estrutura boas decisões de resiliência cedo — não é um substituto para um **AWS Well-Architected Review** formal do sistema construído.

Trate a saída como um **primeiro rascunho bem fundamentado da sua postura de resiliência** para construir e validar — não um resultado final certificado para produção.

A) Sim — aplicar o baseline de resiliência como melhores práticas direcionais e orientação de design (recomendado para workloads críticos de negócio, como ponto de partida informado que você pode validar e endurecer antes do go-live)

B) Não — pular o baseline de resiliência (adequado para PoCs, protótipos e projetos experimentais onde iteração rápida importa mais do que confiabilidade)

X) Other (please describe after [Answer]: tag below)

[Answer]: 
```
