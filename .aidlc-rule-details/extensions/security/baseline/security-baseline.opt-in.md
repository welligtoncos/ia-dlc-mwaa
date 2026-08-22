# Baseline de Segurança — Opt-In

**Extensão**: Baseline de Segurança (Security Baseline)

## Prompt de Opt-In

A seguinte pergunta é automaticamente incluída nas perguntas de esclarecimento da Análise de Requisitos quando esta extensão é carregada:

```markdown
## Question: Security Extensions
As regras da extensão de segurança devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras SECURITY como restrições bloqueantes (recomendado para aplicações de nível de produção)

B) Não — pular todas as regras SECURITY (adequado para PoCs, protótipos e projetos experimentais)

X) Other (please describe after [Answer]: tag below)

[Answer]: 
```
