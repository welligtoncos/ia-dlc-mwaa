# Regras de Baseline de Segurança

## Visão Geral
Estas regras de segurança são restrições transversais OBRIGATÓRIAS que se aplicam a todas as fases do AI-DLC. Não são orientações opcionais — são restrições rígidas que os estágios DEVEM aplicar ao gerar perguntas, produzir artefatos de design, gerar código e apresentar mensagens de conclusão.

**Aplicação**: Em cada estágio aplicável, o modelo DEVE verificar a conformidade com estas regras antes de apresentar a mensagem de conclusão do estágio ao usuário.

### Comportamento de Achado de Segurança Bloqueante
Um **achado de segurança bloqueante** significa:
1. O achado DEVE ser listado na mensagem de conclusão do estágio sob uma seção "Achados de Segurança" com o ID da regra SECURITY e a descrição
2. O estágio NÃO DEVE apresentar a opção "Continuar para o Próximo Estágio" até que todos os achados bloqueantes sejam resolvidos
3. O modelo DEVE apresentar apenas a opção "Solicitar Alterações" com uma explicação clara do que precisa mudar
4. O achado DEVE ser registrado em `aidlc-docs/audit.md` com o ID da regra SECURITY, descrição e contexto do estágio

Se uma regra SECURITY não for aplicável ao projeto atual (ex.: SECURITY-01 quando nenhum armazenamento de dados existir), marque-a como **N/A** no resumo de conformidade — isso não é um achado bloqueante.

### Aplicação Padrão
Todas as regras neste documento são **bloqueantes** por padrão. Se os critérios de verificação de qualquer regra não forem atendidos, é um achado de segurança bloqueante — siga o comportamento de achado bloqueante definido acima.

### Formato dos Critérios de Verificação
Os itens de verificação neste documento são tópicos simples descrevendo verificações de conformidade. Eles são distintos dos checkboxes de rastreamento de progresso `- [ ]` / `- [x]` usados em arquivos de plano de estágio. Cada item deve ser avaliado como conforme ou não conforme durante a revisão.

---

## Regra SECURITY-01: Criptografia em Repouso e em Trânsito

**Regra**: Todo armazenamento de persistência de dados (bancos de dados, object storage, sistemas de arquivos, caches ou qualquer equivalente) DEVE ter:
- Criptografia em repouso habilitada usando um serviço de chaves gerenciado ou chaves gerenciadas pelo cliente
- Criptografia em trânsito aplicada (TLS 1.2+ para todo movimento de dados para dentro e fora do armazenamento)

**Verificação**:
- Nenhum recurso de armazenamento é definido sem um bloco de configuração de criptografia
- Nenhuma string de conexão de banco de dados usa um protocolo não criptografado
- Object storage aplica criptografia em repouso e rejeita solicitações sem TLS via política
- Instâncias de banco de dados têm criptografia de armazenamento habilitada e aplicam conexões TLS

---

## Regra SECURITY-02: Logging de Acesso em Intermediários de Rede

**Regra**: Todo intermediário voltado à rede que trata tráfego externo DEVE ter logging de acesso habilitado. Isso inclui:
- Load balancers → logs de acesso para um armazenamento persistente
- API gateways → logging de execução e logging de acesso para um serviço de log centralizado
- Distribuições CDN → logging padrão ou logs em tempo real

**Verificação**:
- Nenhum recurso de load balancer é definido sem logging de acesso habilitado
- Nenhum stage de API gateway é definido sem logging de acesso configurado
- Nenhuma distribuição CDN é definida sem configuração de logging

---

## Regra SECURITY-03: Logging em Nível de Aplicação

**Regra**: Todo componente de aplicação implantado DEVE incluir infraestrutura de logging estruturado:
- Um framework de logging DEVE ser configurado
- A saída de logs DEVE ser direcionada para um serviço de log centralizado
- Os logs DEVEM incluir: timestamp, correlation/request ID, nível de log e mensagem
- Dados sensíveis (senhas, tokens, PII) NÃO DEVEM aparecer na saída de logs

**Verificação**:
- Todo ponto de entrada de serviço/função inclui um logger configurado
- Nenhum statement de logging ad-hoc é usado como mecanismo principal de logging em código de produção
- A configuração de log roteia a saída para um serviço de log centralizado
- Nenhum segredo, token ou PII é registrado em logs

---

## Regra SECURITY-04: Headers de Segurança HTTP para Aplicações Web

**Regra**: Os seguintes headers de resposta HTTP DEVEM ser definidos em todos os endpoints que servem HTML:

| Header | Valor Obrigatório |
|---|---|
| `Content-Security-Policy` | Definir uma política restritiva (no mínimo: `default-src 'self'`) |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` |
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `DENY` (ou `SAMEORIGIN` se framing for necessário) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |

**Nota**: `X-XSS-Protection` está depreciado em navegadores modernos. Use `Content-Security-Policy` em vez disso.

**Verificação**:
- Middleware ou interceptor de resposta define todos os headers obrigatórios
- A política CSP não usa `unsafe-inline` ou `unsafe-eval` sem justificativa documentada
- O max-age do HSTS é de pelo menos 31536000 (1 ano)

---

## Regra SECURITY-05: Validação de Entrada em Todos os Parâmetros de API

**Regra**: Todo endpoint de API (REST, GraphQL, gRPC, WebSocket) DEVE validar todos os parâmetros de entrada antes do processamento. A validação DEVE incluir:
- **Verificação de tipo**: Rejeitar tipos inesperados
- **Limites de comprimento/tamanho**: Aplicar comprimentos máximos em strings, tamanhos máximos em arrays e payloads
- **Validação de formato**: Usar allowlists (regex ou schema) para entradas estruturadas (e-mails, datas, IDs)
- **Sanitização**: Escapar ou rejeitar conteúdo HTML/script em strings fornecidas pelo usuário para prevenir XSS
- **Prevenção de injeção**: Usar consultas parametrizadas para todas as operações de banco de dados (nunca concatenação de strings)

**Verificação**:
- Todo handler de API usa uma biblioteca de validação ou schema
- Nenhuma entrada bruta do usuário é concatenada em comandos SQL, NoSQL ou OS
- Entradas de string têm restrições explícitas de comprimento máximo
- Limites de tamanho do corpo da solicitação são configurados no nível do framework ou gateway

---

## Regra SECURITY-06: Políticas de Acesso de Menor Privilégio

**Regra**: Toda política, papel ou boundary de permissão de gerenciamento de identidade e acesso DEVE seguir o menor privilégio:
- Usar identificadores específicos de recursos — NUNCA usar recursos wildcard a menos que a API não suporte permissões em nível de recurso (documentar a exceção)
- Usar ações específicas — NUNCA usar ações wildcard
- Escopar condições onde possível
- Separar permissões de leitura e escrita em statements de política distintos

**Verificação**:
- Nenhuma política contém ações wildcard ou recursos wildcard sem uma exceção documentada
- Nenhum papel de serviço tem permissões mais amplas do que o que o serviço realmente chama
- Políticas inline são evitadas em favor de políticas gerenciadas onde possível
- Todo papel tem uma trust policy escopada ao serviço ou conta específico

---

## Regra SECURITY-07: Configuração de Rede Restritiva

**Regra**: Todas as configurações de rede (security groups, network ACLs, route tables) DEVEM seguir deny-by-default:
- Regras de firewall: Abrir apenas portas específicas exigidas pela aplicação
- Nenhuma regra de entrada com origem `0.0.0.0/0` exceto para load balancers públicos nas portas 80/443
- Nenhuma regra de saída com `0.0.0.0/0` em todas as portas a menos que explicitamente justificado
- Subnets privadas NÃO DEVEM ter rotas diretas de internet gateway
- Usar endpoints privados para acesso a serviços de nuvem onde disponível

**Verificação**:
- Nenhuma regra de firewall permite entrada `0.0.0.0/0` em qualquer porta que não seja 80/443 em um load balancer público
- Regras de firewall de banco de dados e aplicação restringem a origem a blocos CIDR específicos ou referências de security group
- Subnets privadas roteiam através de um NAT gateway (não um internet gateway)
- Endpoints privados são usados para chamadas de serviços de nuvem de alto tráfego

---

## Regra SECURITY-08: Controle de Acesso em Nível de Aplicação

**Regra**: Todo endpoint de aplicação que acessa ou muta um recurso DEVE aplicar verificações de autorização na camada de aplicação:
- **Negar por padrão**: Todas as rotas/endpoints DEVEM exigir autenticação a menos que explicitamente marcados como públicos
- **Autorização em nível de objeto**: Toda solicitação que referencia um recurso por ID DEVE verificar se o usuário/principal solicitante possui ou tem permissão para acessar esse recurso (prevenir IDOR)
- **Autorização em nível de função**: Operações administrativas ou privilegiadas DEVEM verificar o papel/permissões do chamador no lado do servidor — nunca confiar em ocultação no lado do cliente
- **Política CORS**: O compartilhamento de recursos entre origens DEVE ser restrito a origens explicitamente permitidas — nunca usar `Access-Control-Allow-Origin: *` em endpoints autenticados
- **Validação de token**: JWTs ou tokens de sessão DEVEM ser validados no lado do servidor em cada solicitação (assinatura, expiração, audience, issuer)

**Verificação**:
- Todo controller/handler tem um middleware ou guard de autorização aplicado
- Nenhum endpoint retorna dados para um ID de recurso sem verificar a ownership ou permissão do chamador
- Rotas admin/privilegiadas têm verificações explícitas de papel aplicadas no lado do servidor
- A configuração CORS não usa origens wildcard em endpoints autenticados
- A validação de token ocorre no lado do servidor em cada solicitação (não apenas no login)

---

## Regra SECURITY-09: Endurecimento de Segurança e Prevenção de Má Configuração

**Regra**: Todos os componentes implantados DEVEM seguir um baseline de endurecimento:
- **Sem credenciais padrão**: Nomes de usuário/senhas padrão DEVEM ser alterados ou desabilitados antes da implantação
- **Instalação mínima**: Remover ou desabilitar funcionalidades não usadas, frameworks, aplicações de exemplo e endpoints de documentação
- **Tratamento de erros**: Respostas de erro de produção NÃO DEVEM expor stack traces, caminhos internos, versões de framework ou detalhes de banco de dados aos usuários finais
- **Listagem de diretórios**: Servidores web DEVEM desabilitar listagem de diretórios
- **Armazenamento em nuvem**: Object storage em nuvem DEVE bloquear acesso público a menos que explicitamente necessário e documentado
- **Gerenciamento de patches**: Ambientes de runtime, frameworks e imagens de OS DEVEM usar versões atuais e suportadas

**Verificação**:
- Nenhuma credencial padrão existe em arquivos de configuração, variáveis de ambiente ou templates IaC
- Respostas de erro em produção retornam mensagens genéricas (sem stack traces ou detalhes internos)
- Object storage em nuvem tem acesso público bloqueado a menos que uma exceção documentada exista
- Nenhuma aplicação de exemplo/demo ou página padrão é implantada
- Versões de framework e runtime são atuais e suportadas


---

## Regra SECURITY-10: Segurança da Cadeia de Suprimentos de Software

**Regra**: Todo projeto DEVE gerenciar sua cadeia de suprimentos de software:
- **Pinning de dependências**: Todas as dependências DEVEM usar versões exatas ou lock files
- **Varredura de vulnerabilidades**: Um scanner de vulnerabilidades de dependências DEVE ser configurado
- **Sem dependências não usadas**: Remover pacotes que não são ativamente usados
- **Apenas fontes confiáveis**: Dependências DEVEM ser obtidas de registries oficiais ou registries privados verificados — sem fontes de terceiros não avaliadas
- **SBOM**: Projetos DEVEM gerar um Software Bill of Materials para implantações de produção
- **Integridade de CI/CD**: Pipelines de build DEVEM usar versões fixas de ferramentas e imagens base verificadas — sem tags `latest` em Dockerfiles de produção ou configurações de CI

**Verificação**:
- Um lock file existe e está commitado no controle de versão
- Uma etapa de varredura de vulnerabilidades de dependências está incluída no CI/CD ou documentada nas instruções de build
- Nenhuma dependência não usada ou abandonada está incluída
- Dockerfiles e configs de CI não usam `latest` ou tags de imagem não fixadas para produção
- Dependências são obtidas de registries oficiais ou verificados

---

## Regra SECURITY-11: Princípios de Design Seguro

**Regra**: O design da aplicação DEVE incorporar segurança desde o início:
- **Separação de preocupações**: Lógica crítica de segurança (autenticação, autorização, processamento de pagamento) DEVE ser isolada em módulos dedicados — não espalhada pela base de código
- **Defesa em profundidade**: Nenhum controle único deve ser a única linha de defesa — empilhar controles (validação + autorização + criptografia)
- **Limitação de taxa**: Endpoints voltados ao público DEVEM implementar rate limiting ou throttling para prevenir abuso
- **Abuso de lógica de negócio**: O design DEVE considerar casos de uso indevido — não apenas cenários de happy-path

**Verificação**:
- Lógica crítica de segurança está encapsulada em módulos ou serviços dedicados
- Rate limiting está configurado em APIs voltadas ao público
- A documentação de design aborda pelo menos um cenário de uso indevido/abuso

---

## Regra SECURITY-12: Autenticação e Gerenciamento de Credenciais

**Regra**: Toda aplicação com autenticação de usuário DEVE implementar:
- **Política de senha**: Mínimo de 8 caracteres, verificar contra listas de senhas vazadas
- **Armazenamento de credenciais**: Senhas DEVEM ser hasheadas usando algoritmos adaptativos — nunca hashing fraco ou não adaptativo
- **Autenticação multifator**: MFA DEVE ser suportado para contas administrativas e DEVERIA estar disponível para todos os usuários
- **Gerenciamento de sessão**: Sessões DEVEM ter expiração no lado do servidor, ser invalidadas no logout e usar atributos de cookie secure/httpOnly/sameSite
- **Proteção contra força bruta**: Endpoints de login DEVEM implementar bloqueio de conta, delays progressivos ou CAPTCHA após falhas repetidas
- **Sem credenciais hardcoded**: Sem senhas, chaves de API ou segredos no código-fonte ou templates IaC — usar um gerenciador de segredos

**Verificação**:
- O hashing de senha usa algoritmos adaptativos (não hashing fraco ou não adaptativo)
- Cookies de sessão definem atributos `Secure`, `HttpOnly` e `SameSite`
- Endpoints de login têm proteção contra força bruta (bloqueio, delay ou CAPTCHA)
- Nenhuma credencial hardcoded no código-fonte ou arquivos de configuração
- MFA é suportado para contas admin
- Sessões são invalidadas no logout e têm uma expiração definida

---

## Regra SECURITY-13: Verificação de Integridade de Software e Dados

**Regra**: Sistemas DEVEM verificar a integridade de software e dados:
- **Segurança de desserialização**: Dados não confiáveis NÃO DEVEM ser desserializados sem validação — usar bibliotecas de desserialização seguras ou allowlists de tipos permitidos
- **Integridade de artefatos**: Dependências baixadas, plugins e atualizações DEVEM ser verificados via checksums ou assinaturas digitais
- **Segurança do pipeline de CI/CD**: Pipelines de build DEVEM restringir quem pode modificar definições de pipeline — separar funções entre autores de código e aprovadores de implantação
- **CDN e recursos externos**: Scripts ou recursos carregados de CDNs externas DEVEM usar hashes Subresource Integrity (SRI)
- **Integridade de dados**: Modificações críticas de dados DEVEM ser auditáveis (quem mudou o quê, quando)

**Verificação**:
- Nenhuma desserialização insegura de entrada não confiável
- Scripts externos incluem atributos de integridade SRI quando carregados de CDNs
- Definições de pipeline de CI/CD têm controle de acesso e mudanças são auditáveis
- Mudanças críticas de dados são registradas com ator, timestamp e valores antes/depois

---

## Regra SECURITY-14: Alertas e Monitoramento

**Regra**: Além do logging (SECURITY-02, SECURITY-03), sistemas DEVEM incluir:
- **Alertas de eventos de segurança**: Alertas DEVEM ser configurados para eventos de segurança de alto valor: falhas repetidas de autenticação, tentativas de escalação de privilégio, acesso de locais incomuns e falhas de autorização
- **Integridade de logs**: Logs DEVEM ser armazenados em armazenamento append-only ou à prova de adulteração — o código da aplicação NÃO DEVE poder excluir ou modificar seus próprios logs de auditoria
- **Retenção de logs**: Logs DEVEM ser retidos por um período mínimo apropriado aos requisitos de conformidade da aplicação (padrão: mínimo de 90 dias)
- **Dashboards de monitoramento**: Um dashboard de monitoramento ou configuração de alarme DEVE ser definido para métricas operacionais e de segurança-chave

**Verificação**:
- Alertas estão configurados para falhas de autenticação e violações de autorização
- Grupos de logs da aplicação têm políticas de retenção definidas (mínimo 90 dias)
- Papéis da aplicação não têm permissão para excluir seus próprios grupos/streams de logs
- Eventos relevantes à segurança (falhas de login, acesso negado, mudanças de privilégio) geram alertas

---

## Regra SECURITY-15: Tratamento de Exceções e Defaults Fail-Safe

**Regra**: Toda aplicação DEVE tratar condições excepcionais com segurança:
- **Capturar e tratar**: Todas as chamadas externas (banco de dados, API, I/O de arquivo) DEVEM ter tratamento explícito de erros — sem rejeições de promise não tratadas ou exceções não capturadas em produção
- **Falhar fechado**: Em erro, o sistema DEVE negar acesso ou interromper a operação — nunca falhar aberto
- **Limpeza de recursos**: Caminhos de erro DEVEM liberar recursos (conexões, handles de arquivo, locks) — usar try/finally, using statements ou padrões equivalentes
- **Erros voltados ao usuário**: Mensagens de erro mostradas aos usuários DEVEM ser genéricas — sem detalhes internos ou informações do sistema
- **Handler global de erros**: Aplicações DEVEM ter um handler de erros global/de nível superior que captura exceções não tratadas, as registra (conforme SECURITY-03) e retorna uma resposta segura

**Verificação**:
- Todas as chamadas externas (DB, HTTP, I/O de arquivo) têm tratamento explícito de erros (try/catch, .catch(), callbacks de erro)
- Um handler global de erros está configurado no ponto de entrada da aplicação
- Caminhos de erro não contornam verificações de autorização ou validação (falhar fechado)
- Recursos são limpos em caminhos de erro (conexões fechadas, transações revertidas)
- Nenhuma rejeição de promise não tratada ou avisos de exceção não capturada no código da aplicação

---

## Integração de Aplicação

Estas regras são restrições transversais que se aplicam a cada estágio do AI-DLC. Em cada estágio:
- Avaliar todos os critérios de verificação das regras SECURITY contra os artefatos produzidos
- Incluir uma seção "Conformidade de Segurança" no resumo de conclusão do estágio listando cada regra como conforme, não conforme ou N/A
- Se qualquer regra estiver não conforme, isso é um achado de segurança bloqueante — siga o comportamento de achado bloqueante definido na Visão Geral
- Incluir referências às regras de segurança na documentação de design e nas instruções de testes

---

## Apêndice: Mapeamento de Referência OWASP

<!-- TODO: CRITICAL - This entire OWASP mapping table needs verification. The "2025" edition may not exist; the latest published OWASP Top 10 is 2021. Category IDs (A01-A10), numbering, and names must be validated against the actual published standard before relying on this mapping. -->
Para revisores humanos, o seguinte mapeia regras SECURITY para categorias do OWASP Top 10 (2025):

| Regra SECURITY | Categoria OWASP |
|---|---|
| SECURITY-08 | A01:2025 – Broken Access Control |
| SECURITY-09 | A02:2025 – Security Misconfiguration |
| SECURITY-10 | A03:2025 – Software Supply Chain Failures |
| SECURITY-11 | A06:2025 – Insecure Design |
| SECURITY-12 | A07:2025 – Authentication Failures |
| SECURITY-13 | A08:2025 – Software or Data Integrity Failures |
| SECURITY-14 | A09:2025 – Logging & Alerting Failures |
| SECURITY-15 | A10:2025 – Mishandling of Exceptional Conditions |
