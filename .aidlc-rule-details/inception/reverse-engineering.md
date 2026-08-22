# Engenharia Reversa

**Propósito**: Analisar a base de código existente e gerar artefatos de design abrangentes

**Executar quando**: Projeto brownfield detectado (código existente encontrado no workspace)

**Pular quando**: Projeto greenfield (sem código existente)

**Comportamento de reexecução**: A reexecução é controlada por workspace-detection.md. Se artefatos existentes de engenharia reversa forem encontrados e ainda estiverem atuais, eles são carregados e a engenharia reversa é pulada. Se os artefatos estiverem desatualizados (mais antigos que a última modificação significativa da base de código) ou o usuário solicitar explicitamente uma reexecução, a engenharia reversa é executada novamente para garantir que os artefatos reflitam o estado atual do código

## Etapa 1: Descoberta Multi-Pacote

### 1.1 Varrer o Workspace
- Todos os pacotes (não apenas os mencionados)
- Relacionamentos de pacotes via arquivos de configuração
- Tipos de pacotes: Application, CDK/Infrastructure, Models, Clients, Tests

### 1.2 Entender o Contexto de Negócio
- O negócio principal que o sistema está implementando no geral
- A visão geral de negócio de cada pacote
- Lista de Transações de Negócio que são implementadas no sistema

### 1.3 Descoberta de Infraestrutura
- Pacotes CDK (package.json com dependências CDK)
- Terraform (arquivos .tf)
- CloudFormation (templates .yaml/.json)
- Scripts de implantação

### 1.4 Descoberta do Sistema de Build
- Sistemas de build: Brazil, Maven, Gradle, npm
- Arquivos de configuração para declarações do sistema de build
- Dependências de build entre pacotes

### 1.5 Descoberta da Arquitetura de Serviços
- Funções Lambda (handlers, triggers)
- Serviços de container (configs Docker/ECS)
- Definições de API (modelos Smithy, specs OpenAPI)
- Armazenamentos de dados (DynamoDB, S3, etc.)

### 1.6 Análise de Qualidade de Código
- Linguagens de programação e frameworks
- Indicadores de cobertura de testes
- Configurações de linting
- Pipelines de CI/CD

## Etapa 2: Gerar Documentação de Visão Geral de Negócio

Criar `aidlc-docs/inception/reverse-engineering/business-overview.md`:

```markdown
# Visão Geral de Negócio

## Diagrama de Contexto de Negócio
[Diagrama Mermaid mostrando o Contexto de Negócio]

## Descrição de Negócio
- **Descrição de Negócio**: [Descrição geral do negócio do que o sistema faz]
- **Transações de Negócio**: [Lista de Transações de Negócio que o sistema implementa e suas descrições]
- **Dicionário de Negócio**: [Termos do dicionário de negócio que o sistema segue e seus significados]

## Descrições de Negócio no Nível de Componente
### [Nome do Pacote/Componente]
- **Propósito**: [O que faz da perspectiva de negócio]
- **Responsabilidades**: [Responsabilidades principais]
```

## Etapa 3: Gerar Documentação de Arquitetura

Criar `aidlc-docs/inception/reverse-engineering/architecture.md`:

```markdown
# Arquitetura do Sistema

## Visão Geral do Sistema
[Descrição de alto nível do sistema]

## Diagrama de Arquitetura
[Diagrama Mermaid mostrando todos os pacotes, serviços, armazenamentos de dados e relacionamentos]

## Descrições de Componentes
### [Nome do Pacote/Componente]
- **Propósito**: [O que faz]
- **Responsabilidades**: [Responsabilidades principais]
- **Dependências**: [Do que depende]
- **Tipo**: [Application/Infrastructure/Model/Client/Test]

## Fluxo de Dados
[Diagrama de sequência Mermaid dos fluxos de trabalho principais]

## Pontos de Integração
- **APIs Externas**: [Lista com propósitos]
- **Bancos de Dados**: [Lista com propósitos]
- **Serviços de Terceiros**: [Lista com propósitos]

## Componentes de Infraestrutura
- **Stacks CDK**: [Lista com propósitos]
- **Modelo de Implantação**: [Descrição]
- **Rede**: [VPC, subnets, security groups]
```

## Etapa 4: Gerar Documentação da Estrutura de Código

Criar `aidlc-docs/inception/reverse-engineering/code-structure.md`:

```markdown
# Estrutura de Código

## Sistema de Build
- **Tipo**: [Maven/Gradle/npm/Brazil]
- **Configuração**: [Arquivos e configurações principais de build]

## Classes/Módulos Principais
[Diagrama de classes Mermaid ou hierarquia de módulos]

### Inventário de Arquivos Existentes
[Listar todos os arquivos-fonte com seus propósitos - estes são candidatos a modificação em projetos brownfield]

**Formato de exemplo**:
- `[path/to/file]` - [Propósito/responsabilidade]

## Padrões de Design
### [Nome do Padrão]
- **Localização**: [Onde é usado]
- **Propósito**: [Por que é usado]
- **Implementação**: [Como é implementado]

## Dependências Críticas
### [Nome da Dependência]
- **Versão**: [Número da versão]
- **Uso**: [Como e onde é usada]
- **Propósito**: [Por que é necessária]
```

## Etapa 5: Gerar Documentação de API

Criar `aidlc-docs/inception/reverse-engineering/api-documentation.md`:

```markdown
# Documentação de API

## APIs REST
### [Nome do Endpoint]
- **Método**: [GET/POST/PUT/DELETE]
- **Caminho**: [/api/path]
- **Propósito**: [O que faz]
- **Requisição**: [Formato da requisição]
- **Resposta**: [Formato da resposta]

## APIs Internas
### [Nome da Interface/Classe]
- **Métodos**: [Lista com assinaturas]
- **Parâmetros**: [Descrições dos parâmetros]
- **Tipos de Retorno**: [Descrições dos tipos de retorno]

## Modelos de Dados
### [Nome do Modelo]
- **Campos**: [Descrições dos campos]
- **Relacionamentos**: [Modelos relacionados]
- **Validação**: [Regras de validação]
```

## Etapa 6: Gerar Inventário de Componentes

Criar `aidlc-docs/inception/reverse-engineering/component-inventory.md`:

```markdown
# Inventário de Componentes

## Pacotes de Aplicação
- [Nome do pacote] - [Propósito]

## Pacotes de Infraestrutura
- [Nome do pacote] - [CDK/Terraform] - [Propósito]

## Pacotes Compartilhados
- [Nome do pacote] - [Models/Utilities/Clients] - [Propósito]

## Pacotes de Teste
- [Nome do pacote] - [Integration/Load/Unit] - [Propósito]

## Contagem Total
- **Total de Pacotes**: [Número]
- **Aplicação**: [Número]
- **Infraestrutura**: [Número]
- **Compartilhados**: [Número]
- **Teste**: [Número]
```

## Etapa 7: Gerar Documentação da Stack Tecnológica

Criar `aidlc-docs/inception/reverse-engineering/technology-stack.md`:

```markdown
# Stack Tecnológica

## Linguagens de Programação
- [Linguagem] - [Versão] - [Uso]

## Frameworks
- [Framework] - [Versão] - [Propósito]

## Infraestrutura
- [Serviço] - [Propósito]

## Ferramentas de Build
- [Ferramenta] - [Versão] - [Propósito]

## Ferramentas de Teste
- [Ferramenta] - [Versão] - [Propósito]
```

## Etapa 8: Gerar Documentação de Dependências

Criar `aidlc-docs/inception/reverse-engineering/dependencies.md`:

```markdown
# Dependências

## Dependências Internas
[Diagrama Mermaid mostrando dependências entre pacotes]

### [Package A] depende de [Package B]
- **Tipo**: [Compile/Runtime/Test]
- **Motivo**: [Por que a dependência existe]

## Dependências Externas
### [Nome da Dependência]
- **Versão**: [Versão]
- **Propósito**: [Por que é usada]
- **Licença**: [Tipo de licença]
```

## Etapa 9: Gerar Avaliação de Qualidade de Código

Criar `aidlc-docs/inception/reverse-engineering/code-quality-assessment.md`:

```markdown
# Avaliação de Qualidade de Código

## Cobertura de Testes
- **Geral**: [Percentual ou Bom/Razoável/Ruim/Nenhuma]
- **Testes Unitários**: [Status]
- **Testes de Integração**: [Status]

## Indicadores de Qualidade de Código
- **Linting**: [Configurado/Não configurado]
- **Estilo de Código**: [Consistente/Inconsistente]
- **Documentação**: [Boa/Razoável/Ruim]

## Débito Técnico
- [Descrição do problema e localização]

## Padrões e Antipadrões
- **Bons Padrões**: [Lista]
- **Antipadrões**: [Lista com localizações]
```

## Etapa 10: Criar Arquivo de Timestamp

Criar `aidlc-docs/inception/reverse-engineering/reverse-engineering-timestamp.md`:

```markdown
# Metadados de Engenharia Reversa

**Data da Análise**: [Timestamp ISO]
**Analisador**: AI-DLC
**Workspace**: [Caminho do workspace]
**Total de Arquivos Analisados**: [Número]

## Artefatos Gerados
- [x] architecture.md
- [x] code-structure.md
- [x] api-documentation.md
- [x] component-inventory.md
- [x] technology-stack.md
- [x] dependencies.md
- [x] code-quality-assessment.md
```

## Etapa 11: Atualizar Rastreamento de Estado

Atualizar `aidlc-docs/aidlc-state.md`:

```markdown
## Status de Engenharia Reversa
- [x] Engenharia Reversa - Concluída em [timestamp]
- **Localização dos Artefatos**: aidlc-docs/inception/reverse-engineering/
```

## Etapa 12: Apresentar Mensagem de Conclusão ao Usuário

```markdown
# 🔍 Engenharia Reversa Concluída

[Resumo gerado pela IA dos achados-chave da análise na forma de tópicos]

> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine os artefatos de engenharia reversa em: `aidlc-docs/inception/reverse-engineering/`

> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações na análise de engenharia reversa se necessário
> ✅ **Aprovar e Continuar** - Aprovar análise e prosseguir para **Análise de Requisitos**
```

## Etapa 13: Aguardar Aprovação do Usuário

- **OBRIGATÓRIO**: Não prosseguir até que o usuário aprove explicitamente
- **OBRIGATÓRIO**: Registrar a resposta do usuário em audit.md com a entrada bruta completa
