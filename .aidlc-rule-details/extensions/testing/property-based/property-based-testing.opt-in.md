# Testes Baseados em Propriedades — Opt-In

**Extensão**: Testes Baseados em Propriedades (Property-Based Testing)

## Prompt de Opt-In

A seguinte pergunta é automaticamente incluída nas perguntas de esclarecimento da Análise de Requisitos quando esta extensão é carregada:

```markdown
## Question: Property-Based Testing Extension
As regras de testes baseados em propriedades (PBT) devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras PBT como restrições bloqueantes (recomendado para projetos com lógica de negócio, transformações de dados, serialização ou componentes com estado)

B) Parcial — aplicar regras PBT apenas para funções puras e round-trips de serialização (adequado para projetos com complexidade algorítmica limitada)

C) Não — pular todas as regras PBT (adequado para aplicações CRUD simples, projetos apenas de UI ou camadas finas de integração sem lógica de negócio significativa)

X) Other (please describe after [Answer]: tag below)

[Answer]: 
```
