# Design NFR

## Pré-requisitos
- Requisitos NFR devem estar completos para a unidade
- Artefatos de requisitos NFR devem estar disponíveis
- O plano de execução deve indicar que o estágio de Design NFR deve executar

## Visão Geral
Incorporar requisitos NFR no design da unidade usando padrões e componentes lógicos.

## Etapas a Executar

### Etapa 1: Analisar Requisitos NFR
- Ler requisitos NFR de `aidlc-docs/construction/{unit-name}/nfr-requirements/`
- Entender necessidades de escalabilidade, desempenho, disponibilidade, segurança

### Etapa 2: Criar Plano de Design NFR
- Gerar plano com checkboxes [] para o design NFR
- Focar em padrões de design e componentes lógicos
- Cada etapa deve ter um checkbox []

### Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente os requisitos NFR para identificar TODAS as áreas onde o esclarecimento melhoraria a qualidade do design NFR. Seja proativo ao fazer perguntas para garantir cobertura abrangente de design não funcional.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar a qualidade do design NFR. É melhor fazer perguntas demais do que fazer pressupostos incorretos sobre padrões não funcionais.

**OBRIGATÓRIO**: Avalie TODAS as seguintes categorias fazendo perguntas direcionadas sobre cada uma. Para cada categoria, determine a aplicabilidade com base em evidências dos requisitos NFR -- não pule categorias sem justificativa explícita:

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de padrões e componentes
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a designs não funcionais ruins

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Padrões de Resiliência** - Pergunte sobre abordagem de tolerância a falhas, estratégias de retry e expectativas de recuperação de falhas
- **Padrões de Escalabilidade** - Pergunte sobre mecanismos de escala, limites de carga e projeções de crescimento
- **Padrões de Desempenho** - Pergunte sobre estratégia de otimização, alvos de latência e requisitos de throughput
- **Padrões de Segurança** - Pergunte sobre abordagem de implementação de segurança, modelo de ameaça e restrições de conformidade
- **Componentes Lógicos** - Pergunte sobre componentes de infraestrutura (filas, caches, circuit breakers, etc.) e seus padrões de integração

### Etapa 4: Armazenar Plano
- Salvar como `aidlc-docs/construction/plans/{unit-name}-nfr-design-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário

### Etapa 5: Coletar e Analisar Respostas
- Aguardar o usuário completar todas as tags [Answer]:
- Revisar respostas vagas ou ambíguas
- Adicionar perguntas de acompanhamento se necessário

### Etapa 6: Gerar Artefatos de Design NFR
- Criar `aidlc-docs/construction/{unit-name}/nfr-design/nfr-design-patterns.md`
- Criar `aidlc-docs/construction/{unit-name}/nfr-design/logical-components.md`

### Etapa 7: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 🎨 Design NFR Concluído - [unit-name]
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos do design NFR
        - Formato: "O design NFR incorporou [descrição]:"
        - Listar padrões-chave de design implementados (tópicos)
        - Listar componentes lógicos e elementos de infraestrutura
        - Mencionar padrões de resiliência, escalabilidade e desempenho aplicados
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine o design NFR em: `aidlc-docs/construction/[unit-name]/nfr-design/`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações no design NFR com base na sua revisão  
> ✅ **Continuar para o Próximo Estágio** - Aprovar design NFR e prosseguir para **[next-stage-name]**

---
```

### Etapa 8: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente o design NFR
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize o design e repita o processo de aprovação

### Etapa 9: Registrar Aprovação e Atualizar Progresso
- Registrar aprovação em audit.md com timestamp
- Registrar a resposta de aprovação do usuário com timestamp
- Marcar o estágio de Design NFR como completo em aidlc-state.md
