# Geração de Unidades - Etapas Detalhadas

## Visão Geral
Este estágio decompõe o sistema em unidades de trabalho gerenciáveis através de duas partes integradas:
- **Parte 1 - Planejamento**: Criar plano de decomposição com perguntas, coletar respostas, analisar ambiguidades, obter aprovação
- **Parte 2 - Geração**: Executar o plano aprovado para gerar artefatos de unidades

**DEFINIÇÃO**: Uma unidade de trabalho é um agrupamento lógico de histórias para fins de desenvolvimento. Para microsserviços, cada unidade se torna um serviço implantável de forma independente. Para monólitos, a unidade única representa toda a aplicação com módulos lógicos.

**Terminologia**: Use "Serviço" para componentes implantáveis de forma independente, "Módulo" para agrupamentos lógicos dentro de um serviço, "Unidade de Trabalho" para contexto de planejamento.

## Pré-requisitos
- Detecção do Workspace deve estar completa
- Análise de Requisitos recomendada (fornece escopo funcional)
- Histórias de Usuário recomendadas (histórias mapeiam para unidades)
- Estágio de Design da Aplicação OBRIGATÓRIO (determina componentes, métodos e serviços)
- O plano de execução deve indicar que o estágio de Design deve executar

---

# PARTE 1: PLANEJAMENTO

## Etapa 1: Criar Plano de Unidade de Trabalho
- Gerar plano com checkboxes [] para decompor o sistema em unidades de trabalho
- Focar em decompor o sistema em unidades de desenvolvimento gerenciáveis
- Cada etapa e subetapa deve ter um checkbox []

## Etapa 2: Incluir Artefatos Obrigatórios de Unidades no Plano
**SEMPRE** incluir estes artefatos obrigatórios no plano de unidades:
- [ ] Gerar `aidlc-docs/inception/application-design/unit-of-work.md` com definições de unidades e responsabilidades
- [ ] Gerar `aidlc-docs/inception/application-design/unit-of-work-dependency.md` com matriz de dependências
- [ ] Gerar `aidlc-docs/inception/application-design/unit-of-work-story-map.md` mapeando histórias para unidades
- [ ] **Apenas Greenfield**: Documentar estratégia de organização de código em `unit-of-work.md` (veja code-generation.md para padrões de estrutura)
- [ ] Validar limites e dependências das unidades
- [ ] Garantir que todas as histórias sejam atribuídas a unidades

## Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente os requisitos, histórias e design da aplicação para identificar TODAS as áreas onde o esclarecimento melhoraria a qualidade da decomposição em unidades. Seja proativo ao fazer perguntas para garantir cobertura abrangente das preocupações de decomposição.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar os limites das unidades ou a qualidade da decomposição. É melhor fazer perguntas demais do que fazer pressupostos incorretos sobre como o sistema deve ser decomposto.

**OBRIGATÓRIO**: Avalie TODAS as seguintes categorias fazendo perguntas direcionadas sobre cada uma. Para cada categoria, determine a aplicabilidade com base em evidências dos requisitos, histórias e design da aplicação -- não pule categorias sem justificativa explícita:

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de decomposição
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a limites de unidades ruins

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Agrupamento de Histórias** - Pergunte sobre estratégia de agrupamento, afinidade de histórias e abordagens de agrupamento lógico
- **Dependências** - Pergunte sobre abordagem de integração, recursos compartilhados e padrões de comunicação entre unidades
- **Alinhamento da Equipe** - Pergunte sobre estrutura da equipe, limites de ownership e modelos de colaboração
- **Considerações Técnicas** - Pergunte sobre requisitos de escalabilidade/implantação que podem diferir entre unidades
- **Domínio de Negócio** - Pergunte sobre limites de domínio, bounded contexts e alinhamento com capacidades de negócio
- **Organização de Código (apenas Greenfield multi-unidade)** - Pergunte sobre modelo de implantação e preferências de estrutura de diretórios

## Etapa 4: Armazenar Plano de UOW
- Salvar como `aidlc-docs/inception/plans/unit-of-work-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário
- Garantir que o plano cubra todos os aspectos da decomposição do sistema

## Etapa 5: Solicitar Entrada do Usuário
- Pedir ao usuário para preencher as tags [Answer]: diretamente no documento do plano
- Enfatizar a importância das decisões de decomposição
- Fornecer instruções claras sobre como completar as tags [Answer]:

## Etapa 6: Coletar Respostas
- Aguardar o usuário fornecer respostas a todas as perguntas usando tags [Answer]: no documento
- Não prosseguir até que TODAS as tags [Answer]: estejam completas
- Revisar o documento para garantir que nenhuma tag [Answer]: esteja em branco

## Etapa 7: ANALISAR RESPOSTAS (OBRIGATÓRIO)
Antes de prosseguir, você DEVE revisar cuidadosamente todas as respostas do usuário em busca de:
- **Respostas vagas ou ambíguas**: "mistura de", "algo entre", "não tenho certeza", "depende"
- **Critérios ou termos indefinidos**: Referências a conceitos sem definições claras
- **Respostas contraditórias**: Respostas que conflitam entre si
- **Detalhes de geração ausentes**: Respostas que carecem de orientação específica
- **Respostas que combinam opções**: Respostas que mesclam abordagens diferentes sem regras de decisão claras

## Etapa 8: Perguntas de Acompanhamento OBRIGATÓRIAS
Se a análise na etapa 7 revelar QUALQUER resposta ambígua, você DEVE:
- Adicionar perguntas de acompanhamento específicas ao documento do plano usando tags [Answer]:
- NÃO prosseguir para aprovação até que todas as ambiguidades sejam resolvidas
- Exemplos de acompanhamentos obrigatórios:
  - "Você mencionou 'mistura de A e B' - quais critérios específicos devem determinar quando usar A vs B?"
  - "Você disse 'algo entre A e B' - pode definir a abordagem exata de meio-termo?"
  - "Você indicou 'não tenho certeza' - quais informações adicionais ajudariam você a decidir?"
  - "Você mencionou 'depende da complexidade' - como você define os níveis de complexidade?"

## Etapa 9: Solicitar Aprovação
- Perguntar: "**Plano de unidade de trabalho completo. Revise o plano em aidlc-docs/inception/plans/unit-of-work-plan.md. Pronto para prosseguir para a geração?**"
- NÃO PROSSIGA até que o usuário confirme

## Etapa 10: Registrar Aprovação
- Registrar prompt e resposta em audit.md com timestamp
- Usar formato de timestamp ISO 8601
- Incluir texto completo do prompt de aprovação

## Etapa 11: Atualizar Progresso
- Marcar Geração de Unidades Parte 1 (Planejamento) como completa em aidlc-state.md
- Atualizar a seção "Current Status"
- Preparar para a transição para Geração de Unidades Parte 2 (Geração)

---

# PARTE 2: GERAÇÃO

## Etapa 12: Carregar Plano de Unidade de Trabalho
- [ ] Ler o plano completo de `aidlc-docs/inception/plans/unit-of-work-plan.md`
- [ ] Identificar a próxima etapa não concluída (primeiro checkbox [ ])
- [ ] Carregar o contexto e requisitos para essa etapa

## Etapa 13: Executar Etapa Atual
- [ ] Realizar exatamente o que a etapa atual descreve
- [ ] Gerar artefatos de unidades conforme especificado no plano
- [ ] Seguir a abordagem de decomposição aprovada do Planejamento
- [ ] Usar os critérios e limites especificados no plano

## Etapa 14: Atualizar Progresso
- [ ] Marcar a etapa concluída como [x] no plano de unidade de trabalho
- [ ] Atualizar o status atual em `aidlc-docs/aidlc-state.md`
- [ ] Salvar todos os artefatos gerados

## Etapa 15: Continuar ou Completar
- [ ] Se mais etapas permanecerem, retornar à Etapa 12
- [ ] Se todas as etapas estiverem completas, verificar se as unidades estão prontas para os estágios de design
- [ ] Marcar o estágio de Geração de Unidades como completo

## Etapa 16: Apresentar Mensagem de Conclusão

```markdown
# 🔧 Geração de Unidades Concluída

[Resumo gerado pela IA das unidades e decomposição criadas em tópicos]

> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine os artefatos de geração de unidades em: `aidlc-docs/inception/application-design/`

> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações na geração de unidades se necessário
> ✅ **Aprovar e Continuar** - Aprovar unidades e prosseguir para **FASE DE CONSTRUCTION**
```

## Etapa 17: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente a geração de unidades
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize as unidades e repita o processo de aprovação

## Etapa 18: Registrar Resposta de Aprovação
- Registre a resposta de aprovação do usuário com timestamp em `aidlc-docs/audit.md`
- Inclua o texto exato da resposta do usuário
- Marque o status de aprovação claramente

## Etapa 19: Atualizar Progresso
- Marque o estágio de Geração de Unidades como completo em `aidlc-docs/aidlc-state.md`
- Atualize a seção "Current Status"
- Prepare para a transição para a FASE DE CONSTRUCTION

---

## Regras Críticas

### Regras da Fase de Planejamento
- Gerar APENAS perguntas relevantes ao contexto
- Usar formato de tag [Answer]: para todas as perguntas
- Analisar todas as respostas em busca de ambiguidades antes de prosseguir
- Resolver TODAS as ambiguidades com perguntas de acompanhamento
- Obter aprovação explícita do usuário antes da geração

### Regras da Fase de Geração
- **SEM LÓGICA HARDCODED**: Execute apenas o que está escrito no plano de unidade de trabalho
- **SIGA O PLANO EXATAMENTE**: Não desvie da sequência de etapas
- **ATUALIZE CHECKBOXES**: Marque [x] imediatamente após concluir cada etapa
- **USE ABORDAGEM APROVADA**: Siga a metodologia de decomposição do Planejamento
- **VERIFIQUE CONCLUSÃO**: Garanta que todos os artefatos de unidades estejam completos antes de prosseguir

## Critérios de Conclusão
- Todas as perguntas de planejamento respondidas e ambiguidades resolvidas
- Aprovação do usuário obtida para o plano
- Todas as etapas no plano de unidade de trabalho marcadas [x]
- Todos os artefatos de unidades gerados conforme o plano:
  - `unit-of-work.md` com definições de unidades
  - `unit-of-work-dependency.md` com matriz de dependências
  - `unit-of-work-story-map.md` com mapeamentos de histórias
- Unidades verificadas e prontas para os estágios de design por unidade
