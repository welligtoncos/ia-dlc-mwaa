# Profundidade Adaptativa

**Propósito**: Explicar como o AI-DLC adapta o nível de detalhe à complexidade do problema

## Princípio Central

**Quando um estágio é executado, TODOS os seus artefatos definidos são criados. A "profundidade" refere-se ao nível de detalhe e rigor dentro desses artefatos, que se adapta à complexidade do problema.**

## Seleção de Estágio vs Nível de Detalhe

### Seleção de Estágio (Binária)
- **Planejamento do Workflow** decide: EXECUTAR ou PULAR para cada estágio
- **Se EXECUTAR**: O estágio roda e cria TODOS os seus artefatos definidos
- **Se PULAR**: O estágio não roda de forma alguma

### Nível de Detalhe (Adaptativo)
- **Problemas simples**: Artefatos concisos com detalhe essencial
- **Problemas complexos**: Artefatos abrangentes com detalhe extenso
- **O modelo decide**: Com base nas características do problema, não em regras prescritivas

## Fatores que Influenciam o Nível de Detalhe

O modelo considera estes fatores ao determinar o detalhe apropriado:

1. **Clareza da Solicitação**: Quão clara e completa é a solicitação do usuário?
2. **Complexidade do Problema**: Quão intrincado é o espaço de solução?
3. **Escopo**: Arquivo único, componente, múltiplos componentes ou em todo o sistema?
4. **Nível de Risco**: Qual o impacto de erros ou omissões?
5. **Contexto Disponível**: Greenfield vs brownfield, documentação existente
6. **Preferências do Usuário**: O usuário expressou preferência por brevidade ou detalhe?

## Exemplo: Artefatos de Análise de Requisitos

**Todos os cenários criam os mesmos artefatos**:
- `requirement-verification-questions.md` (se necessário)
- `requirements.md`

**Nota**: A solicitação inicial do usuário é capturada em `audit.md` (não é necessário um user-intent.md separado)

**O nível de detalhe varia pela complexidade**:

### Cenário Simples (Correção de Bug)
- **requirement-verification-questions.md**: perguntas de esclarecimento necessárias
- **requirements.md**: Requisito funcional conciso, seções mínimas

### Cenário Complexo (Migração de Sistema)
- **requirement-verification-questions.md**: Múltiplas rodadas, 10+ perguntas
- **requirements.md**: Requisitos funcionais + não funcionais abrangentes, rastreabilidade, critérios de aceitação

## Exemplo: Artefatos de Design da Aplicação

**Todos os cenários criam os mesmos artefatos**:
- `application-design.md`
- `component-diagram.md`

**O nível de detalhe varia pela complexidade**:

### Cenário Simples (Componente Único)
- **application-design.md**: Descrição básica do componente, métodos-chave
- **component-diagram.md**: Diagrama simples com relacionamentos essenciais

### Cenário Complexo (Sistema Multi-Componente)
- **application-design.md**: Responsabilidades detalhadas dos componentes, todos os métodos com assinaturas, padrões de design, alternativas consideradas
- **component-diagram.md**: Diagrama abrangente com todos os relacionamentos, fluxos de dados, pontos de integração

## Princípio Orientador para o Modelo

**"Crie exatamente o detalhe necessário para o problema em questão - nem mais, nem menos."**

- Não infle artificialmente problemas simples com detalhe desnecessário
- Não prejudique problemas complexos omitindo detalhe crítico
- Deixe as características do problema impulsionar o nível de detalhe naturalmente
- Todos os artefatos obrigatórios são sempre criados quando o estágio é executado
