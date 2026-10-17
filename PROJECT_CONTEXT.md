# Contexto do Projeto: AposentaFácil PRO

## 1. Visão Geral e Proposta de Valor
O **AposentaFácil PRO** é uma aplicação web moderna e responsiva voltada para a educação e planejamento financeiro pessoal, especificamente focada no movimento **FIRE (Financial Independence, Retire Early)** e no cálculo atuarial de independência financeira.

A principal missão da aplicação é responder de forma visual, interativa e matematicamente precisa à pergunta:  
> *"Quanto preciso investir mensalmente a partir de hoje para atingir a independência financeira e viver exclusivamente do rendimento dos meus investimentos?"*

---

## 2. Conceito e Regra de Negócio (Matemática Financeira)

O cálculo baseia-se na metodologia de **Renda Perpétua com Taxa Real de Retirada Segura (Safe Withdrawal Rate)**:

### 2.1. Patrimônio Alvo ($P_{alvo}$)
Para que o usuário viva apenas dos rendimentos sem nunca consumir o montante principal:
$$P_{alvo} = \frac{\text{Renda Mensal Desejada}}{\text{Taxa de Rendimento Real Mensal}}$$
*Exemplo: R$ 12.000,00 / 0,006 (0,6% a.m.) = R$ 2.000.000,00 de patrimônio alvo.*

### 2.2. Prazo de Acumulação ($n$)
Calculado com base na idade atual e na idade em que deseja se aposentar:
$$n = (\text{Idade Alvo} - \text{Idade Atual}) \times 12 \text{ meses}$$

### 2.3. Valor Futuro do Patrimônio Inicial Já Existente ($FV_{inicial}$)
Caso o usuário já possua investimentos:
$$FV_{inicial} = P_{inicial} \times (1 + i)^n$$

### 2.4. Aporte Mensal Necessário ($PMT$)
Considerando o efeito dos juros compostos:
$$PMT = \frac{(P_{alvo} - FV_{inicial}) \times i}{(1 + i)^n - 1}$$

### 2.5. Efeito Bola de Neve (Ponto de Inflexão)
A simulação calcula ano a ano o ponto exato no tempo em que os **rendimentos mensais gerados pelo patrimônio acumulado superam o valor do aporte mensal do próprio bolso**. A partir desse momento, os juros passam a trabalhar mais rápido do que a capacidade de poupança direta.

---

## 3. Fluxo de Engenharia e Tecnologias Utilizadas

O projeto foi construído para demonstrar um **ciclo de vida de software moderno e profissional**:

1. **Prototipagem Assistida por IA com Stitch (Google)**:
   - As telas e o design system foram inicialmente prototipados no **Google Stitch** (`stitch.withgoogle.com`).
   - A extração dos design tokens, paleta de cores e hierarquia de componentes foi realizada diretamente via **MCP (Model Context Protocol)** com o pacote `@_davideast/stitch-mcp`.

2. **Frontend & Apresentação**:
   - **Framework**: Flutter Web (Canal Estável 3.47.7, Dart 3.13.5).
   - **Estilo Visual**: Tema **Obsidian Dark** (estilo fintech moderno, tons de Zinc `#09090b` a `#18181b`, acentos em Violeta `#a78bfa` e Verde Esmeralda `#34d399`).
   - **Tipografia**: Google Fonts Inter, números em monospace tabular para dados financeiros.
   - **Visualizações de Dados**:
     - *Barra de Proporção*: Decomposição visual entre valor que saiu do bolso vs. juros gerados pelo tempo.
     - *Gráfico de Evolução*: Renderizado via `CustomPainter` vetorial com interpolação de curvas cúbicas de Bézier, preenchimento com gradiente de transparência e marcação do ponto de inflexão.

3. **Arquitetura de Código (Clean Separation)**:
   - `lib/models/financial_plan.dart`: Contratos imutáveis de entrada (`FinancialInput`) e saída (`FinancialResult`).
   - `lib/services/financial_calculator.dart`: Lógica pura de cálculo desacoplada da UI (100% testável).
   - `lib/theme/app_theme.dart`: Constantes de cores e ThemeData padronizados.
   - `lib/widgets/`: Componentes focados e reutilizáveis (`CompoundBreakdownBar`, `WealthEvolutionChart`).
   - `lib/main.dart`: Layout principal responsivo (Split View 5:7 no Desktop e fluida no Mobile) com reatividade em tempo real.

4. **Qualidade & DevOps (CI/CD)**:
   - **Testes Unitários**: Testes cobrindo metas, patrimônio inicial e curva de projeção (`test/financial_calculator_test.dart`).
   - **Testes de Integração**: Testes de fumaça e layout responsivo (`test/widget_test.dart`).
   - **Pipeline GitHub Actions** (`.github/workflows/deploy.yml`):
     - Executa análise estática (`flutter analyze`).
     - Executa todos os testes unitários (`flutter test`).
     - Realiza o build de produção web (`flutter build web --release`).
     - Faz o deploy contínuo e automático no **GitHub Pages**.

---

## 4. Repositório e Branches
- **Repositório GitHub**: `rodrigo-gh/pos-ci-cd-aposenta-facil`
- **Branch principal**: `main`
