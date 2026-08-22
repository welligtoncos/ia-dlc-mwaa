# Procedimentos de Tratamento de Erros e Recuperação

## Princípios Gerais de Tratamento de Erros

### Quando Ocorrem Erros
1. **Identificar o erro**: Declare claramente o que deu errado
2. **Avaliar o impacto**: Determine se o erro é bloqueante ou pode ser contornado
3. **Comunicar**: Informe o usuário sobre o erro e as opções
4. **Oferecer soluções**: Forneça etapas claras para resolver ou contornar o erro
5. **Documentar**: Registre o erro e a resolução em `audit.md`

### Níveis de Severidade de Erro

**Crítico**: O workflow não pode continuar
- Arquivos ou artefatos obrigatórios ausentes
- Entrada inválida do usuário que não pode ser processada
- Erros de sistema impedindo operações de arquivo

**Alto**: O estágio não pode ser concluído conforme planejado
- Respostas incompletas a perguntas obrigatórias
- Respostas contraditórias do usuário
- Dependências ausentes de estágios anteriores

**Médio**: O estágio pode continuar com contornos
- Artefatos opcionais ausentes
- Falhas de validação não críticas
- Conclusão parcial possível

**Baixo**: Problemas menores que não bloqueiam o progresso
- Inconsistências de formatação
- Informações opcionais ausentes
- Avisos não bloqueantes

## Tratamento de Erros Específico por Estágio

### Erros de Detecção do Workspace

**Erro**: Não é possível ler arquivos do workspace
- **Causa**: Problemas de permissão, diretórios ausentes
- **Solução**: Peça ao usuário para verificar o caminho do workspace e as permissões
- **Contorno**: Prosseguir apenas com informações fornecidas pelo usuário

**Erro**: `aidlc-state.md` existente está corrompido
- **Causa**: Edição manual, execução anterior incompleta
- **Solução**: Pergunte ao usuário se deseja começar do zero ou tentar recuperação
- **Recuperação**: Criar backup, iniciar novo arquivo de estado

**Erro**: Não é possível determinar os estágios necessários
- **Causa**: Informações insuficientes do usuário
- **Solução**: Fazer perguntas de esclarecimento sobre intenção e escopo
- **Contorno**: Por padrão, usar plano de execução abrangente

### Erros de Análise de Requisitos

**Erro**: Usuário fornece requisitos contraditórios
- **Causa**: Entendimento pouco claro, necessidades em mudança
- **Solução**: Criar perguntas de acompanhamento para resolver contradições
- **Não Prosseguir**: Até que as contradições sejam resolvidas

**Erro**: Documento de requisitos não pode ser convertido
- **Causa**: Formato não suportado, arquivo corrompido
- **Solução**: Peça ao usuário para fornecer requisitos em formato suportado
- **Contorno**: Trabalhar com a descrição verbal do usuário

**Erro**: Respostas incompletas às perguntas de verificação
- **Causa**: Usuário pulou perguntas, pouco claro o que responder
- **Solução**: Destacar perguntas sem resposta, fornecer exemplos
- **Não Prosseguir**: Até que todas as perguntas obrigatórias sejam respondidas

### Erros de Histórias de Usuário

**Erro**: Não é possível mapear requisitos para histórias
- **Causa**: Requisitos muito vagos, detalhes funcionais ausentes
- **Solução**: Retornar à Análise de Requisitos para esclarecimento
- **Contorno**: Criar histórias com base nas informações disponíveis, marcar como incompletas

**Erro**: Usuário fornece respostas ambíguas no planejamento de histórias
- **Causa**: Opções pouco claras, decisão complexa
- **Solução**: Adicionar perguntas de acompanhamento com exemplos específicos
- **Não Prosseguir**: Até que as ambiguidades sejam resolvidas

**Erro**: Plano de geração de histórias tem etapas não concluídas
- **Causa**: Execução interrompida, etapas puladas
- **Solução**: Retomar a partir da primeira etapa não concluída
- **Recuperação**: Revisar etapas concluídas, continuar a partir do checkpoint

### Erros de Design da Aplicação

**Erro**: Decisão arquitetural está pouco clara ou contraditória
- **Causa**: Respostas ambíguas, requisitos conflitantes
- **Solução**: Adicionar perguntas de acompanhamento para esclarecer a decisão
- **Não Prosseguir**: Até que a decisão esteja clara e documentada

**Erro**: Não é possível determinar o número de serviços/unidades
- **Causa**: Informações insuficientes sobre limites
- **Solução**: Fazer perguntas específicas sobre implantação, estrutura da equipe, escalabilidade
- **Contorno**: Por padrão, usar monólito, permitir mudança depois

### Erros de Design

**Erro**: Dependências de unidades são circulares
- **Causa**: Definição ruim de limites, acoplamento forte
- **Solução**: Identificar dependências circulares, sugerir refatoração
- **Recuperação**: Revisar limites das unidades para quebrar ciclos

**Erro**: Plano de design da unidade tem etapas ausentes
- **Causa**: Geração do plano incompleta, erro de template
- **Solução**: Regenerar plano com todas as etapas obrigatórias
- **Recuperação**: Adicionar etapas ausentes ao plano existente

**Erro**: Não é possível gerar artefatos de design
- **Causa**: Informações da unidade ausentes, requisitos pouco claros
- **Solução**: Retornar à Geração de Unidades para esclarecer a definição da unidade
- **Contorno**: Gerar design parcial, marcar lacunas

### Erros de Implementação NFR

**Erro**: Escolhas de stack tecnológica são incompatíveis
- **Causa**: Requisitos conflitantes, limitações de plataforma
- **Solução**: Destacar incompatibilidades, pedir ao usuário para escolher
- **Não Prosseguir**: Até que escolhas compatíveis sejam feitas

**Erro**: Restrições organizacionais não podem ser atendidas
- **Causa**: Restrições de rede, políticas de segurança
- **Solução**: Documentar restrições, pedir ao usuário contornos
- **Escalação**: Pode exigir intervenção humana para configuração

**Erro**: Etapa de implementação NFR exige ação humana
- **Causa**: A IA não pode realizar certas tarefas (config de rede, credenciais)
- **Solução**: Marcar claramente como **TAREFA HUMANA**, fornecer instruções
- **Aguardar**: Confirmação do usuário antes de prosseguir

### Erros de Planejamento de Geração de Código

**Erro**: Plano de geração de código está incompleto
- **Causa**: Artefatos de design ausentes, requisitos pouco claros
- **Solução**: Retornar ao estágio de Design para completar artefatos
- **Recuperação**: Gerar plano com informações disponíveis, marcar lacunas

**Erro**: Dependências de unidades não satisfeitas
- **Causa**: Unidades dependentes ainda não geradas
- **Solução**: Reordenar a sequência de geração para respeitar dependências
- **Contorno**: Gerar com dependências stub, integrar depois

### Erros de Geração de Código (Parte 2: Geração de Código)

**Erro**: Não é possível gerar código para uma etapa
- **Causa**: Informações de design insuficientes, requisitos pouco claros
- **Solução**: Pular etapa, documentar como incompleta, continuar
- **Recuperação**: Retornar à etapa após reunir mais informações

**Erro**: Código gerado tem erros de sintaxe
- **Causa**: Problemas de template, problemas específicos da linguagem
- **Solução**: Corrigir erros de sintaxe, regenerar se necessário
- **Validação**: Verificar se o código compila antes de prosseguir

**Erro**: Geração de testes falha
- **Causa**: Lógica complexa, configuração de framework de testes ausente
- **Solução**: Gerar estrutura básica de testes, marcar para conclusão manual
- **Contorno**: Prosseguir sem testes, adicionar na fase de Operations

### Erros de Operations

**Erro**: Não é possível determinar a ferramenta de build
- **Causa**: Estrutura de projeto incomum, múltiplos sistemas de build
- **Solução**: Peça ao usuário para especificar a ferramenta de build e comandos
- **Contorno**: Fornecer instruções genéricas, usuário adapta

**Erro**: Alvo de implantação está pouco claro
- **Causa**: Múltiplos ambientes, infraestrutura complexa
- **Solução**: Peça ao usuário para especificar alvos e métodos de implantação
- **Contorno**: Fornecer instruções para plataformas comuns

## Procedimentos de Recuperação

### Conclusão Parcial do Estágio

**Cenário**: Estágio foi interrompido no meio da execução

**Etapas de Recuperação**:
1. Carregar o arquivo de plano do estágio
2. Identificar a última etapa concluída (último checkbox [x])
3. Retomar a partir da próxima etapa não concluída
4. Verificar se todas as etapas anteriores estão realmente concluídas
5. Continuar a execução normalmente

### Arquivo de Estado Corrompido

**Cenário**: `aidlc-state.md` está corrompido ou inconsistente

**Etapas de Recuperação**:
1. Criar backup: `aidlc-state.md.backup`
2. Perguntar ao usuário em qual estágio ele realmente está
3. Regenerar arquivo de estado do zero
4. Marcar estágios concluídos com base nos artefatos existentes
5. Retomar a partir do estágio atual

### Artefatos Ausentes

**Cenário**: Artefatos obrigatórios de estágio anterior estão ausentes

**Etapas de Recuperação**:
1. Identificar quais artefatos estão ausentes
2. Determinar se podem ser regenerados
3. Se sim: Retornar àquele estágio, regenerar artefatos
4. Se não: Pedir ao usuário para fornecer informações manualmente
5. Documentar a lacuna em `audit.md`

### Usuário Quer Reiniciar o Estágio

**Cenário**: Usuário está insatisfeito com os resultados do estágio e quer refazer

**Etapas de Recuperação**:
1. Confirmar que o usuário quer reiniciar (dados serão perdidos)
2. Arquivar artefatos existentes: `{artifact}.backup`
3. Resetar status do estágio em `aidlc-state.md`
4. Limpar checkboxes do estágio nos arquivos de plano
5. Reexecutar o estágio desde o início

### Usuário Quer Pular o Estágio

**Cenário**: Usuário quer pular um estágio que foi planejado

**Etapas de Recuperação**:
1. Confirmar que o usuário entende as implicações
2. Documentar o motivo do pulo em `audit.md`
3. Marcar o estágio como "SKIPPED" em `aidlc-state.md`
4. Prosseguir para o próximo estágio
5. Nota: Pode causar problemas em estágios posteriores se dependências estiverem ausentes

## Diretrizes de Escalação

### Quando Pedir Ajuda ao Usuário

**Imediatamente**:
- Entrada do usuário contraditória ou ambígua
- Informações obrigatórias ausentes
- Restrições técnicas que a IA não pode resolver
- Decisões que exigem julgamento de negócio

**Após Tentar Resolução**:
- Erros repetidos na mesma etapa
- Problemas técnicos complexos
- Estruturas de projeto incomuns
- Integração com sistemas externos

### Quando Sugerir Começar do Zero

**Considere um Novo Começo Se**:
- Múltiplos estágios têm erros
- Arquivo de estado está severamente corrompido
- Requisitos do usuário mudaram significativamente
- Decisão arquitetural precisa ser revertida
- Usuário não pode fornecer informações ausentes
- Artefatos são inconsistentes entre fases

**Antes de Começar do Zero**:
1. Arquivar todo o trabalho existente
2. Documentar lições aprendidas
3. Identificar o que preservar
4. Obter confirmação do usuário
5. Criar novo plano de execução

## Erros de Retomada de Sessão

### Artefatos Ausentes Durante a Retomada

**Erro**: Artefatos obrigatórios de estágios anteriores estão ausentes
- **Causa**: Arquivos excluídos, movidos ou nunca criados
- **Solução**: 
  1. Identificar qual estágio criou os artefatos ausentes
  2. Verificar se o estágio foi marcado como completo em aidlc-state.md
  3. Se marcado como completo mas artefatos ausentes: Regenerar aquele estágio
  4. Se não marcado como completo: Retomar a partir daquele estágio
- **Recuperação**: Retornar ao estágio que cria os artefatos ausentes e reexecutar

**Erro**: Arquivo de artefato existe mas está vazio ou corrompido
- **Causa**: Escrita interrompida, edição manual, problemas de sistema de arquivos
- **Solução**:
  1. Criar backup do arquivo corrompido
  2. Tentar regenerar a partir do estágio que o cria
  3. Se não puder regenerar: Pedir ao usuário informações para recriar
- **Recuperação**: Reexecutar o estágio que cria o artefato

### Estado Inconsistente Durante a Retomada

**Erro**: aidlc-state.md mostra estágio completo mas artefatos não existem
- **Causa**: Arquivo de estado atualizado mas geração de artefato falhou
- **Solução**:
  1. Marcar estágio como incompleto em aidlc-state.md
  2. Reexecutar o estágio para gerar artefatos
  3. Verificar se artefatos existem antes de marcar como completo
- **Recuperação**: Resetar status do estágio e reexecutar

**Erro**: Artefatos existem mas aidlc-state.md mostra estágio incompleto
- **Causa**: Geração de artefato teve sucesso mas atualização de estado falhou
- **Solução**:
  1. Verificar se os artefatos estão completos e válidos
  2. Atualizar aidlc-state.md para marcar estágio como completo
  3. Prosseguir para o próximo estágio
- **Recuperação**: Atualizar arquivo de estado para refletir a conclusão real

**Erro**: Múltiplos estágios marcados como "current" em aidlc-state.md
- **Causa**: Corrupção do arquivo de estado, edição manual
- **Solução**:
  1. Revisar artefatos para determinar o progresso real
  2. Perguntar ao usuário em qual estágio ele realmente está
  3. Corrigir aidlc-state.md para mostrar um único estágio atual
- **Recuperação**: Reconstruir arquivo de estado com base nos artefatos existentes

### Erros de Carregamento de Contexto

**Erro**: Não é possível carregar o contexto obrigatório de estágios anteriores
- **Causa**: Arquivos ausentes, conteúdo corrompido, caminhos de arquivo errados
- **Solução**:
  1. Listar quais artefatos são necessários para o estágio atual
  2. Verificar quais estão ausentes ou corrompidos
  3. Regenerar artefatos ausentes ou pedir informações ao usuário
- **Recuperação**: Completar estágios pré-requisitos antes de retomar o estágio atual

**Erro**: Artefatos carregados contêm informações contraditórias
- **Causa**: Edição manual, múltiplas pessoas trabalhando, atualizações incompletas
- **Solução**:
  1. Identificar contradições e apresentar ao usuário
  2. Perguntar ao usuário qual informação está correta
  3. Atualizar artefatos para resolver contradições
- **Recuperação**: Reconciliar contradições antes de prosseguir

### Melhores Práticas de Retomada

1. **Sempre validar o estado**: Verificar se aidlc-state.md corresponde aos artefatos reais
2. **Carregar incrementalmente**: Carregar artefatos estágio por estágio, validar cada um
3. **Falhar rápido**: Parar imediatamente se artefatos críticos estiverem ausentes
4. **Comunicar claramente**: Dizer ao usuário exatamente o que está ausente e por que é necessário
5. **Oferecer opções**: Regenerar, fornecer manualmente ou começar do zero
6. **Documentar a recuperação**: Registrar todas as ações de recuperação em audit.md

## Requisitos de Registro

### Formato de Registro de Erro

```markdown
## Error - [Stage Name]
**Timestamp**: [ISO timestamp]
**Error Type**: [Critical/High/Medium/Low]
**Description**: [What went wrong]
**Cause**: [Why it happened]
**Resolution**: [How it was resolved]
**Impact**: [Effect on workflow]

---
```

### Formato de Registro de Recuperação

```markdown
## Recovery - [Stage Name]
**Timestamp**: [ISO timestamp]
**Issue**: [What needed recovery]
**Recovery Steps**: [What was done]
**Outcome**: [Result of recovery]
**Artifacts Affected**: [List of files]

---
```

## Melhores Práticas de Prevenção

1. **Validar Cedo**: Verificar entradas e dependências antes de iniciar o trabalho
2. **Fazer Checkpoint Frequentemente**: Atualizar checkboxes imediatamente após concluir etapas
3. **Comunicar Claramente**: Explicar o que você está fazendo e por quê
4. **Fazer Perguntas**: Não pressupor - esclareça ambiguidades imediatamente
5. **Documentar Tudo**: Registrar todas as decisões e mudanças em `audit.md`
