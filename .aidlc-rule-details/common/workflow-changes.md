# Mudanças no Meio do Workflow e Gerenciamento de Estágios

## Visão Geral

Os usuários podem solicitar mudanças no plano de execução ou na execução de estágios durante o workflow. Este documento fornece orientação sobre como tratar essas solicitações de forma segura e eficaz.

---

## Tipos de Mudanças no Meio do Workflow

### 1. Adicionar um Estágio Pulado

**Cenário**: O usuário quer adicionar um estágio que foi originalmente pulado

**Exemplo**: "Na verdade, quero adicionar histórias de usuário mesmo tendo pulado aquele estágio"

**Tratamento**:
1. **Confirmar Solicitação**: "Você quer adicionar o estágio de Histórias de Usuário. Isso criará histórias de usuário e personas. Confirma?"
2. **Verificar Dependências**: Verificar se todos os estágios pré-requisitos estão completos
3. **Atualizar Plano de Execução**: Adicionar estágio a `execution-plan.md` com justificativa
4. **Atualizar Estado**: Marcar estágio como "PENDING" em `aidlc-state.md`
5. **Executar Estágio**: Seguir o processo normal de execução do estágio
6. **Registrar Mudança**: Documentar em `audit.md` com timestamp e motivo

**Considerações**:
- Pode ser necessário atualizar estágios posteriores que poderiam se beneficiar dos novos artefatos
- Artefatos existentes podem precisar de revisão para incorporar novas informações
- O prazo será estendido

---

### 2. Pular um Estágio Planejado

**Cenário**: O usuário quer pular um estágio que estava planejado para executar

**Exemplo**: "Vamos pular o estágio de Design NFR por agora"

**Tratamento**:
1. **Confirmar Solicitação**: "Você quer pular o Design NFR. Isso significa que nenhum padrão NFR ou componentes lógicos serão incorporados. Confirma?"
2. **Avisar Sobre o Impacto**: Explicar o que estará ausente e as potenciais consequências
3. **Obter Confirmação Explícita**: O usuário deve confirmar explicitamente o entendimento do impacto
4. **Atualizar Plano de Execução**: Marcar estágio como "SKIPPED" com motivo
5. **Atualizar Estado**: Marcar estágio como "SKIPPED" em `aidlc-state.md`
6. **Ajustar Estágios Posteriores**: Observar que estágios posteriores podem precisar de configuração manual
7. **Registrar Mudança**: Documentar em `audit.md` com timestamp e motivo

**Considerações**:
- Estágios posteriores podem falhar ou exigir intervenção manual
- O usuário aceita a responsabilidade pelos artefatos ausentes
- Pode ser adicionado de volta depois se necessário

---

### 3. Reiniciar o Estágio Atual

**Cenário**: O usuário está insatisfeito com os resultados do estágio atual e quer refazê-lo

**Exemplo**: "Não gosto dessas histórias de usuário. Podemos começar de novo?"

**Tratamento**:
1. **Entender a Preocupação**: "O que especificamente você gostaria de mudar nas histórias?"
2. **Oferecer Opções**:
   - **Opção A**: Modificar artefatos existentes (mais rápido, preserva parte do trabalho)
   - **Opção B**: Reinício completo (página em branco, mais tempo)
3. **Se Reinício For Escolhido**:
   - Arquivar artefatos existentes: `{artifact}.backup.{timestamp}`
   - Resetar checkboxes do estágio no arquivo de plano
   - Marcar estágio como "IN PROGRESS" em `aidlc-state.md`
   - Limpar status de conclusão do estágio
   - Reexecutar desde o início
4. **Registrar Mudança**: Documentar o motivo do reinício e o que mudará

**Considerações**:
- O trabalho existente será perdido (mas com backup)
- Pode ser necessário refazer estágios dependentes
- O prazo será estendido

---

### 4. Reiniciar Estágio Anterior

**Cenário**: O usuário quer voltar e refazer um estágio concluído

**Exemplo**: "Quero mudar a decisão arquitetural que tomamos anteriormente"

**Tratamento**:
1. **Avaliar Impacto**: Identificar todos os estágios que dependem do estágio a ser reiniciado
2. **Avisar o Usuário**: "Reiniciar o Design da Aplicação exigirá refazer: Geração de Unidades, design por unidade (todas as unidades), Geração de Código. Confirma?"
3. **Obter Confirmação Explícita**: O usuário deve entender o impacto completo
4. **Se Confirmado**:
   - Arquivar todos os artefatos afetados
   - Resetar todos os estágios afetados em `aidlc-state.md`
   - Limpar checkboxes em todos os arquivos de plano afetados
   - Retornar ao estágio a reiniciar
   - Reexecutar a partir desse ponto em diante
5. **Registrar Mudança**: Documentar o impacto completo e o motivo do reinício

**Considerações**:
- Retrabalho significativo necessário
- Todos os estágios dependentes devem ser refeitos
- O prazo será significativamente estendido
- Considere se a modificação é melhor do que o reinício

---

### 5. Mudar a Profundidade do Estágio

**Cenário**: O usuário quer mudar o nível de profundidade do estágio atual ou próximo

**Exemplo**: "Vamos fazer uma análise de requisitos abrangente em vez de padrão"

**Tratamento**:
1. **Confirmar Solicitação**: "Você quer mudar a Análise de Requisitos de profundidade Padrão para Abrangente. Isso será mais completo, mas levará mais tempo. Confirma?"
2. **Atualizar Plano de Execução**: Mudar o nível de profundidade em `workflow-planning.md`
3. **Ajustar Abordagem**: Seguir as diretrizes de profundidade abrangente para o estágio
4. **Atualizar Estimativas**: Informar o usuário da nova estimativa de prazo
5. **Registrar Mudança**: Documentar a mudança de profundidade e o motivo

**Considerações**:
- Mais profundidade = mais tempo, mas melhor qualidade
- Menos profundidade = mais rápido, mas pode perder detalhes
- Só é possível mudar antes ou durante o estágio, não após a conclusão

---

### 6. Pausar o Workflow

**Cenário**: O usuário precisa pausar e retomar depois

**Exemplo**: "Preciso parar por agora e continuar amanhã"

**Tratamento**:
1. **Completar a Etapa Atual**: Terminar a etapa atual em andamento se possível
2. **Atualizar Checkboxes**: Marcar todas as etapas concluídas com [x]
3. **Atualizar Estado**: Garantir que `aidlc-state.md` reflita o status atual
4. **Registrar Pausa**: Documentar o ponto de pausa em `audit.md`
5. **Fornecer Instruções de Retomada**: "Quando você retornar, detectarei seu projeto existente e oferecerei continuar a partir de: [estágio atual, etapa atual]"

**Na Retomada**:
1. **Detectar Projeto Existente**: Verificar `aidlc-state.md`
2. **Carregar Contexto**: Ler todos os artefatos dos estágios concluídos
3. **Mostrar Status**: Exibir estágio atual e próxima etapa
4. **Oferecer Opções**: Continuar de onde parou ou revisar trabalho anterior
5. **Registrar Retomada**: Documentar o ponto de retomada em `audit.md`

---

### 7. Mudar Decisão Arquitetural

**Cenário**: O usuário quer mudar de monólito para microsserviços (ou vice-versa)

**Exemplo**: "Na verdade, vamos fazer microsserviços em vez de um monólito"

**Tratamento**:
1. **Avaliar Progresso Atual**: Determinar até onde o workflow avançou
2. **Explicar Impacto**: 
   - Se antes da Geração de Unidades: Impacto mínimo, apenas atualizar a decisão
   - Se após a Geração de Unidades: Deve refazer Geração de Unidades, todo design por unidade
   - Se após a Geração de Código: Retrabalho significativo necessário
3. **Recomendar Abordagem**:
   - No início do workflow: Reiniciar a partir do estágio de Design da Aplicação
   - No final do workflow: Considerar se a modificação é viável vs. reinício
4. **Obter Confirmação**: O usuário deve entender o escopo completo da mudança
5. **Executar Mudança**: Seguir procedimentos de reinício para estágios afetados

**Considerações**:
- Mudanças arquiteturais têm efeitos em cascata
- Mais cedo no workflow = mais fácil de mudar
- Mais tarde no workflow = considerar custo vs. benefício

---

### 8. Adicionar/Remover Unidades

**Cenário**: O usuário quer adicionar ou remover unidades após a Geração de Unidades

**Exemplo**: "Precisamos dividir a unidade Payment em Payment e Billing"

**Tratamento**:
1. **Avaliar Impacto**: Determinar quais unidades completaram design/código
2. **Explicar Consequências**:
   - Adicionar unidade: Precisa fazer design e código completos para a nova unidade
   - Remover unidade: Precisa redistribuir funcionalidade para outras unidades
   - Dividir unidade: Precisa refazer design e código para ambas as unidades resultantes
3. **Atualizar Artefatos de Unidades**:
   - Modificar `unit-of-work.md`
   - Atualizar `unit-of-work-dependency.md`
   - Revisar `unit-of-work-story-map.md`
4. **Resetar Unidades Afetadas**: Marcar unidades afetadas como precisando de redesign
5. **Executar Mudanças**: Seguir o processo normal de design e código da unidade para unidades afetadas

**Considerações**:
- Afeta todos os estágios downstream para essas unidades
- Pode afetar outras unidades se as dependências mudarem
- O impacto no prazo depende de quantas unidades são afetadas

---

## Diretrizes Gerais para Tratamento de Mudanças

### Antes de Fazer Mudanças

1. **Entender a Solicitação**: Fazer perguntas de esclarecimento sobre o que o usuário quer mudar e por quê
2. **Avaliar Impacto**: Identificar todos os estágios, artefatos e dependências afetados
3. **Explicar Consequências**: Comunicar claramente o que precisará ser refeito e o impacto no prazo
4. **Oferecer Alternativas**: Às vezes a modificação é melhor do que o reinício
5. **Obter Confirmação Explícita**: O usuário deve entender e aceitar o impacto

### Durante as Mudanças

1. **Arquivar Trabalho Existente**: Sempre fazer backup antes de fazer mudanças destrutivas
2. **Atualizar Todo o Rastreamento**: Manter `aidlc-state.md`, arquivos de plano e `audit.md` sincronizados
3. **Comunicar Progresso**: Manter o usuário informado sobre o que está acontecendo
4. **Validar Mudanças**: Garantir que as mudanças sejam consistentes em todos os artefatos
5. **Testar Continuidade**: Verificar se o workflow pode continuar suavemente após as mudanças

### Após as Mudanças

1. **Verificar Consistência**: Verificar se todos os artefatos estão alinhados com as mudanças
2. **Atualizar Documentação**: Garantir que todas as referências sejam atualizadas
3. **Registrar Completamente**: Documentar o histórico completo de mudanças em `audit.md`
4. **Confirmar com o Usuário**: Verificar se as mudanças atendem às expectativas do usuário
5. **Retomar o Workflow**: Continuar com a execução normal a partir do novo estado

---

## Árvore de Decisão de Solicitação de Mudança

```
User requests change
    |
    ├─ Is it current stage?
    |   ├─ Yes: Can modify or restart current stage
    |   └─ No: Go to next question
    |
    ├─ Is it a completed stage?
    |   ├─ Yes: Assess impact on dependent stages
    |   |   ├─ Low impact: Modify and update dependents
    |   |   └─ High impact: Recommend restart from that stage
    |   └─ No: Go to next question
    |
    ├─ Is it adding a skipped stage?
    |   ├─ Yes: Check prerequisites, add to plan, execute
    |   └─ No: Go to next question
    |
    ├─ Is it skipping a planned stage?
    |   ├─ Yes: Warn about impact, get confirmation, skip
    |   └─ No: Go to next question
    |
    └─ Is it changing depth level?
        ├─ Yes: Update plan, adjust approach
        └─ No: Clarify request with user
```

---

## Requisitos de Registro

### Formato de Log de Solicitação de Mudança

```markdown
## Change Request - [Stage Name]
**Timestamp**: [ISO timestamp]
**Request**: [What user wants to change]
**Current State**: [Where we are in workflow]
**Impact Assessment**: [What will be affected]
**User Confirmation**: [User's explicit confirmation]
**Action Taken**: [What was done]
**Artifacts Affected**: [List of files changed/reset]

---
```

---

## Melhores Práticas

1. **Sempre Confirmar**: Nunca faça mudanças destrutivas sem confirmação explícita do usuário
2. **Explicar Impacto**: Os usuários precisam entender as consequências antes de decidir
3. **Oferecer Opções**: Às vezes há múltiplas formas de tratar uma mudança
4. **Arquivar Primeiro**: Sempre faça backup antes de fazer mudanças destrutivas
5. **Atualizar Tudo**: Mantenha todos os arquivos de rastreamento sincronizados
6. **Registrar Completamente**: Documente todas as mudanças para a trilha de auditoria
7. **Validar Depois**: Garanta que o workflow possa continuar suavemente
8. **Seja Flexível**: O workflow deve se adaptar às necessidades do usuário, não forçar um processo rígido
