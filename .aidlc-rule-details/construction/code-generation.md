# Geração de Código - Etapas Detalhadas

## Visão Geral
Este estágio gera código para cada unidade de trabalho através de duas partes integradas:
- **Parte 1 - Planejamento**: Criar plano detalhado de geração de código com etapas explícitas
- **Parte 2 - Geração**: Executar o plano aprovado para gerar código, testes e artefatos

**Nota**: Para projetos brownfield, "gerar" significa modificar arquivos existentes quando apropriado, não criar duplicatas.

## Pré-requisitos
- A Geração de Design da Unidade deve estar completa para a unidade
- A Implementação NFR (se executada) deve estar completa para a unidade
- Todos os artefatos de design da unidade devem estar disponíveis
- A unidade está pronta para geração de código

---

# PARTE 1: PLANEJAMENTO

## Etapa 1: Analisar Contexto da Unidade
- [ ] Ler artefatos de design da unidade da Geração de Design da Unidade
- [ ] Ler o mapa de histórias da unidade para entender as histórias atribuídas
- [ ] Identificar dependências e interfaces da unidade
- [ ] Validar que a unidade está pronta para geração de código

## Etapa 2: Criar Plano Detalhado de Geração de Código da Unidade
- [ ] Ler a raiz do workspace e o tipo de projeto de `aidlc-docs/aidlc-state.md`
- [ ] Determinar a localização do código (veja Regras Críticas para padrões de estrutura)
- [ ] **Apenas Brownfield**: Revisar reverse engineering code-structure.md para arquivos existentes a modificar
- [ ] Documentar caminhos exatos (nunca aidlc-docs/)
- [ ] Criar etapas explícitas para geração da unidade:
  - Configuração da Estrutura do Projeto (apenas greenfield)
  - Geração de Lógica de Negócio
  - Testes Unitários de Lógica de Negócio
  - Resumo de Lógica de Negócio
  - Geração da Camada de API
  - Testes Unitários da Camada de API
  - Resumo da Camada de API
  - Geração da Camada de Repositório
  - Testes Unitários da Camada de Repositório
  - Resumo da Camada de Repositório
  - Geração de Componentes Frontend (se aplicável)
  - Testes Unitários de Componentes Frontend (se aplicável)
  - Resumo de Componentes Frontend (se aplicável)
  - Scripts de Migração de Banco de Dados (se modelos de dados existirem)
  - Geração de Documentação (docs de API, atualizações de README)
  - Geração de Artefatos de Implantação
- [ ] Numerar cada etapa sequencialmente
- [ ] Incluir referências de mapeamento de histórias
- [ ] Adicionar checkboxes [ ] para cada etapa

## Etapa 3: Incluir Contexto de Geração da Unidade
- [ ] Para esta unidade, incluir:
  - Histórias implementadas por esta unidade
  - Dependências de outras unidades/serviços
  - Interfaces e contratos esperados
  - Entidades de banco de dados pertencentes a esta unidade
  - Limites e responsabilidades do serviço

## Etapa 4: Criar Documento do Plano da Unidade
- [ ] Salvar plano completo como `aidlc-docs/construction/plans/{unit-name}-code-generation-plan.md`
- [ ] Incluir numeração de etapas (Etapa 1, Etapa 2, etc.)
- [ ] Incluir contexto da unidade e dependências
- [ ] Incluir rastreabilidade de histórias
- [ ] Garantir que o plano seja executável passo a passo
- [ ] Enfatizar que este plano é a única fonte da verdade para a Geração de Código

## Etapa 5: Resumir Plano da Unidade
- [ ] Fornecer resumo do plano de geração de código da unidade ao usuário
- [ ] Destacar a abordagem de geração da unidade
- [ ] Explicar a sequência de etapas e a cobertura de histórias
- [ ] Observar o número total de etapas e o escopo estimado

## Etapa 6: Registrar Prompt de Aprovação
- [ ] Antes de pedir aprovação, registrar o prompt com timestamp em `aidlc-docs/audit.md`
- [ ] Incluir referência ao plano completo de geração de código da unidade
- [ ] Usar formato de timestamp ISO 8601

## Etapa 7: Aguardar Aprovação Explícita
- [ ] Não prosseguir até que o usuário aprove explicitamente o plano de geração de código da unidade
- [ ] A aprovação deve cobrir o plano inteiro e a sequência de geração
- [ ] Se o usuário solicitar mudanças, atualizar o plano e repetir o processo de aprovação

## Etapa 8: Registrar Resposta de Aprovação
- [ ] Registrar a resposta de aprovação do usuário com timestamp em `aidlc-docs/audit.md`
- [ ] Incluir o texto exato da resposta do usuário
- [ ] Marcar o status de aprovação claramente

## Etapa 9: Atualizar Progresso
- [ ] Marcar Geração de Código Parte 1 (Planejamento) como completa em `aidlc-state.md`
- [ ] Atualizar a seção "Current Status"
- [ ] Preparar para a transição para a Geração de Código

---

# PARTE 2: GERAÇÃO

## Etapa 10: Carregar Plano de Geração de Código da Unidade
- [ ] Ler o plano completo de `aidlc-docs/construction/plans/{unit-name}-code-generation-plan.md`
- [ ] Identificar a próxima etapa não concluída (primeiro checkbox [ ])
- [ ] Carregar o contexto para essa etapa (unidade, dependências, histórias)

## Etapa 11: Executar Etapa Atual
- [ ] Verificar o diretório de destino do plano (nunca aidlc-docs/)
- [ ] **Apenas Brownfield**: Verificar se o arquivo de destino existe
- [ ] Gerar exatamente o que a etapa atual descreve:
  - **Se o arquivo existe**: Modificá-lo no lugar (nunca criar `ClassName_modified.java`, `ClassName_new.java`, etc.)
  - **Se o arquivo não existe**: Criar novo arquivo
- [ ] Escrever nos locais corretos:
  - **Código da Aplicação**: Raiz do workspace conforme estrutura do projeto
  - **Documentação**: `aidlc-docs/construction/{unit-name}/code/` (apenas markdown)
  - **Arquivos de Build/Config**: Raiz do workspace
- [ ] Seguir os requisitos das histórias da unidade
- [ ] Respeitar dependências e interfaces

## Etapa 12: Atualizar Progresso
- [ ] Marcar a etapa concluída como [x] no plano de geração de código da unidade
- [ ] Marcar histórias associadas da unidade como [x] quando sua geração estiver concluída
- [ ] Atualizar o status atual em `aidlc-docs/aidlc-state.md`
- [ ] **Apenas Brownfield**: Verificar que nenhum arquivo duplicado foi criado (ex.: nenhum `ClassName_modified.java` junto com `ClassName.java`)
- [ ] Salvar todos os artefatos gerados

## Etapa 13: Continuar ou Completar Geração
- [ ] Se mais etapas permanecerem, retornar à Etapa 10
- [ ] Se todas as etapas estiverem completas, prosseguir para apresentar a mensagem de conclusão

## Etapa 14: Apresentar Mensagem de Conclusão
- Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 💻 Geração de Código Concluída - [unit-name]
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos
        - **Brownfield**: Distinguir arquivos modificados vs criados (ex.: "• Modificado: `src/services/user-service.ts`", "• Criado: `src/services/auth-service.ts`")
        - **Greenfield**: Listar arquivos criados com caminhos (ex.: "• Criado: `src/services/user-service.ts`")
        - Listar testes, documentação, artefatos de implantação com caminhos
        - Manter factual, sem instruções de workflow
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine o código gerado em:
> - **Código da Aplicação**: `[actual-workspace-path]`
> - **Documentação**: `aidlc-docs/construction/[unit-name]/code/`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações no código gerado com base na sua revisão  
> ✅ **Continuar para o Próximo Estágio** - Aprovar geração de código e prosseguir para **[próxima-unidade/Build e Testes]**

---
```

## Etapa 15: Aguardar Aprovação Explícita
- Não prossiga até que o usuário aprove explicitamente o código gerado
- A aprovação deve ser clara e inequívoca
- Se o usuário solicitar mudanças, atualize o código e repita o processo de aprovação

## Etapa 16: Registrar Aprovação e Atualizar Progresso
- Registrar aprovação em audit.md com timestamp
- Registrar a resposta de aprovação do usuário com timestamp
- Marcar o estágio de Geração de Código como completo para esta unidade em aidlc-state.md

---

## Regras Críticas

### Regras de Localização do Código
- **Código da aplicação**: Apenas na raiz do workspace (NUNCA em aidlc-docs/)
- **Documentação**: apenas aidlc-docs/ (resumos markdown)
- **Ler a raiz do workspace** de aidlc-state.md antes de gerar código

**Padrões de estrutura por tipo de projeto**:
- **Brownfield**: Usar estrutura existente (ex.: `src/main/java/`, `lib/`, `pkg/`)
- **Greenfield unidade única**: `src/`, `tests/`, `config/` na raiz do workspace
- **Greenfield multi-unidade (microsserviços)**: `{unit-name}/src/`, `{unit-name}/tests/`
- **Greenfield multi-unidade (monólito)**: `src/{unit-name}/`, `tests/{unit-name}/`

### Regras de Modificação de Arquivos Brownfield
- Verificar se o arquivo existe antes de gerar
- Se existe: Modificar no lugar (nunca criar cópias como `ClassName_modified.java`)
- Se não existe: Criar novo arquivo
- Verificar se não há arquivos duplicados após a geração (Etapa 12)

### Regras da Fase de Planejamento
- Criar etapas explícitas e numeradas para todas as atividades de geração
- Incluir rastreabilidade de histórias no plano
- Documentar contexto da unidade e dependências
- Obter aprovação explícita do usuário antes da geração

### Regras da Fase de Geração
- **SEM LÓGICA HARDCODED**: Execute apenas o que está escrito no plano da unidade
- **SIGA O PLANO EXATAMENTE**: Não desvie da sequência de etapas
- **ATUALIZE CHECKBOXES**: Marque [x] imediatamente após concluir cada etapa
- **RASTREABILIDADE DE HISTÓRIAS**: Marque histórias da unidade [x] quando a funcionalidade for implementada
- **RESPEITE DEPENDÊNCIAS**: Implemente apenas quando as dependências da unidade forem satisfeitas

### Regras de Código Amigável à Automação
Ao gerar código de UI (web, mobile, desktop), garanta que os elementos sejam amigáveis à automação:
- Adicione atributos `data-testid` a elementos interativos (botões, inputs, links, formulários)
- Use nomenclatura consistente: `{component}-{element-role}` (ex.: `login-form-submit-button`, `user-list-search-input`)
- Evite IDs dinâmicos ou auto-gerados que mudam entre renders
- Mantenha valores de `data-testid` estáveis entre mudanças de código (mude apenas quando o propósito do elemento mudar)

## Critérios de Conclusão
- Plano completo de geração de código da unidade criado e aprovado
- Todas as etapas no plano de geração de código da unidade marcadas [x]
- Todas as histórias da unidade implementadas conforme o plano
- Todo o código e testes gerados (testes serão executados na fase de Build e Testes)
- Artefatos de implantação gerados
- Unidade completa pronta para build e verificação
