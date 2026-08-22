# Regras de Testes Baseados em Propriedades

## Visão Geral

Estas regras de testes baseados em propriedades (PBT) são restrições transversais que se aplicam às fases aplicáveis do AI-DLC. Elas garantem que código com propriedades identificáveis seja testado usando técnicas baseadas em propriedades, complementando (não substituindo) testes tradicionais baseados em exemplos.

Testes baseados em propriedades definem invariantes que devem se manter para todas as entradas válidas, depois usam um framework para gerar entradas aleatórias e buscar contraexemplos. Quando uma falha é encontrada, o framework reduz a entrada a um caso mínimo de reprodução. Esta abordagem descobre casos extremos e bugs sutis que testes baseados em exemplos frequentemente perdem.

**Aplicação**: Em cada estágio aplicável, o modelo DEVE verificar a conformidade com estas regras antes de apresentar a mensagem de conclusão do estágio ao usuário.

### Comportamento de Achado PBT Bloqueante

Um **achado PBT bloqueante** significa:
1. O achado DEVE ser listado na mensagem de conclusão do estágio sob uma seção "Achados PBT" com o ID da regra PBT e a descrição
2. O estágio NÃO DEVE apresentar a opção "Continuar para o Próximo Estágio" até que todos os achados bloqueantes sejam resolvidos
3. O modelo DEVE apresentar apenas a opção "Solicitar Alterações" com uma explicação clara do que precisa mudar
4. O achado DEVE ser registrado em `aidlc-docs/audit.md` com o ID da regra PBT, descrição e contexto do estágio

Se uma regra PBT não for aplicável ao projeto ou unidade atual (ex.: PBT-06 quando nenhum componente com estado existir), marque-a como **N/A** no resumo de conformidade — isso não é um achado bloqueante.

### Aplicação Padrão

Todas as regras neste documento são **bloqueantes** por padrão. Se os critérios de verificação de qualquer regra não forem atendidos, é um achado PBT bloqueante — siga o comportamento de achado bloqueante definido acima.

### Modo de Aplicação Parcial

Se o usuário selecionou aplicação **Parcial** durante o opt-in, apenas as regras PBT-02, PBT-03, PBT-07, PBT-08 e PBT-09 são aplicadas. Todas as outras regras são tratadas como consultivas (não bloqueantes). Registre o modo de aplicação em `aidlc-docs/aidlc-state.md` sob `## Extension Configuration`.

### Formato dos Critérios de Verificação

Os itens de verificação neste documento são tópicos simples descrevendo verificações de conformidade. Cada item deve ser avaliado como conforme ou não conforme durante a revisão.

---

## Regra PBT-01: Identificação de Propriedades Durante o Design

**Regra**: Toda unidade contendo lógica de negócio, transformações de dados ou operações algorítmicas DEVE ser analisada quanto a propriedades testáveis durante o estágio de Design Funcional. A análise DEVE identificar quais das seguintes categorias de propriedades se aplicam:

| Categoria | Descrição | Exemplo |
|---|---|---|
| Round-trip | Uma operação pareada com sua inversa produz o valor original | serialize → deserialize = identity |
| Invariante | Uma transformação preserva alguma característica mensurável | sort preserva tamanho e elementos da coleção |
| Idempotência | Aplicar uma operação duas vezes produz o mesmo resultado que uma vez | dedup(dedup(list)) = dedup(list) |
| Comutatividade | Diferentes ordenações de operações produzem o mesmo resultado | add(a, b) = add(b, a) |
| Oráculo | Uma implementação de referência ou modelo simplificado pode verificar resultados | algoritmo otimizado vs força bruta |
| Indução | Uma propriedade provada para entradas menores se estende a maiores | estruturas recursivas, divide-and-conquer |
| Verificação fácil | O resultado é difícil de computar mas fácil de verificar | a saída de um solver de labirinto pode ser percorrida para verificar |

As propriedades identificadas DEVEM ser documentadas nos artefatos de design funcional da unidade e carregadas adiante para a geração de código como requisitos de testes PBT.

**Verificação**:
- Artefatos de design funcional incluem uma seção "Propriedades Testáveis" listando propriedades identificadas por componente
- Cada propriedade identificada referencia uma das categorias acima
- Componentes sem propriedades identificáveis são explicitamente marcados como "Nenhuma propriedade PBT identificada" com breve justificativa
- A lista de propriedades é referenciada durante o planejamento de geração de código

---

## Regra PBT-02: Propriedades Round-Trip

**Regra**: Qualquer operação que tenha uma inversa lógica DEVE ter um teste baseado em propriedades verificando o round-trip. Isso inclui, mas não se limita a:
- Serialização / desserialização (JSON, XML, Protobuf, formatos binários)
- Encoding / decoding (Base64, URL encoding, compressão)
- Parsing / formatação (parsing de datas, formatação de números, renderização de templates com entrada estruturada)
- Criptografia / descriptografia (onde a chave está disponível)
- Escrita / leitura de banco de dados (para a camada de transformação de dados, não o I/O em si)
- Qualquer par de funções onde `f_inverse(f(x)) = x` para todo `x` válido

O teste baseado em propriedades DEVE gerar entradas válidas aleatórias usando um gerador apropriado ao domínio (veja PBT-07) e afirmar que o round-trip produz um valor igual à entrada original.

**Verificação**:
- Todo par serialização/desserialização tem um teste de propriedade round-trip
- Todo par encoding/decoding tem um teste de propriedade round-trip
- Todo par parsing/formatação tem um teste de propriedade round-trip (ou documenta por que a transformação é lossy)
- Testes round-trip usam entradas geradas, não exemplos hardcoded
- Transformações lossy (ex.: formatação de float com perda de precisão) documentam o desvio aceitável e testam dentro da tolerância

---

## Regra PBT-03: Propriedades de Invariante

**Regra**: Funções com invariantes documentados DEVEM ter testes baseados em propriedades verificando que esses invariantes se mantêm em entradas geradas. Invariantes comuns incluem:
- **Preservação de tamanho**: a coleção de saída tem o mesmo tamanho que a entrada (ex.: map, sort)
- **Preservação de elementos**: a saída contém exatamente os mesmos elementos que a entrada, possivelmente reordenados (ex.: sort, shuffle)
- **Garantias de ordenação**: a saída satisfaz uma restrição de ordenação (ex.: sort produz ordem não decrescente)
- **Restrições de intervalo**: valores de saída caem dentro de um intervalo definido (ex.: normalize produz valores em [0, 1])
- **Preservação de tipo**: o tipo de saída corresponde ao tipo esperado para todas as entradas válidas
- **Invariantes de regra de negócio**: regras específicas do domínio que devem sempre se manter (ex.: "o saldo da conta nunca fica negativo após uma transação válida", "o desconto nunca excede o preço do item")

**Verificação**:
- Cada invariante documentado tem um teste baseado em propriedades correspondente
- Testes de invariante geram uma ampla variedade de entradas incluindo valores de fronteira
- Invariantes de regra de negócio identificados no design funcional são cobertos por PBT
- Testes de invariante não duplicam asserções exatas de testes baseados em exemplos — testam a regra geral, não casos específicos

---

## Regra PBT-04: Propriedades de Idempotência

**Regra**: Qualquer operação que reivindica ou exige idempotência DEVE ter um teste baseado em propriedades provando-a. O teste DEVE verificar que `f(f(x)) = f(x)` para todas as entradas válidas geradas. Isso se aplica a:
- Endpoints de API documentados como idempotentes (PUT, DELETE)
- Funções de normalização ou sanitização de dados
- Operações de população de cache
- Lógica de deduplicação
- Aplicação de configuração (aplicar config duas vezes não deve mudar o estado)
- Processamento de mensagens em sistemas de entrega at-least-once

**Verificação**:
- Toda operação documentada como idempotente tem um PBT afirmando `f(f(x)) = f(x)`
- Testes de idempotência usam geradores apropriados ao domínio (não apenas primitivos)
- Para operações com estado, o teste verifica equivalência de estado observável após aplicação única vs repetida

---

## Regra PBT-05: Testes com Oráculo e Baseados em Modelo

**Regra**: Quando uma implementação de referência, modelo simplificado ou algoritmo conhecido como correto existir, testes baseados em propriedades DEVEM comparar o sistema sob teste contra o oráculo. Isso se aplica a:
- Algoritmos otimizados substituindo uma versão conhecida de força bruta
- Código refatorado substituindo implementações legadas
- Implementações paralelas/concorrentes comparadas contra versões sequenciais
- Implementações customizadas de algoritmos bem conhecidos (ordenação, busca, travessia de grafos)
- Novos engines de consulta comparados contra um banco de dados de referência

O teste baseado em propriedades DEVE gerar entradas válidas aleatórias e afirmar que o sistema sob teste produz resultados equivalentes ao oráculo para todas as entradas geradas.

**Verificação**:
- Quando uma implementação de referência existe (ou pode ser trivialmente escrita), um PBT de oráculo está presente
- Testes de oráculo geram entradas diversas cobrindo casos normais, de fronteira e adversariais
- A equivalência é definida precisamente (igualdade exata, igualdade estrutural ou tolerância documentada)
- Se nenhum oráculo existir, esta regra é marcada N/A com justificativa

---

## Regra PBT-06: Testes de Propriedades com Estado

**Regra**: Componentes que gerenciam estado mutável DEVEM ser avaliados para testes de propriedades com estado. PBT com estado gera sequências aleatórias de comandos (operações) contra o sistema e verifica que invariantes se mantêm após cada etapa. Isso se aplica a:
- Caches e armazenamentos de dados em memória
- Máquinas de estado e engines de workflow
- Implementações de filas e buffers
- Sistemas de gerenciamento de sessão
- Carrinhos de compra, pipelines de pedidos e objetos de negócio com estado similares
- Qualquer componente onde o resultado de uma operação depende de operações anteriores

PBT com estado DEVE:
- Definir um modelo simplificado (estado de referência) que espelha o sistema sob teste
- Gerar sequências aleatórias de comandos válidos (add, remove, update, query, etc.)
- Executar cada comando contra o sistema real e o modelo
- Afirmar que o estado observável ou resultados de consulta correspondem entre sistema e modelo após cada comando
- Testar sequências de comprimentos variados, incluindo sequências vazias

**Verificação**:
- Componentes com estado identificados no design funcional têm PBT com estado ou documentam por que não é aplicável
- Um modelo simplificado é definido para comparação
- Geradores de comando produzem sequências de operações válidas com distribuições realistas de parâmetros
- Invariantes são verificados após cada comando na sequência, não apenas no final
- Se nenhum componente com estado existir, esta regra é marcada N/A

---

## Regra PBT-07: Qualidade do Gerador

**Regra**: Testes baseados em propriedades DEVEM usar geradores específicos do domínio que produzem entradas realistas e estruturadas — não apenas tipos primitivos. Geradores ruins (ex.: strings aleatórias para campos de e-mail, inteiros ilimitados para campos de idade) produzem casos de teste sem sentido e perdem bugs reais.

Requisitos do gerador:
- **Tipos de domínio**: Geradores customizados DEVEM ser criados para objetos de domínio (ex.: User, Order, Transaction) que respeitam restrições de negócio (formato de e-mail válido, valores positivos, intervalos de data válidos)
- **Primitivos restritos**: Geradores numéricos DEVEM ser restringidos a intervalos realistas onde o domínio exige
- **Dados estruturados**: Geradores para entradas complexas (objetos aninhados, listas de objetos de domínio) DEVEM produzir dados estruturalmente válidos
- **Inclusão de casos extremos**: Geradores DEVERIAM ser configurados para incluir valores de fronteira (coleções vazias, zero, valores máximos, strings Unicode) junto com valores normais
- **Reutilização**: Geradores de domínio DEVERIAM ser definidos como utilitários de teste reutilizáveis, não duplicados entre arquivos de teste

**Verificação**:
- Nenhum PBT usa apenas geradores primitivos brutos (ex.: `st.integers()` sozinho) para parâmetros tipados do domínio
- Geradores customizados existem para objetos de domínio usados em PBT
- Geradores respeitam restrições de negócio documentadas (ex.: valores positivos, formatos válidos)
- Definições de geradores são centralizadas e reutilizáveis onde múltiplos testes compartilham os mesmos tipos de domínio

---

## Regra PBT-08: Shrinking e Reprodutibilidade

**Regra**: Todos os testes baseados em propriedades DEVEM suportar shrinking e reprodutibilidade determinística.

- **Shrinking**: Quando uma propriedade falha, o framework PBT DEVE automaticamente reduzir a entrada falha a um caso mínimo de reprodução. Testes NÃO DEVEM desabilitar ou contornar o mecanismo de shrinking do framework a menos que haja um motivo técnico documentado (ex.: shrinking é incompatível com chamadas a serviços externos em testes de integração).
- **Reprodutibilidade**: Toda execução PBT DEVE ser reproduzível via um valor de seed. O seed DEVE ser registrado em falha para que o cenário exato de falha possa ser reproduzido. Configurações de CI DEVEM usar um seed fixo para execuções determinísticas ou registrar o seed aleatório em cada execução para reprodução pós-falha.
- **Integração com CI**: PBT DEVE ser incluído no pipeline de CI do projeto. Falhas PBT flaky (testes que passam no retry sem mudanças de código) DEVEM ser investigadas, não suprimidas.

**Verificação**:
- O shrinking do framework PBT está habilitado (não sobrescrito ou desabilitado)
- A saída do teste em falha inclui o valor do seed e a entrada falha mínima reduzida
- A configuração de CI registra o seed para cada execução PBT ou usa um seed fixo
- Nenhum PBT é excluído do CI sem justificativa documentada
- Falhas PBT flaky são rastreadas e investigadas, não retentadas silenciosamente

---

## Regra PBT-09: Seleção de Framework

**Regra**: O projeto DEVE selecionar e configurar um framework apropriado de testes baseados em propriedades para sua(s) linguagem(ns) principal(is). O framework DEVE suportar:
- Geradores / strategies customizados para tipos de domínio
- Shrinking automático de casos falhos
- Reprodutibilidade baseada em seed
- Integração com o test runner existente do projeto

Frameworks recomendados por linguagem (não exaustivo):

| Linguagem | Framework | Notas |
|---|---|---|
| Python | Hypothesis | Maduro, excelente shrinking, integração Django |
| JavaScript / TypeScript | fast-check | Integra com Jest, Vitest, Mocha |
| Java | jqwik | Integração JUnit 5, suporte a testes com estado |
| Kotlin | Kotest Property Testing | Integração com framework Kotest |
| Scala | ScalaCheck | Integração SBT, amplamente adotado |
| Rust | proptest | Baseado em macros, bom shrinking |
| Go | rapid | Leve, Go idiomático |
| Haskell | QuickCheck | O framework PBT original |
| C# / .NET | FsCheck | Funciona com xUnit, NUnit |
| Erlang / Elixir | PropEr / StreamData | Consciente de OTP, testes com estado |

O framework selecionado DEVE ser documentado nas decisões de stack tecnológica e incluído como dependência do projeto.

**Verificação**:
- Um framework PBT é selecionado e documentado nas decisões de stack tecnológica
- O framework está incluído nas dependências do projeto (package.json, pom.xml, requirements.txt, etc.)
- O framework suporta geradores customizados, shrinking e reprodutibilidade baseada em seed
- Se o projeto usa múltiplas linguagens, cada linguagem com código aplicável a PBT tem um framework selecionado

---

## Regra PBT-10: Estratégia de Testes Complementar

**Regra**: Testes baseados em propriedades DEVEM complementar, não substituir, testes baseados em exemplos. As duas abordagens servem a propósitos diferentes:

- **Testes baseados em exemplos**: Documentam cenários conhecidos específicos, casos de regressão e casos extremos críticos de negócio com valores esperados explícitos. Servem como documentação executável de comportamento concreto.
- **Testes baseados em propriedades**: Verificam invariantes gerais em um amplo espaço de entrada. Encontram casos extremos desconhecidos e validam que propriedades se mantêm universalmente.

Requisitos:
- Cenários críticos de negócio identificados em histórias de usuário ou requisitos DEVEM ter testes baseados em exemplos explícitos, mesmo se um PBT cobrir a mesma propriedade
- PBT NÃO DEVE ser o único teste para qualquer caminho crítico de negócio — pelo menos um teste baseado em exemplos deve fixar o comportamento esperado para cenários-chave
- Quando um PBT descobre um caso falho, o exemplo mínimo reduzido DEVERIA ser adicionado como um teste permanente de regressão baseado em exemplos
- A documentação de testes DEVE distinguir claramente entre testes baseados em exemplos e baseados em propriedades (arquivos de teste separados, classes de teste ou funções de teste claramente nomeadas)

**Verificação**:
- Caminhos críticos de negócio têm tanto testes baseados em exemplos quanto baseados em propriedades
- PBT não é usado como a única cobertura de testes para qualquer funcionalidade crítica
- Arquivos ou classes de teste separam ou rotulam claramente PBT vs testes baseados em exemplos
- Testes de regressão de falhas descobertas por PBT são capturados como testes permanentes baseados em exemplos

---

## Integração de Aplicação

Estas regras são restrições transversais que se aplicam aos seguintes estágios do AI-DLC:

| Estágio | Regras Aplicáveis | Aplicação |
|---|---|---|
| Design Funcional | PBT-01 | A identificação de propriedades deve aparecer nos artefatos de design |
| Requisitos NFR | PBT-09 | A seleção de framework deve ser incluída nas decisões de stack tecnológica |
| Geração de Código (Planejamento) | PBT-01 através de PBT-10 | O plano de geração de código deve incluir etapas de testes PBT para propriedades identificadas |
| Geração de Código (Geração) | PBT-02 através de PBT-08, PBT-10 | Testes gerados devem incluir PBT junto com testes baseados em exemplos |
| Build e Testes | PBT-08 | Instruções de execução de testes devem incluir PBT com logging de seed e integração CI |

Em cada estágio aplicável:
- Avaliar todos os critérios de verificação das regras PBT contra os artefatos produzidos
- Incluir uma seção "Conformidade PBT" no resumo de conclusão do estágio listando cada regra como conforme, não conforme ou N/A
- Se qualquer regra estiver não conforme, isso é um achado PBT bloqueante — siga o comportamento de achado bloqueante definido na Visão Geral
- Incluir referências às regras PBT na documentação de design e nas instruções de testes

---

## Apêndice: Referência Rápida de Categorias de Propriedades

Para desenvolvedores e modelos de IA identificando propriedades durante o Design Funcional (PBT-01):

| Nome do Padrão | Termo Formal | Forma do Teste | Quando Usar |
|---|---|---|---|
| There and back again | Função invertível | `f_inv(f(x)) == x` | Serialização, encoding, parsing |
| Some things never change | Invariante | `measure(f(x)) == measure(x)` | Sort, map, filter, transform |
| The more things change, the more they stay the same | Idempotência | `f(f(x)) == f(x)` | Normalização, dedup, escritas de cache |
| Different paths, same destination | Comutatividade | `f(g(x)) == g(f(x))` | Aritmética, operações de conjunto, transforms independentes |
| Solve a smaller problem first | Indução estrutural | Propriedade em `x` implica propriedade em `x + element` | Estruturas recursivas, listas, árvores |
| Hard to prove, easy to verify | Verificação | `verify(solve(x)) == true` | Solvers, otimizadores, algoritmos de busca |
| The test oracle | Comparação com referência | `f(x) == oracle(x)` | Otimizado vs força bruta, refatorado vs legado |

Fonte: Taxonomia de categorias de propriedades adaptada de Scott Wlaschin's "Choosing properties for property-based testing" ([fsharpforfunandprofit.com](https://fsharpforfunandprofit.com/posts/property-based-testing-2/)).
