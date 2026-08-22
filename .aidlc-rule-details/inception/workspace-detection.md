# Detecção do Workspace

**Propósito**: Determinar o estado do workspace e verificar projetos AI-DLC existentes

## Etapa 1: Verificar Projeto AI-DLC Existente

Verificar se `aidlc-docs/aidlc-state.md` existe:
- **Se existe**: Retomar a partir da última fase (carregar contexto das fases anteriores)
- **Se não existe**: Continuar com a avaliação de novo projeto

## Etapa 2: Varrer o Workspace em Busca de Código Existente

**Determinar se o workspace tem código existente:**
- Varrer o workspace em busca de arquivos de código-fonte (.java, .py, .js, .ts, .jsx, .tsx, .kt, .kts, .scala, .groovy, .go, .rs, .rb, .php, .c, .h, .cpp, .hpp, .cc, .cs, .fs, etc.)
- Verificar arquivos de build (pom.xml, package.json, build.gradle, etc.)
- Procurar indicadores de estrutura de projeto
- Identificar o diretório raiz do workspace (NÃO aidlc-docs/)

**Registrar achados:**
```markdown
## Workspace State
- **Existing Code**: [Yes/No]
- **Programming Languages**: [List if found]
- **Build System**: [Maven/Gradle/npm/etc. if found]
- **Project Structure**: [Monolith/Microservices/Library/Empty]
- **Workspace Root**: [Absolute path]
```

## Etapa 3: Determinar a Próxima Fase

**SE o workspace estiver vazio (sem código existente)**:
- Definir flag: `brownfield = false`
- Próxima fase: Análise de Requisitos

**SE o workspace tiver código existente**:
- Definir flag: `brownfield = true`
- Verificar artefatos existentes de engenharia reversa em `aidlc-docs/inception/reverse-engineering/`
- **SE artefatos de engenharia reversa existirem**:
    - Verificar se os artefatos estão desatualizados (comparar timestamps dos artefatos com a última modificação significativa da base de código)
    - **SE os artefatos estiverem atuais**: Carregá-los, pular para Análise de Requisitos
    - **SE os artefatos estiverem desatualizados**: A próxima fase é Engenharia Reversa (reexecutar para atualizar artefatos)
    - **SE o usuário solicitar explicitamente a reexecução**: A próxima fase é Engenharia Reversa independentemente do estado de atualização
- **SE não houver artefatos de engenharia reversa**: A próxima fase é Engenharia Reversa

## Etapa 4: Criar Arquivo de Estado Inicial

Criar `aidlc-docs/aidlc-state.md`:

```markdown
# AI-DLC State Tracking

## Project Information
- **Project Type**: [Greenfield/Brownfield]
- **Start Date**: [ISO timestamp]
- **Current Stage**: INCEPTION - Workspace Detection

## Workspace State
- **Existing Code**: [Yes/No]
- **Reverse Engineering Needed**: [Yes/No]
- **Workspace Root**: [Absolute path]

## Code Location Rules
- **Application Code**: Workspace root (NEVER in aidlc-docs/)
- **Documentation**: aidlc-docs/ only
- **Structure patterns**: See code-generation.md Critical Rules

## Stage Progress
[Will be populated as workflow progresses]
```

## Etapa 5: Apresentar Mensagem de Conclusão

**Para Projetos Brownfield:**
```markdown
# 🔍 Detecção do Workspace Concluída

Achados da análise do workspace:
• **Tipo de Projeto**: Projeto Brownfield
• [Resumo gerado pela IA dos achados do workspace em tópicos]
• **Próxima Etapa**: Prosseguindo para **Engenharia Reversa** para analisar a base de código existente...
```

**Para Projetos Greenfield:**
```markdown
# 🔍 Detecção do Workspace Concluída

Achados da análise do workspace:
• **Tipo de Projeto**: Projeto Greenfield
• **Próxima Etapa**: Prosseguindo para **Análise de Requisitos**...
```

## Etapa 6: Prosseguir Automaticamente

- **Nenhuma aprovação do usuário necessária** - isso é apenas informativo
- Prosseguir automaticamente para a próxima fase:
  - **Brownfield**: Engenharia Reversa (se não houver artefatos existentes) ou Análise de Requisitos (se artefatos existirem)
  - **Greenfield**: Análise de Requisitos
