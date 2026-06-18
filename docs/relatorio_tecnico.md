# Relatório Técnico — Projeto Integrador

**Projeto:** Ligeirinho Food (Aplicativo Mobile)
**Disciplina:** Projeto Integrador (5º Semestre)
**Data:** 18 de Junho de 2026

---

## 1. Introdução

O **Ligeirinho Food** é um aplicativo mobile de delivery focado no ambiente acadêmico e institucional. O problema abordado é a dificuldade de alunos e funcionários enfrentarem longas filas nas cantinas durante os curtos intervalos de aula, o que muitas vezes inviabiliza a alimentação adequada.

A proposta da solução é uma plataforma onde o usuário pode navegar pelas cantinas de sua instituição, visualizar o cardápio, personalizar seu pedido (adicionais e remoção de ingredientes), realizar o pagamento antecipado (PIX/Cartão) e acompanhar o status do pedido em tempo real. O aplicativo foi desenvolvido em **Flutter**, visando performance nativa e experiência fluida em Android e iOS.

---

## 2. Arquitetura MVVM

Para garantir um código manutenível, testável e desacoplado, o aplicativo foi estruturado utilizando o padrão arquitetural **MVVM (Model - View - ViewModel)**. A implementação contou com o uso do pacote `flutter_riverpod` para o gerenciamento de estado e injeção de dependências.

A separação de responsabilidades foi dividida da seguinte forma:

*   **Model (`lib/data/models` e `lib/data/services`):**
    Representa as entidades do domínio (`ProductModel`, `StoreModel`, `UserModel`, etc.) e a camada de acesso a dados via API (`CatalogApiService`, `OrdersApiService`). As classes de modelo são puras e imutáveis, implementando os métodos `fromJson` e `toJson` para serialização de dados (tanto da API quanto para persistência local).
*   **ViewModel (`lib/data/providers` e providers específicos de feature):**
    Atua como o intermediário entre a View e o Model. As classes `StateNotifier` (como `CartNotifier` e `AuthNotifier`) e os `FutureProvider` e `StateProvider` concentram a **lógica de negócio** e o **estado da tela**. Por exemplo, toda a lógica de filtragem de produtos da tela inicial foi extraída para o `homeFilteredProductsProvider`, garantindo que a interface gráfica fique livre de processamento de dados.
*   **View (`lib/features`):**
    Composta pelas telas do aplicativo (ex: `HomeScreen`, `LoginScreen`). As Views são construídas utilizando `ConsumerWidget` ou `ConsumerStatefulWidget` e sua única responsabilidade é renderizar a interface de usuário observando os ViewModels e repassar as intenções do usuário (eventos de clique, digitação) de volta aos provedores de estado, sem nunca instanciar diretamente os serviços de API.

---

## 3. Padrões de Projeto Adicionais

Além da arquitetura MVVM, o projeto implementou dois padrões de projeto adicionais fundamentais para a estabilidade da aplicação:

### 3.1 Singleton (`ApiService`)
A classe `ApiService` (`lib/core/services/api_service.dart`), responsável por realizar todas as requisições HTTP e injetar o token de autorização, foi implementada sob o padrão **Singleton**. Através de um construtor `factory`, garantimos que uma **única instância do cliente HTTP** seja compartilhada por todo o ciclo de vida do aplicativo. Isso evita o desperdício de memória criando múltiplos clientes para diferentes endpoints e centraliza a configuração da URL base e tratamento de sessão.

### 3.2 Facade (`CatalogApiService`)
A classe `CatalogApiService` (`lib/data/services/catalog_api_service.dart`) implementa o padrão **Facade**. O backend do sistema é distribuído em microsserviços com dezenas de endpoints distintos (produtos, cantinas, adicionais, ingredientes). A classe age como uma fachada unificada que simplifica a complexidade desse ecossistema para as ViewModels. O método `fetchProductDetail()`, por exemplo, realiza chamadas a quatro endpoints diferentes nos bastidores e consolida todas as informações em uma única classe `ProductDetailData`, ocultando essa complexidade das camadas superiores.

---

## 4. Integração com API Remota

O aplicativo se comunica com um backend real baseado em microsserviços (construído em NestJS) rodando sob uma API Gateway central.

**Principais fluxos de integração:**
*   **Autenticação (`/auth/login`):** O usuário envia as credenciais, o backend retorna um token JWT que é interceptado pela aplicação e injetado nos headers (`Authorization: Bearer <token>`) em todas as chamadas futuras.
*   **Catálogo:** Utiliza o método HTTP GET para consultar cantinas (`/canteens`), categorias (`/categories`) e produtos (`/products`).
*   **Pedidos (`/orders` e `/cart`):** Fluxos baseados em POST (adicionar item, fechar pedido) e PATCH (cancelar, retirar, avaliar pedido).

**Tratamento de Estados e Erros:**
As Views respondem a três estados distintos gerenciados pelo Riverpod (`AsyncValue`):
1.  **Loading:** Exibição de `CircularProgressIndicator` ou skeletons durante a comunicação com a API.
2.  **Data:** Renderização do componente visual (ex: lista de cantinas).
3.  **Error:** O cliente HTTP captura as falhas (status >= 300) ou falhas de conexão, lança uma `Exception`, e a View exibe ao usuário uma `SnackBar` com a mensagem original de erro enviada pelo servidor, garantindo transparência no fluxo.

---

## 5. Armazenamento Local e Persistência

Para garantir que a sessão do usuário e suas escolhas não sejam perdidas ao fechar o aplicativo, foi implementada a persistência local de dados utilizando o pacote `shared_preferences`.

**Dados Persistidos:**
1.  **Token JWT (`api_token`):** Essencial para manter o usuário autenticado. É verificado automaticamente ao iniciar o app.
2.  **Sessão do Usuário (`saved_user`):** O modelo `UserModel` é serializado para JSON (`toJson()`) e gravado no armazenamento local. Ao reabrir o app na tela de *Splash*, a função `tryRestoreSession()` do `AuthNotifier` é acionada. Se o usuário estiver salvo, o aplicativo pula o onboarding e a tela de login, navegando diretamente para a `HomeScreen`.
3.  **Carrinho de Compras (`saved_cart`):** A classe `CartNotifier` implementa a auto-persistência. A cada vez que um item é adicionado, atualizado ou removido do carrinho de compras, a lista completa de produtos (e seus adicionais selecionados) é serializada e gravada localmente. Quando o Provider do carrinho é inicializado na abertura do app, ele carrega essa string JSON da memória e restaura exatamente os itens em que o usuário estava trabalhando.

**Justificativa:** O uso do `shared_preferences` atende perfeitamente à necessidade de armazenar chave-valor simples (como strings de tokens e pequenos payloads JSON). Ele é rápido e assíncrono, ideal para checagens de sessão instantâneas durante a inicialização do app.

---

## 6. Conclusão

O desenvolvimento do Ligeirinho Food cumpriu com todos os requisitos estipulados para a aprovação. A aplicação final é robusta e bem segmentada através da arquitetura **MVVM**, o que permitiu um fluxo de trabalho onde a lógica de manipulação de dados nunca se misturou à construção visual das telas.

**Decisões e Limitações:** Optou-se por focar exclusivamente nas funcionalidades de "Cliente" no aplicativo móvel, enquanto a lógica administrativa ("Vendedor") foi movida para uma aplicação web, dada a complexidade natural de gestão de cardápios. Uma limitação do modelo atual de comunicação assíncrona é a necessidade de requisições contínuas de polling para verificação do status do pedido.

**Melhorias Futuras:** Como próximos passos, planeja-se a substituição do polling de pedidos por WebSockets ou Server-Sent Events (SSE), que permitirão que a API empurre (push) atualizações de status em tempo real com menor consumo de bateria e rede, além de adicionar testes unitários completos nas ViewModels.
