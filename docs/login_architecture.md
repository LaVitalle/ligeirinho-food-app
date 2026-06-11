Cliente HTTP & token: ApiService implementa POST/GET básicos, salva/recupera api_token em SharedPreferences (chave api_token) e inclui Authorization: Bearer <token> automaticamente nas requisições.
Autenticação: AuthService.login(email,password) envia POST /auth/login com JSON { email, password }, trata a resposta envolta (forma { data: { accessToken, user }, status: { ... } }), salva accessToken via ApiService.setToken e converte user do backend para UserModel.
Tela de login: LoginScreen agora chama AuthService.login assincronamente, mostra um indicador de carregamento no botão, exibe SnackBar com erros do servidor quando houver, atualiza o authProvider com o UserModel retornado e navega para home (cliente) ou /vendor/orders (vendedor).
Mapeamento de papéis: AuthService faz mapping simples do role do backend: CUSTOMER → UserRole.client, SELLER/VENDOR → UserRole.vendor. Campos opcionais do backend (por ex. profilePhotoUrl, institutionId) são usados quando disponíveis.
Detalhes técnicos

Endpoint esperado: POST /auth/login do backend Ligeirinho (responde com AuthResponseDto contendo accessToken e user).
Formato de resposta tratado: envelope { data: { accessToken, user }, status: { code, message } }.
Token persistido em SharedPreferences para uso em chamadas subsequentes.
Base URL padrão: http://10.0.2.2:4000 (ideal para Android emulator). Para alterar, passe --dart-define=API_BASE_URL=<url> ao rodar ou modifique ApiService construtor.
Como testar localmente

Atualizar dependências:
flutter pub get
Rodar no emulador Android (usa 10.0.2.2 por padrão):
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
Teste manual:
Na tela de login, informe email e senha válidos cadastrados no backend.
Observe navegação correta e ausência de erro (ou mensagem do servidor via SnackBar).