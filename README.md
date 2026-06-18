# 🍔 Ligeirinho Food

Aplicativo mobile de delivery de alimentos para instituições de ensino, desenvolvido em **Flutter** como parte do **Projeto Integrador do 5º semestre**. O app permite que alunos naveguem pelas cantinas da sua instituição, montem pedidos personalizados com adicionais e ingredientes removíveis, e acompanhem o status de cada pedido em tempo real.

## 📸 Funcionalidades

- **Autenticação completa** — cadastro, login, recuperação de senha com verificação por código
- **Catálogo por instituição** — listagem de cantinas, categorias e produtos em destaque
- **Detalhe de produto** — adicionais opcionais, remoção de ingredientes, seleção de quantidade
- **Carrinho multi-cantina** — suporte a itens de diferentes cantinas no mesmo pedido
- **Checkout** — seleção de horário de retirada e forma de pagamento (PIX / Cartão)
- **Acompanhamento de pedidos** — status em tempo real (Aguardando → Em Preparo → Pronto)
- **Avaliação** — nota de 1 a 5 estrelas com comentário opcional após finalização
- **Perfil** — edição de nome e telefone, logout

## 🏗️ Arquitetura — MVVM

O projeto segue o padrão **MVVM (Model – View – ViewModel)** com a seguinte divisão de responsabilidades:

```
lib/
├── core/                          # Infraestrutura compartilhada
│   ├── routes/app_router.dart     # Rotas (go_router)
│   ├── services/api_service.dart  # Cliente HTTP centralizado
│   ├── theme/app_theme.dart       # Design tokens e ThemeData
│   └── widgets/                   # Widgets reutilizáveis (ProductCard, AppButton, etc.)
│
├── data/
│   ├── models/                    # 🟢 MODEL — classes imutáveis com fromJson/copyWith
│   ├── services/                  # Serviços de acesso à API (CatalogApiService, etc.)
│   └── providers/                 # 🟠 VIEWMODEL — Riverpod providers com lógica de estado
│
├── features/
│   ├── auth/                      # 🔵 VIEW + ViewModel de autenticação
│   ├── client/                    # 🔵 VIEW — telas do cliente (home, stores, cart, orders...)
│   ├── onboarding/                # 🔵 VIEW — onboarding inicial
│   └── vendor/                    # Módulo do vendedor (desabilitado no mobile)
│
└── main.dart                      # Entry point com ProviderScope
```

| Camada | Responsabilidade | Exemplos |
|--------|-----------------|----------|
| **Model** | Representação de dados, serialização JSON, regras de domínio | `ProductModel`, `UserModel`, `CartItem`, `StoreModel`, `OrderModel` |
| **ViewModel** | Gerenciamento de estado, orquestração de chamadas à API, lógica de negócio | `AuthNotifier`, `CartNotifier`, `catalogProviders`, `ordersProvider` |
| **View** | Interface do usuário, captura de eventos, exibição de estados | `HomeScreen`, `LoginScreen`, `CheckoutScreen`, `OrdersScreen` |

A separação é garantida pelo **Riverpod**: as Views (`ConsumerWidget` / `ConsumerStatefulWidget`) consomem providers via `ref.watch()` e disparam ações via `ref.read()`, sem acessar serviços diretamente.

## 🎨 Padrão de Projeto Adicional — Facade

Além do MVVM, o projeto implementa o padrão **Facade** através da classe [`CatalogApiService`](lib/data/services/catalog_api_service.dart).

**Por que foi escolhido:** o backend possui uma arquitetura de microsserviços com múltiplos endpoints distribuídos (categorias, cantinas, produtos, adicionais, ingredientes removíveis). O `CatalogApiService` atua como uma **fachada** que simplifica esse acesso para o restante do app, expondo métodos de alto nível como `fetchProductDetail()` que internamente orquestra chamadas a 4 endpoints diferentes:

```dart
// Exemplo do Facade em ação — CatalogApiService.fetchProductDetail()
// Encapsula 4 chamadas separadas em uma única interface simples:
Future<ProductDetailData?> fetchProductDetail(String productId) async {
  final product    = await _getData('/products/$productId');       // 1. Produto
  final store      = await fetchCanteenById(product.storeId);     // 2. Cantina
  final extras     = await fetchExtrasByProduct(productId);       // 3. Adicionais
  final removable  = await fetchRemovableIngredients(productId);  // 4. Ingredientes

  return ProductDetailData(product: ..., store: store, additionals: extras, ...);
}
```

**Onde foi aplicado:** em [`lib/data/services/catalog_api_service.dart`](lib/data/services/catalog_api_service.dart) — todas as ViewModels e Views acessam o catálogo exclusivamente através desta fachada, sem precisar conhecer a estrutura de endpoints do backend.

## 🌐 API Utilizada

O app consome uma **API REST real** hospedada no backend [ligeirinho-food-backend](https://github.com/LaVitalle/ligeirinho-food-backend), construído com **NestJS** em arquitetura de microsserviços:

| Serviço | Porta | Responsabilidade |
|---------|-------|-----------------|
| Gateway | `:4000` | Proxy reverso — entrada única para o app |
| Identity | `:4001` | Autenticação, usuários, instituições |
| Catalog | `:4002` | Cantinas, categorias, produtos, adicionais |
| Orders | `:4003` | Carrinho, pedidos, avaliações, relatórios |

**Principais endpoints consumidos:**

- `POST /auth/login` — autenticação com JWT
- `POST /auth/register` — cadastro de usuário
- `GET /categories` — listagem de categorias
- `GET /canteens` — listagem de cantinas por instituição
- `GET /products/featured` — produtos em destaque
- `GET /products/:id` — detalhe do produto
- `POST /cart/items` — adicionar item ao carrinho
- `POST /orders` — criar pedido
- `GET /orders/me` — listar pedidos do cliente
- `PATCH /orders/:id/pickup` — confirmar retirada
- `PATCH /orders/:id/rating` — avaliar pedido

**Tratamento de estados:**

| Estado | Implementação |
|--------|---------------|
| ⏳ Carregamento | `CircularProgressIndicator` via `.when(loading:)` do Riverpod |
| ✅ Sucesso | Dados renderizados na UI via `.when(data:)` |
| ❌ Erro | `SnackBar` com mensagem extraída do corpo de resposta do servidor (`status.message`) |

## 💾 Armazenamento Local

O projeto utiliza o pacote [`shared_preferences`](https://pub.dev/packages/shared_preferences) para persistência local.

**Dados persistidos:**

| Dado | Chave | Justificativa |
|------|-------|---------------|
| Token JWT | `api_token` | Manter sessão autenticada entre aberturas do app, enviado automaticamente no header `Authorization: Bearer` de todas as requisições |

A persistência do token é gerenciada pela classe [`ApiService`](lib/core/services/api_service.dart), que salva o token ao fazer login e o recupera a cada requisição HTTP subsequente.

## 🚀 Como Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.5.4
- [Docker](https://www.docker.com/) + Docker Compose (para o backend)
- Emulador Android / iOS ou dispositivo físico

### 1. Subir o backend

```bash
cd ligeirinho-food-backend
docker compose up -d --build

# Seed inicial (apenas na primeira vez)
docker compose exec identity npm run db:seed:admin
docker compose exec identity npm run db:seed:location
```

O gateway ficará disponível em `http://localhost:4000`.

### 2. Rodar o app Flutter

```bash
cd ligeirinho-food-app
flutter pub get
flutter run
```

**Para emulador Android** (usa `10.0.2.2` por padrão para acessar o localhost do host):
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

**Para iOS Simulator ou web:**
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

## 🛠️ Tecnologias

| Tecnologia | Uso |
|------------|-----|
| Flutter 3.5+ | Framework mobile |
| Dart | Linguagem |
| Riverpod | Gerenciamento de estado (MVVM) |
| go_router | Navegação declarativa |
| http | Cliente HTTP |
| shared_preferences | Persistência local |
| google_fonts | Tipografia (Inter) |
| intl | Formatação de moeda e datas |
| cached_network_image | Cache de imagens de rede |
| fl_chart | Gráficos (relatórios do vendedor) |
| image_picker | Seleção de fotos de produto |

## 👥 Equipe

Projeto Integrador — 5º Semestre
