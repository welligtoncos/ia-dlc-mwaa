# Regras de Validação de Conteúdo

## OBRIGATÓRIO: Validação de Conteúdo Antes da Criação de Arquivos

**CRÍTICO**: Todo conteúdo gerado DEVE ser validado antes de ser escrito em arquivos para prevenir erros de parsing.

## Padrões de Diagramas ASCII

**CRÍTICO**: Antes de criar QUALQUER arquivo com diagramas ASCII:

1. **CARREGUE** `common/ascii-diagram-standards.md`
2. **VALIDE** cada diagrama:
   - Conte caracteres por linha (todas as linhas DEVEM ter a mesma largura)
   - Use APENAS: `+` `-` `|` `^` `v` `<` `>` e espaços
   - SEM caracteres Unicode de desenho de caixas
   - Apenas espaços (SEM tabs)
3. **TESTE** o alinhamento verificando se os cantos das caixas alinham verticalmente

**Veja `common/ascii-diagram-standards.md` para padrões e checklist de validação.**

## Validação de Diagramas Mermaid

### Etapas de Validação Obrigatórias
1. **Verificação de Sintaxe**: Validar sintaxe Mermaid antes da criação do arquivo
2. **Escape de Caracteres**: Garantir que caracteres especiais sejam devidamente escapados
3. **Conteúdo Alternativo**: Fornecer alternativa em texto se o Mermaid falhar na validação

### Regras de Validação Mermaid
```markdown
## BEFORE creating any file with Mermaid diagrams:

1. Check for invalid characters in node IDs (use alphanumeric + underscore only)
2. Escape special characters in labels: " → \" and ' → \'
3. Validate flowchart syntax: node connections must be valid
4. Test diagram parsing with simple validation

## FALLBACK: If Mermaid validation fails, use text-based workflow representation
```

### Padrão de Implementação
```markdown
## Workflow Visualization

### Mermaid Diagram (if syntax valid)
```mermaid
[validated diagram content]
```

### Text Alternative (always include)
```
Phase 1: INCEPTION
- Stage 1: Workspace Detection (COMPLETED)
- Stage 2: Requirements Analysis (COMPLETED)
[continue with text representation]
```

## Validação Geral de Conteúdo

### Checklist de Validação Pré-Criação
- [ ] Validar blocos de código embutidos (Mermaid, JSON, YAML)
- [ ] Verificar escape de caracteres especiais
- [ ] Verificar correção da sintaxe markdown
- [ ] Testar compatibilidade de parsing do conteúdo
- [ ] Incluir conteúdo alternativo para elementos complexos

### Regras de Prevenção de Erros
1. **Sempre validar antes de usar ferramentas/comandos para escrever arquivos**: Nunca escreva conteúdo não validado
2. **Escapar caracteres especiais**: Particularmente em diagramas e blocos de código
3. **Fornecer alternativas**: Incluir versões em texto de conteúdo visual
4. **Testar sintaxe**: Validar estruturas de conteúdo complexas

## Tratamento de Falha de Validação

### Quando a Validação Falha
1. **Registrar o erro**: Documentar o que falhou na validação
2. **Usar conteúdo alternativo**: Alternar para alternativa baseada em texto
3. **Continuar o workflow**: Não bloquear por falhas de validação de conteúdo
4. **Informar o usuário**: Mencionar que conteúdo simplificado foi usado devido a restrições de parsing
