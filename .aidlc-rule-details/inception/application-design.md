# Design da Aplicação - Etapas Detalhadas

## Propósito
**Identificação de componentes de alto nível e design da camada de serviço**

O Design da Aplicação foca em:
- Identificar os principais componentes funcionais e suas responsabilidades
- Definir interfaces dos componentes (não lógica de negócio detalhada)
- Projetar a camada de serviço para orquestração
- Estabelecer dependências de componentes e padrões de comunicação

**Nota**: O design detalhado da lógica de negócio acontece depois no Design Funcional (por unidade, fase de CONSTRUCTION)

## Pré-requisitos
- Detecção do Workspace deve estar completa
- Análise de Requisitos recomendada (fornece contexto funcional)
- Histórias de Usuário recomendadas (histórias de usuário guiam decisões de design)
- O plano de execução deve indicar que o estágio de Design da Aplicação deve executar

## Execução Passo a Passo

### 1. Analisar Contexto
- Ler `aidlc-docs/inception/requirements/requirements.md` e `aidlc-docs/inception/user-stories/stories.md`
- Identificar capacidades de negócio-chave e áreas funcionais
- Determinar escopo e complexidade do design

### 2. Criar Plano de Design da Aplicação
- Gerar plano com checkboxes [] para o design da aplicação
- Focar em componentes, responsabilidades, métodos, regras de negócio e serviços
- Cada etapa e subetapa deve ter um checkbox []

### 3. Incluir Artefatos Obrigatórios de Design no Plano
- **SEMPRE** incluir estes artefatos obrigatórios no plano de design:
  - [ ] Gerar components.md com definições de componentes e responsabilidades de alto nível
  - [ ] Gerar component-methods.md com assinaturas de métodos (regras de negócio detalhadas depois no Design Funcional)
  - [ ] Gerar services.md com definições de serviços e padrões de orquestração
  - [ ] Gerar component-dependency.md com relacionamentos de dependência e padrões de comunicação
  - [ ] Validar completude e consistência do design

### 4. Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise os requisitos e histórias para gerar perguntas relevantes a ESTE design específico da aplicação. Use as categorias abaixo como orientação. Avalie cada categoria e, na dúvida sobre aplicabilidade, faça a pergunta em vez de pulá-la — o excesso de confiança leva a resultados ruins (veja overconfidence-prevention.md).

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de design
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a designs ruins

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Identificação de Componentes** - Pergunte sobre limites de componentes, organização e estratégias de agrupamento
- **Métodos de Componentes** - Pergunte sobre assinaturas de métodos, expectativas de entrada/saída e contratos de interface (regras de negócio detalhadas vêm depois)
- **Design da Camada de Serviço** - Pergunte sobre orquestração de serviços, limites e padrões de coordenação
- **Dependências de Componentes** - Pergunte sobre padrões de comunicação, gerenciamento de dependências e preocupações de acoplamento
- **Padrões de Design** - Pergunte sobre preferências de estilo arquitetural, escolhas de padrões e restrições de design

### 5. Armazenar Plano de Design da Aplicação
- Salvar como `aidlc-docs/inception/plans/application-design-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário
- Garantir que o plano cubra todos os aspectos do design

### 6. Solicitar Entrada do Usuário
- Pedir ao usuário para preencher as tags [Answer]: diretamente no documento do plano
- Enfatizar a importância das decisões de design
- Fornecer instruções claras sobre como completar as tags [Answer]:

### 7. Coletar Respostas
- Aguardar o usuário fornecer respostas a todas as perguntas usando tags [Answer]: no documento
- Não prosseguir até que TODAS as tags [Answer]: estejam completas
- Revisar o documento para garantir que nenhuma tag [Answer]: esteja em branco

### 8. ANALISAR RESPOSTAS (OBRIGATÓRIO)
Antes de prosseguir, você DEVE revisar cuidadosamente todas as respostas do usuário em busca de:
- **Respostas vagas ou ambíguas**: "mistura de", "algo entre", "não tenho certeza", "depende"
- **Critérios ou termos indefinidos**: Referências a conceitos sem definições claras
- **Respostas contraditórias**: Respostas que conflitam entre si
- **Detalhes de design ausentes**: Respostas que carecem de orientação específica
- **Respostas que combinam opções**: Respostas que mesclam abordagens diferentes sem regras de decisão claras

### 9. Perguntas de Acompanhamento OBRIGATÓRIAS
Se a análise na etapa 8 revelar QUALQUER resposta ambígua, você DEVE:
- Adicionar perguntas de acompanhamento específicas ao documento do plano usando tags [Answer]:
- NÃO prosseguir para aprovação até que todas as ambiguidades sejam resolvidas
- Exemplos de acompanhamentos obrigatórios:
  - "Você mencionou 'mistura de A e B' - quais critérios específicos devem determinar quando usar A vs B?"
  - "Você disse 'algo entre A e B' - pode definir a abordagem exata de meio-termo?"
  - "Você indicou 'não tenho certeza' - quais informações adicionais ajudariam você a decidir?"
  - "Você mencionou 'depende da complexidade' - como você define os níveis de complexidade?"

### 10. Gerar Artefatos de Design da Aplicação
- Executar o plano aprovado para gerar artefatos de design
- Criar `aidlc-docs/inception/application-design/components.md` com:
  - Nome e propósito do componente
  - Responsabilidades do componente
  - Interfaces do componente
- Criar `aidlc-docs/inception/application-design/component-methods.md` com:
  - Assinaturas de métodos para cada componente
  - Propósito de alto nível de cada método
  - Tipos de entrada/saída
  - Nota: Regras de negócio detalhadas serão definidas no Design Funcional (por unidade, fase de CONSTRUCTION)
- Criar `aidlc-docs/inception/application-design/services.md` com:
  - Definições de serviços
  - Responsabilidades dos serviços
  - Interações e orquestração dos serviços
- Criar `aidlc-docs/inception/application-design/component-dependency.md` com:
  - Matriz de dependências mostrando relacionamentos
  - Padrões de comunicação entre componentes
  - Diagramas de fluxo de dados
- Criar `aidlc-docs/inception/application-design/application-design.md` que consolida os múltiplos documentos de design criados acima em um único doc.

### 11. Registrar Aprovação
- Registrar prompt de aprovação com timestamp em `aidlc-docs/audit.md`
- Incluir texto completo do prompt de aprovação
- Usar formato de timestamp ISO 8601

### 12. Apresentar Mensagem de Conclusão

```markdown
# 🏗️ Design da Aplicação Concluído

[Resumo gerado pela IA dos artefatos de design da aplicação criados em tópicos]

> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine os artefatos de design da aplicação em: `aidlc-docs/inception/application-design/`

> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações no design da aplicação se necessário
> [SE Geração de Unidades for pulada:]
> 📝 **Adicionar Geração de Unidades** - Escolher incluir o estágio de **Geração de Unidades** (atualmente pulado)
> ✅ **Aprovar e Continuar** - Aprovar design e prosseguir para **[Geração de Unidades/FASE DE CONSTRUCTION]**
```

### 13. Aguardar Aprovação Explícita
- Não prosseguir até que o usuário aprove explicitamente o design da aplicação
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualizar o design e repetir o processo de aprovação

### 14. Registrar Resposta de Aprovação
- Registrar a resposta de aprovação do usuário com timestamp em `aidlc-docs/audit.md`
- Incluir o texto exato da resposta do usuário
- Marcar o status de aprovação claramente

### 15. Atualizar Progresso
- Marcar o estágio de Design da Aplicação como completo em `aidlc-docs/aidlc-state.md`
- Atualizar a seção "Current Status"
- Preparar para a transição para o próximo estágio
