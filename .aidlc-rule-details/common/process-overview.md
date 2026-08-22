# Visão Geral do Workflow Adaptativo AI-DLC

**Propósito**: Referência técnica para o modelo de IA e desenvolvedores entenderem a estrutura completa do workflow.

**Nota**: Conteúdo semelhante existe em welcome-message.md (mensagem de boas-vindas ao usuário) e README.md (documentação). Esta duplicação é INTENCIONAL - cada arquivo serve a um propósito diferente:
- **Este arquivo**: Referência técnica detalhada com diagrama Mermaid para carregamento de contexto do modelo de IA
- **welcome-message.md**: Mensagem de boas-vindas voltada ao usuário com diagrama ASCII
- **README.md**: Documentação legível por humanos para o repositório

## O Ciclo de Vida em Três Fases:
• **FASE DE INCEPTION**: Planejamento e arquitetura (Detecção do Workspace + fases condicionais + Planejamento do Workflow)
• **FASE DE CONSTRUCTION**: Design, implementação, build e testes (design por unidade + Geração de Código + Build e Testes)
• **FASE DE OPERATIONS**: Placeholder para futuros workflows de implantação e monitoramento

## O Workflow Adaptativo:
• **Detecção do Workspace** (sempre) → **Engenharia Reversa** (apenas brownfield) → **Análise de Requisitos** (sempre, profundidade adaptativa) → **Fases Condicionais** (conforme necessário) → **Planejamento do Workflow** (sempre) → **Geração de Código** (sempre, por unidade) → **Build e Testes** (sempre)

## Como Funciona:
• **A IA analisa** sua solicitação, workspace e complexidade para determinar quais estágios são necessários
• **Estes estágios sempre executam**: Detecção do Workspace, Análise de Requisitos (profundidade adaptativa), Planejamento do Workflow, Geração de Código (por unidade), Build e Testes
• **Todos os outros estágios são condicionais**: Engenharia Reversa, Histórias de Usuário, Design da Aplicação, Geração de Unidades, estágios de design por unidade (Design Funcional, Requisitos NFR, Design NFR, Design de Infraestrutura)
• **Sem sequências fixas**: Os estágios executam na ordem que faz sentido para sua tarefa específica

## Papel da Sua Equipe:
• **Responder perguntas** em arquivos de perguntas dedicados usando tags [Answer]: com escolhas de letra (A, B, C, D, E)
• **Opção E disponível**: Escolha "Outro" e descreva sua resposta personalizada se as opções fornecidas não corresponderem
• **Trabalhar em equipe** para revisar e aprovar cada fase antes de prosseguir
• **Decidir coletivamente** a abordagem arquitetural quando necessário
• **Importante**: Este é um esforço de equipe - envolva stakeholders relevantes para cada fase

## Workflow AI-DLC em Três Fases:

```mermaid
flowchart TD
    Start(["Solicitação do Usuário"])
    
    subgraph INCEPTION["🔵 FASE DE INCEPTION"]
        WD["Detecção do Workspace<br/><b>SEMPRE</b>"]
        RE["Engenharia Reversa<br/><b>CONDICIONAL</b>"]
        RA["Análise de Requisitos<br/><b>SEMPRE</b>"]
        Stories["Histórias de Usuário<br/><b>CONDICIONAL</b>"]
        WP["Planejamento do Workflow<br/><b>SEMPRE</b>"]
        AppDesign["Design da Aplicação<br/><b>CONDICIONAL</b>"]
        UnitsG["Geração de Unidades<br/><b>CONDICIONAL</b>"]
    end
    
    subgraph CONSTRUCTION["🟢 FASE DE CONSTRUCTION"]
        FD["Design Funcional<br/><b>CONDICIONAL</b>"]
        NFRA["Requisitos NFR<br/><b>CONDICIONAL</b>"]
        NFRD["Design NFR<br/><b>CONDICIONAL</b>"]
        ID["Design de Infraestrutura<br/><b>CONDICIONAL</b>"]
        CG["Geração de Código<br/><b>SEMPRE</b>"]
        BT["Build e Testes<br/><b>SEMPRE</b>"]
    end
    
    subgraph OPERATIONS["🟡 FASE DE OPERATIONS"]
        OPS["Operations<br/><b>PLACEHOLDER</b>"]
    end
    
    Start --> WD
    WD -.-> RE
    WD --> RA
    RE --> RA
    
    RA -.-> Stories
    RA --> WP
    Stories --> WP
    
    WP -.-> AppDesign
    WP -.-> UnitsG
    AppDesign -.-> UnitsG
    UnitsG --> FD
    FD -.-> NFRA
    NFRA -.-> NFRD
    NFRD -.-> ID
    
    WP --> CG
    FD --> CG
    NFRA --> CG
    NFRD --> CG
    ID --> CG
    CG -.->|Próxima Unidade| FD
    CG --> BT
    BT -.-> OPS
    BT --> End(["Concluído"])
    
    style WD fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style RA fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style WP fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff

    style CG fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style BT fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style OPS fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style RE fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style Stories fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style AppDesign fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000

    style UnitsG fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style FD fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style NFRA fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style NFRD fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style ID fill:#FFA726,stroke:#E65100,stroke-width:3px,stroke-dasharray: 5 5,color:#000
    style INCEPTION fill:#BBDEFB,stroke:#1565C0,stroke-width:3px, color:#000
    style CONSTRUCTION fill:#C8E6C9,stroke:#2E7D32,stroke-width:3px, color:#000
    style OPERATIONS fill:#FFF59D,stroke:#F57F17,stroke-width:3px, color:#000
    style Start fill:#CE93D8,stroke:#6A1B9A,stroke-width:3px,color:#000
    style End fill:#CE93D8,stroke:#6A1B9A,stroke-width:3px,color:#000
    
    linkStyle default stroke:#333,stroke-width:2px
```

**Descrições dos Estágios:**

**🔵 FASE DE INCEPTION** - Planejamento e Arquitetura
- Detecção do Workspace: Analisar estado do workspace e tipo de projeto (SEMPRE)
- Engenharia Reversa: Analisar base de código existente (CONDICIONAL - apenas Brownfield)
- Análise de Requisitos: Reunir e validar requisitos (SEMPRE - profundidade adaptativa)
- Histórias de Usuário: Criar histórias de usuário e personas (CONDICIONAL)
- Planejamento do Workflow: Criar plano de execução (SEMPRE)
- Design da Aplicação: Identificação de componentes de alto nível e design da camada de serviço (CONDICIONAL)
- Geração de Unidades: Decompor em unidades de trabalho (CONDICIONAL)

**🟢 FASE DE CONSTRUCTION** - Design, Implementação, Build e Testes
- Design Funcional: Design detalhado da lógica de negócio por unidade (CONDICIONAL, por unidade)
- Requisitos NFR: Determinar NFRs e selecionar stack tecnológica (CONDICIONAL, por unidade)
- Design NFR: Incorporar padrões NFR e componentes lógicos (CONDICIONAL, por unidade)
- Design de Infraestrutura: Mapear para serviços reais de infraestrutura (CONDICIONAL, por unidade)
- Geração de Código: Gerar código com Parte 1 - Planejamento, Parte 2 - Geração (SEMPRE, por unidade)
- Build e Testes: Compilar todas as unidades e executar testes abrangentes (SEMPRE)

**🟡 FASE DE OPERATIONS** - Placeholder
- Operations: Placeholder para futuros workflows de implantação e monitoramento (PLACEHOLDER)

**Princípios-Chave:**
- As fases executam apenas quando agregam valor
- Cada fase é avaliada independentemente
- INCEPTION foca em "o quê" e "por quê"
- CONSTRUCTION foca em "como" mais "build e testes"
- OPERATIONS é placeholder para expansão futura
- Mudanças simples podem pular estágios condicionais de INCEPTION
- Mudanças complexas recebem tratamento completo de INCEPTION e CONSTRUCTION
