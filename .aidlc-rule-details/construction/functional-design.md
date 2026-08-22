# Design Funcional

## Propósito
**Design detalhado da lógica de negócio por unidade**

O Design Funcional foca em:
- Lógica de negócio detalhada e algoritmos para a unidade
- Modelos de domínio com entidades e relacionamentos
- Regras de negócio detalhadas, lógica de validação e restrições
- Design agnóstico à tecnologia (sem preocupações de infraestrutura)

**Nota**: Isto se baseia no design de componentes de alto nível do Design da Aplicação (fase de INCEPTION)

## Pré-requisitos
- Geração de Unidades deve estar completa
- Artefatos de unidade de trabalho devem estar disponíveis
- Design da Aplicação recomendado (fornece estrutura de componentes de alto nível)
- O plano de execução deve indicar que o estágio de Design Funcional deve executar

## Visão Geral
Projetar lógica de negócio detalhada para a unidade, agnóstica à tecnologia e focada puramente em funções de negócio.

## Etapas a Executar

### Etapa 1: Analisar Contexto da Unidade
- Ler definição da unidade de `aidlc-docs/inception/application-design/unit-of-work.md`
- Ler histórias atribuídas de `aidlc-docs/inception/application-design/unit-of-work-story-map.md`
- Entender responsabilidades e limites da unidade

### Etapa 2: Criar Plano de Design Funcional
- Gerar plano com checkboxes [] para o design funcional
- Focar em lógica de negócio, modelos de domínio, regras de negócio
- Cada etapa deve ter um checkbox []

### Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente a definição da unidade e os artefatos de design funcional para identificar TODAS as áreas onde o esclarecimento melhoraria o design funcional. Seja proativo ao fazer perguntas para garantir entendimento abrangente.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar a qualidade do design funcional. É melhor fazer perguntas demais do que fazer pressupostos incorretos.

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de design funcional
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a designs ruins

**Categorias de perguntas a considerar** (avalie TODAS as categorias):
- **Modelagem de Lógica de Negócio** - Pergunte sobre entidades principais, fluxos de trabalho, transformações de dados e processos de negócio
- **Modelo de Domínio** - Pergunte sobre conceitos de domínio, relacionamentos de entidades, estruturas de dados e objetos de negócio
- **Regras de Negócio** - Pergunte sobre regras de decisão, lógica de validação, restrições e políticas de negócio
- **Fluxo de Dados** - Pergunte sobre entradas, saídas, transformações e requisitos de persistência de dados
- **Pontos de Integração** - Pergunte sobre interações com sistemas externos, APIs e troca de dados
- **Tratamento de Erros** - Pergunte sobre cenários de erro, falhas de validação e tratamento de exceções
- **Cenários de Negócio** - Pergunte sobre casos extremos, fluxos alternativos e situações de negócio complexas
- **Componentes Frontend** (se aplicável) - Pergunte sobre estrutura de componentes de UI, interações do usuário, gerenciamento de estado e tratamento de formulários

### Etapa 4: Armazenar Plano
- Salvar como `aidlc-docs/construction/plans/{unit-name}-functional-design-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário

### Etapa 5: Coletar e Analisar Respostas
- Aguardar o usuário completar todas as tags [Answer]:
- **OBRIGATÓRIO**: Revisar cuidadosamente TODAS as respostas em busca de respostas vagas ou ambíguas
- **CRÍTICO**: Adicionar perguntas de acompanhamento para QUALQUER resposta pouco clara - não prossiga com ambiguidade
- Procure respostas como "depende", "talvez", "não tenho certeza", "mistura de", "algo entre"
- Criar arquivo de perguntas de esclarecimento se QUALQUER ambiguidade for detectada
- **Não prossiga até que TODAS as ambiguidades sejam resolvidas**

### Etapa 6: Gerar Artefatos de Design Funcional
- Criar `aidlc-docs/construction/{unit-name}/functional-design/business-logic-model.md`
- Criar `aidlc-docs/construction/{unit-name}/functional-design/business-rules.md`
- Criar `aidlc-docs/construction/{unit-name}/functional-design/domain-entities.md`
- Se a unidade incluir frontend/UI: Criar `aidlc-docs/construction/{unit-name}/functional-design/frontend-components.md`
  - Hierarquia e estrutura de componentes
  - Definições de props e state para cada componente
  - Fluxos de interação do usuário
  - Regras de validação de formulários
  - Pontos de integração com API (quais endpoints de backend cada componente usa)

### Etapa 7: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 🔧 Design Funcional Concluído - [unit-name]
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos do design funcional
        - Formato: "O design funcional criou [descrição]:"
        - Listar modelos e entidades-chave de lógica de negócio (tópicos)
        - Listar regras de negócio e lógica de validação definidas
        - Mencionar estrutura do modelo de domínio e relacionamentos
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine os artefatos de design funcional em: `aidlc-docs/construction/[unit-name]/functional-design/`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações no design funcional com base na sua revisão  
> ✅ **Continuar para o Próximo Estágio** - Aprovar design funcional e prosseguir para **[next-stage-name]**

---
```

### Etapa 8: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente o design funcional
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize o design e repita o processo de aprovação

### Etapa 9: Registrar Aprovação e Atualizar Progresso
- Registrar aprovação em audit.md com timestamp
- Registrar a resposta de aprovação do usuário com timestamp
- Marcar o estágio de Design Funcional como completo em aidlc-state.md
