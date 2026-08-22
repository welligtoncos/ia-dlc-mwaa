# Templates de Continuidade de Sessão

## Template de Prompt de Boas-Vindas de Retorno
Quando um usuário retorna para continuar o trabalho em um projeto AI-DLC existente, apresente este prompt:

```markdown
**Bem-vindo de volta! Posso ver que você tem um projeto AI-DLC existente em andamento.**

Com base no seu aidlc-state.md, aqui está o status atual:
- **Projeto**: [project-name]
- **Fase Atual**: [INCEPTION/CONSTRUCTION/OPERATIONS]
- **Estágio Atual**: [Stage Name]
- **Último Concluído**: [Last completed step]
- **Próxima Etapa**: [Next step to work on]

**No que você gostaria de trabalhar hoje?**

A) Continuar de onde parou ([Next step description])

B) Revisar um estágio anterior ([Show available stages])

[Answer]: 
```

## OBRIGATÓRIO: Instruções de Continuidade de Sessão
1. **Sempre ler aidlc-state.md primeiro** ao detectar projeto existente
2. **Analisar o status atual** a partir do arquivo de workflow para preencher o prompt
3. **OBRIGATÓRIO: Carregar Artefatos de Estágios Anteriores** - Antes de retomar qualquer estágio, ler automaticamente todos os artefatos relevantes de estágios anteriores:
   - **Engenharia Reversa**: Ler architecture.md, code-structure.md, api-documentation.md
   - **Análise de Requisitos**: Ler requirements.md, requirement-verification-questions.md
   - **Histórias de Usuário**: Ler stories.md, personas.md, story-generation-plan.md
   - **Design da Aplicação**: Ler artefatos de application-design (components.md, component-methods.md, services.md)
   - **Design (Unidades)**: Ler unit-of-work.md, unit-of-work-dependency.md, unit-of-work-story-map.md
   - **Design Por Unidade**: Artefatos por unidade ficam sob `aidlc-docs/construction/{unit-name}/` nos
     subdiretórios `functional-design/`, `nfr-requirements/`, `nfr-design/` e `infrastructure-design/`.
     Na retomada, determine a unidade em andamento a partir de `aidlc-state.md` e carregue os
     artefatos de design dessa unidade, mais os artefatos de design de quaisquer unidades das quais
     ela depende (conforme `unit-of-work-dependency.md`). Os arquivos exatos em cada subdiretório
     são enumerados pelas regras correspondentes do estágio de construction.
   - **Estágios de Código**: Ler todos os arquivos de código, planos E todos os artefatos anteriores
4. **Carregamento Inteligente de Contexto por Estágio**:
   - **Estágios Iniciais (Detecção do Workspace, Engenharia Reversa)**: Carregar análise do workspace
   - **Requisitos/Histórias**: Carregar artefatos de engenharia reversa + requisitos
   - **Estágios de Design**: Carregar requisitos + histórias + arquitetura + artefatos de design
   - **Estágios de Código**: Carregar TODOS os artefatos + arquivos de código existentes
5. **Adaptar opções** com base na escolha arquitetural e fase atual
6. **Mostrar próximas etapas específicas** em vez de descrições genéricas
7. **Registrar o prompt de continuidade** em audit.md com timestamp
8. **Resumo de Contexto**: Após carregar artefatos, fornecer breve resumo do que foi carregado para conhecimento do usuário
9. **Fazer perguntas**: SEMPRE faça perguntas de esclarecimento ou feedback do usuário colocando-as em arquivos .md. NÃO coloque as perguntas de múltipla escolha em linha na sessão de chat.

## Tratamento de Erros
Se artefatos estiverem ausentes ou corrompidos durante a retomada da sessão, veja [error-handling.md](error-handling.md) para orientação sobre procedimentos de recuperação.
