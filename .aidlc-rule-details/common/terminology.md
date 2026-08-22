# Glossário de Terminologia AI-DLC

## Terminologia Principal

### Fase vs Estágio

**Fase (Phase)**: Uma das três fases de alto nível do ciclo de vida no AI-DLC
- 🔵 **FASE DE INCEPTION** - Planejamento e Arquitetura (O QUÊ e POR QUÊ)
- 🟢 **FASE DE CONSTRUCTION** - Design, Implementação e Testes (COMO)
- 🟡 **FASE DE OPERATIONS** - Implantação e Monitoramento (expansão futura)

**Estágio (Stage)**: Uma atividade individual do workflow dentro de uma fase
- Exemplos: Estágio de Avaliação de Contexto, Estágio de Avaliação de Requisitos, Estágio de Geração de Código
- Cada estágio tem pré-requisitos, etapas e saídas específicos
- Estágios podem ser SEMPRE-EXECUTAR ou CONDICIONAL

**Exemplos de Uso**:
- ✅ "A fase de CONSTRUCTION contém 7 estágios"
- ✅ "O estágio de Geração de Código é sempre executado"
- ✅ "Estamos na fase de INCEPTION, executando o estágio de Avaliação de Requisitos"
- ❌ "A fase de Avaliação de Requisitos" (deveria ser "estágio")
- ❌ "O estágio de CONSTRUCTION" (deveria ser "fase")

## Ciclo de Vida em Três Fases

### FASE DE INCEPTION
**Propósito**: Planejamento e decisões arquiteturais  
**Foco**: Determinar O QUE construir e POR QUÊ  
**Localização**: diretório `inception/`

**Estágios**:
- Detecção do Workspace (SEMPRE)
- Engenharia Reversa (CONDICIONAL - apenas Brownfield)
- Análise de Requisitos (SEMPRE - profundidade adaptativa)
- Histórias de Usuário (CONDICIONAL)
- Planejamento do Workflow (SEMPRE)
- Design da Aplicação (CONDICIONAL)
- Geração de Unidades (CONDICIONAL)

**Saídas**: Requisitos, histórias de usuário, decisões arquiteturais, definições de unidades

### FASE DE CONSTRUCTION
**Propósito**: Design detalhado e implementação  
**Foco**: Determinar COMO construir  
**Localização**: diretório `construction/`

**Estágios**:
- Design Funcional (CONDICIONAL, por unidade)
- Requisitos NFR (CONDICIONAL, por unidade)
- Design NFR (CONDICIONAL, por unidade)
- Design de Infraestrutura (CONDICIONAL, por unidade)
- Geração de Código (SEMPRE) — inclui Parte 1: Planejamento e Parte 2: Geração
- Build e Testes (SEMPRE)

**Saídas**: Artefatos de design, implementações de NFR, código, testes

### FASE DE OPERATIONS
**Propósito**: Implantação e prontidão operacional  
**Foco**: Como IMPLANTAR e EXECUTAR  
**Localização**: diretório `operations/`

**Estágios**:
- Operations (PLACEHOLDER)

**Saídas**: Instruções de build, guias de implantação, configuração de monitoramento, procedimentos de verificação

---

## Estágios do Workflow

### Estágios Sempre Executados
- **Detecção do Workspace**: Análise inicial do estado do workspace e tipo de projeto
- **Análise de Requisitos**: Levantamento de requisitos (profundidade varia com base na complexidade)
- **Planejamento do Workflow**: Criação do plano de execução de quais fases executar
- **Geração de Código**: Estágio único com duas partes — Parte 1 (Planejamento) cria planos detalhados de implementação, Parte 2 (Geração) gera o código real com base nos planos e artefatos anteriores
- **Build e Testes**: Compilação de todas as unidades e execução de testes abrangentes

### Estágios Condicionais
- **Engenharia Reversa**: Análise da base de código existente (apenas projetos brownfield)
- **Histórias de Usuário**: Criação de histórias de usuário e personas (inclui Planejamento de Histórias e Geração de Histórias)
- **Design da Aplicação**: Design de componentes da aplicação, métodos, regras de negócio e serviços
- **Geração de Unidades**: Decomposição do sistema em unidades de trabalho (inclui subetapas internas de planejamento e geração, mais design por unidade)
- **Design Funcional**: Design da lógica de negócio agnóstico à tecnologia (por unidade)
- **Requisitos NFR**: Determinação de NFRs e seleção de stack tecnológica (por unidade)
- **Design NFR**: Incorporação de padrões NFR e componentes lógicos (por unidade)
- **Design de Infraestrutura**: Mapeamento para serviços reais de infraestrutura (por unidade)

## Termos de Design da Aplicação

- **Componente**: Uma unidade funcional com responsabilidades específicas
- **Método**: Uma função ou operação dentro de um componente com regras de negócio definidas
- **Regra de Negócio**: Lógica que governa o comportamento e validação do método
- **Serviço**: Camada de orquestração que coordena a lógica de negócio entre componentes
- **Dependência de Componente**: Relacionamento e padrão de comunicação entre componentes

## Termos de Arquitetura (Infraestrutura)

### Unidade de Trabalho (Unit of Work)
Um agrupamento lógico de histórias de usuário para fins de desenvolvimento. O termo usado durante o planejamento e decomposição.

**Uso**: "Precisamos decompor o sistema em unidades de trabalho"

### Serviço (Service)
Um componente implantável de forma independente em uma arquitetura de microsserviços. Cada serviço é uma unidade de trabalho separada.

**Uso**: "O Payment Service lida com todo o processamento de pagamentos"

### Módulo (Module)
Um agrupamento lógico de funcionalidade dentro de um único serviço ou monólito. Módulos não são implantáveis de forma independente.

**Uso**: "O módulo de autenticação dentro do User Service"

### Componente (Component)
Um bloco de construção reutilizável dentro de um serviço ou módulo. Componentes são classes, funções ou pacotes que fornecem funcionalidade específica.

**Uso**: "O componente EmailValidator valida endereços de e-mail"

## Diretrizes de Terminologia

### Quando Usar Cada Termo

**Unidade de Trabalho**:
- Durante o estágio de Geração de Unidades
- Ao discutir a decomposição do sistema
- Em documentos e discussões de planejamento
- Exemplo: "Como devemos decompor isso em unidades de trabalho?"

**Serviço**:
- Ao se referir a componentes implantáveis de forma independente
- Em contextos de arquitetura de microsserviços
- Em discussões de implantação e infraestrutura
- Exemplo: "O Order Service será implantado no ECS"

**Módulo**:
- Ao se referir a agrupamentos lógicos dentro de um serviço
- Em contextos de arquitetura monolítica
- Ao discutir organização interna
- Exemplo: "O módulo de relatórios gera todos os relatórios"

**Componente**:
- Ao se referir a classes, funções ou pacotes específicos
- Em discussões de design e implementação
- Ao discutir blocos de construção reutilizáveis
- Exemplo: "O componente DatabaseConnection gerencia conexões"

## Terminologia de Estágios

### Planejamento vs Geração
- **Planejamento**: Criar um plano com perguntas e checkboxes para execução
- **Geração**: Executar o plano para criar artefatos

Exemplos (estas são subetapas internas dentro de um único estágio, não estágios separados):
- Planejamento de Histórias → Geração de Histórias (dentro do estágio de Histórias de Usuário)
- Planejamento de Unidades → Geração de Unidades (dentro do estágio de Geração de Unidades)
- Planejamento de Design da Unidade → Geração de Design da Unidade (dentro do design por unidade)
- Planejamento NFR → Geração NFR (dentro do estágio de Requisitos NFR)
- Geração de Código Parte 1 (Planejamento) → Geração de Código Parte 2 (Geração)

### Níveis de Profundidade
- **Mínima**: Execução rápida e focada para mudanças simples
- **Padrão**: Profundidade normal com artefatos padrão para projetos típicos
- **Abrangente**: Profundidade completa com todos os artefatos para projetos complexos/de alto risco

## Tipos de Artefatos

### Planos
Documentos com checkboxes e perguntas que guiam a execução.
- Localizados em `aidlc-docs/plans/`
- Exemplos: `story-generation-plan.md`, `unit-of-work-plan.md`

### Artefatos
Saídas geradas a partir da execução de planos.
- Localizados em vários subdiretórios de `aidlc-docs/`
- Exemplos: `requirements.md`, `stories.md`, `design.md`

### Arquivos de Estado
Arquivos que rastreiam o progresso e status do workflow.
- `aidlc-state.md`: Estado geral do workflow
- `audit.md`: Trilha de auditoria completa de todas as interações

## Abreviações Comuns

- **AI-DLC**: AI-Driven Development Life Cycle
- **NFR**: Non-Functional Requirements (Requisitos Não Funcionais)
- **UOW**: Unit of Work (Unidade de Trabalho)
- **API**: Application Programming Interface
- **CDK**: Cloud Development Kit (AWS)
