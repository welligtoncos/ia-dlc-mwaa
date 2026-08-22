# Padrões de Diagramas ASCII

## OBRIGATÓRIO: Usar Apenas ASCII Básico

**CRÍTICO**: SEMPRE use caracteres ASCII básicos para diagramas (máxima compatibilidade).

### ✅ PERMITIDO: `+` `-` `|` `^` `v` `<` `>` e texto alfanumérico

### ❌ PROIBIDO: Caracteres Unicode de desenho de caixas
- NÃO: `┌` `─` `│` `└` `┐` `┘` `├` `┤` `┬` `┴` `┼` `▼` `▲` `►` `◄`
- Motivo: Renderização inconsistente entre fontes/plataformas

## Padrões Padrão de Diagramas ASCII

### CRÍTICO: Regra de Largura de Caracteres
**Cada linha em uma caixa DEVE ter EXATAMENTE a mesma contagem de caracteres (incluindo espaços)**

✅ CORRETO (todas as linhas = 67 chars):
```
+---------------------------------------------------------------+
|                      Component Name                           |
|  Description text here                                        |
+---------------------------------------------------------------+
```

❌ ERRADO (larguras inconsistentes):
```
+---------------------------------------------------------------+
|                      Component Name                           |
|  Description text here                                   |
+---------------------------------------------------------------+
```

### Padrão de Caixa
```
+-----------------------------------------------------+
|                                                     |
|              Calculator Application                 |
|                                                     |
|  Provides basic arithmetic operations for users     |
|  through a web-based interface                      |
|                                                     |
+-----------------------------------------------------+
```

### Caixas Aninhadas
```
+-------------------------------------------------------+
|              Web Server (PHP Runtime)                 |
|  +-------------------------------------------------+  |
|  |  index.php (Monolithic Application)             |  |
|  |  +-------------------------------------------+  |  |
|  |  |  HTML Template (View Layer)               |  |  |
|  |  |  - Form rendering                         |  |  |
|  |  |  - Result display                         |  |  |
|  |  +-------------------------------------------+  |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
```

### Setas e Conexões
```
+----------+
|  Source  |
+----------+
     |
     | HTTP POST
     v
+----------+
|  Target  |
+----------+
```

### Fluxo Horizontal
```
+-------+     +-------+     +-------+
| Step1 | --> | Step2 | --> | Step3 |
+-------+     +-------+     +-------+
```

### Fluxo Vertical com Rótulos
```
User Action Flow:
    |
    v
+----------+
|  Input   |
+----------+
    |
    | validates
    v
+----------+
| Process  |
+----------+
    |
    | returns
    v
+----------+
|  Output  |
+----------+
```

## Validação

Antes de criar diagramas:
- [ ] Apenas ASCII básico: `+` `-` `|` `^` `v` `<` `>`
- [ ] Sem Unicode de desenho de caixas
- [ ] Espaços (não tabs) para alinhamento
- [ ] Cantos usam `+`
- [ ] **TODAS as linhas da caixa com a mesma largura de caracteres** (conte caracteres incluindo espaços)
- [ ] Teste: Verifique se os cantos alinham verticalmente em fonte monoespaçada

## Alternativa

Para diagramas complexos, use Mermaid (veja `content-validation.md`)
