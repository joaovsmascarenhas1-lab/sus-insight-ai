# SUS — Challenge 2026 (FIAP & Oracle)

> **Grupo:** converSUS
> **Turma:** 1TSCO  
> **Integrante:** João Vítor Santos Mascarenhas 
> **Parceiros:** FIAP & Oracle Corporation  

---

## Sobre o Projeto

O **SUS-Insight AI** é uma solução de Inteligência Artificial Generativa desenvolvida para democratizar o acesso às informações de saúde pública do SUS.

Através da funcionalidade **Oracle Select AI** no **Oracle Autonomous Database**, os gestores públicos e auditores podem realizar perguntas estratégicas em **linguagem natural** (ex: *"Qual a taxa de ocupação de leitos por regional em SP?"*), recebendo código SQL automático, tabelas e gráficos interativos em tempo real.

---

## Tecnologias Utilizadas

- **Frontend:** Streamlit, Plotly
- **Banco de Dados:** Oracle Autonomous Database (23ai / 26ai)
- **Motor de IA:** Oracle Select AI + OCI Generative AI
- **Pipeline ETL:** Python (Pandas, NumPy)

---

## Como Executar

1. Instale as dependências:
   pip install -r requirements.txt