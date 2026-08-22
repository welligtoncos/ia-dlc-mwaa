# Histórias de Usuário - Etapas Detalhadas

## Propósito
**Converter requisitos em histórias centradas no usuário com critérios de aceitação**

Histórias de Usuário focam em:
- Traduzir requisitos de negócio em narrativas centradas no usuário
- Definir critérios de aceitação claros para cada história
- Criar personas de usuário que representam diferentes tipos de stakeholders
- Estabelecer entendimento compartilhado entre equipes
- Fornecer especificações testáveis para implementação

## Pré-requisitos
- Detecção do Workspace deve estar completa
- Análise de Requisitos recomendada (pode referenciar requisitos se disponíveis)
- O Planejamento do Workflow deve indicar que o estágio de Histórias de Usuário deve executar

## Diretrizes de Avaliação Inteligente

**QUANDO EXECUTAR HISTÓRIAS DE USUÁRIO**: Use esta avaliação aprimorada antes de prosseguir:

### Execução de Alta Prioridade (SEMPRE Executar)
- **Novas Funcionalidades do Usuário**: Qualquer nova funcionalidade com a qual os usuários interagirão diretamente
- **Mudanças na Experiência do Usuário**: Modificações em fluxos de trabalho ou interfaces existentes do usuário
- **Sistemas Multi-Persona**: Aplicações que atendem diferentes tipos de usuários
- **APIs Voltadas ao Cliente**: Serviços que usuários ou sistemas externos consumirão
- **Lógica de Negócio Complexa**: Requisitos com múltiplos cenários ou regras de negócio
- **Projetos Entre Equipes**: Trabalho que exige entendimento compartilhado entre múltiplas equipes

### Execução de Prioridade Média (Avaliar Complexidade)
- **Impacto no Usuário via Backend**: Mudanças internas que afetam indiretamente a experiência do usuário
- **Melhorias de Desempenho**: Aprimoramentos com benefícios visíveis ao usuário
- **Trabalho de Integração**: Conectar sistemas que afetam fluxos de trabalho do usuário
- **Mudanças de Dados**: Modificações que afetam dados, relatórios ou analytics do usuário
- **Aprimoramentos de Segurança**: Mudanças que afetam autenticação ou permissões do usuário

### Fatores de Avaliação de Complexidade
Para casos de prioridade média, execute histórias de usuário se QUALQUER destes se aplicar:
- **Escopo**: Mudanças abrangem múltiplos componentes ou pontos de contato do usuário
- **Ambiguidade**: Requisitos têm aspectos pouco claros que as histórias poderiam esclarecer
- **Risco**: Alto impacto de negócio ou potencial de mal-entendido
- **Stakeholders**: Múltiplos stakeholders de negócio envolvidos nos requisitos
- **Testes**: Testes de aceitação do usuário serão necessários
- **Opções**: Múltiplas abordagens válidas de implementação existem

### Pular Apenas Para Casos Simples
- **Refatoração Pura**: Melhorias internas de código com zero impacto no usuário
- **Correções de Bug Isoladas**: Correções simples e bem definidas com escopo claro
- **Apenas Infraestrutura**: Mudanças sem efeitos voltados ao usuário
- **Ferramentas de Desenvolvedor**: Processos de build, CI/CD ou mudanças no ambiente de desenvolvimento
- **Documentação**: Atualizações que não afetam a funcionalidade

### Regra de Decisão Padrão
**Na dúvida, inclua histórias de usuário E faça perguntas de esclarecimento.** O overhead de criar histórias abrangentes com esclarecimento adequado é tipicamente superado pelos benefícios de:
- Entendimento mais claro dos requisitos
- Melhor alinhamento da equipe
- Critérios de teste aprimorados
- Comunicação aprimorada com stakeholders
- Riscos de implementação reduzidos
- Menos mudanças custosas durante o desenvolvimento
- Melhores resultados de experiência do usuário

---

# PARTE 1: PLANEJAMENTO

## Etapa 1: Validar Necessidade de Histórias de Usuário (OBRIGATÓRIO)

**CRÍTICO**: Antes de prosseguir com histórias de usuário, realize esta avaliação:

### Processo de Avaliação
1. **Analisar Contexto da Solicitação**:
   - Revisar a solicitação original do usuário e os requisitos
   - Identificar mudanças voltadas ao usuário vs apenas internas
   - Avaliar complexidade e escopo do trabalho
   - Avaliar envolvimento de stakeholders de negócio

2. **Aplicar Critérios de Avaliação**:
   - Verificar contra indicadores de Alta Prioridade (sempre executar)
   - Avaliar fatores de Prioridade Média (decisão baseada em complexidade)
   - Confirmar que este não é um caso simples que deve ser pulado

3. **Documentar Decisão da Avaliação**:
   - Criar `aidlc-docs/inception/plans/user-stories-assessment.md`
   - Incluir o raciocínio de por que as histórias de usuário são valiosas para esta solicitação
   - Referenciar critérios específicos de avaliação que se aplicam
   - Explicar benefícios esperados (clareza, testes, alinhamento de stakeholders)

4. **Prosseguir Apenas Se Justificado**:
   - Histórias de usuário devem agregar valor claro ao projeto
   - A avaliação deve mostrar que benefícios concretos superam o overhead
   - A decisão deve ser defensável perante os stakeholders do projeto

### Template de Documentação da Avaliação
```markdown
# User Stories Assessment

## Request Analysis
- **Original Request**: [Brief summary]
- **User Impact**: [Direct/Indirect/None]
- **Complexity Level**: [Simple/Medium/Complex]
- **Stakeholders**: [List involved parties]

## Assessment Criteria Met
- [ ] High Priority: [List applicable criteria]
- [ ] Medium Priority: [List applicable criteria with complexity justification]
- [ ] Benefits: [Expected value from user stories]

## Decision
**Execute User Stories**: [Yes/No]
**Reasoning**: [Detailed justification]

## Expected Outcomes
- [List specific benefits user stories will provide]
- [How stories will improve project success]
```

## Etapa 2: Criar Plano de Histórias
- Assumir o papel de um product owner
- Gerar um plano abrangente com checklist de execução passo a passo para desenvolvimento de histórias
- Cada etapa e subetapa deve ter um checkbox []
- Focar na metodologia e abordagem para converter requisitos em histórias de usuário

## Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente os requisitos e o contexto para identificar TODAS as áreas onde o esclarecimento melhoraria a qualidade das histórias e o entendimento da equipe. Seja proativo ao fazer perguntas para garantir o desenvolvimento abrangente de histórias de usuário.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar a qualidade das histórias. É melhor fazer perguntas demais do que criar histórias incompletas ou pouco claras.

**Veja `common/question-format-guide.md` para regras de formatação de perguntas**

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de criação de histórias
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a histórias ruins

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Personas de Usuário** - Pergunte sobre tipos de usuário, papéis, características e motivações
- **Granularidade das Histórias** - Pergunte sobre nível apropriado de detalhe, tamanho das histórias e abordagem de decomposição
- **Formato das Histórias** - Pergunte sobre preferências de formato, uso de templates e padrões de documentação
- **Abordagem de Decomposição** - Pergunte sobre método de organização, priorização e estratégias de agrupamento
- **Critérios de Aceitação** - Pergunte sobre nível de detalhe, formato, abordagem de testes e métodos de validação
- **Jornadas do Usuário** - Pergunte sobre fluxos de trabalho do usuário, padrões de interação e fluxos de experiência
- **Contexto de Negócio** - Pergunte sobre objetivos de negócio, métricas de sucesso e necessidades dos stakeholders
- **Restrições Técnicas** - Pergunte sobre limitações técnicas, requisitos de integração e limites do sistema

## Etapa 4: Incluir Artefatos Obrigatórios de Histórias no Plano
- **SEMPRE** incluir estes artefatos obrigatórios no plano de histórias:
  - [ ] Gerar stories.md com histórias de usuário seguindo critérios INVEST
  - [ ] Gerar personas.md com arquétipos de usuário e características
  - [ ] Garantir que as histórias sejam Independent, Negotiable, Valuable, Estimable, Small, Testable
  - [ ] Incluir critérios de aceitação para cada história
  - [ ] Mapear personas para histórias de usuário relevantes

## Etapa 5: Apresentar Opções de Histórias
- Incluir diferentes abordagens para decomposição de histórias no documento do plano:
  - **Baseada em Jornada do Usuário**: Histórias seguem fluxos de trabalho e interações do usuário
  - **Baseada em Funcionalidade**: Histórias organizadas em torno de funcionalidades e capacidades do sistema
  - **Baseada em Persona**: Histórias agrupadas por diferentes tipos de usuário e suas necessidades
  - **Baseada em Domínio**: Histórias organizadas em torno de domínios ou contextos de negócio
  - **Baseada em Epic**: Histórias estruturadas como epics hierárquicos com sub-histórias
- Explicar trade-offs e benefícios de cada abordagem
- Permitir abordagens híbridas com critérios claros de decisão

## Etapa 6: Armazenar Plano de Histórias
- Salvar o plano completo de histórias com perguntas embutidas no diretório `aidlc-docs/inception/plans/`
- Nome do arquivo: `story-generation-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário
- Garantir que o plano seja abrangente e cubra todos os aspectos do desenvolvimento de histórias

## Etapa 7: Solicitar Entrada do Usuário
- Pedir ao usuário para preencher todas as tags [Answer]: diretamente no documento do plano de histórias
- Enfatizar a importância da trilha de auditoria e documentação de decisões
- Fornecer instruções claras sobre como preencher as tags [Answer]:
- Explicar que todas as perguntas devem ser respondidas antes de prosseguir

## Etapa 8: Coletar Respostas
- Aguardar o usuário fornecer respostas a todas as perguntas usando tags [Answer]: no documento
- Não prosseguir até que TODAS as tags [Answer]: estejam completas
- Revisar o documento para garantir que nenhuma tag [Answer]: esteja em branco

## Etapa 9: ANALISAR RESPOSTAS (OBRIGATÓRIO)
Antes de prosseguir, você DEVE revisar cuidadosamente todas as respostas do usuário em busca de:
- **Respostas vagas ou ambíguas**: "mistura de", "algo entre", "não tenho certeza", "depende", "talvez", "provavelmente"
- **Critérios ou termos indefinidos**: Referências a conceitos sem definições claras
- **Respostas contraditórias**: Respostas que conflitam entre si
- **Detalhes de geração ausentes**: Respostas que carecem de orientação específica para implementação
- **Respostas que combinam opções**: Respostas que mesclam abordagens diferentes sem regras de decisão claras
- **Explicações incompletas**: Respostas que referenciam fatores externos sem defini-los
- **Respostas baseadas em pressupostos**: Respostas que pressupõem conhecimento não explicitamente declarado

## Etapa 10: Perguntas de Acompanhamento OBRIGATÓRIAS
Se a análise na etapa 9 revelar QUALQUER resposta ambígua, você DEVE:
- Criar um arquivo separado de perguntas de esclarecimento usando tags [Answer]:
- NÃO prosseguir para aprovação até que TODAS as ambiguidades sejam completamente resolvidas
- **CRÍTICO**: Seja minucioso - faça perguntas de acompanhamento para cada resposta pouco clara
- Exemplos de acompanhamentos obrigatórios:
  - "Você mencionou 'mistura de A e B' - quais critérios específicos devem determinar quando usar A vs B?"
  - "Você disse 'algo entre A e B' - pode definir a abordagem exata de meio-termo?"
  - "Você indicou 'não tenho certeza' - quais informações adicionais ajudariam você a decidir?"
  - "Você mencionou 'depende da complexidade' - como você define níveis de complexidade e limiares?"
  - "Você escolheu 'abordagem híbrida' - quais são as regras específicas para quando usar cada método?"
  - "Você disse 'provavelmente X' - quais fatores fariam ser definitivamente X vs definitivamente não X?"
  - "Você referenciou 'prática padrão' - pode definir o que é essa prática padrão?"

## Etapa 11: Evitar Detalhes de Implementação
- Foque na metodologia de criação de histórias, não em priorização ou tarefas de desenvolvimento
- Não discuta geração técnica neste estágio
- Evite criar cronogramas de desenvolvimento ou planejamento de sprints
- Mantenha o foco nas decisões de estrutura e formato das histórias

## Etapa 12: Registrar Prompt de Aprovação
- Antes de pedir aprovação, registre o prompt com timestamp em `aidlc-docs/audit.md`
- Inclua o texto completo do prompt de aprovação
- Use formato de timestamp ISO 8601

## Etapa 13: Aguardar Aprovação Explícita do Plano
- Não prossiga até que o usuário aprove explicitamente a abordagem de histórias
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize o plano e repita o processo de aprovação

## Etapa 14: Registrar Resposta de Aprovação
- Registre a resposta de aprovação do usuário com timestamp em `aidlc-docs/audit.md`
- Inclua o texto exato da resposta do usuário
- Marque o status de aprovação claramente

---

# PARTE 2: GERAÇÃO

## Etapa 15: Carregar Plano de Geração de Histórias
- [ ] Ler o plano completo de histórias de `aidlc-docs/inception/plans/story-generation-plan.md`
- [ ] Identificar a próxima etapa não concluída (primeiro checkbox [ ])
- [ ] Carregar o contexto e requisitos para essa etapa

## Etapa 16: Executar Etapa Atual
- [ ] Realizar exatamente o que a etapa atual descreve
- [ ] Gerar artefatos de histórias conforme especificado no plano
- [ ] Seguir a metodologia e formato aprovados do Planejamento
- [ ] Usar a abordagem de decomposição de histórias especificada no plano

## Etapa 17: Atualizar Progresso
- [ ] Marcar a etapa concluída como [x] no plano de geração de histórias
- [ ] Atualizar o status atual em `aidlc-docs/aidlc-state.md`
- [ ] Salvar todos os artefatos gerados

## Etapa 18: Continuar ou Completar Geração
- [ ] Se mais etapas permanecerem, retornar à Etapa 15
- [ ] Se todas as etapas estiverem completas, verificar se as histórias estão prontas para o próximo estágio
- [ ] Garantir que todos os artefatos obrigatórios sejam gerados

## Etapa 19: Registrar Prompt de Aprovação
- Antes de pedir aprovação, registre o prompt com timestamp em `aidlc-docs/audit.md`
- Inclua o texto completo do prompt de aprovação
- Use formato de timestamp ISO 8601

## Etapa 20: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 📚 Histórias de Usuário Concluídas
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos das histórias geradas
        - Formato: "A geração de histórias de usuário criou [descrição]:"
        - Listar personas-chave geradas (tópicos)
        - Listar histórias de usuário criadas com contagens e organização
        - Mencionar estrutura das histórias e conformidade (critérios INVEST, critérios de aceitação)
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine as histórias de usuário e personas em: `aidlc-docs/inception/user-stories/stories.md` e `aidlc-docs/inception/user-stories/personas.md`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações nas histórias ou personas com base na sua revisão  
> ✅ **Aprovar e Continuar** - Aprovar histórias de usuário e prosseguir para **Planejamento do Workflow**

---
```

## Etapa 21: Aguardar Aprovação Explícita das Histórias Geradas
- Não prossiga até que o usuário aprove explicitamente as histórias geradas
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize as histórias e repita o processo de aprovação

## Etapa 22: Registrar Resposta de Aprovação
- Registre a resposta de aprovação do usuário com timestamp em `aidlc-docs/audit.md`
- Inclua o texto exato da resposta do usuário
- Marque o status de aprovação claramente

## Etapa 23: Atualizar Progresso
- Marque o estágio de Histórias de Usuário como completo em `aidlc-state.md`
- Atualize a seção "Current Status"
- Prepare para a transição para o próximo estágio

---

# REGRAS CRÍTICAS

## Regras da Fase de Planejamento
- **PERGUNTAS APROPRIADAS AO CONTEXTO**: Faça apenas perguntas relevantes a este contexto específico
- **ANÁLISE OBRIGATÓRIA DE RESPOSTAS**: Sempre analise as respostas em busca de ambiguidades antes de prosseguir
- **NÃO PROSSEGUIR COM AMBIGUIDADE**: Deve resolver todas as respostas vagas antes da geração
- **APROVAÇÃO EXPLÍCITA OBRIGATÓRIA**: O usuário deve aprovar o plano antes do início da geração

## Regras da Fase de Geração
- **SEM LÓGICA HARDCODED**: Execute apenas o que está escrito no plano de geração de histórias
- **SIGA O PLANO EXATAMENTE**: Não desvie da sequência de etapas
- **ATUALIZE CHECKBOXES**: Marque [x] imediatamente após concluir cada etapa
- **USE METODOLOGIA APROVADA**: Siga a abordagem de histórias do Planejamento
- **VERIFIQUE CONCLUSÃO**: Garanta que todos os artefatos de histórias estejam completos antes de prosseguir

## Critérios de Conclusão
- Todas as perguntas de planejamento respondidas e ambiguidades resolvidas
- Plano de histórias explicitamente aprovado pelo usuário
- Todas as etapas no plano de geração de histórias marcadas [x]
- Todos os artefatos de histórias gerados conforme o plano (stories.md, personas.md)
- Histórias geradas explicitamente aprovadas pelo usuário
- Histórias verificadas e prontas para o próximo estágio
