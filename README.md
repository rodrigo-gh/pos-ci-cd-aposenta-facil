# 📈 AposentaFácil PRO - Planejador de Independência Financeira & FIRE

Aplicação web desenvolvida em **Flutter Web** para cálculo atuarial de independência financeira, simulação de aportes com juros compostos e visualização exponencial de patrimônio.

O projeto foi prototipado no **Google Stitch**, conectado via **Model Context Protocol (MCP)** e implementado com esteira completa de **CI/CD no GitHub Actions**.

---

## 🎯 Objetivo e Escopo do Projeto

O **AposentaFácil** responde a uma pergunta fundamental: *"Quanto preciso investir por mês para atingir a minha aposentadoria dos sonhos e viver exclusivamente de rendimentos?"*

### Modelo Financeiro (Safe Withdrawal Rate / Renda Perpétua)
- **Patrimônio Alvo Necessário ($P_{alvo}$)**:
  $$P_{alvo} = \frac{\text{Renda Mensal Desejada}}{\text{Taxa Real Mensal}}$$
- **Prazo ($n$)**: $(\text{Idade Aposentadoria} - \text{Idade Atual}) \times 12 \text{ meses}$.
- **Valor Futuro do Patrimônio Inicial**:
  $$FV_{inicial} = P_{inicial} \times (1 + i)^n$$
- **Aporte Mensal Necessário ($PMT$)**:
  $$PMT = \frac{(P_{alvo} - FV_{inicial}) \times i}{(1 + i)^n - 1}$$

---

## 🚀 Tecnologias e Arquitetura

- **Frontend**: Flutter Web (Canal Estável 3.47.7, Dart 3.13.5)
- **Design System**: Tema Obsidian Dark (Design Tokens do Stitch, Google Fonts Inter, Paleta Zinc/Violet/Emerald)
- **Gráficos**: Custom Canvas Vector Painter com interpolação Bézier e marcadores de inflexão
- **Testes Automatizados**: Suíte unitária cobrindo cenários matemáticos (`test/financial_calculator_test.dart`) e de interface (`test/widget_test.dart`)
- **Prototipagem & MCP**: Google Stitch conectado via `@_davideast/stitch-mcp`
- **CI/CD**: GitHub Actions com lint, testes, build web e deploy contínuo no **GitHub Pages**

---

## 📁 Estrutura de Arquivos

```text
aposenta_facil/
├── .github/workflows/
│   └── deploy.yml              # Pipeline de CI/CD (Testes + Build + Deploy)
├── lib/
│   ├── models/
│   │   └── financial_plan.dart  # Modelos de dados e contratos
│   ├── services/
│   │   └── financial_calculator.dart # Motor matemático de cálculo financeiro
│   ├── theme/
│   │   └── app_theme.dart       # Tokens do tema Obsidian Dark extraídos do Stitch
│   ├── widgets/
│   │   ├── breakdown_bar.dart   # Barra de proporção (Bolso vs Juros)
│   │   └── wealth_chart.dart    # Gráfico vetorial da curva de riqueza
│   └── main.dart                # Interface responsiva principal
├── test/
│   ├── financial_calculator_test.dart # Testes unitários da lógica financeira
│   └── widget_test.dart         # Testes de integração de interface
└── web/
    └── index.html               # Configuração web, SEO e tema escuro nativo
```

---

## 🛠️ Como Executar Localmente

### Pré-requisitos
- Flutter SDK 3.x instalado e adicionado ao PATH.
- Google Chrome ou Microsoft Edge.

### Comandos:

```bash
# 1. Instalar as dependências
flutter pub get

# 2. Rodar a suíte de testes
flutter test

# 3. Executar no navegador (Flutter Web)
flutter run -d chrome
# ou
flutter run -d edge
```

---

## 🔄 Pipeline de CI/CD (GitHub Actions)

A esteira de integração e entrega contínua está definida em `.github/workflows/deploy.yml`:

1. **Trigger**: Disparado a cada `push` ou `pull_request` na branch `main`.
2. **Quality Gate**:
   - `flutter analyze`: Análise estática do código Dart (zero warnings).
   - `flutter test`: Validação de 100% dos testes unitários e de widget.
3. **Build**:
   - `flutter build web --release`: Compilação dos assets otimizados para produção.
4. **Deploy**:
   - Deploy automatizado e sem downtime no **GitHub Pages**.

---

## 🎓 Apresentação na Faculdade

### Roteiro sugerido para a aula:
1. **Problema**: Desafio de planejamento previdenciário e cálculo atuarial acessível.
2. **Prototipagem com IA**: Utilização do **Google Stitch** com integração de agente via **MCP** para extração direta de design tokens e layout.
3. **Desenvolvimento Moderno**: Implementação em Flutter Web responsivo com tipagem estrita e separação entre modelo, serviço e apresentação.
4. **Qualidade & DevOps**: Apresentação dos testes unitários passando (`flutter test`) e pipeline automatizado com GitHub Actions.
