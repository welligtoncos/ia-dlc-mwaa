# Build e Testes

**Propósito**: Compilar todas as unidades e executar estratégia abrangente de testes

## Pré-requisitos
- Geração de Código deve estar completa para todas as unidades
- Todos os artefatos de código devem estar gerados
- O projeto está pronto para build e testes

---

## Etapa 1: Analisar Requisitos de Testes

Analise o projeto para determinar a estratégia de testes apropriada:
- **Testes unitários**: Já gerados por unidade durante a geração de código
- **Testes de integração**: Testar interações entre unidades/serviços
- **Testes de desempenho**: Testes de carga, stress e escalabilidade
- **Testes end-to-end**: Fluxos de trabalho completos do usuário
- **Testes de contrato**: Validação de contrato de API entre serviços
- **Testes de segurança**: Varredura de vulnerabilidades, testes de penetração

---

## Etapa 2: Gerar Instruções de Build

Criar `aidlc-docs/construction/build-and-test/build-instructions.md`:

```markdown
# Instruções de Build

## Pré-requisitos
- **Ferramenta de Build**: [Nome e versão da ferramenta]
- **Dependências**: [Liste todas as dependências necessárias]
- **Variáveis de Ambiente**: [Liste as variáveis de ambiente necessárias]
- **Requisitos de Sistema**: [SO, memória, espaço em disco]

## Etapas de Build

### 1. Instalar Dependências
\`\`\`bash
[Comando para instalar dependências]
# Exemplo: npm install, mvn dependency:resolve, pip install -r requirements.txt
\`\`\`

### 2. Configurar Ambiente
\`\`\`bash
[Comandos para configurar o ambiente]
# Exemplo: exportar variáveis, configurar credenciais
\`\`\`

### 3. Compilar Todas as Unidades
\`\`\`bash
[Comando para compilar todas as unidades]
# Exemplo: mvn clean install, npm run build, brazil-build
\`\`\`

### 4. Verificar Sucesso do Build
- **Saída Esperada**: [Descreva a saída de um build bem-sucedido]
- **Artefatos de Build**: [Liste os artefatos gerados e localizações]
- **Avisos Comuns**: [Anote quaisquer avisos aceitáveis]

## Solução de Problemas

### Build Falha com Erros de Dependência
- **Causa**: [Causas comuns]
- **Solução**: [Correção passo a passo]

### Build Falha com Erros de Compilação
- **Causa**: [Causas comuns]
- **Solução**: [Correção passo a passo]
```

---

## Etapa 3: Gerar Instruções de Execução de Testes Unitários

Criar `aidlc-docs/construction/build-and-test/unit-test-instructions.md`:

```markdown
# Execução de Testes Unitários

## Executar Testes Unitários

### 1. Executar Todos os Testes Unitários
\`\`\`bash
[Comando para executar todos os testes unitários]
# Exemplo: mvn test, npm test, pytest tests/unit
\`\`\`

### 2. Revisar Resultados dos Testes
- **Esperado**: [X] testes passam, 0 falhas
- **Cobertura de Testes**: [Percentual de cobertura esperado]
- **Localização do Relatório de Testes**: [Caminho para os relatórios de testes]

### 3. Corrigir Testes com Falha
Se os testes falharem:
1. Revise a saída dos testes em [localização]
2. Identifique os casos de teste com falha
3. Corrija os problemas no código
4. Reexecute os testes até que todos passem
```

---

## Etapa 4: Gerar Instruções de Testes de Integração

Criar `aidlc-docs/construction/build-and-test/integration-test-instructions.md`:

```markdown
# Instruções de Testes de Integração

## Propósito
Testar interações entre unidades/serviços para garantir que funcionem corretamente em conjunto.

## Cenários de Teste

### Cenário 1: Integração [Unidade A] → [Unidade B]
- **Descrição**: [O que está sendo testado]
- **Setup**: [Configuração necessária do ambiente de teste]
- **Etapas de Teste**: [Execução do teste passo a passo]
- **Resultados Esperados**: [O que deve acontecer]
- **Limpeza**: [Como limpar após o teste]

### Cenário 2: Integração [Unidade B] → [Unidade C]
[Estrutura semelhante]

## Configurar Ambiente de Testes de Integração

### 1. Iniciar Serviços Necessários
\`\`\`bash
[Comandos para iniciar serviços]
# Exemplo: docker-compose up, iniciar banco de dados de teste
\`\`\`

### 2. Configurar Endpoints dos Serviços
\`\`\`bash
[Comandos para configurar endpoints]
# Exemplo: export API_URL=http://localhost:8080
\`\`\`

## Executar Testes de Integração

### 1. Executar Suite de Testes de Integração
\`\`\`bash
[Comando para executar testes de integração]
# Exemplo: mvn integration-test, npm run test:integration
\`\`\`

### 2. Verificar Interações entre Serviços
- **Cenários de Teste**: [Liste os principais cenários de teste de integração]
- **Resultados Esperados**: [Descreva os resultados esperados]
- **Localização dos Logs**: [Onde verificar os logs]

### 3. Limpeza
\`\`\`bash
[Comandos para limpar o ambiente de teste]
# Exemplo: docker-compose down, parar serviços de teste
\`\`\`
```

---

## Etapa 5: Gerar Instruções de Testes de Desempenho (Se Aplicável)

Criar `aidlc-docs/construction/build-and-test/performance-test-instructions.md`:

```markdown
# Instruções de Testes de Desempenho

## Propósito
Validar o desempenho do sistema sob carga para garantir que atenda aos requisitos.

## Requisitos de Desempenho
- **Tempo de Resposta**: < [X]ms para [Y]% das requisições
- **Throughput**: [X] requisições/segundo
- **Usuários Concorrentes**: Suportar [X] usuários concorrentes
- **Taxa de Erro**: < [X]%

## Configurar Ambiente de Testes de Desempenho

### 1. Preparar Ambiente de Teste
\`\`\`bash
[Comandos para configurar testes de desempenho]
# Exemplo: escalar serviços, configurar load balancers
\`\`\`

### 2. Configurar Parâmetros de Teste
- **Duração do Teste**: [X] minutos
- **Tempo de Ramp-up**: [X] segundos
- **Usuários Virtuais**: [X] usuários

## Executar Testes de Desempenho

### 1. Executar Testes de Carga
\`\`\`bash
[Comando para executar testes de carga]
# Exemplo: jmeter -n -t test.jmx, k6 run script.js
\`\`\`

### 2. Executar Testes de Stress
\`\`\`bash
[Comando para executar testes de stress]
# Exemplo: aumentar a carga gradualmente até a falha
\`\`\`

### 3. Analisar Resultados de Desempenho
- **Tempo de Resposta**: [Real vs Esperado]
- **Throughput**: [Real vs Esperado]
- **Taxa de Erro**: [Real vs Esperado]
- **Gargalos**: [Gargalos identificados]
- **Localização dos Resultados**: [Caminho para os relatórios de desempenho]

## Otimização de Desempenho

Se o desempenho não atender aos requisitos:
1. Identifique gargalos a partir dos resultados dos testes
2. Otimize código/consultas/configurações
3. Reexecute os testes para validar as melhorias
```

---

## Etapa 6: Gerar Instruções de Testes Adicionais (Conforme Necessário)

Com base nos requisitos do projeto, gerar arquivos adicionais de instruções de testes:

### Testes de Contrato (Para Microsserviços)
Criar `aidlc-docs/construction/build-and-test/contract-test-instructions.md`:
- Validação de contrato de API entre serviços
- Testes de contrato orientados ao consumidor
- Validação de schema

### Testes de Segurança
Criar `aidlc-docs/construction/build-and-test/security-test-instructions.md`:
- Varredura de vulnerabilidades
- Verificações de segurança de dependências
- Testes de autenticação/autorização
- Testes de validação de entrada

### Testes End-to-End
Criar `aidlc-docs/construction/build-and-test/e2e-test-instructions.md`:
- Testes de fluxos de trabalho completos do usuário
- Cenários entre serviços
- Testes de UI (se aplicável)

---

## Etapa 7: Gerar Resumo de Testes

Criar `aidlc-docs/construction/build-and-test/build-and-test-summary.md`:

```markdown
# Resumo de Build e Testes

## Status do Build
- **Ferramenta de Build**: [Nome da ferramenta]
- **Status do Build**: [Sucesso/Falhou]
- **Artefatos de Build**: [Liste os artefatos]
- **Tempo de Build**: [Duração]

## Resumo da Execução de Testes

### Testes Unitários
- **Total de Testes**: [X]
- **Passaram**: [X]
- **Falharam**: [X]
- **Cobertura**: [X]%
- **Status**: [Passou/Falhou]

### Testes de Integração
- **Cenários de Teste**: [X]
- **Passaram**: [X]
- **Falharam**: [X]
- **Status**: [Passou/Falhou]

### Testes de Desempenho
- **Tempo de Resposta**: [Real] (Meta: [Esperado])
- **Throughput**: [Real] (Meta: [Esperado])
- **Taxa de Erro**: [Real] (Meta: [Esperado])
- **Status**: [Passou/Falhou]

### Testes Adicionais
- **Testes de Contrato**: [Passou/Falhou/N/A]
- **Testes de Segurança**: [Passou/Falhou/N/A]
- **Testes E2E**: [Passou/Falhou/N/A]

## Status Geral
- **Build**: [Sucesso/Falhou]
- **Todos os Testes**: [Passou/Falhou]
- **Pronto para Operations**: [Sim/Não]

## Próximos Passos
[Se tudo passou]: Pronto para prosseguir para a fase de Operations para planejamento de implantação
[Se houver falhas]: Corrija os testes com falha e recompile
```

---

## Etapa 8: Atualizar Rastreamento de Estado

Atualizar `aidlc-docs/aidlc-state.md`:
- Marcar o estágio de Build e Testes como completo
- Atualizar o status atual

---

## Etapa 9: Apresentar Resultados ao Usuário

Apresentar mensagem de conclusão nesta estrutura:
     1. **Anúncio de Conclusão** (obrigatório): Sempre comece com isto:

```markdown
# 🔨 Build e Testes Concluídos
```

     2. **Resumo da IA** (opcional): Fornecer resumo estruturado em tópicos dos resultados de build e testes
        - Formato: "Build e testes foram concluídos com os seguintes resultados:"
        - Listar status do build e artefatos
        - Listar resultados de testes por categoria (unitário, integração, desempenho, etc.)
        - Listar arquivos de instrução gerados
        - NÃO incluir instruções de workflow ("por favor revise", "me avise", "prossiga para a próxima fase", "antes de prosseguirmos")
        - Manter factual e focado no conteúdo
     3. **Mensagem Formatada de Workflow** (obrigatória): Sempre termine com este formato exato:

```markdown
> **📋 <u>**REVISÃO NECESSÁRIA:**</u>**  
> Por favor, examine o resumo de build e testes em: `aidlc-docs/construction/build-and-test/build-and-test-summary.md`



> **🚀 <u>**O QUE VEM A SEGUIR?**</u>**
>
> **Você pode:**
>
> 🔧 **Solicitar Alterações** - Pedir modificações nas instruções de build e testes com base na sua revisão
> ✅ **Aprovar e Continuar** - Aprovar resultados de build e testes e prosseguir para **Operations**

---
```

---

## Etapa 10: Registrar Interação

**OBRIGATÓRIO**: Registrar a conclusão do estágio em `aidlc-docs/audit.md`:

```markdown
## Estágio de Build e Testes
**Timestamp**: [ISO timestamp]
**Status do Build**: [Sucesso/Falhou]
**Status dos Testes**: [Passou/Falhou]
**Arquivos Gerados**:
- build-instructions.md
- unit-test-instructions.md
- integration-test-instructions.md
- performance-test-instructions.md
- build-and-test-summary.md

---
```
