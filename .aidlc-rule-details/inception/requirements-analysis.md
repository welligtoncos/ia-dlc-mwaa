# Análise de Requisitos (Adaptativa)

**Assuma o papel** de um product owner

**Fase Adaptativa**: Sempre executa. O nível de detalhe se adapta à complexidade do problema.

**Veja [depth-levels.md](../common/depth-levels.md) para explicação da profundidade adaptativa**

## Pré-requisitos
- Detecção do Workspace deve estar completa
- Engenharia Reversa deve estar completa (se brownfield)

## Etapas de Execução

### Etapa 1: Carregar Contexto de Engenharia Reversa (se disponível)

**SE projeto brownfield**:
- Carregar `aidlc-docs/inception/reverse-engineering/architecture.md`
- Carregar `aidlc-docs/inception/reverse-engineering/component-inventory.md`
- Carregar `aidlc-docs/inception/reverse-engineering/technology-stack.md`
- Usar estes para entender o sistema existente ao analisar a solicitação

### Etapa 2: Analisar Solicitação do Usuário (Análise de Intenção)

#### 2.1 Clareza da Solicitação
- **Clara**: Específica, bem definida, acionável
- **Vaga**: Geral, ambígua, precisa de esclarecimento
- **Incompleta**: Informações-chave ausentes

#### 2.2 Tipo de Solicitação
- **Nova Funcionalidade**: Adicionar nova funcionalidade
- **Correção de Bug**: Corrigir problema existente
- **Refatoração**: Melhorar a estrutura do código
- **Upgrade**: Atualizar dependências ou frameworks
- **Migração**: Mover para tecnologia diferente
- **Melhoria**: Aprimorar funcionalidade existente
- **Novo Projeto**: Começar do zero

#### 2.3 Estimativa Inicial de Escopo
- **Arquivo Único**: Mudanças em um arquivo
- **Componente Único**: Mudanças em um componente/pacote
- **Múltiplos Componentes**: Mudanças em múltiplos componentes
- **Em Todo o Sistema**: Mudanças afetando o sistema inteiro
- **Entre Sistemas**: Mudanças afetando múltiplos sistemas

#### 2.4 Estimativa Inicial de Complexidade
- **Trivial**: Mudança simples e direta
- **Simples**: Caminho de implementação claro
- **Moderada**: Alguma complexidade, múltiplas considerações
- **Complexa**: Complexidade significativa, muitas considerações

### Etapa 3: Determinar Profundidade dos Requisitos

**Com base na análise da solicitação, determine a profundidade:**

**Profundidade Mínima** - Use quando:
- A solicitação é clara e simples
- Não são necessários requisitos detalhados
- Apenas documentar o entendimento básico

**Profundidade Padrão** - Use quando:
- A solicitação precisa de esclarecimento
- Requisitos funcionais e não funcionais são necessários
- Complexidade normal

**Profundidade Abrangente** - Use quando:
- Projeto complexo com múltiplos stakeholders
- Sistema de alto risco ou crítico
- Requisitos detalhados com rastreabilidade necessários

### Etapa 4: Avaliar Requisitos Atuais

Analise o que o usuário forneceu:
   - Declarações de intenção ou descrições (já registradas em audit.md)
   - Documentos de requisitos existentes (buscar no workspace se mencionados)
   - Conteúdo colado ou referências a arquivos
   - Converter quaisquer documentos não-markdown para formato markdown

### Etapa 5: Análise Completa de Completude

**CRÍTICO**: Use análise abrangente para avaliar a completude dos requisitos. Por padrão, faça perguntas quando houver QUALQUER ambiguidade ou detalhe ausente.

**OBRIGATÓRIO**: Avalie TODAS estas áreas e faça perguntas para QUALQUER uma que esteja pouco clara:
- **Requisitos Funcionais**: Funcionalidades principais, interações do usuário, comportamentos do sistema
- **Requisitos Não Funcionais**: Desempenho, segurança, escalabilidade, usabilidade
- **Cenários de Usuário**: Casos de uso, jornadas do usuário, casos extremos, cenários de erro
- **Contexto de Negócio**: Objetivos, restrições, critérios de sucesso, necessidades dos stakeholders
- **Contexto Técnico**: Pontos de integração, requisitos de dados, limites do sistema
- **Atributos de Qualidade**: Confiabilidade, manutenibilidade, testabilidade, acessibilidade

**Na dúvida, faça perguntas** - requisitos incompletos levam a implementações ruins.

### Etapa 5.1: Prompts de Opt-In de Extensões

**OBRIGATÓRIO**: Varra todos os arquivos `*.opt-in.md` carregados (carregados no início do workflow a partir dos subdiretórios `extensions/`) em busca de uma seção `## Opt-In Prompt`. Para cada extensão que declarar uma, inclua essa pergunta no arquivo de perguntas de esclarecimento criado na Etapa 6. Apresente cada pergunta de opt-in no mesmo idioma da conversa do usuário.

Após receber as respostas:
1. Registre o status de habilitação de cada extensão em `aidlc-docs/aidlc-state.md` sob `## Extension Configuration`:

```markdown
## Extension Configuration
| Extension | Enabled | Decided At |
|---|---|---|
| [Extension Name] | [Yes/No] | Requirements Analysis |
```

2. **Carregamento Diferido de Regras**: Para cada extensão que o usuário ATIVOU, carregue o arquivo completo de regras agora. O arquivo de regras é derivado por convenção de nomeação: remova `.opt-in.md` do nome do arquivo de opt-in e acrescente `.md` (ex.: `security-baseline.opt-in.md` → `security-baseline.md`). Para extensões que o usuário DESATIVOU, NÃO carregue o arquivo completo de regras.

### Etapa 6: Gerar Perguntas de Esclarecimento (ABORDAGEM PROATIVA)
   - **SEMPRE** criar `aidlc-docs/inception/requirements/requirement-verification-questions.md` a menos que os requisitos estejam excepcionalmente claros e completos
   - Fazer perguntas sobre QUALQUER área ausente, pouco clara ou ambígua
   - Focar em requisitos funcionais, requisitos não funcionais, cenários de usuário e contexto de negócio
   - Solicitar ao usuário que preencha todas as tags [Answer]: diretamente no documento de perguntas
   - Se apresentar opções de múltipla escolha para respostas:
     - Rotular as opções como A, B, C, D etc.
     - Garantir que as opções sejam mutuamente exclusivas e não se sobreponham
     - SEMPRE incluir opção para resposta personalizada: "X) Other (please describe after [Answer]: tag below)"
   - Aguardar respostas do usuário no documento
   - **OBRIGATÓRIO**: Analisar TODAS as respostas em busca de ambiguidades e criar perguntas de acompanhamento se necessário
   - **OBRIGATÓRIO**: Continuar fazendo perguntas até que TODAS as ambiguidades sejam resolvidas OU o usuário peça explicitamente para prosseguir

### ⛔ PORTÃO: Aguardar Respostas do Usuário
NÃO prossiga para a Etapa 7 até que todas as perguntas em requirement-verification-questions.md sejam respondidas e validadas.
Apresente o arquivo de perguntas ao usuário e PARE.

### Etapa 7: Gerar Documento de Requisitos
   - **PRÉ-REQUISITO**: O portão da Etapa 6 deve ser passado — todas as respostas recebidas e analisadas
   - Criar `aidlc-docs/inception/requirements/requirements.md`
   - Incluir resumo da análise de intenção no topo:
     - Solicitação do usuário
     - Tipo de solicitação
     - Estimativa de escopo
     - Estimativa de complexidade
   - Incluir requisitos funcionais e não funcionais
   - Incorporar as respostas do usuário às perguntas de esclarecimento
   - Fornecer breve resumo dos requisitos-chave

### Etapa 8: Atualizar Rastreamento de Estado

Atualizar `aidlc-docs/aidlc-state.md`:

```markdown
## Stage Progress
### 🔵 INCEPTION PHASE
- [x] Workspace Detection
- [x] Reverse Engineering (if applicable)
- [x] Requirements Analysis
```

### Etapa 9: Registrar e Prosseguir
   - Registrar prompt de aprovação com timestamp em `aidlc-docs/audit.md`
   - Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 🔍 Análise de Requisitos Concluída
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos dos requisitos
        - Formato: "A análise de requisitos identificou [tipo/complexidade do projeto]:"
        - Listar requisitos funcionais-chave (tópicos)
        - Listar requisitos não funcionais-chave (tópicos)
        - Mencionar considerações arquiteturais ou decisões técnicas se relevantes
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine o documento de requisitos em: `aidlc-docs/inception/requirements/requirements.md`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações nos requisitos se necessário com base na sua revisão 
> [SE Histórias de Usuário forem puladas, adicione esta opção:]
> 📝 **Adicionar Histórias de Usuário** - Escolher incluir o estágio de **Histórias de Usuário** (atualmente pulado com base na simplicidade do projeto)  
> ✅ **Aprovar e Continuar** - Aprovar requisitos e prosseguir para **[Histórias de Usuário/Planejamento do Workflow]**

---
```

**Nota**: Inclua a opção "Adicionar Histórias de Usuário" apenas quando o estágio de Histórias de Usuário for pulado. Substitua [Histórias de Usuário/Planejamento do Workflow] pelo nome real do próximo estágio.

   - Aguardar aprovação explícita do usuário antes de prosseguir
   - Registrar resposta de aprovação com timestamp
   - Atualizar estágio de Análise de Requisitos como completo em aidlc-state.md
