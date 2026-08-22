# Guia de Formato de Perguntas

## OBRIGATÓRIO: Todas as Perguntas Devem Usar Este Formato

### Regra: Nunca Faça Perguntas no Chat
**CRÍTICO**: Você NUNCA deve fazer perguntas diretamente no chat. TODAS as perguntas devem ser colocadas em arquivos de perguntas dedicados.

### Formato do Arquivo de Perguntas

#### Convenção de Nomenclatura de Arquivos
- Use nomes descritivos: `{phase-name}-questions.md`
- Exemplos:
  - `classification-questions.md`
  - `requirements-questions.md`
  - `story-planning-questions.md`
  - `design-questions.md`

#### Estrutura da Pergunta
Toda pergunta deve incluir opções significativas mais "Outro" como a última opção:

```markdown
## Question [Number]
[Clear, specific question text]

A) [First meaningful option]

B) [Second meaningful option]

[...additional options as needed...]

X) Other (please describe after [Answer]: tag below)

[Answer]: 
```

**CRÍTICO**:
- "Other" / "Outro" é OBRIGATÓRIO como a ÚLTIMA opção para cada pergunta
- Inclua apenas opções significativas - não invente opções para preencher espaços
- Use tantas ou tão poucas opções quanto fizer sentido (mínimo 2 + Outro)
- **Cada opção deve ser separada por uma linha em branco** para que renderizadores CommonMark estritos (IntelliJ, PyCharm, etc.) as exibam em linhas separadas em vez de colapsá-las em um único parágrafo

### Exemplo Completo

```markdown
# Requirements Clarification Questions

Please answer the following questions to help clarify the requirements.

## Question 1
What is the primary user authentication method?

A) Username and password

B) Social media login (Google, Facebook)

C) Single Sign-On (SSO)

D) Multi-factor authentication

E) Other (please describe after [Answer]: tag below)

[Answer]: 

## Question 2
Will this be a web or mobile application?

A) Web application

B) Mobile application

C) Both web and mobile

D) Other (please describe after [Answer]: tag below)

[Answer]: 

## Question 3
Is this a new project or existing codebase?

A) New project (greenfield)

B) Existing codebase (brownfield)

C) Other (please describe after [Answer]: tag below)

[Answer]: 
```

### Formato de Resposta do Usuário
Os usuários responderão preenchendo a escolha de letra após a tag [Answer]:

```markdown
## Question 1
What is the primary user authentication method?

A) Username and password

B) Social media login (Google, Facebook)

C) Single Sign-On (SSO)

D) Multi-factor authentication

[Answer]: C
```

### Leitura das Respostas do Usuário
Após o usuário confirmar a conclusão:
1. Ler o arquivo de perguntas
2. Extrair respostas após as tags [Answer]:
3. Validar que todas as perguntas foram respondidas
4. Prosseguir com a análise com base nas respostas

### Diretrizes de Múltipla Escolha

#### Contagem de Opções
- Mínimo: 2 opções significativas + "Other" (A, B, C)
- Típico: 3-4 opções significativas + "Other" (A, B, C, D, E)
- Máximo: 5 opções significativas + "Other" (A, B, C, D, E, F)
- **CRÍTICO**: Não invente opções apenas para preencher espaços - inclua apenas escolhas significativas

#### Qualidade das Opções
- Torne as opções mutuamente exclusivas
- Cubra os cenários mais comuns
- Inclua apenas opções significativas e realistas
- **SEMPRE inclua "Other" como a ÚLTIMA opção** (OBRIGATÓRIO)
- Seja específico e claro
- **Não invente opções para preencher os espaços A, B, C, D**

#### Bom Exemplo:
```markdown
## Question 5
What database technology will be used?

A) Relational (PostgreSQL, MySQL)

B) NoSQL Document (MongoDB, DynamoDB)

C) NoSQL Key-Value (Redis, Memcached)

D) Graph Database (Neo4j, Neptune)

E) Other (please describe after [Answer]: tag below)

[Answer]: 
```

#### Mau Exemplo (Evitar):
```markdown
## Question 5
What database will you use?

A) Yes

B) No

C) Maybe

[Answer]: 
```

### Integração com o Workflow

#### Etapa 1: Criar Arquivo de Perguntas
```markdown
Create aidlc-docs/{phase-name}-questions.md with all questions
```

#### Etapa 2: Informar o Usuário
```
"Criei {phase-name}-questions.md com [X] perguntas. 
Por favor, responda cada pergunta preenchendo a escolha de letra após a tag [Answer]:. 
Se nenhuma das opções corresponder às suas necessidades, escolha a última opção (Other) e descreva sua preferência. Avise-me quando terminar."
```

#### Etapa 3: Aguardar Confirmação
Aguarde o usuário dizer "done", "completed", "finished", "pronto", "concluído" ou similar.

#### Etapa 4: Ler e Analisar
```
Read aidlc-docs/{phase-name}-questions.md
Extract all answers
Validate completeness
Proceed with analysis
```

### Tratamento de Erros

#### Respostas Ausentes
Se alguma tag [Answer]: estiver vazia:
```
"Notei que a Pergunta [X] não foi respondida. Por favor, forneça uma resposta usando uma das escolhas de letra 
para todas as perguntas antes de prosseguir."
```

#### Respostas Inválidas
Se a resposta não for uma escolha de letra válida:
```
"A Pergunta [X] tem uma resposta inválida '[answer]'. 
Por favor, use apenas as escolhas de letra fornecidas na pergunta."
```

#### Respostas Ambíguas
Se o usuário fornecer explicação em vez de letra:
```
"Para a Pergunta [X], por favor forneça a escolha de letra que melhor corresponde à sua resposta. 
Se nenhuma corresponder, escolha 'Other' e adicione sua descrição após a tag [Answer]:."
```

### Detecção de Contradições e Ambiguidades

**OBRIGATÓRIO**: Após ler as respostas do usuário, você DEVE verificar contradições e ambiguidades.

#### Detectando Contradições
Procure respostas logicamente inconsistentes:
- Incompatibilidade de escopo: "Correção de bug" mas "Toda a base de código afetada"
- Incompatibilidade de risco: "Baixo risco" mas "Mudanças que quebram compatibilidade"
- Incompatibilidade de prazo: "Correção rápida" mas "Múltiplos subsistemas"
- Incompatibilidade de impacto: "Componente único" mas "Mudanças significativas de arquitetura"

#### Detectando Ambiguidades
Procure respostas pouco claras ou limítrofes:
- Respostas que poderiam se encaixar em múltiplas classificações
- Respostas que carecem de especificidade
- Indicadores conflitantes entre múltiplas perguntas

#### Criando Perguntas de Esclarecimento
Se contradições ou ambiguidades forem detectadas:

1. **Criar arquivo de esclarecimento**: `{phase-name}-clarification-questions.md`
2. **Explicar o problema**: Declare claramente qual contradição/ambiguidade foi detectada
3. **Fazer perguntas direcionadas**: Use formato de múltipla escolha para resolver o problema
4. **Referenciar perguntas originais**: Mostre quais perguntas tiveram respostas conflitantes

**Exemplo**:
```markdown
# [Phase Name] Clarification Questions

I detected contradictions in your responses that need clarification:

## Contradiction 1: [Brief Description]
You indicated "[Answer A]" (Q[X]:[Letter]) but also "[Answer B]" (Q[Y]:[Letter]).
These responses are contradictory because [explanation].

### Clarification Question 1
[Specific question to resolve contradiction]

A) [Option that resolves toward first answer]

B) [Option that resolves toward second answer]

C) [Option that provides middle ground]

D) [Option that reframes the question]

[Answer]: 

## Ambiguity 1: [Brief Description]
Your response to Q[X] ("[Answer]") is ambiguous because [explanation].

### Clarification Question 2
[Specific question to clarify ambiguity]

A) [Clear option 1]

B) [Clear option 2]

C) [Clear option 3]

D) [Clear option 4]

[Answer]: 
```

#### Workflow para Esclarecimentos

1. **Detectar**: Analisar todas as respostas em busca de contradições/ambiguidades
2. **Criar**: Gerar arquivo de perguntas de esclarecimento se problemas forem encontrados
3. **Informar**: Contar ao usuário sobre os problemas e o arquivo de esclarecimento
4. **Aguardar**: Não prosseguir até que o usuário forneça esclarecimentos
5. **Revalidar**: Após esclarecimentos, verificar novamente a consistência
6. **Prosseguir**: Avançar apenas quando todas as contradições forem resolvidas

#### Exemplo de Mensagem ao Usuário
```
"Detectei 2 contradições nas suas respostas:

1. Escopo de correção de bug vs. impacto na base de código (Q1 vs Q2)
2. Baixo risco vs. mudanças que quebram compatibilidade (Q7 vs Q4)

Criei classification-clarification-questions.md com 2 perguntas para resolver isso.
Por favor, responda estas perguntas de esclarecimento antes que eu possa prosseguir com a classificação."
```

### Melhores Práticas

1. **Seja Específico**: As perguntas devem ser claras e inequívocas
2. **Seja Abrangente**: Cubra todas as informações necessárias
3. **Seja Conciso**: Mantenha as perguntas focadas em um tópico
4. **Seja Prático**: As opções devem ser realistas e acionáveis
5. **Seja Consistente**: Use o mesmo formato em todos os arquivos de perguntas

### Exemplos Específicos por Fase

#### Exemplo com 2 opções significativas:
```markdown
## Question 1
Is this a new project or existing codebase?

A) New project (greenfield)

B) Existing codebase (brownfield)

C) Other (please describe after [Answer]: tag below)

[Answer]: 
```

#### Exemplo com 3 opções significativas:
```markdown
## Question 2
What is the deployment target?

A) Cloud (AWS, Azure, GCP)

B) On-premises servers

C) Hybrid (both cloud and on-premises)

D) Other (please describe after [Answer]: tag below)

[Answer]: 
```

#### Exemplo com 4 opções significativas:
```markdown
## Question 3
What architectural pattern should be used?

A) Monolithic architecture

B) Microservices architecture

C) Serverless architecture

D) Event-driven architecture

E) Other (please describe after [Answer]: tag below)

[Answer]: 
```

## Resumo

**Lembre-se**: 
- ✅ Sempre criar arquivos de perguntas
- ✅ Sempre usar formato de múltipla escolha
- ✅ **Sempre incluir "Other" como a ÚLTIMA opção (OBRIGATÓRIO)**
- ✅ Incluir apenas opções significativas - não inventar opções para preencher espaços
- ✅ Sempre usar tags [Answer]:
- ✅ Sempre aguardar a conclusão do usuário
- ✅ Sempre validar respostas em busca de contradições
- ✅ Sempre criar arquivos de esclarecimento se necessário
- ✅ Sempre resolver contradições antes de prosseguir
- ❌ Nunca fazer perguntas no chat
- ❌ Nunca inventar opções apenas para ter A, B, C, D
- ❌ Nunca prosseguir sem respostas
- ❌ Nunca prosseguir com contradições não resolvidas
- ❌ Nunca fazer pressupostos sobre respostas ambíguas
