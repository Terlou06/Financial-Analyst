<div align="center">
  <img src="assets/logo.png" alt="Financial Analyst Logo" width="250" style="border-radius: 15px; box-shadow: 0 0 20px rgba(0, 122, 204, 0.5);">

# 🚀 Financial Analyst - ES Futures Trading System

**Robust Market Sentiment Analysis with KiloCode AI & PostgreSQL Database**

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![KiloCode AI](https://img.shields.io/badge/AI-KiloCode%20%7C%20x--ai-FF6600?style=for-the-badge)](https://x.ai/)
[![License: ISC](https://img.shields.io/badge/License-ISC-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/ISC)

  <p align="center">
    <a href="#-quick-start">Quick Start</a> •
    <a href="#-features">Features</a> •
    <a href="#-installation">Installation</a> •
    <a href="#-usage">Usage</a> •
    <a href="#-architecture">Architecture</a> •
    <a href="#documentation">Documentation</a>
  </p>
</div>

---

## 🎯 Quick Start

### Prerequisites

- **Node.js** 18+
- **PostgreSQL** 13+
- **KiloCode AI** (x-ai/grok-code-fast-1)

### One-Command Setup

```bash
# Clone & Install
git clone <repo-url>
cd financial-analyst
npm install

# Configure Database
cp .env.example .env
# Edit .env with your PostgreSQL credentials:
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=postgres
# DB_PASSWORD=your_password
# DB_NAME=financial_analyst

# Initialize Database
npx ts-node create_database.ts

# Run First Analysis
npm run analyze
```

---

## 🚀 Features

### ✅ **Core Capabilities**

- **🤖 KiloCode AI Integration** - Advanced sentiment analysis using x-ai models
- **📊 Database-Driven Analysis** - 22+ news items from PostgreSQL database
- **🚫 No Fallback Policy** - Returns "N/A" when analysis fails (no simulated data)
- **⚡ Real-Time Processing** - 3-5 second analysis time with cached data
- **📈 ES Futures Focus** - Optimized for S&P 500 futures sentiment analysis

### 🎛️ **Operating Modes**

- **Single Analysis** - One-time sentiment analysis
- **Continuous Monitoring** - Automated analysis every 5 minutes
- **Database Status** - View cache status and news statistics

### 1. Clone Repository

```bash
git clone https://github.com/Terlou06/Financial-Analyst.git
cd financial-analyst
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Database Setup

```bash
# Create .env file
cp .env.example .env

# Edit .env with your PostgreSQL settings:
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=9022
DB_NAME=financial_analyst

# Create database
npx ts-node create_database.ts
```

### 4. Verify Installation

```bash
# Test database connection
npm run status

# Run first analysis
npm run analyze
```

---

## 🎮 Usage

### Main Application (run.ts)

The primary entry point with multiple operating modes:

```bash
# Single sentiment analysis
npm run analyze
# or
npx ts-node run.ts --analyze

# Continuous monitoring (5-min intervals)
npm run continuous
# or
npx ts-node run.ts --continuous

# Database status
npm run status
# or
npx ts-node run.ts --status

# Help
npx ts-node run.ts --help
```

### Package.json Scripts

```json
{
  "scripts": {
    "analyze": "npx ts-node run.ts --analyze",
    "continuous": "npx ts-node run.ts --continuous",
    "status": "npx ts-node run.ts --status",
    "dev": "npx ts-node run.ts --analyze",
    "db:init": "npx ts-node create_database.ts"
  }
}
```

### Example Output

```
🚀 Initializing Financial Analyst Application...
============================================================
✅ Database connection successful

📊 Database Status:
   ├─ News items: 22
   ├─ Cache: FRESH
   └─ Time range: Last 48 hours

🔍 Starting Market Sentiment Analysis...
============================================================
✅ ANALYSIS COMPLETED SUCCESSFULLY!

📈 MARKET SENTIMENT RESULT:
{
  "sentiment": "BEARISH",
  "score": -45,
  "risk_level": "HIGH",
  "catalysts": [
    "Bitcoin slide threatening $80,000 break",
    "AI CapEx masking economic weakness",
    "Geopolitical tensions and regulatory pressures"
  ],
  "summary": "Mixed headlines with strong bearish signals...",
  "data_source": "database_cache",
  "news_count": 22,
  "analysis_method": "robust_kilocode_v2"
}

🎯 KEY INSIGHTS:
   Sentiment: BEARISH (-45/100)
   Risk Level: HIGH
   Catalysts: Bitcoin slide threatening $80,000 break, AI CapEx masking economic weakness...
   Summary: Mixed headlines with strong bearish signals from Bitcoin declines...
   News Count: 22 items
   Data Source: database_cache
   Analysis Method: robust_kilocode_v2
```

---

## 🏗 Architecture

### 🤖 SentimentAgentFinal (Core Agent)

```
SentimentAgentFinal
├── Database-Only Mode
│   ├── Extracts news from PostgreSQL (48h window)
│   ├── Uses TOON format for KiloCode processing
│   └── No web scraping - pure database analysis
├── KiloCode Integration
│   ├── Sends structured prompt with 22+ news items
│   ├── Returns JSON with sentiment/score/catalysts
│   └── No fallbacks - returns N/A on failure
└── Database Buffer
    ├── Creates database.md file for inspection
    ├── Maintains transparency of AI input
    └── Preserves analysis workflow
```

### 💾 Database Schema

#### **Core Tables Structure**

```sql
-- 📰 news_items (Articles financiers)
├── id UUID PRIMARY KEY
├── title VARCHAR(500)              -- Titre de l'article
├── source VARCHAR(50)              -- Source (ZeroHedge, CNBC, etc.)
├── url TEXT                       -- URL de l'article
├── content TEXT                    -- Contenu optionnel
├── sentiment VARCHAR(20)           -- Sentiment optionnel
├── created_at TIMESTAMP           -- Date de création
└── updated_at TIMESTAMP           -- Date de mise à jour

-- 📊 sentiment_analyses (Analyses de sentiment)
├── id UUID PRIMARY KEY
├── analysis_date DATE              -- Date de l'analyse
├── overall_sentiment VARCHAR(20)   -- bullish/bearish/neutral
├── score INTEGER                   -- Score -100 à +100
├── risk_level VARCHAR(20)          -- low/medium/high
├── confidence_score FLOAT          -- Score de confiance 0-1
├── catalysts JSONB                 -- Array des catalystes principaux
├── summary TEXT                    -- Résumé de l'analyse
├── news_count INTEGER              -- Nombre d'articles analysés
├── metadata JSONB                  -- Métadonnées additionnelles
├── is_validated BOOLEAN DEFAULT FALSE
└── created_at TIMESTAMP           -- Date de création

-- 📡 news_sources (Configuration des sources)
├── id UUID PRIMARY KEY
├── name VARCHAR(100)               -- Nom de la source
├── url VARCHAR(500)                -- URL de la source
├── type VARCHAR(50)                -- RSS/WEB/API
├── is_active BOOLEAN DEFAULT TRUE  -- Source activée?
├── last_fetch TIMESTAMP            -- Dernière récupération
├── success_rate FLOAT              -- Taux de succès
├── error_count INTEGER DEFAULT 0   -- Compteur d'erreurs
└── created_at TIMESTAMP

-- 🔍 scraping_sessions (Sessions de collecte)
├── id UUID PRIMARY KEY
├── session_start TIMESTAMP         -- Début de session
├── session_end TIMESTAMP           -- Fin de session
├── articles_found INTEGER          -- Articles trouvés
├── articles_saved INTEGER          -- Articles sauvegardés
├── success BOOLEAN                 -- Succès de la session
├── error_message TEXT              -- Message d'erreur
└── created_at TIMESTAMP

-- Tables additionnelles (optimisation)
├── daily_news_summary              -- Résumés quotidiens
├── latest_news                     -- Cache des dernières news
├── recent_sentiment_analyses       -- Cache des analyses récentes
└── source_performance              -- Stats de performance par source
```

#### **Database Connection**

See `.env.example` for configuration details.

#### **Key Features**

- ✅ **22+ articles financiers** analysés en temps réel
- ✅ **Cache intelligent** de 2 heures (TTL configurable)
- ✅ **Nettoyage automatique** (>30 jours pour les anciennes données)
- ✅ **Indexes optimisés** pour les requêtes fréquentes
- ✅ **Monitoring santé** des sources de news
- ✅ **JSONB columns** pour données flexibles (catalysts, metadata)
- ✅ **Historique complet** des analyses de sentiment
- ✅ **Performance tracking** par source

#### **pgAdmin 4 Quick Access**

📄 **Documentation complète**: [doc/commandes_pg_sql.md](doc/commandes_pg_sql.md)

Requête complète pour pgAdmin 4 disponible dans `/doc/commandes_pg_sql.md`

### 🔄 Processing Pipeline

```
PostgreSQL Database (48h news)
        ↓
SentimentAgentFinal (TOON format)
        ↓
KiloCode AI Analysis
        ↓
Structured JSON Result
        ↓
Database Storage + Display
```

---

## 📊 Sentiment Analysis Format

### JSON Output Structure

```json
{
  "sentiment": "BEARISH", // BULLISH | BEARISH | NEUTRAL
  "score": -45, // -100 to +100
  "risk_level": "HIGH", // LOW | MEDIUM | HIGH
  "catalysts": [
    // Key market drivers
    "Bitcoin slide threatening $80,000 break",
    "AI CapEx masking economic weakness",
    "Geopolitical tensions and regulatory pressures"
  ],
  "summary": "Market sentiment analysis summary...",
  "data_source": "database_cache", // Source of analysis data
  "news_count": 22, // Number of news items analyzed
  "analysis_method": "robust_kilocode_v2" // Processing method
}
```

### Error Handling

- **N/A Response** - When KiloCode fails, returns structured N/A result
- **Database Fallback** - Continues without database if connection fails
- **Timeout Protection** - 60-second timeout prevents hanging
- **Graceful Degradation** - Always provides a response, never crashes

---

## 📚 Documentation

### Core Files

- **`run.ts`** - Main application entry point with CLI interface
- **`SentimentAgentFinal.ts`** - Robust sentiment analysis agent
- **`NewsDatabaseService.ts`** - Database operations and caching
- **`schema_simplified.sql`** - PostgreSQL schema definition

### Configuration

- **`.env`** - Database connection settings
- **`package.json`** - Dependencies and npm scripts
- **`database.md`** - Generated buffer file for AI input inspection

### Test Scripts

- **`test_final_sentiment.ts`** - Agent functionality testing
- **`test_database_connection.ts`** - Database connectivity tests
- **`fix_database.ts`** - Database repair utilities

---

## 🛠 Development

### Environment Setup

```bash
# Development mode
npm run dev

# TypeScript compilation
npm run build

# Run tests
npm test
```

### Adding New Features

1. **Create new agent** extending `BaseAgentSimple`
2. **Update database schema** in `schema_simplified.sql`
3. **Add npm script** to `package.json`
4. **Update CLI interface** in `run.ts`

### Monitoring & Debugging

```bash
# Database statistics
npm run status

# View database buffer (created during analysis)
cat database.md

# Check database logs
# PostgreSQL logs contain detailed operation information
```

---

## 🔧 Troubleshooting

### Common Issues

**Database Connection Failed**

```bash
# Check PostgreSQL is running
pg_isready -h localhost -p 5432

# Verify credentials in .env
# Test connection manually
psql -h localhost -U postgres -d financial_analyst
```

**KiloCode Analysis Failed**

```bash
# Check KiloCode installation
kilocode --version

# Test KiloCode directly
echo "Analyze market sentiment" | kilocode -m ask --auto --json
```

**No News in Database**

```bash
# Run news ingestion first
npx ts-node src/backend/ingestion/NewsAggregator.ts

# Check database status
npm run status
```

### Error Messages Explained

- **"Analysis not available: Database not available"** - Database connection failed
- **"KiloCode analysis failed"** - AI service unavailable or error
- **"No news data available in database"** - Empty database, run ingestion first

---

- [ ] **Advanced Caching** - Redis integration for performance

---

## 📄 License

This project is licensed under the **ISC License** - see [LICENSE](LICENSE) for details.

---

<div align="center">

**🚀 Production-Ready Financial Sentiment Analysis System**

_Built with ❤️ using TypeScript, PostgreSQL, and KiloCode AI_

[⭐ Star This Repo] • [🐛 Report Issues] • [📖 Documentation] • [🤝 Contributing]

</div>
