# Design de Infraestrutura

## Pré-requisitos
- Design Funcional deve estar completo para a unidade
- Design NFR recomendado (fornece componentes lógicos para mapear)
- O plano de execução deve indicar que o estágio de Design de Infraestrutura deve executar

## Visão Geral
Mapear componentes lógicos de software para escolhas reais de infraestrutura para ambientes de implantação.

## Etapas a Executar

### Etapa 1: Analisar Artefatos de Design
- Ler design funcional de `aidlc-docs/construction/{unit-name}/functional-design/`
- Ler design NFR de `aidlc-docs/construction/{unit-name}/nfr-design/` (se existir)
- Identificar componentes lógicos que precisam de infraestrutura

### Etapa 2: Criar Plano de Design de Infraestrutura
- Gerar plano com checkboxes [] para o design de infraestrutura
- Focar em mapeamento para serviços reais (AWS, Azure, GCP, on-premise)
- Cada etapa deve ter um checkbox []

### Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente o design funcional e NFR para identificar TODAS as áreas onde o esclarecimento melhoraria as decisões de infraestrutura. Seja proativo ao fazer perguntas para garantir cobertura abrangente de infraestrutura.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar a qualidade da infraestrutura. É melhor fazer perguntas demais do que fazer pressupostos incorretos de infraestrutura.

**OBRIGATÓRIO**: Avalie TODAS as seguintes categorias fazendo perguntas direcionadas sobre cada uma. Para cada categoria, determine a aplicabilidade com base em evidências dos artefatos de design funcional e NFR -- não pule categorias sem justificativa explícita:

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de infraestrutura
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a escolhas ruins de infraestrutura

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Ambiente de Implantação** - Pergunte sobre preferências de provedor de nuvem, configuração de ambiente e alvos de implantação
- **Infraestrutura de Computação** - Pergunte sobre escolhas de serviços de compute, dimensionamento e requisitos de escala
- **Infraestrutura de Armazenamento** - Pergunte sobre seleção de banco de dados, padrões de armazenamento e necessidades de ciclo de vida de dados
- **Infraestrutura de Mensageria** - Pergunte sobre serviços de messaging/queuing, padrões event-driven e processamento assíncrono
- **Infraestrutura de Rede** - Pergunte sobre load balancing, abordagem de API gateway e topologia de rede
- **Infraestrutura de Monitoramento** - Pergunte sobre ferramentas de observabilidade, estratégia de alertas e requisitos de logging
- **Infraestrutura Compartilhada** - Pergunte sobre estratégia de compartilhamento de infraestrutura, multi-tenancy e isolamento de recursos

### Etapa 4: Armazenar Plano
- Salvar como `aidlc-docs/construction/plans/{unit-name}-infrastructure-design-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário

### Etapa 5: Coletar e Analisar Respostas
- Aguardar o usuário completar todas as tags [Answer]:
- Revisar respostas vagas ou ambíguas
- Adicionar perguntas de acompanhamento se necessário

### Etapa 6: Gerar Artefatos de Design de Infraestrutura
- Criar `aidlc-docs/construction/{unit-name}/infrastructure-design/infrastructure-design.md`
- Criar `aidlc-docs/construction/{unit-name}/infrastructure-design/deployment-architecture.md`
- Se infraestrutura compartilhada: Criar `aidlc-docs/construction/shared-infrastructure.md`

### Etapa 7: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 🏢 Design de Infraestrutura Concluído - [unit-name]
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos do design de infraestrutura
        - Formato: "O design de infraestrutura mapeou [descrição]:"
        - Listar serviços e componentes-chave de infraestrutura (tópicos)
        - Listar decisões de arquitetura de implantação e justificativa
        - Mencionar escolhas de provedor de nuvem e mapeamentos de serviços
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine o design de infraestrutura em: `aidlc-docs/construction/[unit-name]/infrastructure-design/`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações no design de infraestrutura com base na sua revisão  
> ✅ **Continuar para o Próximo Estágio** - Aprovar design de infraestrutura e prosseguir para **Geração de Código**

---
```

### Etapa 8: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente o design de infraestrutura
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize o design e repita o processo de aprovação

### Etapa 9: Registrar Aprovação e Atualizar Progresso
- Registrar aprovação em audit.md com timestamp
- Registrar a resposta de aprovação do usuário com timestamp
- Marcar o estágio de Design de Infraestrutura como completo em aidlc-state.md
