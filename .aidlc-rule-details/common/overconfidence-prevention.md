# Guia de Prevenção de Excesso de Confiança

## Declaração do Problema

O AI-DLC estava exibindo excesso de confiança ao não fazer perguntas de esclarecimento suficientes, mesmo para declarações de intenção de projeto complexas. Isso levou a pressupostos sendo feitos em vez de reunir requisitos adequados.

## Análise da Causa Raiz

O problema de excesso de confiança foi causado por diretivas em múltiplos estágios que incentivavam pular perguntas:

1. **Design Funcional**: "Pule categorias inteiras se não forem aplicáveis"
2. **Histórias de Usuário**: "Use categorias como inspiração, NÃO como checklist obrigatório"
3. **Análise de Requisitos**: Padrões semelhantes incentivando questionamento mínimo
4. **Requisitos NFR**: Condições "somente se" que desencorajavam análise completa

Essas diretivas estavam dizendo à IA para evitar fazer perguntas em vez de incentivar o levantamento abrangente de requisitos.

## Solução Implementada

### Filosofia Atualizada de Geração de Perguntas

**ABORDAGEM ANTIGA**: "Só faça perguntas se absolutamente necessário"
**NOVA ABORDAGEM**: "Na dúvida, faça a pergunta - o excesso de confiança leva a resultados ruins"

### Principais Mudanças Realizadas

#### 1. Estágio de Análise de Requisitos
- Mudou de "somente se necessário" para "SEMPRE criar perguntas a menos que excepcionalemente claro"
- Adicionou áreas abrangentes de avaliação (funcional, não funcional, contexto de negócio, contexto técnico)
- Enfatizou abordagem proativa de questionamento

#### 2. Estágio de Histórias de Usuário
- Removeu a diretiva "pular categorias inteiras"
- Adicionou categorias abrangentes de perguntas a avaliar
- Aprimorou requisitos de análise de respostas
- Fortaleceu mandatos de perguntas de acompanhamento

#### 3. Estágio de Design Funcional
- Substituiu condições "somente se" por avaliação abrangente
- Adicionou mais categorias de perguntas (fluxo de dados, pontos de integração, tratamento de erros)
- Fortaleceu requisitos de detecção e resolução de ambiguidades

#### 4. Estágio de Requisitos NFR
- Expandiu categorias de perguntas além de NFRs básicos
- Adicionou considerações de confiabilidade, manutenibilidade e usabilidade
- Aprimorou análise de respostas para ambiguidades técnicas

### Novos Princípios Orientadores

1. **Padrão: Perguntar**: Quando houver qualquer ambiguidade, faça perguntas de esclarecimento
2. **Cobertura Abrangente**: Avalie TODAS as categorias relevantes, não pule áreas
3. **Análise Completa**: Analise cuidadosamente TODAS as respostas do usuário em busca de ambiguidades
4. **Acompanhamento Obrigatório**: Crie perguntas de acompanhamento para QUALQUER resposta pouco clara
5. **Não Prosseguir com Ambiguidade**: Não avance até que TODAS as ambiguidades sejam resolvidas

## Diretrizes de Implementação

### Para Geração de Perguntas
- Avalie TODAS as categorias de perguntas, não pule nenhuma
- Faça perguntas sempre que o esclarecimento melhorar a qualidade
- Inclua categorias abrangentes de perguntas em cada estágio
- Por padrão, inclua perguntas em vez de excluí-las

### Para Análise de Respostas
- Procure respostas vagas: "depende", "talvez", "não tenho certeza", "mistura de", "algo entre"
- Detecte termos indefinidos e referências a conceitos externos
- Identifique respostas contraditórias ou incompletas
- Crie perguntas de acompanhamento para QUALQUER ambiguidade

### Para Perguntas de Acompanhamento
- Crie arquivos de esclarecimento separados quando ambiguidades forem detectadas
- Faça perguntas específicas para resolver cada ambiguidade
- Não prossiga até que TODAS as respostas pouco claras sejam esclarecidas
- Seja minucioso - é melhor esclarecer demais do que esclarecer de menos

## Garantia de Qualidade

### Sinais de Alerta a Observar
- Estágios concluindo sem fazer nenhuma pergunta em projetos complexos
- Prosseguir com respostas vagas ou ambíguas do usuário
- Pular categorias inteiras de perguntas sem justificativa
- Fazer pressupostos em vez de pedir esclarecimento

### Indicadores de Sucesso
- Número apropriado de perguntas de esclarecimento para a complexidade do projeto
- Análise completa das respostas do usuário com acompanhamento quando necessário
- Requisitos claros e inequívocos antes de prosseguir para a implementação
- Necessidade reduzida de mudanças em estágios posteriores devido a melhor esclarecimento inicial

## Manutenção

Este guia deve ser consultado quando:
- Adicionar novos estágios ao AI-DLC
- Atualizar instruções de estágios existentes
- Revisar o desempenho do AI-DLC quanto a problemas de excesso de confiança
- Treinar membros da equipe nos princípios de geração de perguntas do AI-DLC

## Conclusão Principal

**É melhor fazer perguntas demais do que fazer pressupostos incorretos.** O custo de fazer perguntas de esclarecimento no início é muito menor do que o custo de implementar a solução errada com base em pressupostos.
