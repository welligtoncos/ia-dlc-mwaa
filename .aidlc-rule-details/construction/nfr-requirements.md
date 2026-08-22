# Requisitos NFR

## Pré-requisitos
- Design Funcional deve estar completo para a unidade
- Artefatos de design funcional da unidade devem estar disponíveis
- O plano de execução deve indicar que o estágio de Requisitos NFR deve executar

## Visão Geral
Determinar requisitos não funcionais para a unidade e fazer escolhas de stack tecnológica.

## Etapas a Executar

### Etapa 1: Analisar Design Funcional
- Ler artefatos de design funcional de `aidlc-docs/construction/{unit-name}/functional-design/`
- Entender a complexidade e requisitos da lógica de negócio

### Etapa 2: Criar Plano de Requisitos NFR
- Gerar plano com checkboxes [] para avaliação de NFR
- Focar em escalabilidade, desempenho, disponibilidade, segurança
- Cada etapa deve ter um checkbox []

### Etapa 3: Gerar Perguntas Apropriadas ao Contexto
**DIRETIVA**: Analise cuidadosamente o design funcional para identificar TODAS as áreas onde o esclarecimento de NFR melhoraria a qualidade do sistema e as decisões de arquitetura. Seja proativo ao fazer perguntas para garantir cobertura abrangente de NFR.

**CRÍTICO**: Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente que possa afetar a qualidade do sistema. É melhor fazer perguntas demais do que fazer pressupostos incorretos de NFR.

- INCORPORE perguntas usando o formato de tag [Answer]:
- Foque em QUALQUER ambiguidade, informação ausente ou área que precise de esclarecimento
- Gere perguntas sempre que a entrada do usuário melhorar as decisões de NFR e stack tecnológica
- **Na dúvida, faça a pergunta** - o excesso de confiança leva a qualidade de sistema ruim

**Categorias de perguntas a avaliar** (considere TODAS as categorias):
- **Requisitos de Escalabilidade** - Pergunte sobre carga esperada, padrões de crescimento, gatilhos de escala e planejamento de capacidade
- **Requisitos de Desempenho** - Pergunte sobre tempos de resposta, throughput, latência e benchmarks de desempenho
- **Requisitos de Disponibilidade** - Pergunte sobre expectativas de uptime, recuperação de desastres, failover e continuidade de negócio
- **Requisitos de Segurança** - Pergunte sobre proteção de dados, conformidade, autenticação, autorização e modelos de ameaça
- **Seleção de Stack Tecnológica** - Pergunte sobre preferências de tecnologia, restrições, sistemas existentes e requisitos de integração
- **Requisitos de Confiabilidade** - Pergunte sobre tratamento de erros, tolerância a falhas, monitoramento e necessidades de alertas
- **Requisitos de Manutenibilidade** - Pergunte sobre qualidade de código, documentação, testes e requisitos operacionais
- **Requisitos de Usabilidade** - Pergunte sobre experiência do usuário, acessibilidade e requisitos de interface

### Etapa 4: Armazenar Plano
- Salvar como `aidlc-docs/construction/plans/{unit-name}-nfr-requirements-plan.md`
- Incluir todas as tags [Answer]: para entrada do usuário

### Etapa 5: Coletar e Analisar Respostas
- Aguardar o usuário completar todas as tags [Answer]:
- **OBRIGATÓRIO**: Revisar cuidadosamente TODAS as respostas em busca de respostas vagas ou ambíguas
- **CRÍTICO**: Adicionar perguntas de acompanhamento para QUALQUER resposta pouco clara - não prossiga com ambiguidade
- Procure respostas como "depende", "talvez", "não tenho certeza", "mistura de", "algo entre", "padrão", "típico"
- Criar arquivo de perguntas de esclarecimento se QUALQUER ambiguidade for detectada
- **Não prossiga até que TODAS as ambiguidades sejam resolvidas**

### Etapa 6: Gerar Artefatos de Requisitos NFR
- Criar `aidlc-docs/construction/{unit-name}/nfr-requirements/nfr-requirements.md`
- Criar `aidlc-docs/construction/{unit-name}/nfr-requirements/tech-stack-decisions.md`

### Etapa 7: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 📊 Requisitos NFR Concluídos - [unit-name]
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos dos requisitos NFR
        - Formato: "A avaliação de requisitos NFR identificou [descrição]:"
        - Listar requisitos-chave de escalabilidade, desempenho, disponibilidade (tópicos)
        - Listar requisitos de segurança e conformidade identificados
        - Mencionar decisões de stack tecnológica e justificativa
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine os requisitos NFR em: `aidlc-docs/construction/[unit-name]/nfr-requirements/`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações nos requisitos NFR com base na sua revisão  
> ✅ **Continuar para o Próximo Estágio** - Aprovar requisitos NFR e prosseguir para **[next-stage-name]**

---
```

### Etapa 8: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente os requisitos NFR
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize os requisitos e repita o processo de aprovação

### Etapa 9: Registrar Aprovação e Atualizar Progresso
- Registrar aprovação em audit.md com timestamp
- Registrar a resposta de aprovação do usuário com timestamp
- Marcar o estágio de Requisitos NFR como completo em aidlc-state.md
